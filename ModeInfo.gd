@onready var mode_info_label = $%ModeInfoLabel

func _on_mode_selected(index):
    var mode = ModeManager.get_mode(index)
    var info_text = """
    Режим: {name}
    Автор: {author}
    Версия: {version}
    Описание: {desc}
    """.format({
        "name": mode.mode_name,
        "author": mode.author,
        "version": mode.version,
        "desc": mode.description
    })
    mode_info_label.text = info_text
