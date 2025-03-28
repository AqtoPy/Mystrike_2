# weapon_integration.gd
extends Node

# Инициализация оружия для режима
func setup_mode_weapons():
    # Получаем систему оружия из вашего шаблона
    var weapon_system = get_node("/root/WeaponStateMachine")
    
    # Стандартный набор для TDM
    var loadout = {
        "primary": "rifle",
        "secondary": "pistol",
        "melee": "knife"
    }
    
    # Настройка оружия из вашего FPS Template
    weapon_system.initialize_weapons([
        weapon_system.get_weapon_config("rifle"),
        weapon_system.get_weapon_config("pistol"),
        weapon_system.get_weapon_config("knife")
    ])
    
    # Сетевой синхронизатор
    weapon_system.connect("weapon_fired", _on_weapon_fired)
    weapon_system.connect("reload_started", _on_reload_started)

func _on_weapon_fired(weapon_data):
    # Синхронизация выстрелов
    GameAPI.replicate_weapon_event(
        "fire",
        weapon_data.weapon_id,
        weapon_data.player_id
    )

func _on_reload_started(weapon_data):
    GameAPI.replicate_weapon_event(
        "reload",
        weapon_data.weapon_id,
        weapon_data.player_id
    )

# API для режимов
static func give_player_weapon(player_id: int, weapon_id: String):
    var weapon_system = get_node("/root/WeaponStateMachine")
    weapon_system.equip_weapon(player_id, weapon_id)
    
    # Сетевой вызов
    GameAPI.rpc("give_weapon", player_id, weapon_id)
