class_name TripleWarfareMode
extends GameModeAPI

func _init():
    mode_name = "Triple Warfare"
    author = "Developer"
    version = "1.0"
    description = "Бесконечная война трех фракций с мгновенным возрождением"

    config = {
        "respawn_time": 3.0,
        "score_limit": 1000
    }

func register_teams() -> Dictionary:
    return {
        "Red Team": {
            "color": Color("#FF4444"),
            "spawn_group": "red_spawns",
            "score": 0
        },
        "Blue Team": {
            "color": Color("#4444FF"),
            "spawn_group": "blue_spawns",
            "score": 0
        },
        "Green Team": {
            "color": Color("#44FF44"),
            "spawn_group": "green_spawns",
            "score": 0
        }
    }

func _on_game_start():
    broadcast("Война началась!", Color.GOLD)
    _setup_spawns()

func _on_player_death(player: Player, killer: Player):
    if killer and killer.team != player.team:
        _update_score(killer.team)
        broadcast("%s убил %s!" % [killer.name, player.name], killer.team_data.color)
    
    respawn_player(player, config.respawn_time)

func _update_score(team: String):
    var teams_data = register_teams()
    if teams_data.has(team):
        teams_data[team].score += 1
        
        if teams_data[team].score >= config.score_limit:
            _end_game(team)

func _end_game(winning_team: String):
    broadcast("%s побеждают с %d очками!" % [winning_team, config.score_limit], Color.GOLD)
    _on_game_end()

func create_hud():
    return preload("res://gamemodes/triple_warfare_hud.tscn").instantiate()

func _setup_spawns():
    var spawn_points = {
        "red_spawns": $World/RedSpawns.get_children(),
        "blue_spawns": $World/BlueSpawns.get_children(),
        "green_spawns": $World/GreenSpawns.get_children()
    }
    
    for team in register_teams():
        if spawn_points[register_teams()[team].spawn_group].is_empty():
            push_error("No spawn points for team: ", team)
