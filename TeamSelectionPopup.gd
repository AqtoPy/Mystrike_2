extends CanvasLayer

@onready var teams_container = $Panel/VBoxContainer/TeamsContainer
@onready var message_label = $Panel/VBoxContainer/WelcomeMessage
@onready var hint_label = $Panel/VBoxContainer/Hint
@onready var timer = $Panel/VBoxContainer/Timer

var selected_team := ""

func setup(teams: Dictionary, welcome_data: Dictionary):
    message_label.text = welcome_data.message
    hint_label.text = welcome_data.hint
    timer.wait_time = welcome_data.duration
    
    # Создаем кнопки для каждой команды
    for team_name in teams:
        var btn = Button.new()
        btn.text = team_name
        btn.custom_minimum_size = Vector2(200, 50)
        btn.add_theme_color_override("font_color", teams[team_name].color)
        btn.pressed.connect(_on_team_selected.bind(team_name))
        teams_container.add_child(btn)
    
    timer.start()
    _animate_appear()

func _animate_appear():
    var tween = create_tween()
    tween.tween_property($Panel, "position", Vector2(0, 0), 0.5)\
         .from(Vector2(0, -200)).set_ease(Tween.EASE_OUT)

func _on_team_selected(team: String):
    selected_team = team
    GameEvents.emit_signal("team_selected", team)
    _animate_disappear()

func _on_spectate_pressed():
    selected_team = "Spectators"
    GameEvents.emit_signal("team_selected", "Spectators")
    _animate_disappear()

func _on_timer_timeout():
    if selected_team.is_empty():
        _on_spectate_pressed()

func _animate_disappear():
    var tween = create_tween()
    tween.tween_property($Panel, "modulate:a", 0.0, 0.3)
    tween.tween_callback(queue_free)
