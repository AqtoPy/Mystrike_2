extends Node

# Список активных серверов
var active_servers: Array = []

# Все доступные режимы игры
var game_modes: Array = []

func _ready():
    load_default_modes()

# Загрузка стандартных режимов
func load_default_modes():
    game_modes = [
        {"id": "dm", "name": "Deathmatch", "max_players": 8},
        {"id": "ctf", "name": "Capture the Flag", "max_players": 12}
    ]
    load_custom_modes()

# Загрузка кастомных режимов
func load_custom_modes():
    var dir = DirAccess.open("res://GameModes/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".json"):
                var mode = _load_mode_file(file_name)
                if mode: game_modes.append(mode)
            file_name = dir.get_next()

func _load_mode_file(file: String) -> Dictionary:
    var f = FileAccess.open("res://GameModes/" + file, FileAccess.READ)
    if f:
        var json = JSON.new()
        if json.parse(f.get_as_text()) == OK:
            return json.data
    return {}
