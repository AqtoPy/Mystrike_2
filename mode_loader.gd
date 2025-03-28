extends Node

const CUSTOM_MODES_DIR = "user://GameModes/"

func _ready():
    load_custom_modes()

func load_custom_modes():
    var dir = DirAccess.open(CUSTOM_MODES_DIR)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd"):
                var mode_script = load(CUSTOM_MODES_DIR + file_name)
                if mode_script and mode_script.is_base("GameModeAPI/GameMode"):
                    GameModeAPI.ModeManager.register_mode(mode_script)
            file_name = dir.get_next()
