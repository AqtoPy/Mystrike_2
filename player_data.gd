extends Node

const SAVE_PATH = "user://players/"
const ENCRYPT_KEY = "your-secure-key-12345"
const DEV_KEYS = ["DEV-2023-SECRET", "MYSTRIKE-DEV-ACCESS"]

var players = {}
var current_player_id = ""

func _ready():
    load_data()
    ensure_directories()

func ensure_directories():
    var dir = DirAccess.open("user://")
    if !dir.dir_exists("players"):
        dir.make_dir("players")

func generate_player_id() -> String:
    return str(Time.get_unix_time_from_system()).sha1_text()

func register_player(name: String, dev_key: String = ""):
    var is_dev = false
    if dev_key in DEV_KEYS:
        is_dev = true
        print("Developer access granted")
    
    current_player_id = generate_player_id()
    players[current_player_id] = {
        "name": name,
        "vip": false,
        "vip_expire": 0,
        "is_dev": is_dev,
        "currency": 0,
        "joined": Time.get_unix_time_from_system()
    }
    save_data()

func save_data():
    var file = FileAccess.open_encrypted_with_pass(
        SAVE_PATH + current_player_id + ".dat",
        FileAccess.WRITE,
        ENCRYPT_KEY
    )
    file.store_var(players[current_player_id])
    file.close()

func load_data():
    var dir = DirAccess.open(SAVE_PATH)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".dat"):
                var file = FileAccess.open_encrypted_with_pass(
                    SAVE_PATH + file_name,
                    FileAccess.READ,
                    ENCRYPT_KEY
                )
                if file:
                    var data = file.get_var()
                    players[file_name.get_basename()] = data
            file_name = dir.get_next()

func is_vip() -> bool:
    var data = players.get(current_player_id, {})
    return data.get("vip", false) && Time.get_unix_time_from_system() < data.get("vip_expire", 0)

func is_developer() -> bool:
    return players.get(current_player_id, {}).get("is_dev", false)

func grant_vip(days: int):
    var expire = Time.get_unix_time_from_system() + days * 86400
    players[current_player_id]["vip"] = true
    players[current_player_id]["vip_expire"] = expire
    save_data()

func get_player_name() -> String:
    return players.get(current_player_id, {}).get("name", "Player")

func update_name(new_name: String):
    if new_name.strip_edges().length() > 2:
        players[current_player_id]["name"] = new_name.strip_edges()
        save_data()
