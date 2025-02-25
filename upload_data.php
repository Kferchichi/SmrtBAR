<?php

$anaylyseType = $_POST['anaylyseType'];
echo  $anaylyseType.'<br/>';

//echo "Here are debugging information :\n";
//print_r($_FILES);

if ($anaylyseType == "demux_Sequel1-2") { 

  $uploaddir = '~/script_dbac/';
  $xmlFile = $uploaddir . basename($_FILES['xmlFile']['name']);
  $pacbioTags = $uploaddir . basename($_FILES['pacbioTags']['name']);
  $adaptersFile = $uploaddir . basename($_FILES['adaptersFile']['name']);

  echo "$xmlFile <br/>";
  echo "$pacbioTags <br/>";
  echo "$adaptersFile <br/>";

  echo '<pre>';
  if (move_uploaded_file($_FILES['xmlFile']['tmp_name'], $xmlFile)) {
      echo "File exists. Upload done successfully :\n";
  } else {
      echo "No File uploaded !!!:\n";
  }

  if (move_uploaded_file($_FILES['pacbioTags']['tmp_name'], $pacbioTags)) {
      echo "File exists. Upload done successfully :\n";
  } else { 
      echo "No File uploaded !!!:\n";
  }
  if (move_uploaded_file($_FILES['adaptersFile']['tmp_name'], $adaptersFile)) {
      echo "File exists. Upload done successfully :\n";
  } else { 
    echo "No File uploaded !!!:\n";
  }

  $file1 = $_FILES['xmlFile']['name'];
  $file2 = $_FILES['pacbioTags']['name'];
  $file3 = $_FILES['adaptersFile']['name'];

  echo("/usr/bin/perl ~/Smarty.pl $file1 $file2 $file3");
  $result = shell_exec(~/Smarty.pl $file1 $file2 $file3");
  echo $result;
  echo "1";
}
if ($anaylyseType == "demux_Sequel2e") { 
  echo "2";
} 
if ($anaylyseType == "split") { 
  echo "3";
}
?>
