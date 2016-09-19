<?php
// Error reporting
error_reporting(-1);              // Report all type of errors
ini_set('display_errors', 1);     // Display all errors

// When did tournament start?
define("TOURNAMENT_START", "2016-09-17");
define("TOURNAMENT_END", "2017-05-19");

// Database conneection details
define("DSN", "sqlite:" . __DIR__ . "/../data/uptime.sqlite");

// File for functions
$functionsInclude = __DIR__ . "/functions.php";
