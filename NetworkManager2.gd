# NetworkManager.gd
extends Node

func join_server(ip: String):
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(ip, 4242)
    multiplayer.multiplayer_peer = peer

func leave_server():
    multiplayer.multiplayer_peer.close()
    get_tree().change_scene_to_file("res://MainMenu.tscn")
