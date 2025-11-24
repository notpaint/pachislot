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

        conn.commit()


# ('小役名', "払い出し枚数", '入賞系')
role_data = [
    ('upperBell', 3, '[rep-cherry-rep]'),
    ('middleBell', 8, '[bell-bell-bell]'),
    ('downBell', 3, '[rep-bell-suica]'),
    ('Replay', 0, '[rep-rep-rep]'),
    ('Cherry', 2, '[bar-rep-rep]'),
    ('Suica', 5, '[suica-suica-suica]')
]

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

auto_slide(cursor, role_id, "L", 1)


conn.commit()
conn.close()


