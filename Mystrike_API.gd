# game_api.gd
class_name GameAPI extends RefCounted

### 1. Core Game Management ###
static func start_game(mode_id: String, map_name: String):
    var mode = GameModeDB.get_mode(mode_id)
    if mode:
        GameState.current_mode = mode
        NetworkManager.load_map.rpc(map_name)
        mode.on_game_start()
        Logger.log("Game started: " + mode_id)
    else:
        Logger.error("Mode not found: " + mode_id)

static func end_game(winner):
    GameState.current_mode.on_game_end(winner)
    NetworkManager.show_endgame_screen.rpc(winner)
    Logger.log("Game ended. Winner: " + str(winner))

static func set_time_of_day(time: float, transition_duration: float = 5.0):
    WorldEnvironment.set_time(time, transition_duration)
    NetworkManager.sync_time.rpc(time, transition_duration)

static func set_weather(effect: String, intensity: float):
    WeatherSystem.set_effect(effect, intensity)
    NetworkManager.sync_weather.rpc(effect, intensity)

### 2. Player Management ###
static func spawn_player(player_id: int, position: Vector3):
    var player_scene = load("res://objects/player.tscn")
    var player = player_scene.instantiate()
    player.name = str(player_id)
    player.position = position
    get_tree().current_scene.add_child(player)
    NetworkManager.spawn_player.rpc(player_id, position)

static func apply_player_effect(player_id: int, effect: Dictionary):
    var player = get_player(player_id)
    if player:
        player.effects.add(effect)
        NetworkManager.sync_effects.rpc(player_id, effect)

static func teleport_player(player_id: int, new_position: Vector3):
    var player = get_player(player_id)
    if player:
        player.position = new_position
        NetworkManager.teleport_player.rpc(player_id, new_position)

### 3. Weapon System ###
static func create_weapon_template(config: Dictionary):
    var weapon = WeaponTemplate.new()
    weapon.configure(config)
    WeaponDB.register_weapon(weapon)
    NetworkManager.sync_weapons.rpc()

static func give_weapon(player_id: int, weapon_id: String):
    var player = get_player(player_id)
    if player and WeaponDB.has_weapon(weapon_id):
        player.inventory.add_weapon(weapon_id)
        NetworkManager.give_weapon.rpc(player_id, weapon_id)

static func create_projectile(owner_id: int, type: String, position: Vector3, direction: Vector3):
    var projectile = ProjectileFactory.create(type, owner_id)
    projectile.launch(position, direction)
    NetworkManager.spawn_projectile.rpc(projectile)

### 4. Economy & Progression ###
static func get_player_currency(player_id: int) -> int:
    return PlayerDB.get_data(player_id).currency

static func purchase_item(player_id: int, item_id: String) -> bool:
    var player = PlayerDB.get_data(player_id)
    var item = ShopDB.get_item(item_id)
    
    if player.currency >= item.price:
        player.currency -= item.price
        InventoryManager.add_item(player_id, item)
        NetworkManager.purchase_item.rpc(player_id, item_id)
        return true
    return false

static func unlock_achievement(player_id: int, achievement_id: String):
    if AchievementsDB.validate(achievement_id):
        PlayerDB.unlock_achievement(player_id, achievement_id)
        NetworkManager.unlock_achievement.rpc(player_id, achievement_id)

### 5. UI System ###
static func create_hud_element(element_id: String, config: Dictionary):
    var element = UIElement.new(config)
    UIManager.register_element(element_id, element)
    NetworkManager.sync_ui.rpc(element_id, config)

static func show_interactive_menu(menu_type: String, data: Dictionary):
    var menu = UIFactory.create_menu(menu_type, data)
    UIManager.show_menu(menu)
    NetworkManager.show_menu.rpc(menu_type, data)

static func update_scoreboard(data: Array, columns: Array):
    Scoreboard.update_layout(columns)
    Scoreboard.update_data(data)
    NetworkManager.sync_scoreboard.rpc(data, columns)

### 6. Event System ###
static func register_custom_event(event_id: String, callback: Callable):
    EventManager.register(event_id, callback)
    NetworkManager.register_event.rpc(event_id)

static func trigger_global_event(event_id: String, data: Dictionary):
    EventManager.trigger(event_id, data)
    NetworkManager.trigger_event.rpc(event_id, data)

### 7. World Interaction ###
static func spawn_entity(entity_id: String, position: Vector3, properties: Dictionary = {}):
    var entity = EntityDB.instantiate(entity_id, properties)
    entity.position = position
    WorldManager.add_entity(entity)
    NetworkManager.spawn_entity.rpc(entity_id, position, properties)

static func create_destructible(object_id: String, health: float, position: Vector3):
    var destructible = DestructibleObject.new(object_id, health)
    destructible.position = position
    WorldManager.add_destructible(destructible)
    NetworkManager.create_destructible.rpc(object_id, health, position)

### 8. Modding Support ###
static func load_custom_mode(path: String):
    var mode_script = load(path)
    if mode_script and mode_script.is_valid_mode():
        ModeManager.register_mode(mode_script)
        NetworkManager.sync_modes.rpc()
        return true
    return false

static func validate_mode_script(script: GDScript) -> bool:
    const REQUIRED_FUNCTIONS = ["on_game_start", "on_player_join"]
    for func_name in REQUIRED_FUNCTIONS:
        if not script.has_method(func_name):
            return false
    return true

### 9. Network Utilities ###
static func replicate_variable(var_name: String, value, reliable: bool = true):
    if reliable:
        NetworkManager.replicate.rpc_id(1, var_name, value)
    else:
        NetworkManager.replicate_unreliable.rpc_id(1, var_name, value)

static func predict_local_action(action_id: String, data: Dictionary):
    LocalPrediction.queue_action(action_id, data)
    NetworkManager.send_action.rpc(action_id, data)

### 10. Security System ###
static func validate_player_action(player_id: int, action: String) -> bool:
    var player = get_player(player_id)
    return SecuritySystem.validate_action(player.auth_level, action)

static func log_cheat_attempt(player_id: int, details: Dictionary):
    SecuritySystem.log_cheat(player_id, details)
    NetworkManager.report_cheat.rpc_id(1, player_id, details)
