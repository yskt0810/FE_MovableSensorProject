<?php

$getuuid = $_POST['uuid'];
$getData = $_POST['data'];
$base_folder = "<PATH TO SENSOR DATA FOLDER>";
$year = date(Y);
$save_folder = $base_folder . $year;
if(!is_dir($save_folder)){
	mkdir($save_folder);
	chmod($save_folder,0777);
}

$month = date(m);
$save_folder = $save_folder . "/" . $month;
if(!is_dir($save_folder)){
	mkdir($save_folder);
	chmod($save_folder,0777);
}

$day = date(d);
$save_folder = $save_folder . "/" . $day;
if(!is_dir($save_folder)){
	mkdir($save_folder);
	chmod($save_folder,0777);
}

if($getuuid === ""){ $getuuid = "TEST"; }

$filename = $save_folder . "/" . $getuuid . ".csv";
echo $filename;

$file = fopen($filename,"a+");
fwrite($file,$getData);
fclose($file);

echo "Sending Data is succeeded!";

?>