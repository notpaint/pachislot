extends Node

var db : SQLite

var db_path = ""
var db_path_dict = {
	"A": "res://db/A/sub.db",
	"AT": "res://db/AT/sub.db",
	"A+RT": "res://db/A+RT/sub.db"
}

var current_version: String
var order_scene_path: String

var SE_dict: Dictionary = {}
var bonus_music: Dictionary = {}

func _ready():
    if db_path == "":
        db_path = db_path_dict["A"]


func load_sub_db(version):
    if not db_path_dict.has(version):
        print("!!! Failed to load sub.db for version ", version, ". Defaulting to A !!!")
        version = "A"
    
    current_version = version

    if db:
        db.close_db()
    clear_data()

    var res_path = db_path_dict[version]
    var user_path = ""

    if OS.has_feature("editor"):
        user_path = res_path
    else:
        var exe_dir = OS.get_executable_path().get_base_dir()
        var db_folder = exe_dir + "/db"
        if not DirAccess.dir_exists_absolute(db_folder):
            DirAccess.make_dir_absolute(db_folder)
        var version_folder = db_folder + "/" + version
        if not DirAccess.dir_exists_absolute(version_folder):
            DirAccess.make_dir_absolute(version_folder)
        user_path = version_folder + "/sub.db"

        DirAccess.copy_absolute(res_path, user_path)

    db_path = user_path
    db = SQLite.new()
    db.path = db_path
    db.open_db()

    load_order_scene()
    load_data_from_db()

func load_order_scene():
    db.query("SELECT data FROM env WHERE name = 'order_scene_path'")
    var results = db.query_result

    if results:
        var scene_path = results[0]["data"]
        if scene_path:
            order_scene_path = scene_path



func clear_data():
    pass

func load_data_from_db():
    generate_bonus_music()
    generate_SE_dict()

func generate_SE_dict():
    db.query("SELECT name, rule, sound FROM SE")
    var results = db.query_result

    for row in results:
        var item = row["name"]
        var rule_json = row["rule"]
        rule_json = JSON.parse_string(rule_json)
        var sound_json = row["sound"]
        sound_json = JSON.parse_string(sound_json)

        if not SE_dict.has(item):
            SE_dict[item] = {
                "rule": rule_json,
                "sound": sound_json
            }

func generate_bonus_music():
    db.query("SELECT bonus, jingle, rule, track_name, start, end, next FROM bonus_music")
    var results = db.query_result

    for row in results:
        var bonus = row["bonus"]
        var jingle = row["jingle"]
        var rule_array = row["rule"]
        rule_array = JSON.parse_string(rule_array)
        var track_name = row["track_name"]
        if not bonus_music.has(bonus):
            bonus_music[bonus] = {
                "jingle": jingle,
                "rule": rule_array,
                "tracks": {}
            }

        bonus_music[bonus]["tracks"][track_name] = {
            "start": row["start"],
            "end": row["end"],
            "next": row["next"]
        }

        