extends CharacterBody3D
class_name NetworkedPlayer

# Константы
const MOUSE_SENSITIVITY = 0.002
const BASE_SPEED = 5.0
const VIP_SPEED_MULTIPLIER = 1.5
const DEV_SPEED_MULTIPLIER = 2.0
const JUMP_FORCE = 4.8
const VIP_JUMP_BOOST = 1.3
const NETWORK_SMOOTHING = 0.4

# Экспортируемые параметры
@export var camera_path: NodePath
@export var weapon_handler_path: NodePath
@export var popup_anchor_path: NodePath

# Ноды
@onready var camera: Camera3D = get_node(camera_path)
@onready var weapon_handler: Node = get_node(weapon_handler_path)
@onready var popup_anchor: Node3D = get_node(popup_anchor_path)
@onready var name_tag: Label3D = $NameTag

# Сетевые переменные
var sync_pos: Vector3:
    set(value):
        if is_multiplayer_authority():
            position = value
        else:
            position = position.lerp(value, NETWORK_SMOOTHING)

var sync_rot: Vector3:
    set(value):
        if is_multiplayer_authority():
            rotation = value
        else:
            rotation = rotation.lerp(value, NETWORK_SMOOTHING)

# Статусы
var is_vip := false
var is_dev := false
var current_speed := BASE_SPEED
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var health := 100

func _enter_tree():
    if multiplayer.has_multiplayer_peer():
        set_multiplayer_authority(str(name).to_int())

func _ready():
    if not is_multiplayer_authority() and not Engine.is_editor_hint():
        camera.queue_free()
        return
    
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _load_player_settings()
    _update_player_appearance()
    
    # Подключение сигналов
    GameEvents.show_popup.connect(_handle_popup)
    GameEvents.vip_status_updated.connect(_update_vip_status)
    GameEvents.developer_status_updated.connect(_update_dev_status)

func _physics_process(delta):
    if not is_multiplayer_authority() and multiplayer.has_multiplayer_peer():
        return
    
    _handle_movement_input(delta)
    _handle_jump_input()
    move_and_slide()
    
    # Синхронизация только для авторитетного клиента
    if is_multiplayer_authority():
        rpc("_update_position", position, rotation)

func _load_player_settings():
    if PlayerData.is_vip_active():
        _activate_vip_effects(true)
    if PlayerData.is_developer():
        _activate_dev_effects(true)
    
    name_tag.text = PlayerData.get_player_name()
    _update_tag_color()

func _update_player_appearance():
    if is_dev:
        $Mesh.material_override.albedo_color = Color.ROYAL_BLUE
    elif is_vip:
        $Mesh.material_override.albedo_color = Color.GOLD

func _update_tag_color():
    if is_dev:
        name_tag.modulate = Color.DEEP_SKY_BLUE
    elif is_vip:
        name_tag.modulate = Color.GOLD
    else:
        name_tag.modulate = Color.WHITE

func _activate_vip_effects(active: bool):
    is_vip = active
    current_speed = BASE_SPEED * (VIP_SPEED_MULTIPLIER if active else 1.0)
    _update_player_appearance()
    _update_tag_color()

func _activate_dev_effects(active: bool):
    is_dev = active
    current_speed = BASE_SPEED * (DEV_SPEED_MULTIPLIER if active else 1.0)
    _update_player_appearance()
    _update_tag_color()

func _handle_movement_input(delta):
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if is_on_floor():
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
    else:
        velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 5.0)
        velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 5.0)
    
    velocity.y -= gravity * delta

func _handle_jump_input():
    if Input.is_action_just_pressed("jump") and is_on_floor():
        var jump_power = JUMP_FORCE
        if is_vip: jump_power *= VIP_JUMP_BOOST
        if is_dev: jump_power *= 1.5
        velocity.y = jump_power

@rpc("any_peer", "call_local", "reliable")
func _update_position(new_pos: Vector3, new_rot: Vector3):
    sync_pos = new_pos
    sync_rot = new_rot

@rpc("any_peer", "call_local", "reliable")
func take_damage(amount: int, source_id: int):
    if not is_multiplayer_authority():
        return
    
    health -= amount
    GameEvents.player_health_updated.emit(name.to_int(), health)
    
    if health <= 0:
        _die(source_id)

func _die(killer_id: int):
    GameEvents.player_died.emit(name.to_int(), killer_id)
    health = 100
    position = Vector3.ZERO  # Временный респавн
    GameEvents.player_health_updated.emit(name.to_int(), health)

func _handle_popup(title: String, message: String, duration: float):
    if not is_multiplayer_authority() and multiplayer.has_multiplayer_peer():
        return
    
    var popup = preload("res://ui/player_popup.tscn").instantiate()
    popup.setup(title, message, duration)
    popup_anchor.add_child(popup)

func _update_vip_status(player_id: int, status: bool):
    if player_id == name.to_int():
        _activate_vip_effects(status)

func _update_dev_status(player_id: int, status: bool):
    if player_id == name.to_int():
        _activate_dev_effects(status)

@rpc("any_peer", "call_local", "reliable")
func show_damage_popup(amount: int):
    var popup = preload("res://ui/damage_popup.tscn").instantiate()
    popup.setup(str(amount), Color.RED)
    popup_anchor.add_child(popup)
