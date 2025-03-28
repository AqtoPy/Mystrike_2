extends Control

@onready var mode_option = $VBoxContainer/ModeSelection/ModeOption
@onready var server_name_input = $VBoxContainer/ServerName/LineEdit
@onready var max_players_slider = $VBoxContainer/PlayerSettings/MaxPlayers/Slider
@onready var mode_info_text = $VBoxContainer/ModeInfo/ScrollContainer/Text

var selected_mode_id = ""

func _ready():
    _populate_modes()
    _connect_signals()

func _populate_modes():
    mode_option.clear()
    for mode in ServerManager.get_available_modes():
        mode_option.add_item(mode.name)
        mode_option.set_item_metadata(mode_option.item_count-1, mode)

func _connect_signals():
    mode_option.item_selected.connect(_on_mode_selected)
    $VBoxContainer/CreateButton.pressed.connect(_on_create_pressed)
    $VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_mode_selected(index: int):
    var mode = mode_option.get_item_metadata(index)
    selected_mode_id = mode.id
    _update_mode_info(mode)

func _update_mode_info(mode: Dictionary):
    var text = "Название: %s\nАвтор: %s\nВерсия: %s\n\nОписание:\n%s" % [
        mode.name,
        mode.author,
        mode.version,
        mode.description
    ]
    mode_info_text.text = text

func _on_create_pressed():
    var config = {
        "name": server_name_input.text.strip_edges(),
        "mode": selected_mode_id,
        "max_players": int(max_players_slider.value)
    }
    
    if _validate_config(config):
        if ServerManager.create_server(config):
            get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")

func _validate_config(config: Dictionary) -> bool:
    if config.name.length() < 3:
        _show_error("Слишком короткое название сервера!")
        return false
    
    if config.max_players < 2:
        _show_error("Минимум 2 игрока")
        return false
    
    if selected_mode_id == "":
        _show_error("Выберите режим игры!")
        return false
    
    return true

func _show_error(message: String):
    $ErrorDialog.dialog_text = message
    $ErrorDialog.popup_centered()

func _on_back_pressed():
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
