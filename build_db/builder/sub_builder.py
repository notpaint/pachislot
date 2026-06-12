import sqlite3
import json

def generate_SE(cursor_sub, config):
    for name, SE_data in config.SE.items():
        rule = json.dumps(SE_data.get("rule"))
        sound = json.dumps(SE_data.get("sound"))
        cursor_sub.execute("""INSERT OR IGNORE INTO SE(name, rule, sound)
                       VALUES(?, ?, ?)
                       """, (name, rule, sound))

def generate_bonus_music(cursor_main, cursor_sub, config):
    for bonus, music_data in config.bonus_music.items():
        cursor_main.execute("SELECT name from bonus_data WHERE name = (?)", (bonus,))
        if cursor_main.fetchone() is None:
            print(f"ERROR on generate_bonus_music: {bonus} does not exists in main.db")
            continue
        jingle = music_data.get("jingle")
        rule = json.dumps(music_data.get("rule"))
        tracks = music_data.get("tracks", {})
        for track_name, track_info in tracks.items():
            start = track_info.get("start")
            end = track_info.get("end")
            next = track_info.get("next")

            cursor_sub.execute("""INSERT OR IGNORE INTO bonus_music(bonus, jingle, rule, track_name, start, end, next)
                           VALUES(?, ?, ?, ?, ?, ?, ?)
                           """, (bonus, jingle, rule, track_name, start, end, next))
            
def generate_RT_music(cursor_main, cursor_sub, config):
    for RT, music_data in config.RT_music.items():
        cursor_main.execute("SELECT name from RT_data WHERE name = (?)", (RT,))
        if cursor_main.fetchone() is None:
            print(f"ERROR on generate_RT_music: {RT} does not exists in main.db")
            continue
        rule = json.dumps(music_data.get("rule"))
        tracks = music_data.get("tracks", {})
        for track_name, track_info in tracks.items():
            start = track_info.get("start")
            end = track_info.get("end")

            cursor_sub.execute("""INSERT OR IGNORE INTO RT_music(RT, rule, track_name, start, end)
                               VALUES(?, ?, ?, ? ,?)
                               """, (RT, rule, track_name, start, end))
            
def generate_env(cursor_sub, config):
    for name, data in config.env.items():
        cursor_sub.execute("""INSERT OR IGNORE INTO env(name, data) VALUES(?, ?)""", (name, data))

            
def build_sub(config):

    if config.sub_db_path.exists():
        config.sub_db_path.unlink()

    conn_main = sqlite3.connect(config.main_db_path)
    cursor_main = conn_main.cursor()

    conn_sub = sqlite3.connect(config.sub_db_path)
    cursor_sub = conn_sub.cursor()

    with config.sub_sql_path.open("r", encoding = "UTF-8") as f:
        conn_sub.executescript(f.read())

    generate_bonus_music(cursor_main, cursor_sub, config)
    generate_RT_music(cursor_main, cursor_sub, config)
    generate_SE(cursor_sub, config)
    generate_env(cursor_sub, config)

    conn_sub.commit()
    conn_sub.close()
    conn_main.close()