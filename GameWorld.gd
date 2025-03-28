extends Node3D

@onready var notification_system = $GUI/Notifications

var players = {}
var teams = {
    "TeamA": [],
    "TeamB": [],
    "Spectators": []
}

func _ready():
    if multiplayer.is_server():
        setup_server()
    
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    
    load_world()
    show_team_selection()

func setup_server():
    # Инициализация сервера
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(4242)
    multiplayer.multiplayer_peer = peer
    
    # Загрузка параметров
    load_map(ServerManager.current_server.map)
    load_gamemode(ServerManager.current_server.mode)

func load_world():
    # Загрузка карты и режима
    var map_scene = load(ServerManager.current_server.map)
    var map = map_scene.instantiate()
    add_child(map)

func _on_peer_connected(id: int):
    # Новый игрок присоединился
    var player_name = ServerManager.get_player_name(id)
    notification_system.show_notification("[color=green]{0} присоединился[/color]".format([player_name]))
    
    if multiplayer.is_server():
        teams.Spectators.append(id)
        update_teams.rpc(teams)

func _on_peer_disconnected(id: int):
    # Игрок отключился
    var player_name = ServerManager.get_player_name(id)
    notification_system.show_notification("[color=red]{0} вышел[/color]".format([player_name]))
    
    if multiplayer.is_server():
        var team = get_player_team(id)
        teams[team].erase(id)
        update_teams.rpc(teams)
        players.erase(id)

@rpc("call_local", "reliable")
func update_teams(new_teams: Dictionary):
    teams = new_teams
    update_team_display()

func update_team_display():
    $GUI/TeamSelect/TeamAList.clear()
    $GUI/TeamSelect/TeamBList.clear()
    
    for id in teams.TeamA:
        $GUI/TeamSelect/TeamAList.add_item(ServerManager.get_player_name(id))
    
    for id in teams.TeamB:
        $GUI/TeamSelect/TeamBList.add_item(ServerManager.get_player_name(id))

func show_team_selection():
    $GUI/TeamSelect.visible = true
    update_team_display()

func _on_join_a_pressed():
    rpc_id(1, "request_team_change", multiplayer.get_unique_id(), "TeamA")

func _on_join_b_pressed():
    rpc_id(1, "request_team_change", multiplayer.get_unique_id(), "TeamB")

@rpc("any_peer", "reliable")
func request_team_change(player_id: int, team: String):
    if not multiplayer.is_server():
        return
    
    var current_team = get_player_team(player_id)
    if current_team != "Spectators":
        teams[current_team].erase(player_id)
    
    teams[team].append(player_id)
    update_teams.rpc(teams)
    spawn_player(player_id)

func spawn_player(id: int):
    var team = get_player_team(id)
    var spawn = $SpawnPoints.get_node(team).get_children().pick_random()
    
    var player_scene = load("res://Player.tscn")
    var player = player_scene.instantiate()
    player.name = str(id)
    player.position = spawn.global_position
    $Players.add_child(player)
    
    players[id] = player
