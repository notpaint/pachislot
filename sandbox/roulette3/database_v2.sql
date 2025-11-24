CREATE TABLE roles(
    id INTEGER PRIMARY KEY,
    name TEXT,
    payout INTEGER,
    pattern TEXT
);

-- INSERT INTO roles (name, payout, pattern) VALUES ('upperBell', 3, '[rep-cherry-rep]');
-- INSERT INTO roles (name, payout, pattern) VALUES ('middleBell', 15, '[bell-bell-bell]');
-- INSERT INTO roles (name, payout, pattern) VALUES ('lowerBell', 15, '[bell-bell-bell]');
-- INSERT INTO roles (name, payout, pattern) VALUES ('replay', 0 , '[rep-rep-rep]');
-- INSERT INTO roles (name, payout, pattern) VALUES ('norCherryA', 2 , '[bar-rep-rep]');
-- INSERT INTO roles (name, payout, pattern) VALUES ('altCherryA', 2 , '[blank-rep-rep]');
-- INSERT INTO roles (name, payout, pattern) VALUES ('suica', 8 , '[suica-suica-suica]');

CREATE TABLE flags(
    id INTEGER PRIMARY KEY,
    flag_name TEXT,
    weight INT,
    state TEXT
);

INSERT INTO flags (flag_name, weight, state) VALUES ('BellA', 32769, 'Normal');
INSERT INTO flags (flag_name, weight, state) VALUES ('BellB', 32769, 'Normal');

CREATE TABLE reel_poses(
    reel_pos TEXT
);

INSERT INTO reel_poses (reel_pos) VALUES ('L'), ('C'), ('R');

CREATE TABLE reel_IDs(
    reel_id INT
);

INSERT INTO reel_IDs (reel_id) VALUES (0), (1), (2), (3), (4);
-- INSERT INTO reel_IDs (reel_id) VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19), (20);

CREATE TABLE slides(
    role_id INT,
    reel_pos TEXT,
    reel_ID INT,
    slide INT,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    PRIMARY KEY (role_id, reel_pos, reel_ID)
);

INSERT INTO slides (role_id, reel_pos, reel_ID, slide)
SELECT r.id, p.reel_pos, i.reel_id, 0
FROM roles AS r, reel_poses AS p, reel_IDs AS i
WHERE r.name = 'upperBell';

CREATE TABLE mapping(
    flag_id INT,
    role_id INT,
    FOREIGN KEY (flag_id) REFERENCES flags(id),
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

INSERT INTO mapping (flag_id, role_id) 
SELECT f.id, r.id
FROM flags AS f, roles AS r
WHERE f.flag_name = 'BellA' 
AND r.name IN ('upperBell', 'middleBell');

INSERT INTO mapping (flag_id, role_id)
SELECT f.id, r.id
FROM flags AS f, roles AS r
WHERE f.flag_name = 'BellB' 
AND r.name IN ('upperBell', 'lowerBell');

-- INSERT INTO mapping (flag_id, role_id) VALUES (2,1);
-- INSERT INTO mapping (flag_id, role_id) VALUES (2,3);