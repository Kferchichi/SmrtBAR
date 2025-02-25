<?php
// Enter the name of directory
$pathdir = "~/OUTPUT/"; 
//$pathdir = "~/OUTPUT/"; 
  
// Enter the name to creating zipped directory
$zipcreated = "~/OUTPUT/OUTPUT.zip";
  
// Create new zip class
$zip = new ZipArchive;
   
if($zip -> open($zipcreated, ZipArchive::CREATE|ZipArchive::OVERWRITE ) === TRUE) {
      
    // Store the path into the variable
    $dir = opendir($pathdir);
       
    $i=0;
    while($file = readdir($dir)) {
        if(is_file($pathdir.$file)) {
       $zip -> addFile($pathdir.$file, $file);
       echo($i."- ".$pathdir.$file."<br/>");
           $zip -> addFile($pathdir.$file, $file);
           $i=$i+1;
        }
    }
   $zip ->close();
}

//Then download the zipped file.
header('Content-Type: application/zip');
header('Content-disposition: attachment; filename='.$zipcreated);
header('Content-Length: ' . filesize($zipcreated));
readfile($zipcreated);

?>
