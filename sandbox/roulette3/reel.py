import sqlite3
import os

#%%
# ('小役名', "払い出し枚数", '入賞系')
role_data = [
    ('upperBell', 3, '[rep-cherry-rep]'),
    ('middleBell', 8, '[bell-bell-bell]'),
    ('downBell', 3, '[rep-bell-suica]'),
    ('Replay', 0, '[rep-rep-rep]'),
    ('Cherry', 2, '[bar-rep-rep]'),
    ('Suica', 5, '[suica-suica-suica]')
]

# ('フラグ名', '確率', '状態') [通常時]
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

JAC_data = {
    "RB1" : [
        {"name": "Bell", "weight": 65536}
    ]
}

#%%

#現在のフラグの内訳を表示
def check():
    total = sum(d["weight"] for d in flag_data_normal if d["flag_name"])
    print(f"現在の合計:{total}")
    print(f"残り変数:{65536 - total}")
    table = {}
    for d in flag_data_normal:
        name = d["flag_name"]
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
    

#スベリ代入自動化(α)
def auto_slide(cursor, role_ID, reel_pos, target_index):
    for slide_num in range(5):
        stop_index = (target_index - slide_num) % 5

        sql = """
            UPDATE slides
            SET slide = ?
            WHERE role_ID = ?
            AND reel_pos = ?
            AND reel_ID =?
            """

        cursor.execute(sql, (slide_num, role_ID, reel_pos, stop_index))

#%%

# def generate_flag_table(cursor):
#     flag_data = {}
#     flag_data["Normal"] = generate_flag_list(flag_data_normal)
#     for x,y in JAC_data.items():
#         flag_data[x] = y
#     for status, weights in flag_data.items():
#         cursor.execute("""
#                        INSERT OR IGNORE INTO weight_status (weight_state)
#                        VALUES (?)""", (status,))
#         cursor.execute("""
#                        SELECT id FROM weight_status
#                        WHERE weight_state = (?)""", (status,))
#         state_id = cursor.fetchone()[0]

#         for item in weights:
#             name = item["name"]
#             weight = item["weight"]
#             cursor.execute("""
#                            INSERT OR IGNORE INTO flags (flag)
#                            VALUES (?)""", (name,))
#             cursor.execute("""
#                            SELECT id FROM flags
#                            WHERE flag = (?)""", (name,))
#             flag_id = cursor.fetchone()[0]

#             cursor.execute("""
#                            INSERT INTO flag_table (weight_status_id, flag_id, weight)
#                            VALUES (?, ?, ?)""", (state_id, flag_id, weight))


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


flag_data = {}
flag_data["Normal"] = generate_flag_list(flag_data_normal)
for x,y in JAC_data.items():
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
                        INSERT INTO flag_table (weight_status_id, flag_id, weight)
                        VALUES (?, ?, ?)""", (state_id, flag_id, weight))


cursor.executemany("INSERT INTO roles (name, payout, pattern) VALUES (?, ?, ?)", role_data)

cursor.execute("""
               INSERT INTO slides (role_id, reel_pos, reel_ID, slide)
               SELECT r.id, p.reel_pos, i.reel_ID, 0
               FROM roles AS r
               CROSS JOIN reel_poses AS p
               CROSS JOIN reel_IDs AS i
               """)

cursor.execute("SELECT name, id FROM roles")
role_dict = dict(cursor.fetchall())

role_id = role_dict["middleBell"]
auto_slide(cursor, role_id, 0, 0)
role_id = role_dict["Replay"]
auto_slide(cursor, role_id, 0, 1)

conn.commit()
conn.close()

#%%