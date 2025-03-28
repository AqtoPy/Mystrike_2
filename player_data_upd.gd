# Добавьте в начало скрипта
signal data_updated

# Модифицируйте метод save_data
func save_data():
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("players"):
        dir.make_dir("players")
    
    var file = FileAccess.open_encrypted_with_pass(SAVE_PATH % data.player_id, FileAccess.WRITE, ENCRYPTION_KEY)
    file.store_var(data)
    file.close()
    emit_signal("data_updated")

# Добавьте метод для добавления валюты
func add_currency(amount: int):
    data.currency += amount
    save_data()
