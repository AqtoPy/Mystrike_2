# core/game_state.gd
class_name GameState
extends Node

# Автозагружается в Project Settings > AutoLoad

enum State {
    LOBBY,      # В лобби
    PREGAME,    # Подготовка
    PLAYING,    # Идет игра
    POSTGAME    # Завершена
}

var current_state = State.LOBBY
var current_mode = null

func set_state(new_state: State):
    current_state = new_state
    NetworkManager.sync_game_state.rpc(current_state)
