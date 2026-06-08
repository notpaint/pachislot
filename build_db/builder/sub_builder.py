import sqlite3

def generate_SE(corsor, config):
    pass

def generate_bonus_music(cursor_main, cursor_sub, config):
    for bonus, music_data in config.bonus_music.items():
        cursor_main.execute("SELECT name from bonus_data WHERE name = (?)", (bonus,))
        if cursor_main.fetchone() is None:
            print(f"ERROR on generate_bonus_music: {bonus} does not exists in main.db")
            continue
        jingle = music_data.get("jingle")
        tracks = music_data.get("tracks", {})
        for track_name, track_info in tracks.items():
            start = track_info.get("start")
            loop = track_info.get("loop")
            end = track_info.get("end")
            next = track_info.get("next")

            cursor_sub.execute("""INSERT OR IGNORE INTO bonus_music(bonus, jingle, track_name, start, loop, end, next)
                           VALUES(?, ?, ?, ?, ?, ?, ?)
                           """, (bonus, jingle, track_name, start, loop, end, next))
            
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

    conn_sub.commit()
    conn_sub.close()
    conn_main.close()