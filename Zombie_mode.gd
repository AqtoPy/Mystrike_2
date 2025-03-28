class_name ZombieMode
extends BaseGameMode

# Константы
const ZOMBIE_TEAM = "zombies"
const SURVIVOR_TEAM = "survivors"
const MATCH_DURATION = 300.0 # 5 минут
const INITIAL_INFECTION_DELAY = 10.0

# Переменные
var match_timer: Timer
var infection_timer: Timer
var infected_count = 0

func _init():
    # Метаданные режима
    mode_name = "Zombie Apocalypse"
    author = "Horror Studios"
    version = "2.1"
    description = "Выжившие против зомби. Последний выживший побеждает!"

func initialize_mode():
    # Инициализация таймеров
    match_timer = Timer.new()
    match_timer.wait_time = MATCH_DURATION
    match_timer.timeout.connect(_on_match_end)
    add_child(match_timer)
    
    infection_timer = Timer.new()
    infection_timer.wait_time = INITIAL_INFECTION_DELAY
    infection_timer.timeout.connect(_select_initial_zombie)
    add_child(infection_timer)

func start_game():
    # Старт игры
    broadcast_message("Бегите! Заражение начнётся через %d секунд!" % INITIAL_INFECTION_DELAY, Color.ORANGE)
    infection_timer.start()
    match_timer.start()
    
    # Настройка игроков
    for player in get_players():
        _setup_survivor(player)

func _setup_survivor(player: Node):
    if player.has_method("set_team"):
        player.set_team(SURVIVOR_TEAM)
        player.set_health(150.0 if PlayerData.is_vip(player.get_id()) else 100.0)
        player.set_speed(1.5 if PlayerData.is_developer(player.get_id()) else 1.0)

func _select_initial_zombie():
    var candidates = []
    for player in get_players():
        if player.get_team() == SURVIVOR_TEAM:
            candidates.append(player)
    
    if candidates.size() > 0:
        var zombie = candidates[randi() % candidates.size()]
        _infect_player(zombie)
        broadcast_message("%s стал первым зомби!" % zombie.get_name(), Color.RED)

func _infect_player(player: Node):
    if player.has_method("set_team"):
        player.set_team(ZOMBIE_TEAM)
        player.set_health(200.0)
        player.set_speed(1.8)
        infected_count += 1
        
        # VIP/Dev бонусы для зомби
        if PlayerData.is_vip(player.get_id()):
            player.set_health(250.0)
        if PlayerData.is_developer(player.get_id()):
            player.set_speed(2.5)
        
        broadcast_message("%s был заражён!" % player.get_name(), Color.RED_RED)

func _on_player_death(player: Node, killer: Node):
    if player.get_team() == SURVIVOR_TEAM and killer.get_team() == ZOMBIE_TEAM:
        _infect_player(player)
    else:
        respawn_player(player, 5.0)

func _on_match_end():
    var survivors = 0
    for player in get_players():
        if player.get_team() == SURVIVOR_TEAM:
            survivors += 1
    
    if survivors > 0:
        broadcast_message("Выжившие победили! Осталось %d человек" % survivors, Color.GREEN)
    else:
        broadcast_message("Зомби победили! Все заражены", Color.RED)
    
    end_game()

func create_hud() -> Control:
    return preload("res://ui/zombie_hud.tscn").instantiate()
