extends Node

const SAVE_PATH = "user://players/%s.dat"
const ENCRYPTION_KEY = "your-secure-key"

var data = {
    "player_id": "",
    "name": "Player",
    "currency": 0,
    "vip": false,
    "vip_expire": 0,
    "dev": false,
    "stats": {},
    "unlocks": []
}

func _ready():
    load_data()

func load_data():
    if not FileAccess.file_exists(SAVE_PATH % data.player_id):
        data.player_id = generate_id()
        save_data()
        return
    
    var file = FileAccess.open_encrypted_with_pass(SAVE_PATH % data.player_id, FileAccess.READ, ENCRYPTION_KEY)
    if file:
        data = file.get_var()
        file.close()

func save_data():
    var file = FileAccess.open_encrypted_with_pass(SAVE_PATH % data.player_id, FileAccess.WRITE, ENCRYPTION_KEY)
    file.store_var(data)
    file.close()

func generate_id() -> String:
    return str(randi()).sha1_text()

func is_vip_active() -> bool:
    return data.vip and Time.get_unix_time_from_system() < data.vip_expire

func verify_dev_key(key: String) -> bool:
    var valid_keys = load_dev_keys()
    if key in valid_keys:
        data.dev = true
        save_data()
        return true
    return false

func load_dev_keys() -> Array:
    var keys = []
    var file = FileAccess.open("user://dev_keys/valid_keys.txt", FileAccess.READ)
    if file:
        while not file.eof_reached():
            keys.append(file.get_line().strip_edges())
        file.close()
    return keys
