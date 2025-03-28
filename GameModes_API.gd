class_name BaseGameMode
extends RefCounted

# Сигналы
signal mode_initialized
signal player_respawned(player: Node)
signal game_ended(winner: String)
signal show_popup(title: String, message: String, duration: float)

# Конфигурация
var config: Dictionary = {}
var world: Node
var players: Array[Node] = []

# Вспомогательные ссылки
var popup_scene = preload("res://ui/popup_message.tscn")

# Виртуальные методы ======================================

func initialize_mode() -> void:
    """Вызывается при загрузке режима"""
    push_warning("initialize_mode() not implemented")

func start_game() -> void:
    """Старт игрового режима"""
    push_warning("start_game() not implemented")

func end_game(winner: String = "") -> void:
    """Завершение режима"""
    game_ended.emit(winner)

func _on_player_join(player: Node) -> void:
    """Обработка подключения игрока"""
    push_warning("_on_player_join() not implemented")

func _on_player_death(player: Node, killer: Node) -> void:
    """Обработка смерти игрока"""
    push_warning("_on_player_death() not implemented")

# Основной API ============================================

func show_popup_message(title: String, message: String, duration: float = 3.0) -> void:
    """Показать всплывающее сообщение всем игрокам"""
    show_popup.emit(title, message, duration)
    
    # Локальный вызов для хоста
    if Engine.is_editor_hint() or not multiplayer.is_server():
        _create_local_popup(title, message, duration)

func get_players() -> Array[Node]:
    """Получить всех игроков"""
    return get_tree().get_nodes_in_group("players") if get_tree() else []

func spawn_player(player: Node, spawn_point: Vector3) -> void:
    """Спавн игрока в указанной позиции"""
    if world and world.has_method("spawn_player"):
        world.call("spawn_player", player, spawn_point)
    else:
        push_error("World not set or missing spawn method")

func respawn_player(player: Node, delay: float = 5.0) -> void:
    """Возрождение игрока с задержкой"""
    await get_tree().create_timer(delay).timeout
    player_respawned.emit(player)

# Внутренние методы =======================================

func _create_local_popup(title: String, message: String, duration: float) -> void:
    """Создать PopUp локально (для синглплеера/редактора)"""
    var popup = popup_scene.instantiate()
    popup.setup(title, message, duration)
    get_tree().root.add_child(popup)

func _broadcast_message(text: String, color: Color) -> void:
    """Альтернатива для broadcast_message"""
    show_popup_message("Система", text, 3.0)
