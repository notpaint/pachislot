import sqlite3
import os
import csv

#%%
# ('小役名', "払い出し枚数",'小役(N)orリプレイ(R)orボーナス(B),' '入賞系')
role_data = [
    ('upperBell', 3, "N", '[rep-cherry-rep]'),
    ('middleBell', 8, "N", '[bell-bell-bell]'),
    ('downBell', 3, "N", '[rep-bell-suica]'),
    ('Replay', 0, "R", '[rep-rep-rep]'),
    ('Cherry', 2, "N", '[bar-rep-rep]'),
    ('Suica', 5, "N", '[suica-suica-suica]')
]

# [{'フラグ名', '確率'}]
flag_data_normal = [
    {"name": 'Bell', "weight": 13107},
    {"name": 'Replay_A', "weight": 4000},
    {"name": 'vac', "weight": 10000},
    {"name": 'Replay_A', "weight": 4978},
    {"name": 'vac', "weight": 10000},
    {"name": 'Cherry', "weight": 3300},
    {"name": 'Suica', "weight": 2200},
    {"name": 'vac', "weight": 17951}
]

flag_data_JAC = {
    "RB1" : [
        {"name": "Bell", "weight": 65536}
    ]
}

# [{"フラグ名", "重複役"}]
flag_role_map = [
    {
        "flag": "Bell",
        "roles": ["middleBell","upperBell"]
     },
    {
        "flag": "Replay_A",
        "roles": ["Replay"]
    },
    {
        "flag": "Cherry",
        "roles": ["Cherry"]
    },
    {
        "flag": "Suica",
        "roles": ["Suica"]
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
def generate_flag_list(seq):
    flag_list = []
    for item in seq:
        name = item["name"]
        weight = item["weight"]
        flag_list.append({"name": name, "weight": weight})
    return flag_list
    

def load_slide_csv(csv_path, reel_pos):

    slide_list = []

    with open(csv_path, "r", encoding="UTF-8-SIG") as f:
        reader = csv.DictReader(f)

        slide_data = {}

        for row in reader:
            for name, val in row.items():
                if name == "reel_ID": continue 

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
    print(slide_list)
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
    flag_data["Normal"] = generate_flag_list(flag_data_normal)
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
                       INSERT INTO roles (role, payout, kind, pattern)
                       VALUES (?, ?, ?, ?)
                       """, role_data)
    
    cursor.execute("SELECT role,id FROM roles")
    role_dict = dict(cursor.fetchall())

    for reel_pos, csv_file in reel_csv.items():
        dir = os.path.dirname(__file__)
        csv_path = os.path.join(dir, csv_file)
        slide_list = load_slide_csv(csv_path, reel_pos)
        for item in slide_list:
            name = item["name"]
            reel_pos = item["reel_pos"]
            target = item["target"]
            if name in role_dict:
                role_id = role_dict[name]
                apply_control_table(cursor, role_id, reel_pos, target)
            elif name =="vac":
                apply_vac_control(cursor, reel_pos, target)
            else:
                print(f"ERROR ON generate_control_table() : {name} IS NOT EXIST")


def generate_flag_role_map(cursor):
    for data in flag_role_map:
        flag = data["flag"]
        roles = data["roles"]
        cursor.execute("SELECT id FROM flags WHERE flag = (?)", (flag,))
        flag_row = cursor.fetchone()
        if flag_row is None:
            print(f"ERROR ON generate_flag_role_map() : {flag} IS DO NOT EXIST")
            continue
        flag_ID = flag_row[0]
        for role in roles:
            cursor.execute("SELECT id FROM roles WHERE role = (?)", (role,))
            role_row = cursor.fetchone()
            if role_row is None:
                print(f"ERROR ON generate_flag_role_map() : {role} IS DO NOT EXIST")
                continue
            role_ID = role_row[0]
            cursor.execute("""
                           INSERT OR IGNORE INTO flag_role_map (flag_ID, role_ID)
                           VALUES (?, ?)""", (flag_ID, role_ID))   



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
    
    conn.commit()
    conn.close()
