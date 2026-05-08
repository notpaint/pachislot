-- 小役テーブル
CREATE TABLE roles(
    id INTEGER PRIMARY KEY,
    role TEXT,
    kind INT,
    payout INTEGER,
    pattern TEXT,
    miss_pattern TEXT
);

--　フラグ一覧
CREATE TABLE flags(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    flag TEXT UNIQUE
);

CREATE TABLE flag_HUD(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    flag_ID INT,
    flag_name TEXT
);

CREATE TABLE JAC_data(
    name TEXT,
    prize_count INT,
    play_count INT,
    play_bet INT
);

CREATE TABLE bonus_data(
    name TEXT,
    max_payout INT,
    JACIN_type TEXT,
    JAC_nums TEXT,
    before_RT TEXT,
    after_RT TEXT
);

CREATE TABLE RT_data(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    game INT,
    type INT
);

CREATE TABLE RT_pattern(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    RT_id INT,
    pattern TEXT,
    FOREIGN KEY(RT_id) REFERENCES RT_data(id)
);

CREATE TABLE flag_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bonus_state TEXT,
    RT_state TEXT,
    bet_state INT,
    flag_id INT,
    weight INT,
    FOREIGN KEY(flag_id) REFERENCES flags(id)
);

--　制御テーブル
CREATE TABLE control_table(
    role_id INT,
    reel_pos INT,
    reel_ID INT,
    slide INT,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    PRIMARY KEY (role_id, reel_pos, reel_ID)
);

-- 外れ制御テーブル
CREATE TABLE vac_control_table(
    reel_pos INT,
    reel_ID INT,
    slide INT
);

CREATE TABLE vac_pattern(
    pattern TEXT
);

CREATE TABLE role_pattern_priority(
    role_id INT,
    bonus_state TEXT,
    reel_pos INT,
    reel_ID INT,
    priority INT,
    route TEXT,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    FOREIGN KEY (reel_pos) REFERENCES reel_poses(reel_pos),
    FOREIGN KEY (reel_ID) REFERENCES reel_IDs(reel_id),
    PRIMARY KEY (role_id, bonus_state, reel_pos, reel_ID, route)
);

CREATE TABLE flag_role_priority(
    flag_ID INT,
    bonus_state TEXT,
    reel_pos INT,
    priority INT,
    FOREIGN KEY (flag_ID) REFERENCES flags(id),
    FOREIGN KEY (reel_pos) REFERENCES reel_poses(reel_pos)
);

CREATE TABLE reel_table(
    reel_pos INT,
    reel_id INT,
    reel_design TEXT,
    FOREIGN KEY (reel_pos) REFERENCES reel_poses(reel_pos),
    FOREIGN KEY (reel_id) REFERENCES reel_IDs(reel_id),
    PRIMARY KEY (reel_pos, reel_id)
);


-- リールの位置(左:0 中:1 右:2)
CREATE TABLE reel_poses(
    reel_pos INT
);

INSERT INTO reel_poses (reel_pos) VALUES (0), (1), (2);


-- コマ数
CREATE TABLE reel_IDs(
    reel_id INT
);

INSERT INTO reel_IDs (reel_id) VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19), (20);



CREATE TABLE flag_role_map(
    flag_id INT,
    role_id INT,
    FOREIGN KEY (flag_id) REFERENCES flags(id),
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

