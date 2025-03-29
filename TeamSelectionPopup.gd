extends PanelContainer

signal team_selected(team: String)

@onready var teams_container = $ScrollContainer/VBoxContainer

var team_colors = {}

func setup(teams_data: Dictionary):
    team_colors = teams_data
    _clear_teams()
    _create_team_blocks()

func _clear_teams():
    for child in teams_container.get_children():
        child.queue_free()

func _create_team_blocks():
    for team in team_colors:
        var panel = PanelContainer.new()
        var vbox = VBoxContainer.new()
        var header = HBoxContainer.new()
        
        # Настройка стилей
        var style = StyleBoxFlat.new()
        style.bg_color = team_colors[team].color
        panel.add_theme_stylebox_override("panel", style)
        
        # Заголовок команды
        var title = Label.new()
        title.text = team.capitalize()
        title.add_theme_font_size_override("font_size", 20)
        header.add_child(title)
        
        # Кнопка выбора
        var select_btn = Button.new()
        select_btn.text = "Выбрать"
        select_btn.pressed.connect(_on_team_selected.bind(team))
        header.add_child(select_btn)
        
        # Список игроков
        var players_label = Label.new()
        players_label.text = "Игроки:\n" + "\n".join(team_colors[team].players)
        
        vbox.add_child(header)
        vbox.add_child(players_label)
        panel.add_child(vbox)
        teams_container.add_child(panel)

func _on_team_selected(team: String):
    team_selected.emit(team)
    queue_free()
