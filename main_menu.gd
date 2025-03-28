extends Control

@onready var create_btn = $VBoxContainer/CreateServerBtn
@onready var join_btn = $VBoxContainer/JoinServerBtn
@onready var settings_btn = $VBoxContainer/SettingsBtn
@onready var exit_btn = $VBoxContainer/ExitBtn

func _ready():
    create_btn.connect("pressed", _on_create_pressed)
    join_btn.connect("pressed", _on_join_pressed)
    settings_btn.connect("pressed", _on_settings_pressed)
    exit_btn.connect("pressed", _on_exit_pressed)

func _on_create_pressed():
    get_tree().change_scene_to_file("res://scenes/main/server_creation.tscn")

func _on_join_pressed():
    get_tree().change_scene_to_file("res://scenes/main/server_browser.tscn")

func _on_settings_pressed():
    get_tree().change_scene_to_file("res://scenes/main/settings.tscn")

func _on_exit_pressed():
    get_tree().quit()
