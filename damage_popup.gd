extends Node3D

@onready var label = $Label

func setup(text: String, color: Color):
    label.text = text
    label.modulate = color
    
    var tween = create_tween()
    tween.tween_property(self, "position:y", position.y + 2.0, 0.8)
    tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
    tween.tween_callback(queue_free)
