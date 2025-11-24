import keyboard
import time
import sqlite3
import os

dir = os.path.dirname(__file__)
path1 = os.path.join(dir, "database.sql")
path2 = os.path.join(dir, "database_d.db")

loop = 0.5
stop_key = "space"
exit_key = "enter"
pressed = False

conn = sqlite3.connect(path2) 
cursor = conn.cursor()
with open(path1, "r", encoding="utf-8") as f:
    conn.executescript(f.read())

def drawing(value):    
    
    print(f"値は{value}")

    result_id = 0
    result_flag = ""

    for id, name, weight in conn.execute("SELECT id, flag_name, weight FROM flags"):
        value -= weight
        if value < 0:
            result_id = id
            result_flag = name
            break
        else:
            pass
    
    print(f"当選役は{result_flag}")
    
    sql = """
SELECT
    r.name, r.payout, r.pattern
FROM
    mapping AS m
JOIN
    roles AS r
ON
    m.role_id = r.id
WHERE
    m.flag_id = ?
"""
    for role_name, payout, pattern in conn.execute(sql, (result_id,)):
        print(f"{role_name} {payout} {pattern}")



while True:
    current_time = time.time()
    current_value = current_time % loop
    ratio = current_value / loop
    result = int(65536 * ratio)

    if keyboard.is_pressed(exit_key):
        print("exit")
        break
    if keyboard.is_pressed(stop_key):
        if not pressed:
            drawing(result)
            pressed = True
    else:
        pressed = False


