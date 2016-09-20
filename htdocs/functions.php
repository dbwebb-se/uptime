<?php
/**
 * Open database connection.
 */
function openDatabase($dsn)
{
    try {
        $pdo = new PDO($dsn);
        return $pdo;
    } catch (Exception $e) {
          //throw $e; // For debug purpose, shows all connection details
          throw new PDOException('Could not connect to database, hiding connection details.');
    }
}



/**
 * Get user.
 */
function getUser($pdo, $who)
{
    $sql = "SELECT * FROM participant WHERE who = ?";
    $stm = $pdo->prepare($sql);
    $params = [$who];
    $stm->execute($params);
    $res = $stm->fetchObject();
    return $res;
}



/**
 * Add new user.
 */
function addUser($pdo, $who)
{
    $sql = "INSERT INTO participant (who) VALUES (?)";
    $stm = $pdo->prepare($sql);
    $params =  [$who];
    $stm->execute($params);
}



/**
 * Add log entry.
 */
function addLogEntry($pdo, $who, $uptime)
{
    // Check if logentry for current date exists
    $sql = "SELECT who FROM log where who = ? AND date = date('now')";
    $stm = $pdo->prepare($sql);
    $params =  [$who];
    $stm->execute($params);
    $res = $stm->fetchObject();

    if ($res == false) {
        // Insert
        $sql = <<<EOD
INSERT INTO log 
        (who, date, timestamp, uptime)
    VALUES
        (?, date('now'), datetime('now', 'localtime'), ?)
EOD;
        $stm = $pdo->prepare($sql);
        $params =  [$who, $uptime];
        return $stm->execute($params);
    }

    // Update existing logentry
    $sql = <<<EOD
UPDATE log
    SET 
        timestamp = datetime('now', 'localtime'),
        uptime = ?
    WHERE
        who = ? AND date = date('now')
EOD;

    $stm = $pdo->prepare($sql);
    $params =  [$uptime, $who];
    return $stm->execute($params);
}



/**
 * Latest log entry.
 */
function lastLogEntry($pdo, $who)
{
    $sql = "SELECT * FROM log WHERE who = ? ORDER BY date DESC LIMIT 1";
    $stm = $pdo->prepare($sql);
    $params =  [$who];
    $stm->execute($params);
    $res = $stm->fetchObject();
    return $res;
}



/**
 * Update uptime.
 */
function updateUptime($pdo, $whoId, $uptime)
{
    $sql = "SELECT latest, top FROM uptime WHERE who = ?";
    $stm = $pdo->prepare($sql);
    $params =  [$whoId];
    $stm->execute($params);
    $res = $stm->fetchObject();

    if ($res === false) {
        // Insert uptime
        $sql = "INSERT INTO uptime (who, latest, top, updated) VALUES (?, ?, ?, date('now'))";
        $stm = $pdo->prepare($sql);
        $params =  [$whoId, $uptime, $uptime];
        return $stm->execute($params);
    }

    // Update uptime
    $top = $res->top;
    $top = $uptime > $top ? $uptime : $top;
    $sql = "UPDATE uptime set latest = ?, top = ?, updated = date('now') WHERE who = ?";
    $stm = $pdo->prepare($sql);
    $params =  [$uptime, $top, $whoId];
    return $stm->execute($params);
}



/**
 * Calculate max uptime.
 */
function maxUptime()
{
    // Check if uptime is larger than expected, check with tournament start
    $start = new DateTime(TOURNAMENT_START);
    $today = new DateTime();
    $max = $today->diff($start)->format("%a");
    return $max;
}
