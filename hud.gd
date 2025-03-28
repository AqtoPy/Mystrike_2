extends CanvasLayer

@onready var message_label = $TopBar/MessageLabel
@onready var timer_label = $TopBar/TimerLabel
@onready var team_scores = $TopBar/TeamScores
@onready var team_panel = $TeamPanel
@onready var leaderboard = $Leaderboard

func show_message(text: String, duration: float = 3.0):
    message_label.text = text
    message_label.visible = true
    await get_tree().create_timer(duration).timeout
    message_label.visible = false

func update_timer(time_seconds: int):
    var minutes = time_seconds / 60
    var seconds = time_seconds % 60
    timer_label.text = "%02d:%02d" % [minutes, seconds]

func update_team_scores(scores: Dictionary):
    for team_id in scores:
        var label = team_scores.get_node("Team%dScore" % team_id)
        if label:
            label.text = str(scores[team_id])

func toggle_team_panel(show: bool):
    team_panel.visible = show
    if show:
        GameManager.request_team_update()

func update_leaderboard(stats: Array, players: Dictionary):
    leaderboard.update_data(stats, players)

func _input(event):
    if event.is_action_pressed("show_teams"):
        toggle_team_panel(not team_panel.visible)
    elif event.is_action_pressed("show_leaderboard"):
        leaderboard.visible = not leaderboard.visible
