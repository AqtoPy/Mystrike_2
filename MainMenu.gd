extends Control

@onready var name_input: LineEdit = $%NameInput
@onready var vip_button: Button = $%VIPButton
@onready var key_input: LineEdit = $%KeyInput
@onready var status_label: Label = $%StatusLabel
@onready var coins_label: Label = $%CoinsLabel

func _ready():
    PlayerData.load_data()
    update_ui()

func update_ui():
    # Обновление имени
    name_input.text = PlayerData.data.name
    
    # Обновление VIP статуса
    var vip_status = "Активен до: %s" % format_date(PlayerData.data.vip_expire) if PlayerData.is_vip_active() else "Не активен"
    vip_button.text = "Купить VIP (500 coins)\n%s" % vip_status
    
    # Обновление валюты
    coins_label.text = "Coins: %d" % PlayerData.data.currency
    
    # Статус разработчика
    if PlayerData.data.dev:
        status_label.text = "Режим разработчика активирован!"
        status_label.add_theme_color_override("font_color", Color.GREEN_YELLOW)

func format_date(timestamp: int) -> String:
    var date: Dictionary = Time.get_datetime_dict_from_unix_time(timestamp)
    return "%02d.%02d.%d" % [date.day, date.month, date.year]

func _on_name_input_text_submitted(new_text: String):
    var clean_name = new_text.strip_edges()
    if clean_name.length() > 0:
        PlayerData.data.name = clean_name
        PlayerData.save_data()
        update_ui()

func _on_vip_button_pressed():
    if PlayerData.data.currency >= 500 and not PlayerData.is_vip_active():
        PlayerData.data.currency -= 500
        PlayerData.data.vip = true
        PlayerData.data.vip_expire = Time.get_unix_time_from_system() + 30*24*60*60  # 30 дней
        PlayerData.save_data()
        update_ui()
    else:
        status_label.text = "Недостаточно средств или VIP уже активен!"
        status_label.add_theme_color_override("font_color", Color.RED)

func _on_key_input_text_submitted(new_text: String):
    if PlayerData.verify_dev_key(new_text.strip_edges()):
        status_label.text = "Доступ разработчика получен!"
        status_label.add_theme_color_override("font_color", Color.GREEN)
        await get_tree().create_timer(1.5).timeout
        get_tree().change_scene_to_file("res://dev_room.tscn")
    else:
        status_label.text = "Неверный ключ доступа!"
        status_label.add_theme_color_override("font_color", Color.RED)

func _on_start_button_pressed():
    get_tree().change_scene_to_file("res://main_game.tscn")
