extends Node3D

@onready var spawn_points = $SpawnPoints
@onready var game_timer = $GameTimer

var players = {}
var current_game_mode = null

func _ready():
    NetworkManager.peer_connected.connect(_on_player_connected)
    NetworkManager.peer_disconnected.connect(_on_player_disconnected)
    
    if multiplayer.is_server():
        initialize_game_mode()

func initialize_game_mode():
    var mode_name = ServerManager.current_server_config.get("mode", "dm")
    current_game_mode = ModeManager.get_mode(mode_name).new()
    current_game_mode.game_world = self
    current_game_mode.on_game_start()
    
    game_timer.wait_time = current_game_mode.MATCH_DURATION
    game_timer.start()

func _on_player_connected(id: int):
    var player_scene = preload("res://Player.tscn").instantiate()
    player_scene.name = str(id)
    add_child(player_scene)
    
    var player_data = {
        "id": id,
        "team": "",
        "is_zombie": false,
        "health": 100.0
    }
    
    if PlayerData.is_developer():
        player_data["health"] = 150.0
        player_data["speed_multiplier"] = 2.0
    elif PlayerData.is_vip():
        player_data["health"] = 150.0
        player_data["speed_multiplier"] = 1.5
    
    players[id] = player_data
    spawn_player(id)

func spawn_player(id: int):
    var player = get_node(str(id))
    var team = players[id].get("team", "")
    
    var spawn_group = "survivor_spawns"
    if players[id].get("is_zombie", false):
        spawn_group = "zombie_spawns"
    
    var points = spawn_points.get_node(spawn_group).get_children()
    if points.size() > 0:
        player.global_transform = points[randi() % points.size()].global_transform

func _on_player_death(id: int):
    if multiplayer.is_server():
        players[id].health = 0
        current_game_mode.handle_player_death(id)
        respawn_player(id)

func respawn_player(id: int, delay: float = 5.0):
    await get_tree().create_timer(delay).timeout
    if players.has(id):
        players[id].health = players[id].get("max_health", 100.0)
        spawn_player(id)

func _on_game_timer_timeout():
    if multiplayer.is_server():
        current_game_mode.end_game()
        game_timer.stop()

func _on_player_disconnected(id: int):
    if players.has(id):
        players.erase(id)
    get_node(str(id)).queue_free()
