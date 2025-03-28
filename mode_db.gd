extends Node
class_name GameModeDB

# База данных всех доступных режимов
static var registered_modes = {}

# Регистрация режима
static func register_mode(mode_id: String, mode_script: GDScript, config: Dictionary = {}):
    if mode_script.has_method("on_game_start"):
        registered_modes[mode_id] = {
            "script": mode_script,
            "config": config,
            "icon": load("res://ui/icons/modes/%s.png" % mode_id)
        }

# Получение экземпляра режима
static func get_mode(mode_id: String) -> GameMode:
    if mode_id in registered_modes:
        var mode = registered_modes[mode_id]["script"].new()
        mode.mode_id = mode_id
        return mode
    return null

# Загрузка всех режимов
static func load_modes():
    # Официальные режимы
    register_mode("tdm", preload("res://game_modes/tdm/tdm_mode.gd"))
    register_mode("dm", preload("res://game_modes/dm/dm_mode.gd"))
    
    # Пользовательские режимы
    var dir = DirAccess.open("user://custom_modes/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd"):
                var script = load("user://custom_modes/" + file_name)
                if script and script.has_meta("is_game_mode"):
                    register_mode(
                        script.get_meta("mode_id"),
                        script,
                        script.get_meta("config", {})
                    )
            file_name = dir.get_next()
