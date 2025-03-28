extends Node
class_name ModeRegistrationSystem

# Словарь для автоматической загрузки режимов
const MODE_PATHS = {
    "tdm": "res://game_modes/tdm/tdm_mode.gd",
    "dm": "res://game_modes/deathmatch/deathmatch_mode.gd"
}

func _ready():
    register_all_modes()

func register_all_modes():
    # Регистрация стандартных режимов
    register_mode(
        "tdm",
        "Team Deathmatch",
        "GameDev Studio",
        "1.3",
        load(MODE_PATHS["tdm"]),
        {"min_players": 4, "max_players": 16}
    )
    
    # Автоматическая регистрация пользовательских режимов
    load_custom_modes()

func register_mode(mode_id: String, name: String, author: String, version: String, script: GDScript, config: Dictionary = {}):
    if not script.has_method("on_game_start"):
        push_error("Invalid mode script: missing required methods")
        return
    
    var mode_data = {
        "id": mode_id,
        "name": name,
        "author": author,
        "version": version,
        "script": script,
        "config": config,
        "icon": load("res://ui/icons/modes/%s.png" % mode_id)
    }
    
    GameModeDatabase.add_mode(mode_data)
    Logger.debug("Registered mode: " + name + " by " + author)

func load_custom_modes():
    var dir = DirAccess.open("user://custom_modes/")
    if not dir:
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".gd"):
            var script = load("user://custom_modes/" + file_name)
            if script and script.has_meta("is_game_mode"):
                register_mode(
                    script.get_meta("mode_id"),
                    script.get_meta("name"),
                    script.get_meta("author", "Unknown"),
                    script.get_meta("version", "1.0"),
                    script
                )
        file_name = dir.get_next()
