import sqlite3
import csv

def generate_flag_list(seq, RT_mode = None):
    flag_list = []
    for item in seq:
        name = item["name"]
        weight = item["weight"]
        replace = item.get("replace", {})
        if RT_mode is not None and RT_mode in replace:
            name = replace[RT_mode]
        flag_list.append({"name": name, "weight": weight})
    return flag_list

def load_reel_csv(csv_path):

    reel_table = [[],[],[]]

    with open(csv_path, "r", encoding="UTF-8-SIG") as f:
        reader = csv.DictReader(f)

        rows = list(reader)

        for row in reversed(rows):
            for val, name in row.items():
                if val == "reel_ID": continue
                reel_pos = int(val)
                flag = name
                reel_table[reel_pos].append(flag)
    
    return(reel_table)

def load_slide_csv(csv_path, reel_pos):

    slide_list = []

    with open(csv_path, "r", encoding="UTF-8-SIG") as f:
        reader = csv.DictReader(f)

        rows = list(reader)

        slide_data = {}

        for row in reversed(rows):
            for name, val in row.items():
                if name == "reel_ID": continue
                if name.startswith("#"): continue

                if name not in slide_data:
                    slide_data[name] = []
                
                try:
                    slide_data[name].append(int(val))
                except:
                    print("error")
        
        for name, val in slide_data.items():
            slide_list.append(
                {"name" : name,
                 "reel_pos" : reel_pos,
                 "target" : val
                 }
            )

    return(slide_list)

def load_control_map(csv_path):
    mapping = {}
    with open(csv_path, "r", encoding="UTF-8-SIG") as f:
        reader = csv.DictReader(f)
        for row in reader:
            role = (row.get("role") or "").strip()
            if not role or role.startswith("#"): continue

            mapping[role] = {
                0: row["L_reel"].strip(),
                1: row["C_reel"].strip(),
                2: row["R_reel"].strip()
            }
    return mapping

                

def apply_control_table(cursor, role_ID, reel_pos, slides):
    for reel_ID, slide in enumerate(slides):
        cursor.execute("""INSERT INTO control_table (role_id, reel_pos, reel_ID, slide)
                       VALUES (?, ?, ?, ?)
                       """, (role_ID, reel_pos, reel_ID, slide))

def apply_vac_control_table(cursor, reel_pos, slides):
    for reel_ID, slide in enumerate(slides):
        cursor.execute("""INSERT INTO vac_control_table (reel_pos, reel_ID, slide)
                       VALUES (?, ?, ?)
                       """, (reel_pos, reel_ID, slide))


#%%

def generate_flag_table(cursor, config):
    for bonus_state, RT_list in config.flag_data_normal.items():
        for RT_state, bet_list in RT_list.items():
            for bet_state, weights in bet_list.items():
                if RT_state != "None":
                    current_RT = RT_state
                else:
                    current_RT = None
                final_flags = generate_flag_list(weights, RT_mode = current_RT)

                for item in final_flags:
                    name = item["name"]
                    weight = item["weight"]
                    cursor.execute("INSERT OR IGNORE INTO flags (flag) VALUES (?)", (name,))
                    cursor.execute("SELECT id FROM flags WHERE flag = (?)", (name,))
                    flag_id = cursor.fetchone()[0]

                    cursor.execute("""
                                   INSERT OR IGNORE INTO flag_table 
                                   (bonus_state, RT_state, bet_state, flag_id, weight)
                                   VALUES (?, ?, ?, ? ,?)
                                   """, (bonus_state, RT_state, bet_state, flag_id, weight))
                

def generate_flag_HUD(cursor, config):
    for flag, flag_name in config.HUD_flag_data.items():
        cursor.execute("SELECT id FROM flags WHERE flag = (?)", (flag,))
        flag_row = cursor.fetchone()
        if flag_row is None:
            print(f"ERROR ON generate_flag_HUD() : {flag} DOES NOT EXIST IN flags")
            continue
        flag_ID = flag_row[0]
        cursor.execute("""
                       INSERT OR IGNORE INTO flag_HUD (flag_ID, flag_name)
                       VALUES (?, ?)
                       """, (flag_ID, flag_name))

def generate_control_table(cursor, config):
    cursor.executemany("""
                       INSERT INTO roles (role, payout, kind, pattern, miss_pattern)
                       VALUES (?, ?, ?, ?, ?)
                       """, config.role_data)
    
    cursor.execute("SELECT role,id FROM roles")

    role_dict = dict(cursor.fetchall())
    control_map = load_control_map(config.slide_map_csv)

    for reel_pos, csv_path in config.reel_csv.items():

        slide_list = load_slide_csv(csv_path, reel_pos)

        slide_dict = {}
        for item in slide_list:
            slide_dict[item["name"]] = item["target"]
        
        for role, reel in control_map.items():
            role_control = reel[reel_pos]
            if role_control not in slide_dict:
                print(f"ERROR ON generate_control_table() : {role_control} DOES NOT EXIST IN {reel_pos}, {role}")
                continue
            slide = slide_dict[role_control]

            if role == "vac":
                apply_vac_control_table(cursor, reel_pos, slide)
                continue

            if role not in role_dict:
                print(f"ERROR ON generate_control_table() : {role} DOES NOT EXIST")
                continue

            role_id = role_dict[role]
            apply_control_table(cursor, role_id, reel_pos, slide)

def generate_role_pattern_priority(cursor, config):
    for role, bonus_data in config.role_pattern_priority.items():
        cursor.execute("SELECT id FROM roles WHERE role = (?)", (role,))
        role_row = cursor.fetchone()
        if role_row is None:
            print(f"ERROR ON generate_role_pattern_priority() : {role} DOES NOT EXIST")
            continue
        role_id = role_row[0]
        for bonus, reel_data in bonus_data.items():
            bonus_state = bonus
            for reel, data in reel_data.items():
                reel_pos = int(reel)
                for item in data:
                    reel_ID = int(item["reel_ID"])
                    priority = int(item["priority"])
                    route = item["route"]
                    cursor.execute("""
                                   INSERT OR IGNORE INTO role_pattern_priority (role_id, bonus_state, reel_pos, reel_ID, priority, route)
                                   VALUES (? ,?, ?, ? ,? ,?)
                                   """, (role_id, bonus_state, reel_pos, reel_ID, priority, route))


def generate_flag_role_map(cursor, config):
    for data in config.flag_role_map:
        flag = data["flag"]
        roles = data["roles"]
        cursor.execute("SELECT id FROM flags WHERE flag = (?)", (flag,))
        flag_row = cursor.fetchone()
        if flag_row is None:
            print(f"ERROR ON generate_flag_role_map() : {flag} DOES NOT EXIST")
            continue
        flag_ID = flag_row[0]
        for role in roles:
            cursor.execute("SELECT id FROM roles WHERE role = (?)", (role,))
            role_row = cursor.fetchone()
            if role_row is None:
                print(f"ERROR ON generate_flag_role_map() : {role} DOES NOT EXIST")
                continue
            role_ID = role_row[0]
            cursor.execute("""
                           INSERT OR IGNORE INTO flag_role_map (flag_ID, role_ID)
                           VALUES (?, ?)""", (flag_ID, role_ID))   


def generate_flag_combo_priority(cursor, config):
    for flag, bonus_data in config.flag_combo_priority.items():
        cursor.execute("SELECT id FROM flags WHERE flag = (?)", (flag,))
        flag_row = cursor.fetchone()
        if flag_row is None:
            print(f"ERROR ON generate_flag_combo_priority(): {flag} DOES NOT EXIST")
            continue
        flag_ID = flag_row[0]
        for bonus, reel_data in bonus_data.items():
            bonus_state = bonus
            for reel_pos, priority in enumerate(reel_data):
                cursor.execute("""
                               INSERT OR IGNORE INTO flag_combo_priority (flag_ID, bonus_state, reel_pos, priority)
                               VALUES(?, ?, ?, ?)""", (flag_ID, bonus_state, reel_pos, priority))


def generate_flag_role_priority(cursor, config):
    for flag, bonus_data in config.flag_role_priority.items():
        cursor.execute("SELECT id FROM flags WHERE flag = (?)", (flag,))
        flag_row = cursor.fetchone()
        if flag_row is None:
            print(f"ERROR ON generate_flag_role_priority(): {flag} DOES NOT EXIST")
            continue
        flag_ID = flag_row[0]
        for bonus, reel_data in bonus_data.items():
            bonus_state = bonus
            for reel, role_data in reel_data.items():
                reel_pos = reel
                for role, priority in role_data.items():
                    cursor.execute("SELECT id FROM roles WHERE role = (?)", (role,))
                    role_row = cursor.fetchone()
                    if role_row is None:
                        print(f"ERROR ON generate_flag_role_priority(): {role} DOES NOT EXIST")
                        continue
                    role_ID = role_row[0]
                    cursor.execute("""
                                   INSERT OR IGNORE INTO flag_role_priority (flag_ID, bonus_state, reel_pos, role_ID, priority)
                                   VALUES(?, ?, ?, ?, ?)""", (flag_ID, bonus_state, reel_pos, role_ID, priority))

def generate_reel_table(cursor, config):
    csv_path = config.csv_path / "reel_table.csv"
    reel_table = load_reel_csv(csv_path)
    for reel_pos, item in enumerate(reel_table):
        for reel_ID, design in enumerate(item):
            cursor.execute("""INSERT OR IGNORE INTO reel_table (reel_pos, reel_id, reel_design)
                           VALUES (?, ?, ?)""", (reel_pos, reel_ID, design))


def generate_JAC_data(cursor, config):
    for name, data in config.JAC_data.items():
        prize_count = data["prize_count"]
        play_count = data["play_count"]
        play_bet = data["play_bet"]
        cursor.execute("""INSERT OR IGNORE INTO JAC_data (name, prize_count, play_count, play_bet)
                       VALUES (?, ?, ?, ?)""", (name, prize_count, play_count, play_bet))


def generate_bonus_data(cursor, config):
    for name, data in config.bonus_data.items():
        max_payout = data["max_payout"]
        JACIN_type = data["JACIN_type"]
        JAC_nums = data["JAC_nums"]
        before_RT = data["before_RT"]
        present_RT = data["present_RT"]
        after_RT = data["after_RT"]
        cursor.execute("""INSERT OR IGNORE INTO bonus_data (name, max_payout, JACIN_type, JAC_nums, before_RT, present_RT, after_RT)
                       VALUES (?, ?, ?, ?, ?, ?, ?)""", (name, max_payout, JACIN_type, JAC_nums, before_RT, present_RT, after_RT))


def generate_RT_data(cursor, config):
    cursor.executemany("""INSERT OR IGNORE INTO RT_data (name, game, type)
                    VALUES (?, ?, ?)""", config.RT_data)
    
def generate_RT_pattern(cursor, config):
    for RT, patterns in config.RT_pattern.items():
        cursor.execute("SELECT id FROM RT_data WHERE name = (?)", (RT,))
        RT_row = cursor.fetchone()
        if RT_row is None:
            print(f"ERROR")
            continue
        RT_id = RT_row[0]
        for pattern in patterns:
            cursor.execute("""INSERT OR IGNORE INTO RT_pattern (RT_id, pattern)
                        VALUES (?, ?)""", (RT_id, pattern))
        

def generate_vac_pattern(cursor, config):
    cursor.execute("""INSERT INTO vac_pattern (pattern) VALUES (?)""", config.vac_pattern)

def build_main(config):
    config.main_db_path.parent.mkdir(parents=True, exist_ok=True)

    if config.main_db_path.exists():
        config.main_db_path.unlink()

    conn = sqlite3.connect(config.main_db_path)
    cursor = conn.cursor()

    with config.main_sql_path.open("r", encoding="UTF-8") as f:
        conn.executescript(f.read())

    generate_flag_table(cursor, config)
    generate_flag_HUD(cursor, config)
    generate_control_table(cursor, config)
    generate_flag_role_map(cursor, config)
    generate_flag_combo_priority(cursor, config)
    generate_flag_role_priority(cursor, config)
    generate_role_pattern_priority(cursor, config)
    generate_reel_table(cursor, config)
    generate_JAC_data(cursor, config)
    generate_bonus_data(cursor, config)
    generate_RT_data(cursor, config)
    generate_RT_pattern(cursor, config)
    generate_vac_pattern(cursor, config)

    conn.commit()
    conn.close()
