extends Node

# Конфигурация сервера
var current_server_config = {
    "name": "",
    "mode": null,
    "max_players": 8,
    "players": [],
    "status": "lobby"
}

# Сетевые настройки
const PORT = 9080
var peer: ENetMultiplayerPeer

# Режимы игры
var available_modes = []
var custom_modes_loaded = false

func _ready():
    load_builtin_modes()
    load_custom_modes()

func load_builtin_modes():
    var builtin_modes = [
        {
            "id": "dm",
            "name": "Deathmatch",
            "author": "System",
            "version": "1.0",
            "description": "Classic free-for-all deathmatch",
            "teams": 0,
            "max_players": 16
        }
    ]
    available_modes = builtin_modes

func load_custom_modes():
    var dir = DirAccess.open("user://GameModes/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd"):
                var mode = _load_custom_mode(file_name)
                if mode:
                    available_modes.append(mode)
            file_name = dir.get_next()
    custom_modes_loaded = true

func _load_custom_mode(file_path: String) -> Dictionary:
    var script = load("user://GameModes/" + file_path)
    if script and script.has_method("get_mode_info"):
        var instance = script.new()
        return instance.get_mode_info()
    return {}

func create_server(config: Dictionary):
    current_server_config = config
    peer = ENetMultiplayerPeer.new()
    
    var error = peer.create_server(PORT, config.max_players)
    if error != OK:
        push_error("Failed to create server: ", error)
        return false
    
    multiplayer.multiplayer_peer = peer
    _setup_network_signals()
    return true

func _setup_network_signals():
    multiplayer.peer_connected.connect(_on_player_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _on_player_connected(player_id: int):
    var player_data = PlayerData.get_player(player_id)
    current_server_config.players.append(player_data)
    broadcast_system_message("%s присоединился" % player_data.name)

func _on_player_disconnected(player_id: int):
    var index = current_server_config.players.find(
        func(p): return p.id == player_id
    )
    if index != -1:
        var player_name = current_server_config.players[index].name
        current_server_config.players.remove_at(index)
        broadcast_system_message("%s вышел" % player_name)

func broadcast_system_message(message: String):
    rpc("receive_system_message", "[System] " + message)

@rpc("reliable")
func receive_system_message(message: String):
    GameEvents.emit_signal("system_message_received", message)

func get_available_modes() -> Array:
    if not custom_modes_loaded:
        load_custom_modes()
    return available_modes

func clear_server():
    if peer:
        peer.close()
    current_server_config = {}
