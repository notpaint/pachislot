CREATE TABLE env(
    name TEXT,
    data TEXT
);

CREATE TABLE SE(
    name TEXT,
    rule TEXT,
    sound TEXT
);

CREATE TABLE bonus_music(
    bonus TEXT,
    rule TEXT,
    track_name TEXT,
    start TEXT,
    end TEXT
);

CREATE TABLE back_music(
    track TEXT,
    path TEXT
);

CREATE TABLE flag_trigger(
    flag TEXT,
    type TEXT,
    state TEXT,
    weight INTEGER
);

CREATE TABLE mode_list(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mode TEXT UNIQUE
);

CREATE TABLE mode_release(
    mode_id INT,
    game INT,
    weight INT,
    premonition INT,
    FOREIGN KEY(mode_id) REFERENCES mode_list(id)
);


CREATE TABLE mode_map(
    mode_id INT,
    next_mode_id INT,
    weight TEXT,
    FOREIGN KEY(mode_id) REFERENCES mode_list(id)
    FOREIGN KEY(next_mode_id) REFERENCES mode_list(id)
);

CREATE TABLE mode_ratio(
    mode_ID INT,
    bonus TEXT,
    weight INT,
    FOREIGN KEY(mode_id) REFERENCES mode_list(id)
);

CREATE TABLE premonition_map(
    type TEXT,
    trigger TEXT,
    flag TEXT,
    is_win INT,
    game INT,
    weight INT
);

CREATE TABLE stage_map(
    type TEXT,
    route INT,
    is_win INT,
    game INT,
    effect TEXT,
    weight INT
);