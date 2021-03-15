#!/usr/bin/php -q
<?php
//---------------------------------------------------------------------------------------------------
// Wetter4 - Datencleaner
//---------------------------------------------------------------------------------------------------

function logg($level, $message) {
  echo gmdate("Y-m-d H:i:s", time())." $level $message\n";
}


$homedir = "/home/netuser/Work/wetter4_data/";

$lockfile = $homedir."clean_data_efs.lock";
if (file_exists($lockfile)) {
  logg("FATAL","this program is already runing ... exit");
  exit();
} else {
  $fp = fopen($lockfile, "w");
  fputs($fp, "");
  fclose($fp);
}


$now = time();
$three_days_ago = $now - 3 * 86400;


// Modell-Plumes
$plumdir = $homedir."plume/";
if ($handle = opendir($plumdir)) {
  logg("INFO","checking ".$plumdir);
  while (($mf = readdir($handle)) !== false) {
    if (substr($mf, 0, 3) == "plm") {
      $filedate = gmmktime(substr($mf, 16, 2), 0, 0, substr($mf, 12, 2), substr($mf, 14, 2), substr($mf, 8, 4));
      if ($filedate < $three_days_ago) {
        logg("INFO","remove ".$mf);
        unlink($plumdir."/".$mf);
      }
    }
  }
}


// Mos
$mosdir = $homedir."mos/";
if ($handle = opendir($mosdir)) {
  logg("INFO","checking ".$mosdir);
  while (($mf = readdir($handle)) !== false) {
    if (substr($mf, 12, 3) == "csv") {
      $filedate = gmmktime(substr($mf, 6, 2), 0, 0, substr($mf, 2, 2), substr($mf, 4, 2), "20".substr($mf, 0, 2));
      if ($filedate < $three_days_ago) {
        logg("INFO", "remove ".$mf);
        unlink($mosdir."/".$mf);
      }
    }
  }
}


// Mos Road
$mosdir = $homedir."mos_road/";
if ($handle = opendir($mosdir)) {
  logg("INFO", "checking ".$mosdir);
  while (($mf = readdir($handle)) !== false) {
    if (substr($mf, 9, 4) == "road") {
      $filedate = gmmktime(substr($mf, 6, 2), 0, 0, substr($mf, 2, 2), substr($mf, 4, 2), "20".substr($mf, 0, 2));
      if ($filedate < $three_days_ago) {
        logg("INFO", "remove ".$mf);
        unlink($mosdir."/".$mf);
      }
    }
  }
}


// Radarimages
// config radar dirs: directory => file prefix
$radars = array(
  "prectype_can" => "prectype_can",
  "radar_can" => "radar_can",
  "radar_ch" => "radar_ch",
  "radar_dx" => "refl_dxcmp",
  "radar_dx/log" => "dxlog",
  "radar_es" => "radar_es",
  "radar_eu" => "radar_eu",
  "radar_fr" => "radar_fr_flatmap",
  // "radar_kr", data transfer deactivated
  "radar_nl" => "radar_nl_flatmap",
  "radar_pl" => "radar",
  "radar_skan" => "radar_skan",
  "radar_ukmo" => "radar_ukmo",
  // "radar_usa", data transfer deactivated
);

$radar_homedir = $homedir."radar/";

foreach ($radars as $radar => $file_prefix) {
  $radar_dir = $radar_homedir.$radar;
  if (is_dir($radar_dir)) {
    if ($handle = opendir($radar_dir)) {
      logg("INFO", "checking ".$radar_dir);
      while (($file_name = readdir($handle)) !== false) {
        $file_path = $radar_dir."/".$file_name;
        if (is_file($file_path) && filemtime($file_path) < $three_days_ago) {
          // remove old prog files (forecasts)
          if (preg_match('/^prog_/', $file_name)) {
            logg("INFO", "remove ".$file_path);
            unlink($file_path);
          } elseif (preg_match('/^'.$file_prefix.'_(\d{4})/', $file_name, $matches)) {
            // move old radar files to yearly subdirectory
            $year = $matches[1];
            if ($radar == "radar_dx/log") {
              $sub_dir = $radar_homedir."/radar_dx/".$year."/log";
            } else {
              $sub_dir = $radar_dir."/".$year;
            }
            if (!is_dir($sub_dir)) {
              logg("INFO", "create dir ".$sub_dir);
              mkdir($sub_dir);
            }
            logg("INFO", "move ".$file_path." to ".$sub_dir);
            rename($file_path, $sub_dir."/".$file_name);
          } else {
            logg("WARNING", "unknown file ".$file_name);
          }
        }
      }
    }
  } else {
    logg("WARNING", "directory ".$radar_dir." not found");
  }
}


// sat images, (rss, msgrgb and mtsatwv are not archived)
$satdir = $homedir."sat/";

if (is_dir($satdir)) {
  if ($handle = opendir($satdir)) {
    logg("INFO", "checking ".$satdir);
    while (($file_name = readdir($handle)) !== false) {
      if(preg_match('/^(\d{4})\d{4}_\d{4}_/', $file_name, $matches) && filemtime($satdir.$file_name) < $three_days_ago) {
        $year = $matches[1];
        if (strstr($file_name, "rss") || strstr($file_name, "msgrgb") || strstr($file_name, "mtsatwv")) {
          logg("INFO", "remove ".$satdir.$file_name);
          unlink($satdir.$file_name);
        } else {
          logg("INFO", "move ".$file_name." to ".$satdir.$year);
          rename($satdir.$file_name, $satdir.$year."/".$file_name);
        }
      }
    }
  }
}


if (file_exists($lockfile)) {
  $kommando = "rm ".$lockfile;
  exec($kommando);
}

?>

