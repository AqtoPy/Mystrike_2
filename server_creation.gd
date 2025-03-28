extends Control

@onready var name_input = $Panel/VBoxContainer/NameInput
@onready var mode_option = $Panel/VBoxContainer/ModeOption
@onready var players_slider = $Panel/VBoxContainer/PlayersSlider
@onready var password_input = $Panel/VBoxContainer/PasswordInput
@onready var create_btn = $Panel/VBoxContainer/CreateBtn

var available_modes = []

func _ready():
    load_game_modes()
    create_btn.connect("pressed", _on_create_pressed)

func load_game_modes():
    var dir = DirAccess.open("res://scripts/game_modes/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd") and file_name != "base_mode.gd":
                var mode = load("res://scripts/game_modes/" + file_name).new()
                mode_option.add_item(mode.mode_name)
                available_modes.append(mode)
            file_name = dir.get_next()

func _on_create_pressed():
    var server_name = name_input.text
    var mode = available_modes[mode_option.selected]
    var max_players = players_slider.value
    var password = password_input.text
    
    if ServerManager.create_server(server_name, mode, max_players, password):
        get_tree().change_scene_to_file("res://scenes/game/game_world.tscn")
