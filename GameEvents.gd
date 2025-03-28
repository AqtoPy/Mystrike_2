# GameEvents.gd
extends Node

# Сигналы (остаются без изменений)
signal player_connected(player_id: int)
signal player_disconnected(player_id: int)
signal player_spawned(player_id: int, team: String)
signal player_died(player_id: int, killer_id: int)
signal player_team_changed(player_id: int, old_team: String, new_team: String)
signal player_health_updated(player_id: int, health: float)
signal game_started(mode_name: String)
signal game_ended(winner_team: String)
signal match_time_updated(time_left: float)
signal show_system_message(text: String, color: Color)
signal update_hud(data: Dictionary)
signal show_popup(title: String, message: String)
signal vip_status_updated(player_id: int, is_vip: bool)
signal developer_status_updated(player_id: int, is_dev: bool)
signal server_created(success: bool)
signal server_joined(success: bool)
signal dev_cheat_activated(cheat_name: String)
signal dev_spawn_object(object_type: String)

# Удаляем статические методы и делаем обычные
func emit_player_connected(player_id: int):
    player_connected.emit(player_id)

func emit_vip_status(player_id: int, status: bool):
    vip_status_updated.emit(player_id, status)

func emit_dev_status(player_id: int, status: bool):
    developer_status_updated.emit(player_id, status)

func emit_system_message(text: String, color: Color = Color.WHITE):
    show_system_message.emit(text, color)
