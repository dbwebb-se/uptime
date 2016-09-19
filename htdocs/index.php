<?php
// Get config
include __DIR__ . "/config.php";
include $functionsInclude;



// Get toplist
$pdo = openDatabase(DSN);

$sql = "SELECT u.*, p.who AS whoName FROM uptime AS u INNER JOIN participant AS p ON u.who = p.id";
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

    $html .= <<<EOD
    <tr>
        <td>$place</td>
        <td>${val["whoName"]}</td>
        <td class="right">${val["top"]}</td>
        <td class="right">${val["latest"]}</td>
        <td class="center">${val["updated"]}</td>
    </tr>
EOD;
}
?>
<!doctype html>
<html lang="sv">
<meta charset="utf-8">
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
</style>

<h1>Uptime topplista</h1>
<table>
    <tr>
        <th>Plats</th>
        <th>Vem</th>
        <th>Uptime topp</th>
        <th>Senaste uptime</th>
        <th>Rapporterat</th>
    </tr>
<?= $html ?>
</table>
