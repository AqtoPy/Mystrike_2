extends Control

@onready var server_list = $Panel/VBoxContainer/ServerList
@onready var refresh_btn = $Panel/VBoxContainer/RefreshBtn

func _ready():
    refresh_btn.connect("pressed", _on_refresh_pressed)
    refresh_servers()

func refresh_servers():
    # Очищаем список
    for child in server_list.get_children():
        child.queue_free()
    
    # Получаем сервера от мастер-сервера
    var servers = ServerManager.get_available_servers()
    
    # Создаем элементы списка
    for server in servers:
        var entry = preload("res://scenes/ui/server_entry.tscn").instantiate()
        entry.setup(server)
        entry.connect("join_pressed", _on_join_pressed.bind(server))
        server_list.add_child(entry)

func _on_join_pressed(server):
    if ServerManager.join_server(server.ip, server.port, server.password):
        get_tree().change_scene_to_file("res://scenes/game/game_world.tscn")

func _on_refresh_pressed():
    refresh_servers()
