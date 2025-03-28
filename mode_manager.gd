class_name ModeManager
extends Node

var loaded_modes = {}

func load_modes():
    var dir = DirAccess.open("res://gamemodes/")
    for file in dir.get_files():
        if file.ends_with(".gd"):
            var script = load(dir.get_current_dir().path_join(file))
            if script and script.is_class("GDScript"):
                var instance = script.new()
                if _validate_mode(instance):
                    loaded_modes[instance.mode_name] = instance

func _validate_mode(mode: GameModeAPI) -> bool:
    var required = [
        "mode_name", "author", "version",
        "register_teams", "_on_game_start"
    ]
    
    for method in required:
        if not mode.get_script().has_method(method):
            push_error("Invalid mode: missing ", method)
            return false
    
    return true

func get_mode_info(mode_name: String) -> Dictionary:
    var mode = loaded_modes.get(mode_name)
    if mode:
        return {
            "name": mode.mode_name,
            "author": mode.author,
            "version": mode.version,
            "description": mode.description
        }
    return {}
