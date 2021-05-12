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
    "uptime" INTEGER, -- TEXT in original database
    "uptimeTot" INTEGER,
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
    "current" INTEGER,
    "updated" TEXT,
    FOREIGN KEY("who") REFERENCES participant(id)
);


--
-- To upgrade
--
-- alter table log add column uptimeTot INTEGER;
-- alter table uptime add column current INTEGER; 
