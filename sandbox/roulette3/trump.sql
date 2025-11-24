DROP TABLE IF EXISTS trump_ranks;
DROP TABLE IF EXISTS trump_suits;
DROP TABLE IF EXISTS cards;


CREATE TABLE trump_ranks(
    ranks INTEGER
);

INSERT INTO trump_ranks (ranks) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13);

CREATE TABLE trump_suits(
    suits TEXT
);

INSERT INTO trump_suits (suits) VALUES ('Spade'), ('Diamond'), ('Heart'), ('Club');

CREATE TABLE cards(
    id INTEGER PRIMARY KEY,
    suit TEXT,
    rank INTEGER
);

INSERT INTO cards (suit, rank)
SELECT suits, ranks
FROM trump_suits AS s, trump_ranks AS r;

