import sqlite3
import os
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
    ('upperBell', 3, 2,
     create_multi_pattern(
         (rep_any, "cherry", rep_any),
         (rep_any, "blank", rep_any),
         (rep_any, "bar", rep_any)
         ),
     '[]'
     ),

    ('middleBell', 8, 2,
      create_multi_pattern(
          (bell_any, bell_any, bell_any)
      ),
     '[]'
     ),

     ('Replay_A', 0, 3, 
      create_multi_pattern(
          (rep_any, rep_any, rep_any)
      ),
      '[]'
      ),

      ('Replay_B', 0, 3,
       create_multi_pattern(
           (bell_any, "suica", bell_any),
           (bell_any, "cherry", bell_any),
           (bell_any, "r7", bell_any)
       ),
       '[]'
       ),

      ('Cherry', 2, 2,
       create_multi_pattern(
           ("bar", bell_any, bell_any),
           ("blank", bell_any, bell_any)
       ),
       create_multi_pattern(
           (bonus_any, bell_any, bell_any),
           ("suica", bell_any, bell_any)
       )
       ),

    ('downSuica', 5, 2,
     create_multi_pattern(
         (bell_any, "suica", "cherry")
     ),
     create_multi_pattern(
         (bell_any, suica_group, rep_any)
     )
     ),

    ('middleSuica', 5, 2,
    '[["suica", "suica", "suica"]]',
     create_multi_pattern(
         ("suica", suica_group, rep_any)
     ),
    ),

    ('BB1', 0, 1,
    '[["r7", "r7", "r7"]]',
     create_multi_pattern(
        ("rep_2", "suica", "bell_2"),
        ("rep_2", bonus_any, bell_any),
        ("rep_2", rep_any, bonus_any),
        ("rep_2", rep_any, "suica"),
        (bell_any, "suica", "suica"),
        (bell_any, "cherry", "suica"),
        (bell_any, "r7", "suica"),
        ("r7", rep_any, bell_any)
     )
     ),

    ('RB1', 0, 1, 
    '[["r7", "r7", "bar"]]',
     create_multi_pattern(
        ("rep_2", bonus_any, bonus_any),
        ("rep_2", rep_any, bell_any),
        ("rep_2", rep_any, "suica"),
        (bell_any, "suica", "suica"),
        (bell_any, "cherry", "suica"),
        (bell_any, "r7", "suica"),
        ("r7", rep_any, rep_any)
     )
     )
]


# [{'フラグ名', '確率', 'RT状態'}]
flag_data_normal = [
    {"name": 'middleBell', "weight": 6554},
    {"name": 'upperBell', "weight": 6553},
    {"name": 'Replay_A', "weight": 4000, 'RT': 'BB1'},
    {"name": 'RB1', "weight": 10000},
    {"name": 'Replay_A', "weight": 4978, 'RT': 'BB1'},
    {"name": 'BB1', "weight": 10000},
    {"name": 'Cherry', "weight": 3300},
    {"name": 'Suica', "weight": 2200},
    {"name": 'vac', "weight": 13107, 'RT': 'RT1'},
    {"name": 'vac', "weight": 4844, 'RT': 'RT1'}
]


flag_data_JAC = {
    "JAC1" : [
        {"name": "middleBell", "weight": 65536}
    ]
}


RT_map = {
    'BB1' : {
        "Replay_A": "vac"
    },
    'RT1' : {
        "vac" : "Replay_A"
    }
}

#('RT名', 継続ゲーム数, rank{0 = RT0, 1 = ボーナス中orボーナス後or入賞系無限RT, 2 = 入賞系有限RT, 3 = ボーナス成立中RT})
RT_data = {
    ('RT0', None, 0),
    ('RT1', 30, 1),
    ('BB1', None, 1)
}


JAC_BB1 = [{"weight": 65535, "JAC_type" : "JAC1"}]


JAC_data = {
    'JAC1' : {
        "prize_count" : 8,
        "play_count": 12
    }
}

bonus_data = {
    'RB1' : {
        "max_payout" : None,
        "JACIN_type" : "JAC1",
        "JAC_nums" : None,
        "before_RT" : None,
        "after_RT" : None
    },
    'BB1' : {
        "max_payout" : 2,
        "JACIN_type" : "JAC1",
        "JAC_nums" : json.dumps(JAC_BB1),
        "before_RT" : None,
        "after_RT" : "RT1"
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
        "flag": "Replay_A",
        "roles": ["Replay_A"]
    },
    {
        "flag": "Cherry",
        "roles": ["Cherry"]
    },
    {
        "flag": "Suica",
        "roles": ["downSuica"]
    },
    {
        "flag": "BB1",
        "roles": ["BB1"]

    },
    {
        "flag": "RB1",
        "roles": ["RB1"]
    }
]

#%%

reel_csv = {
    0: "L_slide.csv",
    1: "C_slide.csv",
    2: "R_slide.csv"
}

#現在のフラグの内訳を表示
def check():
    total = sum(d["weight"] for d in flag_data_normal if d["name"])
    print(f"現在の合計:{total}")
    print(f"残り変数:{65536 - total}")
    table = {}
    for d in flag_data_normal:
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
        tag = item.get("RT")
        if RT_mode is not None and tag in RT_map and tag == RT_mode:
            mode = RT_map[tag]
            if name in mode:
                name = mode[name]
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

def apply_control_table(cursor, role_ID, reel_pos, slides):
    for reel_ID, slide in enumerate(slides):
        cursor.execute("""INSERT INTO control_table (role_id, reel_pos, reel_ID, slide)
                       VALUES (?, ?, ?, ?)
                       """, (role_ID, reel_pos, reel_ID, slide))

def apply_vac_control(cursor, reel_pos, slides):
    for reel_ID, slide in enumerate(slides):
        cursor.execute("""INSERT INTO vac_control (reel_pos, reel_ID, slide)
                       VALUES (?, ?, ?)
                       """, (reel_pos, reel_ID, slide))


#%%

def generate_flag_table(cursor):
    flag_data = {}
    flag_data["RT0"] = generate_flag_list(flag_data_normal, RT_mode = None)
    flag_data["BB1"] = generate_flag_list(flag_data_normal, RT_mode = "BB1")
    flag_data["RT1"] = generate_flag_list(flag_data_normal, RT_mode = "RT1")
    for x,y in flag_data_JAC.items():
        flag_data[x] = y
    for status, weights in flag_data.items():
        cursor.execute("""
                       INSERT OR IGNORE INTO weight_status (weight_state)
                       VALUES (?)""", (status,))
        cursor.execute("""
                       SELECT id FROM weight_status
                       WHERE weight_state = (?)""", (status,))
        state_id = cursor.fetchone()[0]
        for item in weights:
            name = item["name"]
            weight = item["weight"]
            cursor.execute("""
                           INSERT OR IGNORE INTO flags (flag)
                           VALUES (?)""", (name,))
            cursor.execute("""
                           SELECT id FROM flags
                           WHERE flag = (?)""", (name,))
            flag_id = cursor.fetchone()[0]

            cursor.execute("""
                           INSERT OR IGNORE INTO flag_table (weight_status_id, flag_id, weight)
                           VALUES (?, ?, ?)""", (state_id, flag_id, weight))


def generate_control_table(cursor):
    cursor.executemany("""
                       INSERT INTO roles (role, payout, kind, pattern, miss_pattern)
                       VALUES (?, ?, ?, ?, ?)
                       """, role_data)
    
    cursor.execute("SELECT role,id FROM roles")

    role_dict = dict(cursor.fetchall())

    for reel_pos, csv_file in reel_csv.items():
        dir = os.path.dirname(__file__)
        csv_path = os.path.join(dir, csv_file)
        slide_list = load_slide_csv(csv_path, reel_pos)
        for item in slide_list:
            role_id_list = []
            name = item["name"]
            reel_pos = item["reel_pos"]
            target = item["target"]
            if name in role_dict:
                role_id_list.append(role_dict[name])
            if role_id_list:
                for role_id in role_id_list:
                   apply_control_table(cursor, role_id, reel_pos, target) 
            elif name =="vac":
                apply_vac_control(cursor, reel_pos, target)
            else:
                print(f"ERROR ON generate_control_table() : {name} DOES EXIST")


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


def generate_reel_table(cursor):
    dir = os.path.dirname(__file__)
    csv_path = os.path.join(dir, "reel_table.csv")
    reel_table = load_reel_csv(csv_path)
    for reel_pos, item in enumerate(reel_table):
        for reel_ID, design in enumerate(item):
            cursor.execute("""INSERT OR IGNORE INTO reel_table (reel_pos, reel_id, reel_design)
                           VALUES (?, ?, ?)""", (reel_pos, reel_ID, design))


def generate_JAC_data(cursor):
    for name, data in JAC_data.items():
        prize_count = data["prize_count"]
        play_count = data["play_count"]
        cursor.execute("""INSERT OR IGNORE INTO JAC_data (name, prize_count, play_count)
                       VALUES (?, ?, ?)""", (name, prize_count, play_count))


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

#%%

if __name__=="__main__":

    dir = os.path.dirname(__file__)
    sql_path = os.path.join(dir, "database_v2.sql")
    db_path = os.path.join(dir, "database_v2.db")

    if os.path.exists(db_path):
        try:
            print("初期化完了")
            os.remove(db_path)
        except PermissionError:
            print("他のプログラムが使用中")
            exit()

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    with open(sql_path, "r", encoding="UTF-8") as f:
        conn.executescript(f.read())
    generate_control_table(cursor)
    generate_flag_table(cursor)
    generate_flag_role_map(cursor)
    generate_reel_table(cursor)
    generate_JAC_data(cursor)
    generate_bonus_data(cursor)
    generate_RT_data(cursor)
    
    conn.commit()
    conn.close()
