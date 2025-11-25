import sqlite3
import os

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


# ('小役名', "払い出し枚数", '入賞系')
role_data = [
    ('upperBell', 3, '[rep-cherry-rep]'),
    ('middleBell', 8, '[bell-bell-bell]'),
    ('downBell', 3, '[rep-bell-suica]'),
    ('Replay', 0, '[rep-rep-rep]'),
    ('Cherry', 2, '[bar-rep-rep]'),
    ('Suica', 5, '[suica-suica-suica]')
]

#%%
# ('役名', '確率', '状態')
flag_data = [
    {"flag_name": 'Bell', "weight": 13107},
    {"flag_name": 'Replay_A', "weight": 4000},
    {"flag_name": 'vac', "weight": 10000},
    {"flag_name": 'Replay_A', "weight": 4978},
    {"flag_name": 'vac', "weight": 10000},
    {"flag_name": 'Cherry', "weight": 3300},
    {"flag_name": 'Suica', "weight": 2200},
    {"flag_name": 'vac', "weight": 17951},
]

#%%

def check():
    total = sum(d["weight"] for d in flag_data if d["flag_name"])
    print(f"現在の合計:{total}")
    print(f"残り変数:{65536 - total}")
    table = {}
    for d in flag_data:
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

#%%



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


