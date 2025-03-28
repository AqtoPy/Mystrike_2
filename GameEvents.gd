# GameEvents.gd
extends Node

## Автолоад для глобального управления событиями игры

# Сигналы игрока
signal player_connected(player_id: int)               # Игрок подключился
signal player_disconnected(player_id: int)            # Игрок отключился
signal player_spawned(player_id: int, team: String)   # Игрок заспавнился
signal player_died(player_id: int, killer_id: int)    # Игрок убит
signal player_team_changed(player_id: int, old_team: String, new_team: String)
signal player_health_updated(player_id: int, health: float)

# Сигналы состояния игры
signal game_started(mode_name: String)                # Начало матча
signal game_ended(winner_team: String)                # Конец матча
signal match_time_updated(time_left: float)           # Обновление таймера

# Сигналы пользовательского интерфейса
signal show_system_message(text: String, color: Color) # Системное сообщение
signal update_hud(data: Dictionary)                   # Обновление HUD
signal show_popup(title: String, message: String)     # Всплывающее окно

# Сигналы статусов игроков
signal vip_status_updated(player_id: int, is_vip: bool)
signal developer_status_updated(player_id: int, is_dev: bool)

# Сигналы сетевых событий
signal server_created(success: bool)                  # Сервер создан
signal server_joined(success: bool)                   # Подключение к серверу

# Сигналы разработческих функций
signal dev_cheat_activated(cheat_name: String)        # Активация читов
signal dev_spawn_object(object_type: String)          # Спавн объектов

## Методы для генерации событий
static func emit_player_connected(player_id: int):
    player_connected.emit(player_id)

static func emit_vip_status(player_id: int, status: bool):
    vip_status_updated.emit(player_id, status)

static func emit_dev_status(player_id: int, status: bool):
    developer_status_updated.emit(player_id, status)

static func emit_system_message(text: String, color: Color = Color.WHITE):
    show_system_message.emit(text, color)

# Пример использования:
# GameEvents.emit_system_message("Игрок %s присоединился" % player_name)
