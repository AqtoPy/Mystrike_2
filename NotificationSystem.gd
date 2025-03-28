extends CanvasLayer

@onready var notification_label = $NotificationPanel/RichTextLabel

func show_notification(text: String):
    var msg = "[center]{0}[/center]".format([text])
    notification_label.append_text(msg + "\n")
    
    # Анимация
    var tween = create_tween()
    tween.tween_interval(3.0)
    tween.tween_callback(remove_oldest_notification)

func remove_oldest_notification():
    var lines = notification_label.text.split("\n")
    if lines.size() > 5:
        lines.remove_at(0)
        notification_label.text = "\n".join(lines)
