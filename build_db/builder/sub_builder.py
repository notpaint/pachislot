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

            cursor_sub.execute("""INSERT OR IGNORE INTO bonus_music(bonus, jingle, rule, track_name, start, end)
                           VALUES(?, ?, ?, ?, ?, ?)
                           """, (bonus, jingle, rule, track_name, start, end))
            
def generate_back_music(cursor_sub, config):
    for track, path in config.back_music.items():
        cursor_sub.execute("""INSERT OR IGNORE INTO back_music(track, path)
                           VALUES(?, ?)""", (track, path))
            
            
def generate_flag_trigger(cursor_main, cursor_sub, config):
    for flag, type_data in config.flag_trigger.items():
        cursor_main.execute("SELECT flag from flags WHERE flag = (?)", (flag,))
        if cursor_main.fetchone() is None:
            print(f"ERROR on generate_flag_trigger: {flag} does not exists in main.db")
            continue
        for type, state_data in type_data.items():
            for state, weight in state_data.items():
                cursor_sub.execute("""INSERT OR IGNORE INTO flag_trigger(flag, type, state, weight)
                                VALUES(?, ?, ?, ?)""", (flag, type, state, weight))
            
def generate_pseudo_bonus_mode(cursor_sub, config):
    for mode in config.pseudo_bonus_mode.keys():
        cursor_sub.execute("INSERT OR IGNORE INTO mode_list(mode) VALUES(?)", (mode,))

    for mode, data in config.pseudo_bonus_mode.items():
        cursor_sub.execute("SELECT id FROM mode_list WHERE mode = (?)", (mode,))
        mode_id = cursor_sub.fetchone()[0]

        release_data = data.get("release")
        for game, info in release_data.items():
            weight = info.get("weight", 0)
            premonition = info.get("premonition", 256)
            cursor_sub.execute("""INSERT OR IGNORE INTO mode_release(mode_id, game, weight, premonition)
                               VALUES(?, ?, ?, ?)""", (mode_id, game, weight, premonition))
        
        map_data = data.get("map")
        for next_mode, weight in map_data.items():
            cursor_sub.execute("SELECT id FROM mode_list WHERE mode = (?)", (next_mode,))
            next_mode_id = cursor_sub.fetchone()[0]
            cursor_sub.execute("""INSERT OR IGNORE INTO mode_map(mode_id, next_mode_id, weight)
                               VALUES(?, ?, ?)""", (mode_id, next_mode_id, weight))
            
        ratio_data = data.get("ratio")
        for bonus, weight in ratio_data.items():
                cursor_sub.execute("""INSERT OR IGNORE INTO mode_ratio(mode_id, bonus, weight)
                                VALUES(?, ?, ?)""", (mode_id, bonus, weight))

def generate_premonition_map(cursor_main, cursor_sub, config):
    for type, trigger_data in config.premonition_map.items():
        for trigger, flag_data in trigger_data.items():
            for flag, target_data in flag_data.items():
                if flag != "default":
                    cursor_main.execute("SELECT id from flags WHERE flag = (?)", (flag,))
                    if cursor_main.fetchone() is None:
                        print(f"ERROR ON generate_premonition_map: {flag} does not exists in main.db")
                for target, game_data in target_data.items():
                    is_win = 1 if target == "win" else 0
                    for game, weight in game_data.items():
                        cursor_sub.execute("""INSERT OR IGNORE INTO premonition_map
                                           (type, trigger, flag, is_win, game, weight)
                                           VALUES
                                           (?, ?, ?, ?, ?, ?)""", (type, trigger, flag, is_win, game, weight))


            
def generate_env(cursor_sub, config):
    for name, data in config.env.items():
        if isinstance(data, (list,dict)):
            db_data = json.dumps(data)
        else:
            db_data = data
        cursor_sub.execute("""INSERT OR IGNORE INTO env(name, data) VALUES(?, ?)""", (name, db_data))

            
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
    generate_back_music(cursor_sub, config)
    generate_SE(cursor_sub, config)
    generate_env(cursor_sub, config)
    generate_flag_trigger(cursor_main, cursor_sub, config)
    generate_pseudo_bonus_mode(cursor_sub, config)
    generate_premonition_map(cursor_main, cursor_sub, config)

    conn_sub.commit()
    conn_sub.close()
    conn_main.close()