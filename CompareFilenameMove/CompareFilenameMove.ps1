# Script to move files if the same file is found in folder1 and folder2. 
# It recursively goes through both folders and compares the base filename, filename without extension, of 
# each file in the first folder. If a match is found both files are moved to a third folder, the 
# destination, $destinationfolder. 
# Created by Jaap Brasser 
 
$folder1 = ls "e:\1" -recurse 
$folder2 = ls "e:\2" -recurse 
$destinationfolder = "e:\3" 
 
$folder1count = $folder1.count 
$folder2count = $folder2.count 
 
for ($j=0;$j -lt $folder1count;$j++) { 
    for ($k=0;$k -lt $folder2count;$k++) { 
        if (compare-object $folder1[$j].basename $folder2[$k].basename -excludedifferent -includeequal) { 
            move-item $folder1[$j].fullname $destinationfolder -force 
            move-item $folder2[$k].fullname $destinationfolder -force 
            $copycount = $copycount + 2 
        } 
    } 
} 
 
write-host "$copycount Files moved" 