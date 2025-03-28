extends Node

const PORT = 8910
const MAX_PLAYERS = 16

func _ready():
    start_server()

func start_server():
    var peer = ENetMultiplayerPeer.new()
    var err = peer.create_server(PORT, MAX_PLAYERS)
    if err != OK:
        push_error("Failed to start server")
        return
    
    multiplayer.multiplayer_peer = peer
    register_player_types()
    load_game_mode("tdm")
    
    print("Server started on port ", PORT)

func register_player_types():
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func load_game_mode(mode_id: String):
    var mode = GameModeLoader.get_mode(mode_id)
    add_child(mode.new())
    mode.on_game_start()

func _on_peer_connected(id):
    print("Player ", id, " connected")
    spawn_player(id)

func _on_peer_disconnected(id):
    print("Player ", id, " disconnected")
    despawn_player(id)

func spawn_player(id):
    var player = preload("res://player.tscn").instantiate()
    player.name = str(id)
    get_node("/root/World/Players").add_child(player)
