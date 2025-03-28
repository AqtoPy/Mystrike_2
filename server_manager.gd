extends Node

const PORT = 8910
const MAX_SERVERS = 50

var current_server = null

func create_server(server_name: String, game_mode, max_players: int, password: String) -> bool:
    var peer = ENetMultiplayerPeer.new()
    var err = peer.create_server(PORT, max_players)
    if err != OK:
        return false
    
    multiplayer.multiplayer_peer = peer
    
    current_server = {
        "name": server_name,
        "mode": game_mode,
        "max_players": max_players,
        "password": password,
        "players": []
    }
    
    register_with_master_server()
    return true

func join_server(ip: String, port: int, password: String) -> bool:
    var peer = ENetMultiplayerPeer.new()
    var err = peer.create_client(ip, port)
    if err != OK:
        return false
    
    multiplayer.multiplayer_peer = peer
    return true

func register_with_master_server():
    # Регистрация сервера в публичном списке
    pass

func get_available_servers():
    # Получение списка серверов
    return []
