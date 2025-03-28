extends Node
class_name GameManager

# Системные компоненты
var network_manager: NetworkManager
var player_manager: PlayerManager
var mode_manager: ModeManager
var ui_manager: UIManager

# Текущее состояние игры
enum GameState { LOBBY, PLAYING, ENDED }
var current_state = GameState.LOBBY
var current_mode: GameMode = null

func _ready():
    # Инициализация подсистем
    network_manager = NetworkManager.new()
    player_manager = PlayerManager.new()
    mode_manager = ModeManager.new()
    ui_manager = UIManager.new()
    
    add_child(network_manager)
    add_child(player_manager)
    add_child(mode_manager)
    add_child(ui_manager)
    
    # Загрузка режимов при старте
    mode_manager.load_modes()

# Основные методы
func start_game(mode_id: String):
    var mode = mode_manager.get_mode(mode_id)
    if mode:
        current_mode = mode
        current_state = GameState.PLAYING
        mode.on_game_start()
        ui_manager.show_hint("Game started!", 3.0)

func end_game(winner_team = null):
    current_state = GameState.ENDED
    if current_mode:
        current_mode.on_game_end(winner_team)
    ui_manager.show_popup("Game Over", "Team %s wins!" % winner_team)

func restart_game():
    if current_mode:
        current_mode.on_game_restart()
    current_state = GameState.LOBBY

# Сетевые методы
func sync_game_state():
    network_manager.rpc("update_game_state", {
        "mode": current_mode.mode_id if current_mode else "",
        "state": current_state
    })

# Управление игроками
func register_player(player_id: int, player_data: Dictionary):
    player_manager.register_player(player_id, player_data)
    if current_mode:
        current_mode.on_player_join(player_id)
