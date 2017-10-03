<?php
// Get config
include __DIR__ . "/config.php";
include $functionsInclude;



// Get toplist
$pdo = openDatabase(DSN);

$sql = "SELECT u.*, p.who AS whoName FROM uptime AS u INNER JOIN participant AS p ON u.who = p.id ORDER BY top DESC";
$stm = $pdo->prepare($sql);
$stm->execute();
$res = $stm->fetchAll();



// Draw toplist
$html = "";
$last = -1;
$place = 0;
$numContenders = 0;

foreach ($res as $val) {
    $numContenders++;
    $place = null;
    if ($last == -1 || $val["top"] < $last) {
        $place = $numContenders;
    }
    $last = $val["top"];
    
    // Has it been updated today?
    $today = date("Y-m-d");
    $updated = date("Y-m-d", strtotime($val["updated"]));
    if ($today == $updated) {
        $classOld = "";
    } else {
        $classOld = ' class="old"';
    }

    $name = htmlentities($val["whoName"]);
    $html .= <<<EOD
    <tr${classOld}>
        <td>$place</td>
        <td>$name</td>
        <td class="right">${val["top"]}</td>
        <td class="right">${val["latest"]}</td>
        <td class="right">${val["current"]}</td>
        <td class="center">${val["updated"]}</td>
    </tr>
EOD;
}
?>
<!doctype html>
<html lang="sv">
<meta charset="utf-8">
<title>Uptime Topplista</title>
<style>
td.right {
    text-align: right;
}
td.center {
    text-align: center;
}
td {
    border: 1px solid #ccc;
}
tr:hover {
    background-color: #eee;
}
tr.old {
    color: #ccc;
}
</style>

<h1>Uptime topplista</h1>

<p>Tävlingen pågår mellan <?= TOURNAMENT_START ?> - <?= TOURNAMENT_END ?></p>

<p>Max uptime per <?= date("Y-m-d") ?> är <?= maxUptime() ?> dagar.</p>

<table>
    <tr>
        <th>Plats</th>
        <th>Vem</th>
        <th><span title="Högsta noterade uptime under tävlingsperioden - denna är det vi tävlar med">Uptime<br>topp</span></th>
        <th><span title="Senast rapporterad uptime (nuvarande uptime), kan vara mindre än toppnoteringen om servern startat om...">Senaste<br>uptime</span></th>
        <th><span title="Rapporterad verklig uptime (utom tävlan - men ändå - lets showoff)">Verklig<br>uptime</span></th>
        <th>Rapporterat</th>
    </tr>
<?= $html ?>
</table>

<p><a href=add>Skicka in bidrag</a></p>

<p><a href=https://github.com/mosbth/uptime>GitHub</a></p>

<p>Mer info i <a href="https://dbwebb.se/forum/viewtopic.php?f=23&t=5595">forumet</a> och på <a href="https://grillcon.dbwebb.se/blogg/vem-vinner-uptime-ligan">GrillCons blogg</a>.</p>
