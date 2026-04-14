import sqlite3
from pathlib import Path
import csv
import itertools
import json

#%%

def get_combo(L, C, R):
    return [list(x) for x in itertools.product(L, C, R)]

def create_multi_pattern(*patterns):
    
    all_combo = []

    for pattern in patterns:
        reel = []
        for design in pattern:
            if isinstance(design, str):
                reel.append([design])
            else:
                reel.append(design)
        combos = get_combo(reel[0], reel[1], reel[2])
        all_combo.extend(combos)
    
    return json.dumps(all_combo)



#%%
# ('小役名', "払い出し枚数",'リプレイ(3)or小役(2)orボーナス(1),', '入賞系', 'こぼし目')

rep_any = ["rep_1", "rep_2"]
bell_any = ["bell_1", "bell_2"]
bonus_any = ["r7", "b7", "bar"]
suica_group = ["suica", "r7", "cherry"]


role_data = [
    ('upperBell', 8, 2,
     create_multi_pattern(
         (rep_any, "cherry", rep_any),
         (rep_any, "blank", rep_any),
         (rep_any, "bar", rep_any)
         ),
     None
     ),

     ('downBell', 8, 2,
      create_multi_pattern(
          (rep_any, bell_any, "suica"),
          (rep_any, bell_any, "bar"),
          (rep_any, bell_any, "r7")
        ),
    None
    ),

    ('middleBell', 8, 2,
      create_multi_pattern(
          (bell_any, bell_any, bell_any)
      ),
     None
     ),

    ('missBell_A', 1, 2,
     create_multi_pattern(
         (rep_any, "bell_1", "bell_1")
     ),
     None
     ),

    ('missBell_B', 1, 2,
      create_multi_pattern(
          (rep_any, "bell_1", "bell_2")
      ),
      None
      ),

    ('missBell_C', 1, 2,
       create_multi_pattern(
           (rep_any, "bell_2", "bell_1")
       ),
       None
       ),

    ('missBell_D', 1, 2,
        create_multi_pattern(
            (rep_any, "bell_2", "bell_2")
        ),
        None
        ),

    ('Replay_A', 0, 3, 
      create_multi_pattern(
          (rep_any, rep_any, rep_any)
      ),
      None
      ),

    ('Replay_B', 0, 3,
       create_multi_pattern(
           (bell_any, rep_any, bell_any)
       ),
       None
       ),
    
    ("Replay_C", 0, 3,
     create_multi_pattern(
         ("suica", rep_any, rep_any)
     ),
     None
     ),
    

    ('Cherry_A', 2, 2,
       create_multi_pattern(
           ("bar", rep_any, rep_any),
           ("blank", rep_any, rep_any)
       ),
       create_multi_pattern(
           (rep_any, rep_any, bell_any),
       )
       ),

    ('downSuica', 5, 2,
     create_multi_pattern(
         (bell_any, "suica", "cherry")
     ),
     create_multi_pattern(
         (bell_any, suica_group, rep_any),
         (bell_any, "cherry", rep_any),
         (bell_any, suica_group, "cherry"),
         (bell_any, "cherry", "cherry")
     )
     ),

    ('middleSuica', 5, 2,
    create_multi_pattern(
        ("suica", "suica", "suica")
    ),
     create_multi_pattern(
         ("suica", suica_group, rep_any)
     ),
    ),

    ('BB1', 0, 1,
    create_multi_pattern(
        ("r7", "r7", "r7")
    ),
     create_multi_pattern(
        ("rep_2", "suica", "bell_2"),
        ("rep_2", "r7", bell_any),
        ("rep_2", rep_any, bonus_any),
        ("rep_2", rep_any, "suica"),
        (bell_any, "suica", "suica"),
        (bell_any, "cherry", "suica"),
        (bell_any, "r7", "suica"),
        ("r7", bell_any, rep_any)
     )
     ),

    ('RB1', 0, 1, 
     create_multi_pattern(
         ("r7", "r7", "bar")
     ),
     create_multi_pattern(
        ("rep_2", "r7", bonus_any),
        ("rep_2", rep_any, bell_any),
        ("rep_2", rep_any, "suica"),
        (bell_any, "suica", "suica"),
        (bell_any, "cherry", "suica"),
        (bell_any, "r7", "suica"),
        ("r7", bell_any, rep_any)
     )
     )
]

vac_pattern = [
    create_multi_pattern(
        (rep_any, rep_any, "r7"),
        (rep_any, rep_any, "bar"),
        (rep_any, rep_any, "blank"),
        (rep_any, rep_any, "cherry"),
        ("rep_2", "bar", "bar"),
        ("rep_2", "bar", "cherry"),
        ("rep_2", "bar", "blank"),
        ("rep_2", "r7", "bar"),
        ("rep_2", "r7", "cherry"),
        ("rep_2", "r7", "blank")
    )
]

role_pattern_priority = {
    "upperBell": {
        "default": {
            1: [
                {"reel_ID": 1, "priority": 2, "route": "valid"},
                {"reel_ID": 6, "priority": 2, "route": "valid"}
            ]
        }
    },
    "downSuica": {
        "default": {
            1: [
                {"reel_ID": 13, "priority": 2, "route": "valid"}
            ]
        },
        "BB1": {
            1: [
                {"reel_ID": 12, "priority": 2, "route": "valid"}
            ]
        }
    },
    "BB1": {
        "default": {
            1: [
                {"reel_ID": 13, "priority": 2, "route": "ghost"}
            ]
        }
    }
}




# [{'フラグ名', '確率', 'RT状態'}]
flag_data_3bet = [
    {"name": 'middleBell', "weight": 0},
    {"name": 'upperBell', "weight": 3277},
    {"name": 'downBell', 'weight': 3277},
    {"name": '321Bell', 'weight':0},
    {"name": 'Replay_A', "weight": 4000},
    {"name": 'RB1', "weight": 188},
    {"name": 'Replay_A', "weight": 4978},
    {"name": 'BB1', "weight": 188},
    {"name": 'Cherry_A', "weight": 655},
    {"name": 'downSuica', "weight": 820},
    {"name": 'vac', "weight": 13107, 'replace': {'RT1': 'Replay_A'}},
    {"name": 'vac', "weight": 35046, 'replace': {'RT1': 'Replay_A'}},
    {"name": 'Cherry_A_with_BB1', 'weight': 0}
]

flag_data_1bet = [
    {"name": 'vac', "weight": 65536}
]


flag_data_JAC = {
    "RB1" : [
        {"name": "middleBell", "weight": 65536}
    ]
}

flag_data_bet = {3: flag_data_3bet, 1: flag_data_1bet}

flag_data_normal = {
    "None": {
        "RT0": flag_data_bet,
        "RT1": flag_data_bet
    },
    "RB1": {
        "RT0" : {
        1 : flag_data_JAC["RB1"]
        }
    }
}

RT_map = {
    'BB1' : {
        "Replay_A": "vac"
    },
    'RT1' : {
        "vac" : "Replay_A"
    }
}

#('RT名', 継続ゲーム数, rank{0 = RT0, 1 = ボーナス後or入賞系無限RT, 2 = 入賞系有限RT, 3 = ボーナス成立中RT})
RT_data = {
    ('RT0', None, 0),#基底RT
    ('RT1', 30, 1),#BB1終了後RT
    ('RT2', None, 1),#入賞系無限RT
    ('RT3', 30, 2),#入賞系有限RT
    ('BB1', None, 3)#BB1成立中RT
}


JAC_BB1 = [{"weight": 65535, "JAC_type" : "RB1"}]


JAC_data = {
    'RB1' : {
        "prize_count" : 8,
        "play_count": 12,
        "play_bet": 1
    }
}

bonus_data = {
    'RB1' : {
        "max_payout" : None,
        "JACIN_type" : "RB1",
        "JAC_nums" : None,
        "before_RT" : None,
        "after_RT" : "RT0"
    },
    'BB1' : {
        "max_payout" : 4,
        "JACIN_type" : "RB1",
        "JAC_nums" : json.dumps(JAC_BB1),
        "before_RT" : "BB1",
        "after_RT" : "RT1"
    }
}

bonus_music = {
    'RB1' : {
        "start" : None,
        "loop" : None,
        "end" : None
    },
    'BB1' : {
        "start": None,
        "loop" : None,
        "end": None
    }
}

# [{"フラグ名", "重複役"}]
flag_role_map = [
    {
        "flag": "middleBell",
        "roles": ["middleBell"]
     },
    {
        "flag": "upperBell",
        "roles": ["upperBell"]
    },
    {
        "flag": "downBell",
        "roles": ["downBell"]
    },
    {
        "flag" : "321Bell",
        "roles" : ["middleBell", "missBell_A", "missBell_B", "missBell_C", "missBell_D"]
    },
    {
        "flag": "Replay_A",
        "roles": ["Replay_A"]
    },
    {
        "flag": "Cherry_A",
        "roles": ["Cherry_A"]
    },
    {
        "flag": "downSuica",
        "roles": ["downSuica"]
    },
    {
        "flag": "BB1",
        "roles": ["BB1"]

    },
    {
        "flag": "RB1",
        "roles": ["RB1"]
    },
    {
        "flag": "Cherry_A_with_BB1",
        "roles": ["Cherry_A", "BB1"]
    }
]

flag_role_priority = {
    "321Bell" : {
        "default" : [1, 1, 0]
    }
}


HUD_role_data = {
    "upperBell": {"name": "上段ベル"}
}

HUD_flag_data = {
    "middleBell": "中段ベル",
    "upperBell": "上段ベル",
    "Replay_A": "中段リプレイ",
    "Cherry_A": "弱チェリー",
    "downSuica": "右下がりスイカ",
    "BB1": "BB1",
    "RB1": "RB1",
    "Cherry_A_with_BB1": "弱チェリー+BB1"
}



#%%

dir = Path(__file__).resolve().parent
csv_dir = dir / "csv"
sql_path = dir / "sql" / "database_v2.sql"
db_path = dir / "db" / "database_v2.db"

slide_map_csv = csv_dir / "control_map.csv"

reel_csv = {
    0: csv_dir / "L_slide.csv",
    1: csv_dir / "C_slide.csv",
    2: csv_dir / "R_slide.csv"
}

#現在のフラグの内訳を表示
def check():
    total = sum(d["weight"] for d in flag_data_3bet if d["name"])
    print(f"現在の合計:{total}")
    print(f"残り変数:{65536 - total}")
    table = {}
    for d in flag_data_3bet:
        name = d["name"]
        w = d["weight"]

        if name in table:
            table[name] += w
        else:
            table[name] = w

    for x, y in table.items():
        if y > 0:
            table[x] = round((65536 / y), 1)

    print(table)


#タグ付け
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

def generate_flag_table(cursor):
    for bonus_state, RT_list in flag_data_normal.items():
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
                

def generate_flag_HUD(cursor):
    for flag, flag_name in HUD_flag_data.items():
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

def generate_control_table(cursor):
    cursor.executemany("""
                       INSERT INTO roles (role, payout, kind, pattern, miss_pattern)
                       VALUES (?, ?, ?, ?, ?)
                       """, role_data)
    
    cursor.execute("SELECT role,id FROM roles")

    role_dict = dict(cursor.fetchall())
    control_map = load_control_map(slide_map_csv)

    for reel_pos, csv_path in reel_csv.items():

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

def generate_role_pattern_priority(cursor):
    for role, bonus_data in role_pattern_priority.items():
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


def generate_flag_role_map(cursor):
    for data in flag_role_map:
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

def generate_flag_role_priority(cursor):
    for flag, bonus_data in flag_role_priority.items():
        cursor.execute("SELECT id FROM flags WHERE flag = (?)", (flag,))
        flag_row = cursor.fetchone()
        if flag_row is None:
            print(f"ERROR ON generate_flag_role_priority(): {flag} DOES NOT EXIST")
            continue
        flag_ID = flag_row[0]
        for bonus, reel_data in bonus_data.items():
            bonus_state = bonus
            for reel_pos, priority in enumerate(reel_data):
                cursor.execute("""
                               INSERT OR IGNORE INTO flag_role_priority (flag_ID, bonus_state, reel_pos, priority)
                               VALUES(?, ?, ?, ?)""", (flag_ID, bonus_state, reel_pos, priority))

def generate_reel_table(cursor):
    csv_path = csv_dir / "reel_table.csv"
    reel_table = load_reel_csv(csv_path)
    for reel_pos, item in enumerate(reel_table):
        for reel_ID, design in enumerate(item):
            cursor.execute("""INSERT OR IGNORE INTO reel_table (reel_pos, reel_id, reel_design)
                           VALUES (?, ?, ?)""", (reel_pos, reel_ID, design))


def generate_JAC_data(cursor):
    for name, data in JAC_data.items():
        prize_count = data["prize_count"]
        play_count = data["play_count"]
        play_bet = data["play_bet"]
        cursor.execute("""INSERT OR IGNORE INTO JAC_data (name, prize_count, play_count, play_bet)
                       VALUES (?, ?, ?, ?)""", (name, prize_count, play_count, play_bet))


def generate_bonus_data(cursor):
    for name, data in bonus_data.items():
        max_payout = data["max_payout"]
        JACIN_type = data["JACIN_type"]
        JAC_nums = data["JAC_nums"]
        before_RT = data["before_RT"]
        after_RT = data["after_RT"]
        cursor.execute("""INSERT OR IGNORE INTO bonus_data (name, max_payout, JACIN_type, JAC_nums, before_RT, after_RT)
                       VALUES (?, ?, ?, ?, ?, ?)""", (name, max_payout, JACIN_type, JAC_nums, before_RT, after_RT))


def generate_RT_data(cursor):
    cursor.executemany("""INSERT OR IGNORE INTO RT_data (name, game, type)
                    VALUES (?, ?, ?)""", (RT_data))
    

def generate_vac_pattern(cursor):
    cursor.execute("""INSERT INTO vac_pattern (pattern) VALUES (?)""", vac_pattern)

#%%

if __name__=="__main__":

    dir = Path(__file__).resolve().parent
    csv_dir = dir / "csv"
    sql_path = dir / "sql" / "database_v2.sql"
    db_path = dir / "db" / "database_v2.db"

    if db_path.exists():
        try:
            print("初期化完了")
            db_path.unlink()
        except PermissionError:
            print("他のプログラムが使用中")
            exit()

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    with sql_path.open("r", encoding="UTF-8") as f:
        conn.executescript(f.read())
    
    generate_control_table(cursor)
    generate_role_pattern_priority(cursor)
    generate_flag_table(cursor)
    generate_flag_role_map(cursor)
    generate_flag_role_priority(cursor)
    generate_reel_table(cursor)
    generate_JAC_data(cursor)
    generate_bonus_data(cursor)
    generate_RT_data(cursor)
    generate_flag_HUD(cursor)
    generate_vac_pattern(cursor)

    conn.commit()
    conn.close()
