# Автозагружается через Project Settings > AutoLoad
class_name GameStateManager
extends Node

# Состояния игры
enum GameModeState {
    LOBBY,
    PREGAME,
    PLAYING,
    POSTGAME
}

var current_state: GameModeState = GameModeState.LOBBY
var current_mode: GameMode = null  # Текущий активный режим игры

func set_game_state(new_state: GameModeState):
    current_state = new_state
    NetworkManager.sync_game_state.rpc(new_state)

func set_current_mode(mode: GameMode):
    current_mode = mode
    NetworkManager.sync_current_mode.rpc(mode.mode_id)
