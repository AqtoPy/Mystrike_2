extends Control

# Элементы UI
@onready var server_name_input: LineEdit = $%ServerNameInput
@onready var mode_option: OptionButton = $%ModeOption
@onready var max_players_spinbox: SpinBox = $%MaxPlayersSpinBox
@onready var status_label: Label = $%StatusLabel

func _ready():
    # Загружаем режимы при старте сцены
    reload_game_modes()
    setup_ui()

func setup_ui():
    # Настройка элементов управления
    max_players_spinbox.value = 8
    max_players_spinbox.min_value = 2
    max_players_spinbox.max_value = 16
    server_name_input.placeholder_text = "Введите название сервера"
    update_mode_list()

func update_mode_list():
    mode_option.clear()
    # Добавляем режимы из ServerManager с иконкой кастомных
    for mode in ServerManager.game_modes:
        var text = mode["name"]
        if mode.get("custom", false):
            text += " [MOD]"
        mode_option.add_item(text)

func reload_game_modes():
    # Перезагружаем режимы из менеджера
    ServerManager.load_all_modes()
    update_mode_list()

func validate_input() -> bool:
    # Проверка корректности введенных данных
    if server_name_input.text.strip_edges().length() < 3:
        status_label.text = "Ошибка: Слишком короткое название сервера!"
        return false
        
    if mode_option.selected == -1:
        status_label.text = "Ошибка: Выберите режим игры!"
        return false
        
    return true

func get_selected_mode() -> Dictionary:
    # Получаем данные выбранного режима
    return ServerManager.game_modes[mode_option.selected]

func _on_create_button_pressed():
    if not validate_input():
        return
    
    var selected_mode = get_selected_mode()
    
    # Собираем конфигурацию сервера
    var server_config = {
        "name": server_name_input.text.strip_edges(),
        "mode": selected_mode["id"],
        "mode_data": selected_mode,
        "max_players": int(max_players_spinbox.value),
        "players": [],
        "status": "waiting"
    }
    
    # Создание сети
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(4242)
    if error != OK:
        status_label.text = "Ошибка создания сервера: %d" % error
        return
    
    # Настройка мультиплеера
    multiplayer.multiplayer_peer = peer
    multiplayer.peer_connected.connect(_on_player_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)
    
    # Регистрация сервера
    ServerManager.register_server(server_config)
    
    # Переход в лобби
    get_tree().change_scene_to_file("res://scenes/server_lobby.tscn")

func _on_player_connected(id: int):
    # Обработка подключения игрока
    var player_name = "Player%d" % id
    ServerManager.add_player_to_server(multiplayer.get_unique_id(), player_name)

func _on_player_disconnected(id: int):
    # Обработка отключения игрока
    ServerManager.remove_player_from_server(multiplayer.get_unique_id(), id)

func _on_refresh_modes_button_pressed():
    # Обновление списка режимов
    reload_game_modes()
    status_label.text = "Список режимов обновлен!"

func _on_back_button_pressed():
    # Возврат в главное меню
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
