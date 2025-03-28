extends CanvasLayer

@onready var title_label = $Panel/Title
@onready var message_label = $Panel/Message
@onready var timer = $Timer

func setup(title: String, message: String, duration: float) -> void:
    title_label.text = title
    message_label.text = message
    timer.wait_time = duration
    timer.start()

func _on_timer_timeout() -> void:
    queue_free()
