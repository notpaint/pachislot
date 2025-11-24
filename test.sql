DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS flags;
DROP TABLE IF EXISTS mapping;

CREATE TABLE roles(
    id INTEGER PRIMARY KEY,
    name TEXT,
    kind TEXT,
    payout INTEGER,
    pattern TEXT
);

INSERT INTO roles (name, kind, payout, pattern) VALUES ('upperBell', 'N', '3', '[bell-bell-bell]');
INSERT INTO roles (name, kind, payout, pattern) VALUES ('middleBell', 'N', '15', '[bell-bell-bell]');
INSERT INTO roles (name, kind, payout, pattern) VALUES ('lowerBell', 'N', '15', '[bell-bell-bell]');
INSERT INTO roles (name, kind, payout, pattern) VALUES ('Replay', 'R', '0' , '[rep-rep-rep]');
INSERT INTO roles (name, kind, payout, pattern) VALUES ('norCherryA', 'N', '2' , '[bar-rep-rep]');
INSERT INTO roles (name, kind, payout, pattern) VALUES ('altCherryA', 'N', '2' , '[blank-rep-rep]');
INSERT INTO roles (name, kind, payout, pattern) VALUES ('Suica', 'N', '8' , '[suica-suica-suica]');

CREATE TABLE flags(
    id INTEGER PRIMARY KEY,
    flag_name TEXT,
    state TEXT,
    weight INT
);

INSERT INTO flags (flag_name, state, weight) VALUES ('BellA','Normal' ,'7000');
INSERT INTO flags (flag_name, state, weight) VALUES ('BellB','Normal' ,'7000');
INSERT INTO flags (flag_name, state, weight) VALUES ('Replay','Normal' ,'8976');
INSERT INTO flags (flag_name, state, weight) VALUES ('CherryA','Normal' ,'3277');
INSERT INTO flags (flag_name, state, weight) VALUES ('Suica','Normal' ,'2185');


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

INSERT INTO mapping (flag_id, role_id) VALUES (3,4);

INSERT INTO mapping (flag_id, role_id) VALUES (4,5);
INSERT INTO mapping (flag_id, role_id) VALUES (4,6);

INSERT INTO mapping (flag_id, role_id) VALUES (5,7);