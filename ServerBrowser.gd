extends Control

@onready var server_list = $VBoxContainer/ScrollContainer/ServerList

func _ready():
    refresh_server_list()

func refresh_server_list():
    # Очищаем список
    for child in server_list.get_children():
        child.queue_free()
    
    # Загружаем серверы (пример)
    var servers = ServerManager.get_servers()
    
    for server in servers:
        var panel = PanelContainer.new()
        var hbox = HBoxContainer.new()
        
        var name_label = Label.new()
        name_label.text = server.name
        hbox.add_child(name_label)
        
        var mode_label = Label.new()
        mode_label.text = server.mode
        hbox.add_child(mode_label)
        
        var players_label = Label.new()
        players_label.text = "%d/%d" % [server.players.size(), server.max_players]
        hbox.add_child(players_label)
        
        var join_button = Button.new()
        join_button.text = "Присоединиться"
        join_button.connect("pressed", Callable(self, "_on_join_pressed").bind(server))
        hbox.add_child(join_button)
        
        panel.add_child(hbox)
        server_list.add_child(panel)

func _on_join_pressed(server):
    # Подключаемся к серверу
    var peer = ENetMultiplayerPeer.new()
    peer.create_client("127.0.0.1", 4242) # Используйте реальный IP сервера
    multiplayer.multiplayer_peer = peer
    
    # Переходим в лобби
    get_tree().change_scene_to_file("res://scenes/server_lobby.tscn")

func _on_refresh_button_pressed():
    refresh_server_list()
