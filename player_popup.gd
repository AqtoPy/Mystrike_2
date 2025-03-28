extends Node3D

@onready var label = $Label

func setup(title: String, text: String, duration: float):
    label.text = "[%s]\n%s" % [title, text]
    await get_tree().create_timer(duration).timeout
    queue_free()
