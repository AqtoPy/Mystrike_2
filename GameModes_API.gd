class_name BaseGameMode
extends RefCounted

## Базовый класс для создания кастомных режимов

# Сигналы
signal mode_preload_started
signal mode_loaded_successfully
signal game_started
signal game_ended(winner: String)
signal player_joined(player: Node)
signal player_left(player: Node)
signal player_spawned(player: Node, team: String)
signal player_died(player: Node, killer: Node)
signal team_score_changed(team: String, new_score: int)

# Основные свойства режима (должны быть переопределены)
var mode_name := "Unnamed Mode"
var author := "Unknown"
var version := "1.0"
var description := "No description provided"
var icon: Texture2D = null

# Системные свойства
var world: Node
var players := {}
var teams := {}
var config := {}
var is_game_active := false

# API для моддеров ======================================================

## Должен быть переопределен - настройка команд и правил
func setup_mode() -> void:
    push_warning("setup_mode() not overridden")

## Должен быть переопределен - логика начала матча
func start_game() -> void:
    push_warning("start_game() not overridden")

## Должен быть переопределен - логика завершения матча
func end_game(winner: String = "") -> void:
    push_warning("end_game() not overridden")

## Регистрация команд (автоматически вызывает setup_spawn_points)
func register_team(team_name: String, team_data: Dictionary) -> void:
    teams[team_name] = {
        "color": team_data.get("color", Color.WHITE),
        "score": 0,
        "spawn_points": [],
        "max_players": team_data.get("max_players", 0),
        "players": []
    }
    _setup_spawn_points(team_name)

## Добавить условие победы
func add_win_condition(condition_name: String, condition: Callable) -> void:
    if not world.has_method("add_win_condition"):
        push_error("World doesn't support win conditions")
        return
    world.add_win_condition(condition_name, condition)

## Спавн кастомного объекта
func spawn_object(object_scene: PackedScene, position: Vector3, parent: Node = world) -> Node:
    var obj = object_scene.instantiate()
    obj.position = position
    parent.add_child(obj)
    return obj

## Показать сообщение всем игрокам
func broadcast_message(message: String, color: Color = Color.WHITE) -> void:
    if multiplayer.is_server():
        rpc("_receive_broadcast_message", message, color)

# Внутренние методы =====================================================

func _initialize(world_node: Node, mode_config: Dictionary) -> void:
    world = world_node
    config = mode_config
    setup_mode()
    mode_loaded_successfully.emit()

func _on_player_connected(player: Node) -> void:
    players[player.name] = player
    player_joined.emit(player)
    _show_team_selection(player)

func _on_player_disconnected(player_id: int) -> void:
    var player = players.get(str(player_id))
    if player:
        player_left.emit(player)
        players.erase(str(player_id))

func _show_team_selection(player: Node) -> void:
    var popup = preload("res://ui/TeamSelectionPopup.tscn").instantiate()
    popup.setup(teams)
    
    popup.team_selected.connect(func(team: String):
        _assign_player_to_team(player, team)
    )
    
    player.get_node("UI").add_child(popup)

func _assign_player_to_team(player: Node, team: String) -> void:
    if not teams.has(team):
        push_error("Invalid team: ", team)
        return
    
    # Удаляем из предыдущей команды
    var old_team = player.get("team", "")
    if teams.has(old_team):
        teams[old_team].players.erase(player)
    
    # Добавляем в новую команду
    player.set("team", team)
    teams[team].players.append(player)
    player_spawned.emit(player, team)
    
    # Обновляем визуал игрока
    _apply_team_visuals(player, team)

func _apply_team_visuals(player: Node, team: String) -> void:
    if player.has_method("set_team_color"):
        player.set_team_color(teams[team].color)

func _setup_spawn_points(team_name: String) -> void:
    var spawn_group = team_name.to_lower() + "_spawns"
    teams[team_name].spawn_points = world.get_tree().get_nodes_in_group(spawn_group)

# Сетевые методы =======================================================

@rpc("call_local", "reliable")
func _receive_broadcast_message(message: String, color: Color) -> void:
    GameEvents.emit_signal("show_system_message", message, color)
