extends CharacterBody3D
class_name NetworkedPlayer

const MOUSE_SENSITIVITY = 0.002
const BASE_SPEED = 5.0
const VIP_SPEED_MULTIPLIER = 1.3
const JUMP_FORCE = 4.8

@export var camera_path: NodePath
@export var weapon_handler_path: NodePath

@onready var camera: Camera3D = get_node(camera_path)
@onready var weapon_handler: Node = get_node(weapon_handler_path)

var is_vip := false
var current_speed := BASE_SPEED
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Сетевая синхронизация
var sync_pos: Vector3:
    set(value):
        if is_multiplayer_authority():
            position = value
        else:
            position = position.lerp(value, 0.3)

var sync_rot: Vector3:
    set(value):
        if is_multiplayer_authority():
            rotation = value
        else:
            rotation = rotation.lerp(value, 0.3)

func _enter_tree():
    if multiplayer.has_multiplayer_peer():
        set_multiplayer_authority(str(name).to_int())

func _ready():
    if not is_multiplayer_authority():
        camera.queue_free()
        return
    
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    load_player_settings()
    
    # VIP проверка
    if PlayerData.is_vip_active():
        activate_vip_effects()

func _physics_process(delta):
    if not is_multiplayer_authority():
        return
    
    handle_movement_input(delta)
    handle_jump_input()
    move_and_slide()
    
    # Синхронизация позиции
    rpc("update_position", position, rotation)

@rpc("any_peer", "call_local", "reliable")
func update_position(new_pos: Vector3, new_rot: Vector3):
    sync_pos = new_pos
    sync_rot = new_rot

func activate_vip_effects():
    current_speed *= VIP_SPEED_MULTIPLIER
    gravity *= 0.9
    is_vip = true

func handle_movement_input(delta):
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if is_on_floor():
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
    else:
        velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 5.0)
        velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 5.0)
    
    velocity.y -= gravity * delta

func handle_jump_input():
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_FORCE * (1.1 if is_vip else 1.0)

@rpc("any_peer", "call_local")
func take_damage(amount: int, source_id: int):
    if not is_multiplayer_authority():
        return
    
    GameManager.player_take_damage.rpc_id(1, get_name(), amount, source_id)
