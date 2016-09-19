--
-- Table for participant
--
DROP TABLE IF EXISTS participant;
CREATE TABLE participant (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "who" TEXT UNIQUE
);



--
-- Table for log entries
--
DROP TABLE IF EXISTS log;
CREATE TABLE log (
    "who" INTEGER,
    "date" TEXT,
    "timestamp" INTEGER,
    "uptime" TEXT,
    PRIMARY KEY("who", "date"),
    FOREIGN KEY("who") REFERENCES participant(id)
);



--
-- Table for uptime
--
DROP TABLE IF EXISTS uptime;
CREATE TABLE uptime (
    "who" INTEGER PRIMARY KEY,
    "latest" INTEGER,
    "top" INTEGER,
    "updated" TEXT,
    FOREIGN KEY("who") REFERENCES participant(id)
);
