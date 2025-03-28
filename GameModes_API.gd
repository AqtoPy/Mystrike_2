class_name GameModeAPI
extends RefCounted

# Метаданные режима (обязательные поля)
var mode_name := "Unnamed Mode"
var author := "Unknown Author"
var version := "1.0.0"
var description := "No description provided"

# Конфигурация
var config: Dictionary
var world: Node3D
var players: Array[Player] = []

# Сигналы
signal mode_initialized
signal player_respawned(player: Player)

# Основные методы
func _on_mode_preload() -> void:
    pass

func _on_game_start() -> void:
    pass

func _on_game_end() -> void:
    pass

func _on_player_join(player: Player) -> void:
    pass

func _on_player_leave(player: Player) -> void:
    pass

func _on_player_death(player: Player, killer: Player) -> void:
    pass

func register_teams() -> Dictionary:
    return {}

func create_hud() -> Control:
    return null

# Вспомогательные методы
final func respawn_player(player: Player, delay: float = 5.0) -> void:
    await get_tree().create_timer(delay).timeout
    player.respawn()
    player_respawned.emit(player)

final func broadcast(message: String, color: Color = Color.WHITE) -> void:
    GameEvents.emit_signal("broadcast_message", message, color)
