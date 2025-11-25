CREATE TABLE roles(
    id INTEGER PRIMARY KEY,
    name TEXT,
    payout INTEGER,
    pattern TEXT
);


CREATE TABLE flags(
    id INTEGER PRIMARY KEY,
    flag_name TEXT,
    weight INT,
    state TEXT
);


CREATE TABLE slides(
    role_id INT,
    reel_pos INT,
    reel_ID INT,
    slide INT,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    PRIMARY KEY (role_id, reel_pos, reel_ID)
);


CREATE TABLE bonus_status (
    weight_status TEXT
);


CREATE TABLE reel_poses(
    reel_pos INT
);

INSERT INTO reel_poses (reel_pos) VALUES (0), (1), (2);


CREATE TABLE reel_IDs(
    reel_id INT
);

INSERT INTO reel_IDs (reel_id) VALUES (0), (1), (2), (3), (4);
-- INSERT INTO reel_IDs (reel_id) VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19), (20);



CREATE TABLE mapping(
    flag_id INT,
    role_id INT,
    FOREIGN KEY (flag_id) REFERENCES flags(id),
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- INSERT INTO mapping (flag_id, role_id) 
-- SELECT f.id, r.id
-- FROM flags AS f, roles AS r
-- WHERE f.flag_name = 'BellA' 
-- AND r.name IN ('upperBell', 'middleBell');

-- INSERT INTO mapping (flag_id, role_id)
-- SELECT f.id, r.id
-- FROM flags AS f, roles AS r
-- WHERE f.flag_name = 'BellB' 
-- AND r.name IN ('upperBell', 'lowerBell');

-- INSERT INTO mapping (flag_id, role_id) VALUES (2,1);
-- INSERT INTO mapping (flag_id, role_id) VALUES (2,3);