extends Control

@onready var server_list = %ServerList
@onready var refresh_timer = %RefreshTimer

var servers = []

func _ready():
    _setup_list()
    _refresh_servers()
    refresh_timer.timeout.connect(_refresh_servers)

func _setup_list():
    server_list.set_column_title(0, "Сервер")
    server_list.set_column_title(1, "Режим")
    server_list.set_column_title(2, "Игроки")
    server_list.set_column_title(3, "Пинг")
    server_list.set_column_expand(0, true)
    server_list.set_column_expand(1, false)
    server_list.set_column_expand(2, false)
    server_list.set_column_expand(3, false)
    server_list.set_column_custom_minimum_width(1, 150)
    server_list.set_column_custom_minimum_width(2, 80)
    server_list.set_column_custom_minimum_width(3, 80)

func _refresh_servers():
    NetworkManager.request_server_list()
    servers.clear()
    server_list.clear()

    # Заглушка для тестирования
    _add_test_server()
    
    # В реальном проекте:
    # for server in NetworkManager.get_available_servers():
    #     _add_server_to_list(server)

func _add_test_server():
    var test_server = {
        "name": "Тестовый сервер",
        "mode": "Zombie Mode",
        "players": "3/8",
        "ping": "45"
    }
    _add_server_to_list(test_server)

func _add_server_to_list(server: Dictionary):
    var line = server_list.get_item_count()
    server_list.add_item(server.name)
    server_list.set_item_text(line, 1, server.mode)
    server_list.set_item_text(line, 2, server.players)
    server_list.set_item_text(line, 3, server.ping + " ms")
    server_list.set_item_metadata(line, server)

func _on_join_pressed():
    var selected = server_list.get_selected_items()
    if selected.size() > 0:
        var server = server_list.get_item_metadata(selected[0])
        NetworkManager.join_server(server.ip, server.port)

func _on_refresh_pressed():
    _refresh_servers()

func _on_server_selected(index: int):
    %JoinButton.disabled = false

func _on_back_pressed():
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
