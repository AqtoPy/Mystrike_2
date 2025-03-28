# game_logger.gd
extends Node

enum LOG_LEVEL {
    DEBUG,
    INFO,
    WARNING,
    ERROR
}

static func log(message: String, level: LOG_LEVEL = INFO):
    var timestamp = Time.get_time_string_from_system()
    var log_text = "[%s] %s: %s" % [timestamp, LOG_LEVEL.keys()[level], message]
    
    # Вывод в консоль
    print(log_text)
    
    # Для debug-версии добавляем в UI
    if OS.is_debug_build() and level >= LOG_LEVEL.INFO:
        GameAPI.add_debug_message(log_text)
    
    # Сохранение в файл (только ошибки)
    if level >= LOG_LEVEL.WARNING:
        save_to_log_file(log_text)

static func save_to_log_file(message: String):
    var file = FileAccess.open("user://game_log.txt", FileAccess.WRITE_READ)
    file.seek_end()
    file.store_string(message + "\n")
    file.close()
