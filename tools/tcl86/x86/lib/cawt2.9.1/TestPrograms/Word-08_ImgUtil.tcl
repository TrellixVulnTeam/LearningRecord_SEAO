# Test CawtWord procedures for dealing with images.
#
# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
package require cawt

set squareImg    [file join [pwd] "testIn/Square.gif"]
set landscapeImg [file join [pwd] "testIn/Landscape.gif"]
set portraitImg  [file join [pwd] "testIn/Portrait.gif"]
set wishImg      [file join [pwd] "testIn/wish.gif"]

# Open new Word instance and show the application window.
set appId [Word OpenNew true]

# Delete Word file from previous test run.
file mkdir testOut
set wordFile [file join [pwd] "testOut" "Word-08_ImgUtil"]
append wordFile [Word GetExtString $appId]
file delete -force $wordFile

# Create a new document.
set docId [Word AddDocument $appId]

Cawt CheckNumber 0 [Word GetNumImages $docId] "Number of images: "
puts "Inserting images of different sizes ..."
Word AppendText $docId "Images of different sizes\n"

Word AppendText $docId "Square image:\n"
Word InsertImage [Word GetEndRange $docId] $squareImg
Word AppendParagraph $docId

Word AppendText $docId "Landscape image:\n"
Word InsertImage [Word GetEndRange $docId] $landscapeImg
Word AppendParagraph $docId

Word AppendText $docId "Portrait image:\n"
Word InsertImage [Word GetEndRange $docId] $portraitImg
Word AppendParagraph $docId


Cawt CheckNumber 3 [Word GetNumImages $docId] "Number of images: "
puts "Inserting images with different modes ..."
Word AddPageBreak [Word GetEndRange $docId]
Word AppendText $docId "Images with different insertion modes\n"

Word AppendText $docId "Linked image:\n"
Word InsertImage [Word GetEndRange $docId] $squareImg true false
Word AppendParagraph $docId

Word AppendText $docId "Embedded image:\n"
Word InsertImage [Word GetEndRange $docId] $squareImg false true
Word AppendParagraph $docId

Word AppendText $docId "Linked and Embedded image:\n"
Word InsertImage [Word GetEndRange $docId] $squareImg false true
Word AppendParagraph $docId

set catchVal [ catch { Word InsertImage [Word GetEndRange $docId] $squareImg false false } retVal]
Cawt CheckNumber 1 $catchVal "Catch invalid usage"
if { $catchVal } {
    puts "Successfully caught: $retVal"
}


Cawt CheckNumber 6 [Word GetNumImages $docId] "Number of images: "
puts "Inserting and scaling images ..."
Word AddPageBreak [Word GetEndRange $docId]
Word AppendText $docId "Images with different scalings\n"

Word AppendText $docId "Landscape scaled to Square:\n"
set scaleId1 [Word InsertImage [Word GetEndRange $docId] $landscapeImg]
Word ScaleImage $scaleId1 1 2
Word AppendParagraph $docId

Word AppendText $docId "Portrait scaled to Square:\n"
set scaleId2 [Word InsertImage [Word GetEndRange $docId] $portraitImg]
Word ScaleImage $scaleId2 2 1
Word AppendParagraph $docId


Cawt CheckNumber 8 [Word GetNumImages $docId] "Number of images: "
puts "Inserting and cropping images ..."
Word AddPageBreak [Word GetEndRange $docId]
Word AppendText $docId "Images with different croppings\n"

# CropImage shapeId cropBottom cropTop cropLeft cropRight
Word AppendText $docId "Square cropped at the bottom side:\n"
set cropId1 [Word InsertImage [Word GetEndRange $docId] $squareImg]
Word CropImage $cropId1 5c 0  0 0
Word AppendParagraph $docId

Word AppendText $docId "Square cropped at the top side:\n"
set cropId2 [Word InsertImage [Word GetEndRange $docId] $squareImg]
Word CropImage $cropId2 0 0.5c  0 0
Word AppendParagraph $docId

Word AppendText $docId "Square cropped at the left side:\n"
set cropId3 [Word InsertImage [Word GetEndRange $docId] $squareImg]
Word CropImage $cropId3 0 0  2c 0
Word AppendParagraph $docId

Word AppendText $docId "Square cropped at the right side:\n"
set cropId4 [Word InsertImage [Word GetEndRange $docId] $squareImg]
Word CropImage $cropId4 0 0  0 2c
Word AppendParagraph $docId

#
# Note: Image names are available only in Word 2010 and newer.
#
Cawt CheckNumber 12 [Word GetNumImages $docId] "Number of images: "
puts "Replacing images ..."
Word AddPageBreak [Word GetEndRange $docId]
Word AppendText $docId "Images replaced with other images\n"

Word AppendText $docId "Landscape replaced with Square (-keepsize true):\n"
set replaceId1 [Word InsertImage [Word GetEndRange $docId] $landscapeImg]
catch { Word SetImageName $replaceId1 "LandscapeToSquare" }
Word AppendParagraph $docId

Word AppendText $docId "Portrait replaced with Square (-keepsize true):\n"
set replaceId2 [Word InsertImage [Word GetEndRange $docId] $portraitImg]
catch { Word SetImageName $replaceId2 "PortraitToSquare" }
Word AppendParagraph $docId

Word AppendText $docId "Landscape replaced with Square (-keepsize false):\n"
set replaceId3 [Word InsertImage [Word GetEndRange $docId] $landscapeImg]
catch { Word SetImageName $replaceId3 "LandscapeToSquareScaled" }
Word AppendParagraph $docId

Word AppendText $docId "Portrait replaced with Square (-keepsize false):\n"
set replaceId4 [Word InsertImage [Word GetEndRange $docId] $portraitImg]
catch { Word SetImageName $replaceId4 "PortraitToSquareScaled" }
Word AppendParagraph $docId

if { [Word GetVersion $appId] < 14.0 } {
    set indexOrName1 13
    set indexOrName2 14
    set indexOrName3 15
    set indexOrName4 16
} else {
    set indexOrName1 "LandscapeToSquare"
    set indexOrName2 "PortraitToSquare"
    set indexOrName3 "LandscapeToSquareScaled"
    set indexOrName4 "PortraitToSquareScaled"
}
set imgId1 [Word GetImageId $docId $indexOrName1]
Word ReplaceImage $imgId1 $squareImg -keepsize true

set imgId2 [Word GetImageId $docId $indexOrName2]
Word ReplaceImage $imgId2 $squareImg -keepsize true

set imgId3 [Word GetImageId $docId $indexOrName3]
Word ReplaceImage $imgId3 $squareImg -keepsize false

set imgId4 [Word GetImageId $docId $indexOrName4]
Word ReplaceImage $imgId4 $squareImg

Cawt CheckNumber 16 [Word GetNumImages $docId] "Number of images: "

puts "Images in a table ..."
Word AddPageBreak [Word GetEndRange $docId]
Word AppendText $docId "Image tables\n"

Word AppendText $docId "Table with 3 columns (Images and Caption):\n"
set imgList  [list $squareImg $landscapeImg $portraitImg]
set textList [list "Square Image" "Landscape Image" "Portrait Image"]
set tableId [Word AddImageTable [Word GetEndRange $docId] 3 $imgList $textList]
Word SetTableBorderLineStyle $tableId
Word AppendParagraph $docId
Cawt CheckNumber 2 [Word GetNumRows    $tableId] "Number of rows   : "
Cawt CheckNumber 3 [Word GetNumColumns $tableId] "Number of columns: "

Word AppendText $docId "Table with 1 column (Images only):\n"
set tableId [Word AddImageTable [Word GetEndRange $docId] 1 $imgList]
Word SetTableBorderLineStyle $tableId
Word AppendParagraph $docId
Cawt CheckNumber 3 [Word GetNumRows    $tableId] "Number of rows   : "
Cawt CheckNumber 1 [Word GetNumColumns $tableId] "Number of columns: "

Cawt CheckNumber 22 [Word GetNumImages $docId] "Number of images: "

# Save document as Word file.
puts "Saving as Word file: $wordFile"
Word SaveAs $docId $wordFile

Cawt PrintNumComObjects

if { [lindex $argv 0] eq "auto" } {
    Word Quit $appId
    Cawt Destroy
    exit 0
}
Cawt Destroy
