<?php

$day = $_POST['day'];
$sensor = $_POST['sensor'];
$time = $_POST['time'];

//if($day == ""){ $day = 22; }
//if($sensor == ""){ $sensor = 4;}

$dirpath = "./2016/02/" . $day . "/";
$dir = opendir($dirpath);

  while(false != ($file_list[] = readdir($dir)));

  closedir($dir);

?>


<!DOCTYPE html>
<html>
  <head>
  	<title> SENSOR VISUALIZER </title>
  	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <style type="text/css">
      html { height: 100%; }
      body { height: 100%; margin: 0px; padding: 0px; }
      #map { height: 90%; }
    </style>

    <script type="text/javascript" src="rgbcolor.js"></script> 
    <script src="http://maps.google.com/maps/api/js?v=3&sensor=false" type="text/javascript" charset="UTF-8"></script>
    <script type="text/javascript">
   
        var map;

        function init(){


          var filelist = [];
            <?php

              $count = 0;
              foreach ($file_list as $file_name){

                if(is_file($dirpath . $file_name)){

                  print "filelist[" . $count . "] = '" . $file_name ."'; \n";
                  $count = $count + 1;

                }

                

              }
              
            ?>
            var latlng = new google.maps.LatLng(35.628703, 139.659706);
            var opts = {

                zoom: 15,
                mapTypeId: google.maps.MapTypeId.ROADMAP,
                center: latlng
            };

            map = new google.maps.Map(document.getElementById("map"), opts);

          var circles = [];


          <?php

          if($sensor == 4){

            print "var sensor = " . $sensor . ";\n";

            $sensor_min = 0;
            $sensor_max = 30;
          }else if($sensor == 5){
            print "var sensor = " . $sensor . ";\n";
            $sensor_min = 950;
            $sensor_max = 1030;
          }else if($sensor == 6){
            print "var sensor = " . $sensor . ";\n";
            $sensor_min = 0;
            $sensor_max = 100;
          }else if($sensor == 7){
            print "var sensor = " . $sensor . ";\n";
            $sensor_min = 0;
            $sensor_max = 12000;
          }else if($sensor == 8){
            print "var sensor = 3;\n";
            $sensor_min = 0;
            $sensor_max = 14;
          }else if($sensor =- 9){
            print "var sensor = 3;\n";
            $sensor = 3;
            $sensor_min = 10;
            $sensor_max = 3300;
          }else{
            print "var sensor = " . $sensor . ";\n";
            $sensor_min = 0;
            $sensor_max = 30;
          }


          ?>
          for(var i=0;i<filelist.length; i++){
            var sensordata = csv2array("<?php print $dirpath; ?>" + filelist[i]);

            

            for(var n=0; n<sensordata.length; n++){

              var data_x;
              var syntax;

              var flag = false;
              var dt = new Date(sensordata[n][0]);
              
              <?php if($time == 1){ ?>
                if(dt.getHours() > 7 || dt.getHours() < 17){
                  flag = true;
                }
              <?php } ?>

              <?php if($time == 2){ ?>
                  if( dt.getHours() < 8 ||dt.getHours() > 16){
                  flag = true;
                }
              <?php } ?>


              if(flag){

                if(sensor == 3){

                  var tmp = sensordata[n][sensor];
                  tmparr = tmp.split(":");
                  syntax = tmparr[0];
                  data_x = tmparr[1];
                  

                }else{

                  data_x = sensordata[n][sensor];

                }

                var h = floatMap(data_x, <?php print $sensor_min; ?>, <?php print $sensor_max; ?>, 240, 30);
                var rgbValue = HSVtoRGB(h, 255, 255);
                var r10 = rgbValue.r;
                var g10 = rgbValue.g;
                var b10 = rgbValue.b;

                if(r10 < 16){ r_hex = "0" + r10.toString(16); }else{ var r_hex = r10.toString(16); }
                if(g10 < 16){ g_hex = "0" + g10.toString(16); }else{ var g_hex = g10.toString(16); }
                if(b10 < 16){ b_hex = "0" + b10.toString(16); }else{ var b_hex = b10.toString(16); }

                var hex = "#" + r_hex + g_hex + b_hex; 

                var circleOpts = {
                  center: new google.maps.LatLng(sensordata[n][1], sensordata[n][2]),
                  map: map,
                  radius: 15,
                  fillOpacity: 1,
                  fillColor: hex,
                  strokeColor: hex,
                  strokeOpacity: 0
                };

                <?php 

                  if($sensor == 8){
                    ?>

                    if(syntax == "uv"){
                      circles.push(new google.maps.Circle(circleOpts));
                    }

                    <?php
                  }else if($sensor == 9){
                    ?>

                    if(syntax == "sound"){
                      circles.push(new google.maps.Circle(circleOpts));
                    }

                    <?php
                  } else{

                    ?>

                    circles.push(new google.maps.Circle(circleOpts));

                    <?php

                  }
                ?>
              }
              
            }
          //var sensordata = csv2array("./SensorProject/2016/02/26/36173E35-C9AF-45E8-A15B-B02D3DBB6A4C.csv");
          }

        }

        function csv2array(filepath){
          var csvData = new Array();
          var data = new XMLHttpRequest();
          data.open("GET",filepath,false);
          data.send(null);

          var LF = String.fromCharCode(10);
          var lines = data.responseText.split(LF);
          for(var i=0;i < lines.length; i++){
            var cells = lines[i].split(",");
            if(cells.length != 1){
              csvData.push(cells);
            }
          }
          return csvData;
        }

        function HSVtoRGB (h, s, v) {
          var r, g, b; // 0..255
          while (h < 0) {
            h += 360;
          }

          h = h % 360;

          // 特別な場合 saturation = 0

          if (s == 0) {
            // → RGB は V に等しい
            v = Math.round(v);
            return {'r': v, 'g': v, 'b': v};
          }

          s = s / 255;

          var i = Math.floor(h / 60) % 6,
              f = (h / 60) - i,
              p = v * (1 - s),
              q = v * (1 - f * s),
              t = v * (1 - (1 - f) * s)

          switch (i) {
            case 0 :
              r = v;  g = t;  b = p;  break;
            case 1 :
              r = q;  g = v;  b = p;  break;
            case 2 :
              r = p;  g = v;  b = t;  break;
            case 3 :
              r = p;  g = q;  b = v;  break;
            case 4 :
              r = t;  g = p;  b = v;  break;
            case 5 :
              r = v;  g = p;  b = q;  break;
          }

          return {'r': Math.round(r), 'g': Math.round(g), 'b': Math.round(b)};
        
        }
        

        function floatMap(x, in_min, in_max, out_min, out_max){

          return ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);

        }





    </script>
  </head>
  <body onload="init()">
    <form method="POST" action="./visualizing.php">
      <table border="1" width="100%">
        <tr><td>日付を選択</td>
          <td>
            <select name="day">
              
              <option value="16" <?php if($day == "16"){ print "selected"; } ?>>2月16日</option> 
              <option value="17" <?php if($day == "17"){ print "selected"; } ?>>2月17日</option> 
              <option value="18" <?php if($day == "18"){ print "selected"; } ?>>2月18日</option> 
              <option value="19" <?php if($day == "19"){ print "selected"; } ?>>2月19日</option> 
              <option value="22" <?php if($day == "22"){ print "selected"; } ?>>2月22日</option> 
              <option value="23" <?php if($day == "23"){ print "selected"; } ?>>2月23日</option>
              <option value="24" <?php if($day == "24"){ print "selected"; } ?>>2月24日</option>
              <option value="25" <?php if($day == "25"){ print "selected"; } ?>>2月25日</option>
              <option value="26" <?php if($day == "26"){ print "selected"; } ?>>2月26日</option>
              <option value="27" <?php if($day == "27"){ print "selected"; } ?>>2月27日</option>
              <option value="28" <?php if($day == "28"){ print "selected"; } ?>>2月28日</option>
            </select>
            <input type="radio" name="time" value="1" checked>日中（８時〜１７時）
            <input type="radio" name="time" value="2">夜間（１７時〜朝７時）
          </td>
        </tr>
        <tr><td>センサーデータを選択</td>
          <td>
            <select name="sensor">
              <option value="4" <?php if($sensor == 4){ print "selected"; } ?>>気温</option>
              <option value="5" <?php if($sensor == 5){ print "selected"; } ?>>気圧</option>
              <option value="6" <?php if($sensor == 6){ print "selected"; } ?>>湿度</option>
              <option value="7" <?php if($sensor == 7){ print "selected"; } ?>>照度</option>
              <option value="8" <?php if($sensor == 8){ print "selected"; } ?>>UV INDEX</option>
              <option value="9" <?php if($sensor == 9){ print "selected"; } ?>>騒音</option>
            </select>
          </td>
        </tr>
        <tr><td></td>
          <td><input type="submit" value="送信"></td>
        </tr>
      </table>
      
    </form>

    <div id="map"></div>
  </body>
  </html>
