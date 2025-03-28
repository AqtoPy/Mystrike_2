extends Node

@export var server_ip = "127.0.0.1"
@export var server_port = 8910

func _ready():
    connect_to_server()

func connect_to_server():
    var peer = ENetMultiplayerPeer.new()
    var err = peer.create_client(server_ip, server_port)
    if err != OK:
        push_error("Failed to connect to server")
        return
    
    multiplayer.multiplayer_peer = peer
    setup_local_player()

func setup_local_player():
    var player = preload("res://player.tscn").instantiate()
    player.name = str(multiplayer.get_unique_id())
    get_node("/root/World/Players").add_child(player)
    player.set_multiplayer_authority(multiplayer.get_unique_id())
