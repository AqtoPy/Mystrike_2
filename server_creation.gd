extends Control

@onready var server_name_input = %ServerNameInput
@onready var map_option = %MapOption
@onready var mode_option = %ModeOption
@onready var max_players_slider = %MaxPlayersSlider
@onready var status_label = %StatusLabel

var available_modes = []
var available_maps = []

func _ready():
    _load_resources()
    _populate_ui()
    _connect_signals()

func _load_resources():
    # Загрузка доступных режимов из папки gamemodes
    var dir = DirAccess.open("res://gamemodes/")
    if dir:
        dir.list_dir_begin()
        var file = dir.get_next()
        while file != "":
            if file.ends_with(".gd"):
                var mode = load("res://gamemodes/" + file).new()
                available_modes.append({
                    "name": mode.mode_name,
                    "id": file.get_basename(),
                    "description": mode.description
                })
            file = dir.get_next()

    # Загрузка доступных карт из папки maps
    var maps_dir = DirAccess.open("res://maps/")
    if maps_dir:
        maps_dir.list_dir_begin()
        var map_file = maps_dir.get_next()
        while map_file != "":
            if map_file.ends_with(".tscn"):
                available_maps.append({
                    "name": map_file.get_basename().replace("_", " ").capitalize(),
                    "path": "res://maps/" + map_file
                })
            map_file = maps_dir.get_next()

func _populate_ui():
    # Заполнение выбора режимов
    for mode in available_modes:
        mode_option.add_item(mode.name)
    
    # Заполнение выбора карт
    for map in available_maps:
        map_option.add_item(map.name)
    
    # Настройка слайдера игроков
    max_players_slider.min_value = 2
    max_players_slider.max_value = 16
    max_players_slider.value = 8

func _connect_signals():
    %CreateButton.pressed.connect(_on_create_pressed)
    %BackButton.pressed.connect(_on_back_pressed)
    %RefreshMapsButton.pressed.connect(_load_resources)

func _on_create_pressed():
    var config = {
        "server_name": server_name_input.text.strip_edges(),
        "map": available_maps[map_option.selected]["path"],
        "mode": available_modes[mode_option.selected]["id"],
        "max_players": int(max_players_slider.value),
        "players": []
    }
    
    if _validate_config(config):
        NetworkManager.create_server(config)
        get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _validate_config(config: Dictionary) -> bool:
    if config.server_name.length() < 3:
        _show_error("Название сервера должно быть не менее 3 символов")
        return false
    
    if config.max_players < 2:
        _show_error("Минимальное количество игроков - 2")
        return false
    
    return true

func _show_error(message: String):
    status_label.text = message
    status_label.add_theme_color_override("font_color", Color.RED)
    %ErrorAnimation.play("shake")

func _on_back_pressed():
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
