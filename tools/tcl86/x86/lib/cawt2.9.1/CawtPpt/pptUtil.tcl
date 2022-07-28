# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Ppt {
    namespace ensemble create

    namespace export ExportPptFile
    namespace export GetPresImages
    namespace export GetPresVideos

    proc _CreateThumbImg { phImg phName maxThumbSize } {
        set w [image width  $phImg]
        set h [image height $phImg]

        if { $w > $h } {
            set ws [expr int ($maxThumbSize)]
            set hs [expr int ((double($h)/double($w)) * $maxThumbSize)]
        } else {
            set ws [expr int ((double($w)/double($h)) * $maxThumbSize)]
            set hs [expr int ($maxThumbSize)]
        }
        set thumbImg [image create photo $phName -width $ws -height $hs]
        set xsub [expr ($w / $ws) + 1]
        set ysub [expr ($h / $hs) + 1]
        $thumbImg copy $phImg -subsample $xsub $ysub -to 0 0
        return $thumbImg
    }

    proc ExportPptFile { pptFile outputDir  outputFileFmt { startIndex 1 } { endIndex "end" } \
                         { imgType "GIF" } { width -1 } { height -1 } \
                         { useMaster true } { genHtmlTable true } { thumbsPerRow 4 } { thumbSize 150 }  } {
        # Export a PowerPoint file to an image sequence.
        #
        # pptFile       - Name of the PowerPoint file.
        # outputDir     - Name of the output folder.
        # outputFileFmt - Name of the output file names.
        # startIndex    - Start index for slide export.
        # endIndex      - End index for slide export.
        # imgType       - Name of the image format filter. This is the name as stored in
        #                 the Windows registry. Supported names: `BMP` `GIF` `JPG` `PNG` `TIF`.
        # width         - Width of the generated images in pixels.
        # height        - Height of the generated images in pixels.
        # useMaster     - If set to true, export with the contents of the master slide.
        #                 Otherwise do not export the contents of the master slide.
        # genHtmlTable  - Additionally generate a HTML table with preview images.
        # thumbsPerRow  - Number of preview images per HTML table row.
        # thumbSize     - Maximum size of the preview images in pixels.
        #
        # If the output directory does not exist, it is created.
        # Caution: All existing files in the output directory are deleted before exporting.
        #
        # The output file name must contain either a `%s` or a `%d` format.
        # In the first case, it is assumed that each slide has a comment of the form
        # `Export: Name`, where `Name` is substituted for the `%s` format option.
        # If the output file name contains a `%d` format option, the slide number
        # is substituted instead. 
        #
        # If $width and $height are not specified or less than zero, the default sizes
        # of PowerPoint are used.
        #
        # Returns no value.
        #
        # See also: ExportSlide ExportSlides

        set appId [Ppt OpenNew]

        # Open presentation file in read-only mode
        set presId [Ppt OpenPres $appId $pptFile -readonly true]

        set actWin  [$appId ActiveWindow]
        set actPres [$appId ActivePresentation]

        if { ! $useMaster } {
            # ViewType throws an error, if the corresponding master slide
            # is not available.
            set retVal [catch {$actWin ViewType $Ppt::ppViewTitleMaster}]
            if { $retVal == 0 } {
                set shape [$actPres -with { TitleMaster } Shapes]
                $shape SelectAll
                set curSelection [$actWin Selection]
                # Delete all shapes from the master slide. No problem, as
                # we opened the presentation in read-only mode.
                if { [$curSelection Type] != $Ppt::ppSelectionNone } {
                    $actWin -with { Selection ShapeRange } Delete
                }
                Cawt Destroy $curSelection
                Cawt Destroy $shape
            }

            set retVal [catch {$actWin ViewType $Ppt::ppViewSlideMaster}]
            if { $retVal == 0 } {
                set shape [$actPres -with { SlideMaster } Shapes]
                $shape SelectAll
                set curSelection [$actWin Selection]
                if { [$curSelection Type] != $Ppt::ppSelectionNone } {
                    $actWin -with { Selection ShapeRange } Delete
                }
                Cawt Destroy $curSelection
                Cawt Destroy $shape
            }
        }
        $actWin ViewType $Ppt::ppViewSlide

        if { [file isdir $outputDir] } {
            file delete -force $outputDir
        }

        Ppt ExportSlides $actPres $outputDir $outputFileFmt $startIndex $endIndex $imgType $width $height
        Ppt Close $presId
        Ppt Quit  $appId

        Cawt Destroy $actWin
        Cawt Destroy $actPres
        Cawt Destroy $presId
        Cawt Destroy $appId

        if { $genHtmlTable } {
            package require Tk
            set haveImg true
            set retVal [catch {package require Img} version]
            if { $retVal } {
                set haveImg false
            }

            set dirCont [glob -directory $outputDir \
                         [format "*.%s" [string tolower $imgType]]]
            if { [llength $dirCont] == 0 } {
                set dirCont [glob -directory $outputDir \
                         [format "*.%s" [string toupper $imgType]]]
            }
            set noImgs [llength $dirCont]
            set count 1
            set htmlStr "<html>\n<head>\n</head>\n\n<body>\n"
            append htmlStr "<center><h2>\n"
            append htmlStr "  Presentation [file tail $pptFile]\n"
            append htmlStr "</center></h2>\n\n"
            append htmlStr "<center>\n"
            append htmlStr "<table border cellpadding=5>\n"
            append htmlStr "  <tr>\n"
            set c 0
            foreach fileName [lsort -dictionary $dirCont] {
                set dirName   [file dirname $fileName]
                set shortName [file tail $fileName]
                set rootName  [file rootname $shortName]
                set extension [file extension $shortName]
                set catchVal [catch {image create photo -file $fileName} phImg]
                set thumbImg [Ppt::_CreateThumbImg $phImg "thumb" $thumbSize]

                set thumbName [format "%s.thumb%s" $rootName $extension]
                set tkFmt $imgType
                if { $imgType eq "JPG" } {
                    set tkFmt "JPEG"
                } elseif { $imgType eq "TIF" } {
                    set tkFmt "TIFF"
                }
                $thumbImg write [file join $dirName $thumbName] -format $tkFmt
                image delete $phImg
                image delete $thumbImg
                incr count
                append htmlStr [format "    <td><a href=\"./%s\"> \
                    <img src=\"./%s\" alt=\"%s\"></a></td>\n" \
                    $shortName $thumbName $shortName]
                incr c
                if { $c == $thumbsPerRow } {
                    set c 0
                    append htmlStr "  </tr>\n  <tr>\n"
                }
            }
            append htmlStr "  </tr>\n"
            append htmlStr "</table>\n\n"
            append htmlStr "</center>\n"
            append htmlStr "<hr>\n"
            set curTime [clock format [clock seconds] -format "%Y-%m-%d %H:%M"]
            append htmlStr "<center><small>Last update: $curTime</small></center>\n"
            append htmlStr "\n</body>\n</html>"
            # Write out HTML file
            set fp [open [file join $outputDir "index.html"] "w"]
            puts $fp $htmlStr
            close $fp
        }
    }

    proc GetPresImages { presId } {
        # Get the images of a presentation.
        #
        # presId - Identifier of the presentation.
        #
        # Returns a key-value list containing the image name and its
        # corresponding slide index.
        #
        # See also: InsertImage GetSlideImages GetPresVideos GetShapeType GetShapeMediaType

        set imgList [list]
        set numSlides [Ppt GetNumSlides $presId]
        for { set i 1 } { $i <= $numSlides } { incr i } {
            set slideId [Ppt GetSlideId $presId $i]
            foreach imgName [Ppt::GetSlideImages $slideId] {
                lappend imgList $imgName $i
            }
            Cawt Destroy $slideId
        }
        return $imgList
    }

    proc GetPresVideos { presId } {
        # Get the videos of a presentation.
        #
        # presId - Identifier of the presentation.
        #
        # Returns a key-value list containing the video name and its
        # corresponding slide index.
        #
        # See also: InsertVideo GetSlideVideos GetPresImages GetShapeType GetShapeMediaType

        set videoList [list]
        set numSlides [Ppt GetNumSlides $presId]
        for { set i 1 } { $i <= $numSlides } { incr i } {
            set slideId [Ppt GetSlideId $presId $i]
            foreach videoName [Ppt::GetSlideVideos $slideId] {
                lappend videoList $videoName $i
            }
            Cawt Destroy $slideId
        }
        return $videoList
    }
}
