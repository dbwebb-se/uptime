<?php
// Get config
include __DIR__ . "/../config.php";
include $functionsInclude;

// Get incoming
if (empty($_GET)) {
?>
<!doctype html>
<html lang=sv>
<meta charset=utf-8>
<title>Lägg till entry i uptime tävling</title>
<h1>Rapportera till uptime tävlingen</h1>
    <form>
    <p>
        Vem: <input type=text name=who> (unik identifierare på dig och din server)
    </p>
    <p>
        Uptime: <input type=text name=uptime> (antal dagar taget direkt från kommandot uptimes utskrift)
    </p>
    <p>
        <input type=submit value="Skicka in">
    </p>
</form>

<?php
    die();
}



// Get incoming
$uptime = isset($_GET["uptime"])   ? $_GET["uptime"]   : null;
$who    = isset($_GET["who"])      ? $_GET["who"]      : null;



// Validate incoming
(is_numeric($uptime) and $uptime > 0)
    or die("Uptime must be positive integer");
is_string($who)
    or die("Who must be a string");



// Add log entry to database
$pdo = openDatabase(DSN);

// Get or add participant
$user = getUser($pdo, $who);
if ($user === false) {
    addUser($pdo, $who);
    $user = getUser($pdo, $who);
}

$username = htmlentities($user->who);
echo <<<EOD
<p>Got user, nice...
<pre>
User:    $username
User id: $user->id
</pre>
EOD;



// Get last log entry && validate new log entry
// Is it a reasonable uptime coming in?

// Check if uptime is larger than expected, check with tournament start
$start = new DateTime(TOURNAMENT_START);
$today = new DateTime();
$max = $today->diff($start)->format("%a");
if ($uptime == $max) {
    echo "<p>Right on, seems like your uptime is max!";
} elseif ($uptime > $max) {
    echo "<p>Your uptime ($uptime) is above max uptime ($max), resetting your value to max.";
    $uptime = $max;
}

// Add new log entry
$added = addLogEntry($pdo, $who, $uptime);
$update = updateUptime($pdo, $user->id, $uptime);

$last = lastLogEntry($pdo, $who);
echo <<<EOD
<p>Added logentry for $username, super...
<pre>
timestamp: $last->timestamp
date:      $last->date
uptime:    $last->uptime 
</pre>
EOD;

echo "<p><a href=..>Visa topplista</a>";
