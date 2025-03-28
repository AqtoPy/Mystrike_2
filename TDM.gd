class_name AdvancedTDMMode extends GameMode
# Метаданные режима (для регистрации)
@export_meta var mode_id = "advanced_tdm"
@export_meta var name = "Advanced TDM"
@export_meta var author = "ProGamer"
@export_meta var version = "2.1"
@export_meta var is_game_mode = true

# Конфигурация
var config = {
    "score_limit": 150,
    "round_time": 600,
    "vip_score_bonus": 2
}

func on_game_start():
    # Инициализация UI
    GameAPI.set_hint_text("Team Deathmatch started! First to %d wins" % config.score_limit, 5.0)
    GameAPI.show_popup("Round Start", "Fight for your team!", 3.0)
    
    # Настройка лидерборда
    GameAPI.set_leaderboard_columns([
        {"name": "Player", "width": 200},
        {"name": "Kills", "width": 80},
        {"name": "Deaths", "width": 80},
        {"name": "Score", "width": 80},
        {"name": "VIP", "width": 50}
    ])
    
    # Инициализация командного UI
    GameAPI.create_team_panel({
        "team1": {"name": "Red Team", "color": Color.RED},
        "team2": {"name": "Blue Team", "color": Color.BLUE}
    })

func on_player_join(player_id: int):
    # Обновляем UI при подключении
    GameAPI.update_hint_text("Player %s joined" % GameAPI.get_player_name(player_id), 2.0)
    
    # VIP статус в лидерборде
    if GameAPI.is_player_vip(player_id):
        GameAPI.set_leaderboard_value(player_id, "VIP", "★")

func on_player_death(victim_id: int, killer_id: int):
    # Эффекты для убийств
    if killer_id != -1:
        var bonus = config.vip_score_bonus if GameAPI.is_player_vip(killer_id) else 1
        GameAPI.add_score(killer_id, bonus)
        
        # PopUp для VIP
        if bonus > 1:
            GameAPI.show_popup("VIP Bonus!", "+%d points!" % bonus, 1.5)

func update(delta: float):
    # Обновление таймера в UI
    GameAPI.update_hint_text("Time left: %d" % get_remaining_time())
    
    # Обновление лидерборда каждую секунду
    if Engine.get_frames_drawn() % 60 == 0:
        update_leaderboard()

func update_leaderboard():
    var data = []
    for player in get_players():
        data.append({
            "Player": player.name,
            "Kills": player.stats.kills,
            "Deaths": player.stats.deaths,
            "Score": player.stats.score,
            "VIP": "★" if player.is_vip else ""
        })
    GameAPI.update_leaderboard(data)
