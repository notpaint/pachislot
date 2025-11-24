import sqlite3
import os

dir = os.path.dirname(__file__)
path1 = os.path.join(dir, "trump.sql")
path2 = os.path.join(dir, "trump_d.db")

conn = sqlite3.connect(path2) 
cursor = conn.cursor()

with open(path1, "r", encoding="utf-8") as f:
    conn.executescript(f.read())

cursor.execute("SELECT * FROM cards")
cards = cursor.fetchall()

for card in cards:
    print(card)