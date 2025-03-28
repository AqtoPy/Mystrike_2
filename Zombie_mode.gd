class_name ZombieMode extends GameModeAPI

const MATCH_DURATION = 300.0 # 5 минут
const ZOMBIE_HEALTH = 150.0
const ZOMBIE_SPEED = 2.0
const SURVIVOR_HEALTH = 100.0

var match_timer: Timer
var initial_zombie_set = false

func _init():
    mode_name = "Zombie Apocalypse"
    author = "Horror Studios"
    version = "1.3"
    description = "Зомби против выживших. Выживи любой ценой!"

func register_teams() -> Dictionary:
    return {
        "Выжившие": {
            "color": Color("#00FF00"),
            "spawn_group": "survivor_spawns",
            "score": 0
        },
        "Зомби": {
            "color": Color("#FF0000"),
            "spawn_group": "zombie_spawns",
            "score": 0
        }
    }

func _on_game_start():
    match_timer = Timer.new()
    match_timer.wait_time = MATCH_DURATION
    match_timer.timeout.connect(_on_match_end)
    add_child(match_timer)
    match_timer.start()
    
    broadcast("Спасайтесь! Заражение начинается!", Color.RED)
    _select_initial_zombie()

func _on_player_join(player: Player):
    if not initial_zombie_set:
        _apply_survivor_modifiers(player)
    else:
        _apply_zombie_modifiers(player)

func _on_player_death(player: Player, killer: Player):
    if killer and killer.team == "Зомби" and player.team == "Выжившие":
        _infect_player(player)
    respawn_player(player, 5.0)

func _select_initial_zombie():
    var players = get_players()
    if players.is_empty():
        return
    
    var zombie = players.pick_random()
    _infect_player(zombie)
    initial_zombie_set = true

func _infect_player(player: Player):
    player.team = "Зомби"
    player.set_health(ZOMBIE_HEALTH)
    player.speed_multiplier = ZOMBIE_SPEED
    broadcast("%s был заражен!" % player.name, Color.RED)
    
    # VIP/Developer бонусы
    if PlayerData.is_vip(player.id) or PlayerData.is_developer(player.id):
        player.set_health(ZOMBIE_HEALTH * 1.5)
        player.speed_multiplier = ZOMBIE_SPEED * 1.5

func _apply_survivor_modifiers(player: Player):
    player.team = "Выжившие"
    player.set_health(SURVIVOR_HEALTH)
    
    # VIP/Developer бонусы
    if PlayerData.is_vip(player.id) or PlayerData.is_developer(player.id):
        player.set_health(SURVIVOR_HEALTH * 1.5)
        player.speed_multiplier = 2.0

func _apply_zombie_modifiers(player: Player):
    player.team = "Зомби"
    player.set_health(ZOMBIE_HEALTH)
    player.speed_multiplier = ZOMBIE_SPEED

func _on_match_end():
    var survivors = get_players().filter(
        func(p): return p.team == "Выжившие" and p.is_alive
    )
    
    if survivors.size() > 0:
        broadcast("Выжившие победили!", Color.GREEN)
    else:
        broadcast("Зомби захватили мир!", Color.RED)
    
    end_game()

func create_hud():
    return preload("res://gamemodes/zombie_hud.tscn").instantiate()

func _process(delta):
    if match_timer:
        var time_left = match_timer.time_left
        var minutes = floor(time_left / 60)
        var seconds = floor(fmod(time_left, 60))
        broadcast("Осталось времени: %02d:%02d" % [minutes, seconds], Color.WHITE, true)
