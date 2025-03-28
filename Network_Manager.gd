class_name NetworkManager
extends Node

## Autoload singleton для управления сетевым взаимодействием

# Сигналы
signal server_created(success: bool)
signal connection_success()
signal connection_failed()
signal player_connected(player_id: int)
signal player_disconnected(player_id: int)
signal player_data_received(player_id: int, data: Dictionary)

# Конфигурация сети
const DEFAULT_PORT = 9080
const MAX_PLAYERS = 16
const SERVER_IP = "127.0.0.1"

# Данные игроков
var players = {}
var local_player_id = 0

var peer: ENetMultiplayerPeer = null

func _ready():
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_server(port: int = DEFAULT_PORT) -> void:
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(port, MAX_PLAYERS)
    
    if error != OK:
        push_error("Failed to create server: ", error)
        server_created.emit(false)
        return
    
    multiplayer.multiplayer_peer = peer
    local_player_id = 1
    _register_local_player()
    server_created.emit(true)

func join_server(ip: String = SERVER_IP, port: int = DEFAULT_PORT) -> void:
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(ip, port)
    
    if error != OK:
        push_error("Failed to connect to server: ", error)
        connection_failed.emit()
        return
    
    multiplayer.multiplayer_peer = peer

func disconnect_from_server() -> void:
    if peer:
        peer.close()
        peer = null
    players.clear()

func get_player_list() -> Dictionary:
    return players.duplicate()

func _register_local_player():
    var player_data = {
        "name": PlayerData.get_player_name(),
        "vip": PlayerData.is_vip_active(),
        "dev": PlayerData.is_developer(),
        "position": Vector3.ZERO,
        "rotation": Vector3.ZERO
    }
    players[local_player_id] = player_data
    _update_player_data(local_player_id, player_data)

@rpc("any_peer", "reliable")
func _update_player_data(player_id: int, data: Dictionary):
    players[player_id] = data
    player_data_received.emit(player_id, data)

func _on_peer_connected(player_id: int):
    print("Player connected: ", player_id)
    player_connected.emit(player_id)
    
    if multiplayer.is_server():
        # Отправляем новому игроку данные всех существующих игроков
        for id in players:
            rpc_id(player_id, "_update_player_data", id, players[id])
        
        # Запрашиваем данные нового игрока
        rpc_id(player_id, "_request_player_data")

@rpc("any_peer", "reliable")
func _request_player_data():
    if multiplayer.is_server():
        return
    _register_local_player()
    _update_player_data.rpc_id(1, local_player_id, players[local_player_id])

@rpc("any_peer", "reliable")
func _on_player_data_update(player_id: int, data: Dictionary):
    players[player_id] = data

func _on_peer_disconnected(player_id: int):
    print("Player disconnected: ", player_id)
    players.erase(player_id)
    player_disconnected.emit(player_id)

func _on_connected_to_server():
    print("Successfully connected to server")
    local_player_id = multiplayer.get_unique_id()
    connection_success.emit()

func _on_connection_failed():
    print("Connection failed")
    connection_failed.emit()
    disconnect_from_server()

func _on_server_disconnected():
    print("Server disconnected")
    disconnect_from_server()

@rpc("any_peer", "call_local", "reliable")
func sync_player_transform(player_id: int, position: Vector3, rotation: Vector3):
    if players.has(player_id):
        players[player_id]["position"] = position
        players[player_id]["rotation"] = rotation

# Пример использования в игроке:
# func _physics_process(delta):
#     if is_multiplayer_authority():
#         NetworkManager.sync_player_transform.rpc(
#             multiplayer.get_unique_id(),
#             global_position,
#             rotation
#         )

@rpc("any_peer", "call_local", "reliable")
func send_chat_message(message: String):
    var player_name = players.get(multiplayer.get_remote_sender_id(), {}).get("name", "Unknown")
    GameEvents.emit_system_message("[%s]: %s" % [player_name, message])

@rpc("any_peer", "reliable")
func admin_command(command: String, parameters = null):
    if multiplayer.is_server() and players[multiplayer.get_remote_sender_id()].get("dev", false):
        _execute_admin_command(command, parameters)

func _execute_admin_command(command: String, parameters):
    match command:
        "kick":
            if typeof(parameters) == TYPE_INT:
                disconnect_peer(parameters)
        "restart":
            get_tree().reload_current_scene()
        _:
            push_error("Unknown admin command: ", command)

func is_server() -> bool:
    return peer != null and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and multiplayer.is_server()

func get_player_name(player_id: int) -> String:
    return players.get(player_id, {}).get("name", "Unknown Player")

func get_player_vip_status(player_id: int) -> bool:
    return players.get(player_id, {}).get("vip", false)

func get_player_dev_status(player_id: int) -> bool:
    return players.get(player_id, {}).get("dev", false)
