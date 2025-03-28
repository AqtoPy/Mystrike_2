class_name NetworkManager
extends Node

# Настройки
const DEFAULT_PORT = 9080
const MAX_PLAYERS = 16
const BROADCAST_INTERVAL = 1.0
const BROADCAST_PORT = 9090

# Сигналы
signal server_created(success: bool)
signal server_joined()
signal connection_failed()
signal player_list_updated()
signal team_selected(team: String)

# Данные
var players = {}
var local_player_info = {}
var available_servers = []
var broadcast_timer = Timer.new()
var udp_listener = PacketPeerUDP.new()

func _ready():
    # Настройка таймера для локального вещания
    broadcast_timer.wait_time = BROADCAST_INTERVAL
    broadcast_timer.timeout.connect(_broadcast_server_presence)
    add_child(broadcast_timer)
    
    # Настройка UDP listener
    udp_listener.bind(BROADCAST_PORT)

func create_server(config: Dictionary):
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
    
    if error != OK:
        server_created.emit(false)
        return
    
    multiplayer.multiplayer_peer = peer
    _setup_server(config)
    server_created.emit(true)
    broadcast_timer.start()

func join_server(ip: String = "127.0.0.1"):
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(ip, DEFAULT_PORT)
    
    if error != OK:
        connection_failed.emit()
        return
    
    multiplayer.multiplayer_peer = peer

func _setup_server(config: Dictionary):
    players[1] = {
        "name": config.server_name,
        "team": "",
        "ip": "127.0.0.1",
        "port": DEFAULT_PORT,
        "max_players": config.max_players,
        "map": config.map,
        "mode": config.mode
    }
    
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _broadcast_server_presence():
    if multiplayer.is_server():
        var udp = PacketPeerUDP.new()
        udp.set_dest_address("224.0.0.1", BROADCAST_PORT)
        var data = JSON.stringify(players[1])
        udp.put_packet(data.to_utf8_buffer())
        udp.close()

func _on_peer_connected(id: int):
    players[id] = {"name": "Player %d" % id, "team": ""}
    player_list_updated.emit()
    
    # Отправляем новые данные всем клиентам
    update_player_data()

func _on_peer_disconnected(id: int):
    players.erase(id)
    player_list_updated.emit()
    update_player_data()

@rpc("any_peer", "reliable")
func select_team(team: String):
    var id = multiplayer.get_remote_sender_id()
    if players.has(id):
        players[id].team = team
        team_selected.emit(team)
        player_list_updated.emit()
        
        # Спавн игрока после выбора команды
        GameEvents.spawn_player_requested.emit(id, team)

func update_player_data():
    rpc("_receive_player_data", players)

@rpc("reliable")
func _receive_player_data(data: Dictionary):
    players = data
    player_list_updated.emit()

func _process(delta):
    if udp_listener.get_available_packet_count() > 0:
        var packet = udp_listener.get_packet()
        var server_info = JSON.parse_string(packet.get_string_from_utf8())
        if server_info and not _server_exists(server_info.ip):
            available_servers.append(server_info)

func _server_exists(ip: String) -> bool:
    for server in available_servers:
        if server.ip == ip: return true
    return false

func get_available_servers() -> Array:
    return available_servers

func disconnect_peer():
    if multiplayer.multiplayer_peer:
        multiplayer.multiplayer_peer.close()
    players.clear()
