class_name ModeManager extends Node

var modes = []

func _ready():
    scan_modes()

func scan_modes():
    var dir = DirAccess.open("res://gamemodes/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd"):
                var mode = _load_mode(file_name)
                if mode:
                    modes.append(mode)
            file_name = dir.get_next()

func _load_mode(file: String) -> GameModeAPI:
    var script = load("res://gamemodes/" + file)
    if script and script.is_class("GDScript"):
        var instance = script.new()
        if instance is GameModeAPI:
            return instance
    return null

func get_mode_list() -> Array:
    return modes
