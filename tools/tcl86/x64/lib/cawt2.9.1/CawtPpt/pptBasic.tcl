# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Ppt {

    namespace ensemble create

    namespace export AddPres
    namespace export AddSlide
    namespace export AddTextbox
    namespace export AddTextboxText
    namespace export CheckCreateVideoStatus
    namespace export Close
    namespace export CloseAll
    namespace export CopySlide
    namespace export CreateVideo
    namespace export ExitSlideShow
    namespace export ExportSlide
    namespace export ExportSlides
    namespace export GetActivePres
    namespace export GetComments
    namespace export GetCommentKeyValue
    namespace export GetCommentKeyTopPosition
    namespace export GetCurrentSlideIndex
    namespace export GetCustomLayoutId
    namespace export GetCustomLayoutName
    namespace export GetExtString
    namespace export GetNumComments
    namespace export GetNumCustomLayouts
    namespace export GetNumSlideShows
    namespace export GetNumSlideImages
    namespace export GetNumSlides
    namespace export GetNumSlideVideos
    namespace export GetPresPageHeight
    namespace export GetPresPageWidth
    namespace export GetPptImageFormat
    namespace export GetSlideId
    namespace export GetSlideIdByName
    namespace export GetSlideImages
    namespace export GetSlideIndex
    namespace export GetSlideName
    namespace export GetSlideVideos
    namespace export GetSupportedImageFormats
    namespace export GetTemplateExtString
    namespace export GetVersion
    namespace export GetCreateVideoStatus
    namespace export GetViewType
    namespace export InsertImage
    namespace export InsertVideo
    namespace export IsImageFormatSupported
    namespace export IsValidPresId
    namespace export MoveSlide
    namespace export Open
    namespace export OpenNew
    namespace export OpenPres
    namespace export Quit
    namespace export SaveAs
    namespace export SetPresPageSetup
    namespace export SetSlideName
    namespace export SetSlideShowTransition
    namespace export SetTextboxFontSize
    namespace export SetViewType
    namespace export ShowAlerts
    namespace export ShowSlide
    namespace export SlideShowFirst
    namespace export SlideShowLast
    namespace export SlideShowNext
    namespace export SlideShowPrev
    namespace export UseSlideShow
    namespace export Visible

    variable pptVersion  "0.0"
    variable pptAppName  "PowerPoint.Application"

    variable _ruff_preamble {
        The `Ppt` namespace provides commands to control Microsoft PowerPoint.
    }

    proc GetVersion { objId { useString false } } {
        # Return the version of a PowerPoint application.
        #
        # objId     - Identifier of a PowerPoint object instance.
        # useString - If set to true, return the version name (ex. `PowerPoint 2003`).
        #             Otherwise return the version number (ex. `11.0`).
        #
        # Returns the version of a PowerPoint application.
        # Both version name and version number are returned as strings.
        # Version number is in a format, so that it can be evaluated as a
        # floating point number.
        #
        # See also: GetExtString

        array set map {
            "8.0"  "PowerPoint 97"
            "9.0"  "PowerPoint 2000"
            "10.0" "PowerPoint 2002"
            "11.0" "PowerPoint 2003"
            "12.0" "PowerPoint 2007"
            "14.0" "PowerPoint 2010"
            "15.0" "PowerPoint 2013"
            "16.0" "PowerPoint 2016/2019"
        }
        set version [Office GetApplicationVersion $objId]
        if { $useString } {
            if { [info exists map($version)] } {
                return $map($version)
            } else {
                return "Unknown PowerPoint version"
            }
        } else {
            return $version
        }
        return $version
    }

    proc GetExtString { appId } {
        # Return the default extension of a PowerPoint file.
        #
        # appId - Identifier of the PowerPoint instance.
        #
        # Starting with PowerPoint 12 (2007) this is the string `.pptx`.
        # In previous versions it was `.ppt`.
        #
        # Returns the default extension of a PowerPoint file.
        #
        # See also: ::Office::GetOfficeType

        # appId is only needed, so we are sure, that pptVersion is initialized.

        variable pptVersion

        if { $pptVersion >= 12.0 } {
            return ".pptx"
        } else {
            return ".ppt"
        }
    }

    proc GetTemplateExtString { appId } {
        # Return the default extension of a PowerPoint template file.
        #
        # appId - Identifier of the PowerPoint instance.
        #
        # Starting with PowerPoint 12 (2007) this is the string `.potx`.
        # In previous versions it was `.pot`.
        #
        # Returns the default extension of a PowerPoint template file.

        # appId is only needed, so we are sure, that pptVersion is initialized.

        variable pptVersion

        if { $pptVersion >= 12.0 } {
            return ".potx"
        } else {
            return ".pot"
        }
    }

    proc OpenNew { { width -1 } { height -1 } } {
        # Open a new PowerPoint instance.
        #
        # width   - Width of the application window. If negative, open with last used width.
        # height  - Height of the application window. If negative, open with last used height.
        #
        # Returns the identifier of the new PowerPoint application instance.
        #
        # See also: Open Quit

        variable pptAppName
        variable pptVersion

        set appId [Cawt GetOrCreateApp $pptAppName false]
        set pptVersion [Ppt GetVersion $appId]
        Ppt Visible $appId true
        if { $width >= 0 } {
            $appId Width [expr $width]
        }
        if { $height >= 0 } {
            $appId Height [expr $height]
        }
        return $appId
    }

    proc Open { { width -1 } { height -1 } } {
        # Open a PowerPoint instance. Use an already running instance, if available.
        #
        # width  - Width of the application window. If negative, open with last used width.
        # height - Height of the application window. If negative, open with last used height.
        #
        # Returns the identifier of the PowerPoint application instance.
        #
        # See also: OpenNew Quit

        variable pptAppName
        variable pptVersion

        set appId [Cawt GetOrCreateApp $pptAppName true]
        set pptVersion [Ppt GetVersion $appId]
        Ppt Visible $appId true
        if { $width >= 0 } {
            $appId Width [expr $width]
        }
        if { $height >= 0 } {
            $appId Height [expr $height]
        }
        return $appId
    }

    proc ShowAlerts { appId onOff } {
        # Toggle the display of PowerPoint application alerts.
        #
        # appId - The application identifier.
        # onOff - Switch the alerts on or off.
        #
        # Returns no value.

        if { $onOff } {
            set alertLevel [expr $Ppt::ppAlertsAll]
        } else {
            set alertLevel [expr $Ppt::ppAlertsNone]
        }
        $appId DisplayAlerts $alertLevel
    }

    proc Quit { appId { showAlert true } } {
        # Quit a PowerPoint instance.
        #
        # appId     - Identifier of the PowerPoint instance.
        # showAlert - If set to true, show an alert window, if there are unsaved changes.
        #             Otherwise quit without saving any changes.
        #
        # Note, that the $showAlert parameter does not work. 
        # PowerPoint always quits without showing the alert window.
        #
        # Returns no value.
        #
        # See also: Open

        Ppt::ShowAlerts $appId $showAlert
        $appId Quit
    }

    proc Visible { appId visible } {
        # Toggle the visibility of a PowerPoint application window.
        #
        # appId   - Identifier of the PowerPoint instance.
        # visible - If set to true, show the application window.
        #           Otherwise hide the application window.
        #
        # Returns no value.
        #
        # See also: Open OpenNew

        $appId Visible [Cawt TclInt $visible]
    }


    proc Close { presId } {
        # Close a presentation without saving changes.
        #
        # presId - Identifier of the presentation to close.
        #
        # Use the [SaveAs] method before closing, if you want to save changes.
        #
        # Returns no value.
        #
        # See also: SaveAs CloseAll

        $presId Close
    }

    proc CloseAll { appId } {
        # Close all presentations of a PowerPoint instance.
        #
        # appId - Identifier of the PowerPoint instance.
        #
        # Use the [SaveAs] method before closing, if you want to save changes.
        #
        # Returns no value.
        #
        # See also: SaveAs Close

        set numWins [$appId -with { Windows } Count]
        for { set ind $numWins } { $ind >= 1 } { incr ind -1 } {
            [$appId -with { Windows } Item $ind] Activate
            $appId -with { ActiveWindow } Close
        }
    }

    proc SaveAs { presId fileName { fmt "" } { embedFonts true } } {
        # Save a presentation to a PowerPoint file.
        #
        # presId     - Identifier of the presentation to save.
        # fileName   - Name of the PowerPoint file.
        # fmt        - Value of enumeration type [Enum::PpSaveAsFileType].
        #              If not given or the empty string, the file is stored in the native
        #              format corresponding to the used PowerPoint version (`ppSaveAsDefault`).
        # embedFonts - If set to true, embed `TrueType` fonts.
        #              Otherwise do not embed `TrueType` fonts.
        #
        # **Note:**
        # If $fmt is not a PowerPoint format, but an image format, PowerPoint takes the
        # specified file name and creates a directory with that name. Then it copies all
        # slides as images into that directory. The slide images are automatically named by
        # PowerPoint (ex. in German versions the slides are called Folie1.gif, Folie2.gif, ...).
        # Use the [ExportSlide] procedure, if you want full control over image file names.
        #
        # Returns no value.
        #
        # See also: ExportSlides ExportSlide

        set fileName [file nativename [file normalize $fileName]]
        set appId [Office GetApplicationId $presId]
        Ppt::ShowAlerts $appId false
        if { $fmt eq "" } {
            $presId SaveAs $fileName
        } else {
            $presId -callnamedargs SaveAs \
                     FileName $fileName \
                     FileFormat [Ppt GetEnum $fmt] \
                     EmbedTrueTypeFonts [Cawt TclInt $embedFonts]
        }
        Ppt::ShowAlerts $appId true
        Cawt Destroy $appId
    }

    proc IsValidPresId { presId } {
        # Check, if a presentation identifier is valid.
        #
        # presId - Identifier of the presentation.
        #
        # Returns true, if $presId is valid.
        # Otherwise returns false.
        #
        # See also: Open Close AddPres

        set catchVal [catch { $presId PageSetup }]
        if { $catchVal == 0 } {
            return true
        }
        return false
    }

    proc AddPres { appId { templateFile "" }  } {
        # Add a new empty presentation.
        #
        # appId        - Identifier of the PowerPoint instance.
        # templateFile - Name of an optional template file.
        #
        # Returns the identifier of the new presentation.
        #
        # See also: OpenPres GetActivePres

        variable pptVersion

        set presId [$appId -with { Presentations } Add]
        if { $templateFile ne "" } {
            if { $pptVersion < 12.0 } {
                error "CustomLayout available only in PowerPoint 2007 or newer. Running [Ppt GetVersion $appId true]."
            }
            set nativeName [file nativename [file normalize $templateFile]]
            $presId ApplyTemplate $nativeName
        }
        return $presId
    }

    proc OpenPres { appId fileName args } {
        # Open a presentation, i.e. load a PowerPoint file.
        #
        # appId    - Identifier of the PowerPoint instance.
        # fileName - Name of the PowerPoint file.
        # args     - Options described below.
        #
        # -readonly <bool> - If set to true, open the workbook in read-only mode.
        #                    Default is to open the workbook in read-write mode.
        # -embed <frame>   - Embed the workbook into a Tk frame. This frame must
        #                    exist and must be created with option `-container true`.
        #
        # Returns the identifier of the opened presentation.
        # If the presentation was already open, activate that presentation
        # and return the identifier to that presentation.
        #
        # See also: AddPres GetActivePres

        set opts [dict create \
            -readonly false   \
            -embed    ""      \
        ]
        if { [llength $args] == 1 } {
            # Old mode with optional boolean parameter readOnly
            dict set opts -readonly [lindex $args 0]
        } else {
            foreach { key value } $args {
                if { [dict exists $opts $key] } {
                    if { $value eq "" } {
                        error "OpenPres: No value specified for key \"$key\"."
                    }
                    dict set opts $key $value
                } else {
                    error "OpenPres: Unknown option \"$key\" specified."
                }
            }
        }

        set nativeName [file nativename [file normalize $fileName]]
        set presentations [$appId Presentations]
        set retVal [catch {[$presentations Item [file tail $fileName]] Activate} d]
        if { $retVal == 0 } {
            set presId [$presentations Item [file tail $fileName]]
        } else {
            set presId [$presentations Open $nativeName [Cawt TclInt [dict get $opts "-readonly"]]]
        }
        Cawt Destroy $presentations

        set embedFrame [dict get $opts "-embed"]
        if { $embedFrame ne "" } {
            Cawt EmbedApp $embedFrame -appid [Office GetApplicationId $presId] -filename $fileName
        }
        return $presId
    }

    proc GetActivePres { appId } {
        # Return the active presentation of an application.
        #
        # appId - Identifier of the PowerPoint instance.
        #
        # Returns the identifier of the active presentation.
        #
        # See also: OpenPres AddPres

        return [$appId ActivePresentation]
    }

    proc SetPresPageSetup { presId args } {
        # Set the page size of a presentation.
        #
        # presId - Identifier of the presentation.
        # args   - Options described below.
        #
        # -width <size>  - Set the width of the presentation slides.
        # -height <size> - Set the height of the presentation slides.
        #
        # The width and height values may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: AddPres OpenPres GetPresPageWidth GetPresPageHeight

        set pageSetup [$presId PageSetup]
        foreach { key value } $args {
            if { $value eq "" } {
                error "SetPresPageSetup: No value specified for key \"$key\""
            }
            set pointValue [Cawt ValueToPoints $value]
            switch -exact -nocase -- $key {
                "-width"  { $pageSetup SlideWidth  $pointValue }
                "-height" { $pageSetup SlideHeight $pointValue }
                 default  { error "SetPresPageSetup: Unknown key \"$key\" specified" }
            }
        }
        Cawt Destroy $pageSetup
    }

    proc GetPresPageWidth { presId } {
        # Get the page width of a presentation.
        #
        # presId - Identifier of the presentation.
        #
        # Returns the page width in points.
        #
        # See also: SetPresPageSetup GetPresPageHeight ::Cawt::PointsToCentiMeters

        set pageSetup [$presId PageSetup]
        set width [$pageSetup SlideWidth]
        Cawt Destroy $pageSetup
        return $width
    }

    proc GetPresPageHeight { presId } {
        # Get the page height of a presentation.
        #
        # presId - Identifier of the presentation.
        #
        # Returns the page height in points.
        #
        # See also: SetPresPageSetup GetPresPageWidth ::Cawt::PointsToCentiMeters

        set pageSetup [$presId PageSetup]
        set height [$pageSetup SlideHeight]
        Cawt Destroy $pageSetup
        return $height
    }

    proc SetViewType { presId viewType } {
        # Set the view type of a presentation.
        #
        # presId   - Identifier of the presentation.
        # viewType - Value of enumeration type [Enum::PpViewType].
        #
        # Returns no value.
        #
        # See also: GetViewType

        set appId [Office GetApplicationId $presId]
        set actWin [$appId ActiveWindow]
        $actWin ViewType [Ppt GetEnum $viewType]
        Cawt Destroy $actWin
        Cawt Destroy $appId
    }

    proc GetViewType { presId } {
        # Return the view type of a presentation.
        #
        # presId - Identifier of the presentation.
        #
        # Returns the view type of the presentation.
        #
        # See also: SetViewType

        set appId [Office GetApplicationId $presId]
        set actWin [$appId ActiveWindow]
        set viewType [$actWin ViewType]
        Cawt Destroy $actWin
        Cawt Destroy $appId
        return $viewType
    }

    proc AddSlide { presId { type ppLayoutBlank } { slideIndex -1 } } {
        # Add a new slide to a presentation.
        #
        # presId     - Identifier of the presentation.
        # type       - Value of enumeration type [Enum::PpSlideLayout] or
        #              CustomLayout object.
        # slideIndex - Insertion index of new slide. Slide indices start at 1.
        #              If negative or `end`, add slide at the end.
        #
        # Note, that CustomLayouts are not supported with PowerPoint versions before 2007.
        #
        # Returns the identifier of the new slide.
        #
        # See also: CopySlide GetNumSlides GetCustomLayoutName GetCustomLayoutId

        variable pptVersion

        set typeInt [Ppt GetEnum $type]
        if { $typeInt eq "" } {
            # type seems to be a CustomLayout object.
            if { $pptVersion < 12.0 } {
                error "CustomLayout available only in PowerPoint 2007 or newer. Running [Ppt GetVersion $presId true]."
            }
        }

        if { $slideIndex eq "" || $slideIndex < 0 } {
            set slideIndex [expr [Ppt GetNumSlides $presId] +1]
        }
        if { $typeInt eq "" } {
            set newSlide [$presId -with { Slides } AddSlide $slideIndex $type]
        } else {
            set newSlide [$presId -with { Slides } Add $slideIndex $typeInt]
        }
        set newSlideIndex [Ppt GetSlideIndex $newSlide]
        Ppt ShowSlide $presId $newSlideIndex
        return $newSlide
    }

    proc GetCurrentSlideIndex { presId } {
        # Return the current slide index of a presentation.
        #
        # presId - Identifier of the presentation.
        #
        # Returns the slide index of the current slide of the presentation.
        #
        # See also: AddSlide ShowSlide

        set appId [Office GetApplicationId $presId]
        set actWin [$appId ActiveWindow]
        set slideIndex [$actWin -with { View Slide } SlideIndex]
        Cawt Destroy $actWin
        Cawt Destroy $appId
        return $slideIndex
    }

    proc SetSlideShowTransition { slideId args } {
        # Set transition attributes of a slide.
        #
        # slideId - Identifier of the slide.
        # args    - Options described below.
        #
        # -duration <double>    - Set the length of an animation in seconds.
        # -advancetime <double> - Set the slide advance time in seconds.
        # -effect <enum>        - Set the special effect applied to the slide transition.
        #                         Enumeration of type [Enum::PpEntryEffect].
        #
        # If no options are specified, PowerPoint default values are used.
        #
        # Returns no value.
        #
        # See also: AddSlide InsertImage CreateVideo

        foreach { key value } $args {
            if { $value eq "" } {
                error "SetSlideShowTransition: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-duration" {
                    $slideId -with { SlideShowTransition } Duration [expr {double ($value)}]
                }
                "-advancetime" {
                    $slideId -with { SlideShowTransition } AdvanceOnTime [Cawt TclInt true]
                    $slideId -with { SlideShowTransition } AdvanceTime   [expr {double ($value)}]
                }
                "-effect" {
                    $slideId -with { SlideShowTransition } EntryEffect [Ppt GetEnum $value]
                }
                default {
                    error "SetSlideShowTransition: Unknown key \"$key\" specified" 
                }
            }
        }
    }

    proc CopySlide { presId fromSlideIndex { toSlideIndex -1 } { toPresId "" } } {
        # Make a copy of a slide.
        #
        # presId         - Identifier of the presentation.
        # fromSlideIndex - Index of source slide. Slide indices start at 1.
        #                  If negative or `end`, use last slide as source.
        # toSlideIndex   - Insertion index of copied slide. Slide indices start at 1.
        #                  If negative or `end`, insert slide at the end.
        # toPresId       - Identifier of the presentation the slide is copied to. If not specified
        #                  or the empty string, the slide is copied into presentation $presId.
        #
        # A new empty slide is created at the insertion index and the contents of the source
        # slide are copied into the new slide.
        #
        # Returns the identifier of the new slide.
        #
        # See also: AddSlide GetNumSlides MoveSlide

        if { $toPresId eq "" } {
            set toPresId $presId
        }
        if { $toSlideIndex eq "end" || $toSlideIndex < 0 } {
            set toSlideIndex [expr [Ppt GetNumSlides $toPresId] +1]
        }
        if { $fromSlideIndex eq "end" || $fromSlideIndex < 0 } {
            set fromSlideIndex [expr [Ppt GetNumSlides $presId] +1]
        }

        set fromSlideId [Ppt GetSlideId $presId $fromSlideIndex]
        $fromSlideId Copy

        Cawt WaitClipboardReady
        $toPresId -with { Slides } Paste
        set toSlideId [Ppt GetSlideId $toPresId end]
        Ppt MoveSlide $toSlideId $toSlideIndex

        Ppt ShowSlide $toPresId $toSlideIndex

        Cawt Destroy $fromSlideId

        return $toSlideId
    }

    proc GetCommentKeyValue { slideId key } {
        # Return the value of a key stored in a comment.
        #
        # slideId - Identifier of the slide.
        # key     - Key to search for.
        #
        # All comments of the specified slide are search for strings of the
        # form `Key: Value`.
        #
        # Returns the corresponding value, if the key is found in the comments.
        # Otherwise an empty string is returned.
        #
        # See also: GetNumComments GetComments GetCommentKeyTopPosition
        # ExportSlides

        set value ""
        if { [Ppt GetNumComments $slideId] > 0 } {
            foreach comment [Ppt GetComments $slideId] {
                if { [string match "$key:*" $comment] } {
                    set value [string trim [lindex [split $comment ":"] 1]]
                    break
                }
            }
        }
        return $value
    }

    proc GetCommentKeyTopPosition { slideId key } {
        # Return the top position of a comment with specific key.
        #
        # slideId - Identifier of the slide.
        # key     - Key to search for.
        #
        # All comments of the specified slide are searched for strings of the
        # form `Key: Value`.
        #
        # Returns the top position of the comment, if the key is found in the
        # comments. Otherwise an empty string is returned.
        #
        # See also: GetNumComments GetComments GetCommentKeyValue ExportSlides

        set numComments [Ppt GetNumComments $slideId]
        set commentsId [$slideId Comments]
        set top ""
        for { set commentInd 1 } { $commentInd <= $numComments } { incr commentInd } {
            set commentId [$commentsId Item $commentInd]
            set comment [$commentId Text]
            if { [string match "$key:*" $comment] } {
                set top [$commentId Top]
            }
            Cawt Destroy $commentId
        }
        Cawt Destroy $commentsId
        return $top
    }

    proc ExportSlide { slideId outputFile { imgType "GIF" } { width -1 } { height -1 } } {
        # Export a slide as an image.
        #
        # slideId    - Identifier of the slide.
        # outputFile - Name of the output file.
        # imgType    - Name of the image format filter. This is the name as stored in
        #              the Windows registry. Supported names: `BMP` `GIF` `JPG` `PNG` `TIF`.
        # width      - Width of the generated images in pixels.
        # height     - Height of the generated images in pixels.
        #
        # If $width and $height are not specified or less than zero, the default sizes
        # of PowerPoint are used.
        #
        # Returns no value. If the export failed, an error is thrown.
        #
        # See also: ExportPptFile ExportSlides

        set nativeName [file nativename [file normalize $outputFile]]
        if { $width >= 0 && $height >= 0 } {
            set retVal [catch {$slideId Export $nativeName $imgType $width $height} errMsg]
        } else {
            set retVal [catch {$slideId Export $nativeName $imgType} errMsg]
        }
        if { $retVal } {
            error "Slide export failed. ( $errMsg )"
        }
    }

    proc ExportSlides { presId outputDir outputFileFmt { startIndex 1 } { endIndex "end" } \
                        { imgType "GIF" } { width -1 } { height -1 } } {
        # Export a range of slides as image files.
        #
        # presId        - Identifier of the presentation.
        # outputDir     - Name of the output folder.
        # outputFileFmt - Name of the output file names.
        # startIndex    - Start index for slide export.
        # endIndex      - End index for slide export.
        # imgType       - Name of the image format filter. This is the name as stored in
        #                 the Windows registry. Supported names: `BMP` `GIF` `JPG` `PNG` `TIF`.
        # width         - Width of the generated images in pixels.
        # height        - Height of the generated images in pixels.
        #
        # If the output directory does not exist, it is created.
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
        # Returns no value. If the export failed, an error is thrown.
        #
        # See also: ExportPptFile ExportSlide

        set numSlides [Ppt GetNumSlides $presId]
        if { $startIndex < 1 || $startIndex > $numSlides } {
            error "startIndex ($startIndex) not in slide range."
        }
        if { $endIndex eq "end" } {
            set endIndex $numSlides
        }
        if { $endIndex < 1 || $endIndex > $numSlides || $endIndex < $startIndex } {
            error "endIndex ($endIndex) not in slide range."
        }

        if { ! [file isdir $outputDir] } {
            file mkdir $outputDir
        }

        for { set i $startIndex } { $i <= $endIndex } { incr i } {
            set slideId [Ppt GetSlideId $presId $i]
            set outputFile [file join $outputDir $outputFileFmt]
            set exportSlide true

            if { [string match "*\%s*" $outputFile] } {
                set exportFileName [Ppt GetCommentKeyValue $slideId "Export"]
                if { $exportFileName eq "" } {
                    set exportSlide false
                }
                set outputFile [format $outputFile $exportFileName]
            } else {
                set outputFile [format $outputFile $i]
            }
            if { $exportSlide } {
                Ppt ExportSlide $slideId $outputFile $imgType $width $height
            }
            Cawt Destroy $slideId
        }
    }

    proc ShowSlide { presId slideIndex } {
        # Show a specific slide.
        #
        # presId     - Identifier of the presentation.
        # slideIndex - Index of slide. Slide indices start at 1.
        #              If negative or `end`, show last slide.
        #
        # Returns no value.
        #
        # See also: GetNumSlides

        if { $slideIndex eq "end" || $slideIndex < 0 } {
            set slideIndex [GetNumSlides $presId]
        }
        set slideId [$presId -with { Slides } Item $slideIndex]
        $slideId Select
        Cawt Destroy $slideId
    }

    proc GetNumSlides { presId } {
        # Return the number of slides of a presentation.
        #
        # presId - Identifier of the presentation.
        #
        # Returns the number of slides of the presentation.
        #
        # See also: GetNumSlideShows

        return [$presId -with { Slides } Count]
    }

    proc GetSlideIndex { slideId } {
        # Return the index of a slide.
        #
        # slideId - Identifier of the slide.
        #
        # Returns the index of the slide.
        #
        # See also: GetNumSlides AddSlide

        return [$slideId SlideIndex]
    }

    proc GetSlideId { presId slideIndex } {
        # Get slide identifier from slide index.
        #
        # presId     - Identifier of the presentation.
        # slideIndex - Index of slide. Slide indices start at 1.
        #              If negative or `end`, use last slide.
        #
        # Returns the identifier of the slide.
        #
        # See also: GetNumSlides AddSlide

        if { $slideIndex eq "end" || $slideIndex < 0 } {
            set slideIndex [GetNumSlides $presId]
        }
        set slideId [$presId -with { Slides } Item $slideIndex]
        return $slideId
    }

    proc GetSlideName { slideId } {
        # Return the name of a slide.
        #
        # slideId - Identifier of the slide.
        #
        # Returns the name of the slide.
        #
        # See also: GetSlideId GetNumSlides AddSlide SetSlideName

        return [$slideId Name]
    }

    proc SetSlideName { slideId slideName } {
        # Set the name of a worksheet.
        #
        # slideId   - Identifier of the slide.
        # slideName - Name of the slide.
        #
        # Returns no value.
        #
        # See also: GetSlideId GetNumSlides AddSlide GetSlideName

        $slideId Name $slideName
    }

    proc GetSlideIdByName { presId slideName } {
        # Find a slide by its name.
        #
        # presId    - Identifier of the presentation.
        # slideName - Name of the slide to find.
        #
        # Returns the identifier of the found slide.
        # If a slide with given name does not exist an error is thrown.
        #
        # See also: GetSlideId GetNumSlides AddSlide GetSlideName

        set numSlides [Ppt GetNumSlides $presId]
        for { set i 1 } { $i <= $numSlides } { incr i } {
            set slideId [Ppt GetSlideId $presId $i]
            if { $slideName eq [$slideId Name] } {
                return $slideId
            }
            Cawt Destroy $slideId
        }
        error "GetSlideIdByName: No slide with name $slideName"
    }

    proc GetSlideImages { slideId } {
        # Get the images of a slide.
        #
        # slideId - Identifier of the slide.
        #
        # Returns list containing the image names.
        #
        # See also: InsertImage GetSlideVideos GetPresImages
        # GetNumSlideImages GetShapeType
 
        set imgList [list]
        set numShapes [Ppt GetNumShapes $slideId]
        for { set s 1 } { $s <= $numShapes } { incr s } {
            set shapeId [Ppt GetShapeId $slideId $s]
            set shapeType [Ppt GetShapeType $shapeId]
            if { $shapeType == $::Office::msoPicture || \
                 $shapeType == $::Office::msoLinkedPicture } {
                lappend imgList [Ppt GetShapeName $shapeId]
            }
            Cawt Destroy $shapeId
        }
        return $imgList
    }

    proc GetSlideVideos { slideId } {
        # Get the videos of a slide.
        #
        # slideId - Identifier of the slide.
        #
        # Returns a list containing the video names.
        #
        # See also: InsertVideo GetSlideImages GetPresVideos
        # GetNumSlideVideos GetShapeType
 
        set videoList [list]
        set numShapes [Ppt GetNumShapes $slideId]
        for { set s 1 } { $s <= $numShapes } { incr s } {
            set shapeId [Ppt GetShapeId $slideId $s]
            set shapeType [Ppt GetShapeType $shapeId]
            if { $shapeType == $::Office::msoMedia } {
                lappend videoList [Ppt GetShapeName $shapeId]
            }
            Cawt Destroy $shapeId
        }
        return $videoList
    }

    proc GetNumSlideImages { slideId } {
        # Return the number of images of a slide.
        #
        # slideId - Identifier of the slide.
        #
        # Returns the number of images of a slide.
        #
        # See also: GetSlideImages GetPresImages GetShapeType

        return [llength [Ppt GetSlideImages $slideId]]
    }

    proc GetNumSlideVideos { slideId } {
        # Return the number of videos of a slide.
        #
        # slideId - Identifier of the slide.
        #
        # Returns the number of videos of a slide.
        #
        # See also: GetSlideVideos GetPresVideos GetShapeType

        return [llength [Ppt GetSlideVideos $slideId]]
    }

    proc GetNumSlideShows { appId } {
        # Return the number of slide shows of a presentation.
        #
        # appId - Identifier of the PowerPoint instance.
        #
        # Returns the number of slide shows of the presentation.
        #
        # See also: GetNumSlides UseSlideShow ExitSlideShow

        return [$appId -with { SlideShowWindows } Count]
    }

    proc UseSlideShow { presId slideShowIndex } {
        # Use specified slide show.
        #
        # presId         - Identifier of the presentation.
        # slideShowIndex - Index of the slide show. Indices start at 1.
        #
        # Returns the identifier of the specified slide show.
        #
        # See also: GetNumSlides ExitSlideShow SlideShowNext

        $presId -with { SlideShowSettings } Run
        set appId [Office GetApplicationId $presId]
        set slideShow [$appId -with { SlideShowWindows } Item $slideShowIndex]
        Cawt Destroy $appId
        return $slideShow
    }

    proc ExitSlideShow { slideShowId } {
        # Exit specified slide show.
        #
        # slideShowId - Identifier of the slide show as returned by [UseSlideShow].
        #
        # Returns no value.
        #
        # See also: GetNumSlideShows UseSlideShow SlideShowNext

        $slideShowId -with { View } Exit
    }

    proc SlideShowNext { slideShowId } {
        # Go to next slide in slide show.
        #
        # slideShowId - Identifier of the slide show.
        #
        # Returns no value.
        #
        # See also: UseSlideShow SlideShowPrev SlideShowFirst SlideShowLast

        $slideShowId -with { View } Next
    }

    proc SlideShowPrev { slideShowId } {
        # Go to previous slide in slide show.
        #
        # slideShowId - Identifier of the slide show.
        #
        # Returns no value.
        #
        # See also: UseSlideShow SlideShowNext SlideShowFirst SlideShowLast

        $slideShowId -with { View } Previous
    }

    proc SlideShowFirst { slideShowId } {
        # Go to first slide in slide show.
        #
        # slideShowId - Identifier of the slide show.
        #
        # Returns no value.
        #
        # See also: UseSlideShow SlideShowNext SlideShowPrev SlideShowLast

        $slideShowId -with { View } First
    }

    proc SlideShowLast { slideShowId } {
        # Go to last slide in slide show.
        #
        # slideShowId - Identifier of the slide show.
        #
        # Returns no value.
        #
        # See also: UseSlideShow SlideShowNext SlideShowPrev SlideShowFirst

        $slideShowId -with { View } Last
    }

    proc MoveSlide { slideId slideIndex } {
        # Move a slide to another position.
        #
        # slideId    - Identifier of the slide to be moved.
        # slideIndex - Index of new slide position. Slide indices start at 1.
        #              If negative or `end`, move slide to the end of the presentation.
        #
        # Returns no value.
        #
        # See also: AddSlide CopySlide

        $slideId MoveTo $slideIndex
    }

    proc GetSupportedImageFormats { { usePptFmtNames false } } {
        # Get the image formats supported by PowerPoint.
        #
        # usePptFmtNames - Use format names as supported by PowerPoint.
        #
        # Returns a list of image formats which can be loaded by PowerPoint. 
        # If $usePptFmtNames is set to true, the image format strings are returned
        # according to the format names of the Img extension.
        # Otherwise the image format strings are returned according to the format
        # names of PowerPoint.
        #
        # Img format names - `BMP` `GIF` `JPEG` `TIFF` `PNG`<br/>
        # Ppt format names - `BMP` `GIF` `JPG`  `TIF`  `PNG`
        #
        # See also: InsertImage IsImageFormatSupported GetPptImageFormat

        if { $usePptFmtNames } {
            return [list "BMP" "GIF" "JPG"  "TIF"  "PNG"]
        } else {
            return [list "BMP" "GIF" "JPEG" "TIFF" "PNG"]
        }
    }

    proc IsImageFormatSupported { imgFmt { usePptFmtNames false } } {
        # Check, if the image format is supported by PowerPoint.
        #
        # imgFmt         - Image format name.
        # usePptFmtNames - Use format names as supported by PowerPoint.
        #
        # Returns true, if images of format $imgFmt can be loaded by
        # PowerPoint. See [GetSupportedImageFormats] for a list of
        # supported image formats.
        #
        # See also: InsertImage GetSupportedImageFormats GetPptImageFormat

        if { [lsearch -exact [Ppt GetSupportedImageFormats $usePptFmtNames] $imgFmt] >= 0 } {
            return true
        } else {
            return false
        }
    }

    proc GetPptImageFormat { tkImgFmt } {
        # Get PowerPoint image format from Img format.
        #
        # tkImgFmt - Image format name as supported by the Img extension.
        #
        # Returns the PowerPoint image format name corresponding to the image
        # format name supported by the Img extension.
        # See [GetSupportedImageFormats] for a list of supported image formats.
        #
        # See also: InsertImage GetSupportedImageFormats IsImageFormatSupported

        set pptImgFmt ""
        set index [lsearch -exact [Ppt GetSupportedImageFormats] $tkImgFmt]
        if { $index >= 0 } {
            set pptImgFmt [lindex [Ppt GetSupportedImageFormats true] $index]
        }
        return $pptImgFmt
    }

    proc InsertImage { slideId photoOrImgFileName args } {
        # Insert an image into a slide.
        #
        # slideId            - Identifier of the slide where the image is inserted.
        # photoOrImgFileName - Tk photo identifier or file name of the image.
        # args               - Options described below.
        #
        # -left <pos>    - Set the X position of the top-left image position.
        # -top <pos>     - Set the Y position of the top-left image position.
        # -width <size>  - Set the width of the image.
        # -height <size> - Set the height of the image.
        # -fit <bool>    - Fit image to page. Default: false.
        # -link <bool>   - Indicates whether to link to the file.
        #                  Default: false.
        # -embed <bool>  - Indicates whether to save the image with the document.
        #                  Default: true.
        #
        # The following image formats are supported by the Img extension, 
        # but not by PowerPoint:<br/>`DTED PCX PPM RAW SGI SUN TGA XBM XPM`.<br/>
        # Images in these formats may be loaded into PowerPoint by using the Img
        # extension to load the image into a Tk photo and supplying the photo
        # identifier in parameter $photoOrImgFileFile.
        #
        # The position and size values may be specified in a format acceptable
        # by procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # If no position or size values are specified, the image is placed
        # automatically by PowerPoint.
        # If `-fit` is set to true, the position and size values are ignored 
        # and the image is made as big as possible on the slide
        # without changing the aspect ratio.
        #
        # Returns the identifier of the inserted image.
        #
        # See also: GetPresImages InsertVideo AddSlide GetPresPageWidth GetPresPageHeight
        # IsImageFormatSupported GetSupportedImageFormats GetPptImageFormat 

        set left    0.0
        set top     0.0
        set width  -1.0
        set height -1.0
        set link   [Cawt TclInt false]
        set embed  [Cawt TclInt true]
        set fit    false

        if { [llength $args] > 0 && [string index [lindex $args 0] 0] ne "-" } {
            if { [llength $args] >= 1 } { set left   [Cawt ValueToPoints [lindex $args 0]] }
            if { [llength $args] >= 2 } { set top    [Cawt ValueToPoints [lindex $args 1]] }
            if { [llength $args] >= 3 } { set width  [Cawt ValueToPoints [lindex $args 2]] }
            if { [llength $args] >= 4 } { set height [Cawt ValueToPoints [lindex $args 3]] }
        } else {
            foreach { key value } $args {
                if { $value eq "" } {
                    error "InsertImage: No value specified for key \"$key\""
                }
                switch -exact -nocase -- $key {
                    "-left"   { set left    [Cawt ValueToPoints $value] }
                    "-top"    { set top     [Cawt ValueToPoints $value] }
                    "-width"  { set width   [Cawt ValueToPoints $value] }
                    "-height" { set height  [Cawt ValueToPoints $value] }
                    "-link"   { set link    [Cawt TclInt $value] }
                    "-embed"  { set embed   [Cawt TclInt $value] }
                    "-fit"    { set fit     [Cawt TclInt $value] }
                    default   { error "InsertImage: Unknown key \"$key\" specified" }
                }
            }
        }

        set fileName [file nativename [file normalize $photoOrImgFileName]]
        if { [file exists $fileName] } {
            set imgId [$slideId -with { Shapes } AddPicture $fileName \
                       $link $embed $left $top $width $height]
        } else {
            if { [info commands image] ne "" } {
                if { [lsearch -exact [image names] $photoOrImgFileName] >= 0 } {
                    Cawt ImgToClipboard $photoOrImgFileName
                    set imgId [$slideId -with { Shapes } Paste]
                }
            }
        }

        if { $fit } {
            # Get the page size and then position and size the image.
            set presId [$slideId Parent]

            set pageWidth  [Ppt::GetPresPageWidth $presId]
            set pageHeight [Ppt::GetPresPageHeight $presId]
            set imgWidth   [$imgId Width]
            set imgHeight  [$imgId Height]

            set xzoom [expr { ($imgWidth  / $pageWidth) }]
            set yzoom [expr { ($imgHeight / $pageHeight) }]
            if { $xzoom > $yzoom } {
                set zoomFact $xzoom
                set zoomDir "x"
            } else {
                set zoomFact $yzoom
                set zoomDir "y"
            }
            set newWidth  [expr { $imgWidth  / $zoomFact }]
            set newHeight [expr { $imgHeight / $zoomFact }]

            $imgId Width  $newWidth
            $imgId Height $newHeight

            if { $zoomDir eq "x" } {
                set off [expr { 0.5 * ($pageHeight - $newHeight) }]
                $imgId Top  $off
                $imgId Left 0.0
            } else {
                set off [expr { 0.5 * ($pageWidth - $newWidth) }]
                $imgId Top  0.0
                $imgId Left $off
            }
            Cawt Destroy $presId
        }
        return $imgId
    }

    proc GetCreateVideoStatus { presId } {
        # Get video creation status.
        #
        # presId - Identifier of the presentation.
        #
        # Returns video creation status as enumeration type [Enum::PpMediaTaskStatus].
        #
        # See also: InsertVideo CreateVideo CheckCreateVideoStatus
        
        return [$presId CreateVideoStatus]
    }

    proc CheckCreateVideoStatus { presId { verbose false } { checkUpdate 1.0 } } {
        # Check video creation status.
        #
        # presId      - Identifier of the presentation.
        # verbose     - Print creation status to stdout.
        # checkUpdate - Check for status every $checkUpdate seconds.
        #
        # Returns true, if the video could be created successfully or if
        # creating the video in asynchronous mode.
        #
        # See also: InsertVideo CreateVideo GetCreateVideoStatus
        
        while { 1 } {
            set status [Ppt GetCreateVideoStatus $presId]
            if { $status == $Ppt::ppMediaTaskStatusDone } {
                if { $verbose } {
                    puts "Video creation completed."
                }
                return true
            }
            if { $status == $Ppt::ppMediaTaskStatusFailed } {
                return false
            }
            if { $status == $Ppt::ppMediaTaskStatusInProgress } {
                if { $verbose } {
                    puts "Video creation in progress."
                }
            }
            if { $status == $Ppt::ppMediaTaskStatusNone } {
                # You'll get this value when you ask for the status 
                # and no conversion is happening or has completed.
                if { $verbose } {
                    puts "Video creation completed."
                }
                return true
            }
            if { $status == $Ppt::ppMediaTaskStatusQueued } {
            }
            after [expr { int ($checkUpdate * 1000.0) }]
        }
    }

    proc CreateVideo { presId fileName args } {
        # Create a video from a presentation.
        #
        # presId   - Identifier of the presentation.
        # fileName - File name of the video.
        # args     - Options described below.
        #
        # -verbose <bool>   - Print creation status to stdout. Default: false.
        # -wait <bool>      - Wait for completion. Default: true.
        # -check <float>    - Check status every specified second. Default: 1.0.
        # -timings <bool>   - Use timings and narrations. Default: true.
        # -duration <int>   - Duration of earch slide in seconds. Default: 5.
        # -resolution <int> - Vertical resolution of the video. Default: 720.
        # -fps <int>        - Frames per seconds of the video. Default: 30.
        # -quality  <int>   - Compression quality in percent. Default: 85.
        #
        # The video is created asynchronously. If `-wait` is set to true, the
        # procedure checks the creation status periodically.
        # If `-wait` is false, this procedure returns immediately and 
        # you should check completion of the video by calling [CheckCreateVideoStatus].
        #
        # The file name extension determines the video format.
        # The following formats are supported:
        # .mp4 - MPEG4 Video
        # .wmv - Windows Media Video
        #
        # Returns true, if the video could be created successfully or if
        # creating the video in asynchronous mode.
        #
        # See also: InsertVideo CheckCreateVideoStatus AddSlide
        # InsertImage SetSlideShowTransition
        
        set verbose                 false
        set waitForCompletion       true
        set checkUpdate             1.0
        set useTimingsAndNarrations true
        set duration                5
        set verticalResolution      720
        set fps                     30
        set quality                 85

        foreach { key value } $args {
            if { $value eq "" } {
                error "CreateVideo: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-verbose"    { set verbose                 [Cawt TclBool $value] }
                "-wait"       { set waitForCompletion       [Cawt TclBool $value] }
                "-check"      { set checkUpdate             [expr double ($value)] }
                "-timings"    { set useTimingsAndNarrations [Cawt TclInt $value] }
                "-duration"   { set duration                [expr int ($value)] }
                "-resolution" { set verticalResolution      [expr int ($value)] }
                "-fps"        { set fps                     [expr int ($value)] }
                "-quality"    { set quality                 [expr int ($value)] }
                default       { error "CreateVideo: Unknown key \"$key\" specified" }
            }
        }

        # FileName, UseTimingsAndNarrations, DefaultSlideDuration, VertResolution, FramesPerSecond, Quality)
        set fileName [file nativename [file normalize $fileName]]
        $presId CreateVideo $fileName $useTimingsAndNarrations $duration $verticalResolution $fps $quality

        # Presentation.CreateVideo does its work asynchronously.
        # You can use the Presentation.CreateVideoStatus property
        # to periodically check the status, and react accordingly.
        if { $waitForCompletion } {
            return [Ppt::CheckCreateVideoStatus $presId $verbose $checkUpdate]
        }
        return true
    }

    proc InsertVideo { slideId videoFileName args } {
        # Insert a video into a slide.
        #
        # slideId       - Identifier of the slide where the video is inserted.
        # videoFileName - File name of the video.
        # args          - Options described below.
        #
        # -left <pos>    - Set the X position of top-left video position.
        # -top <pos>     - Set the Y position of top-left video position.
        # -width <size>  - Set the width of the video.
        # -height <size> - Set the height of the video.
        # -link <bool>   - Indicates whether to link to the file.
        #                  Default: false.
        # -embed <bool>  - Indicates whether to save the video with the document.
        #                  Default: true.
        #
        # The position and size values may be specified in a format acceptable
        # by procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # If no position or size values are specified, the video is placed
        # automatically by PowerPoint.
        #
        # ** Important notice: **
        #
        # This procedure may not work with older video formats (ex. .mpg),
        # when using newer PowerPoint versions (>= 2016).
        # When manually inserting such a video, it works. A message box is displayed
        # informing that the video is converted to a suitable format.
        # When inserting such a video via the COM interface, an error occurs. You may
        # catch that error, but afterwards the PowerPoint COM interface is not working anymore.
        #
        # Returns the identifier of the inserted video.
        #
        # See also: GetPresVideos SetMediaPlaySettings InsertImage AddSlide CreateVideo

        variable pptVersion

        if { $pptVersion < 14.0 } {
            error "Videos available only in PowerPoint 2010 or newer. Running [Ppt GetVersion $slideId true]."
        }

        set left   -1.0
        set top    -1.0
        set width  -1.0
        set height -1.0
        set link   [Cawt TclInt false]
        set embed  [Cawt TclInt true]

        if { [llength $args] > 0 && [string index [lindex $args 0] 0] ne "-" } {
            if { [llength $args] >= 1 } { set left   [Cawt ValueToPoints [lindex $args 0]] }
            if { [llength $args] >= 2 } { set top    [Cawt ValueToPoints [lindex $args 1]] }
            if { [llength $args] >= 3 } { set width  [Cawt ValueToPoints [lindex $args 2]] }
            if { [llength $args] >= 4 } { set height [Cawt ValueToPoints [lindex $args 3]] }
        } else {
            foreach { key value } $args {
                if { $value eq "" } {
                    error "InsertVideo: No value specified for key \"$key\""
                }
                switch -exact -nocase -- $key {
                    "-left"    { set left    [Cawt ValueToPoints $value] }
                    "-top"     { set top     [Cawt ValueToPoints $value] }
                    "-width"   { set width   [Cawt ValueToPoints $value] }
                    "-height"  { set height  [Cawt ValueToPoints $value] }
                    "-link"    { set link    [Cawt TclInt $value] }
                    "-embed"   { set embed   [Cawt TclInt $value] }
                     default   { error "InsertVideo: Unknown key \"$key\" specified" }
                }
            }
        }

        set fileName [file nativename [file normalize $videoFileName]]
        set videoId [$slideId -with { Shapes } AddMediaObject2 $fileName \
                     $link $embed $left $top $width $height]
        return $videoId
    }

    proc GetNumCustomLayouts { presId } {
        # Return the number of custom layouts of a presentation.
        #
        # presId - Identifier of the presentation.
        #
        # Returns the number of custom layouts of a presentation.
        #
        # See also: GetNumSlides GetCustomLayoutName GetCustomLayoutId

        return [$presId -with { SlideMaster CustomLayouts } Count]
    }

    proc GetCustomLayoutName { customLayoutId } {
        # Return the name of a custom layout.
        #
        # customLayoutId - Identifier of the custom layout.
        #
        # Returns the name of a custom layout.
        #
        # See also: GetCustomLayoutId GetNumCustomLayouts

        return [$customLayoutId Name]
    }

    proc GetCustomLayoutId { presId indexOrName } {
        # Get a custom layout by its index or name.
        #
        # presId      - Identifier of the presentation containing the custom layout.
        # indexOrName - Index or name of the custom layout to find.
        #
        # Instead of using the numeric index the special word `end` may
        # be used to specify the last custom layout.
        #
        # Returns the identifier of the found custom layout.
        # If the index is out of bounds or a custom layout with specified name
        # is not found, an error is thrown.
        #
        # See also: GetNumCustomLayouts GetCustomLayoutName AddPres

        set count [Ppt GetNumCustomLayouts $presId]
        if { [string is integer $indexOrName] || $indexOrName eq "end" } {
            if { $indexOrName eq "end" } {
                set indexOrName $count
            } else {
                if { $indexOrName < 1 || $indexOrName > $count } {
                    error "GetCustomLayoutId: Invalid index $indexOrName given."
                }
            }
            set customLayoutId [$presId -with { SlideMaster CustomLayouts } Item [expr $indexOrName]]
            return $customLayoutId
        } else {
            for { set i 1 } { $i <= $count } { incr i } {
                set customLayouts [$presId -with { SlideMaster } CustomLayouts]
                set customLayoutId [$customLayouts Item [expr $i]]
                if { $indexOrName eq [$customLayoutId Name] } {
                    Cawt Destroy $customLayouts
                    return $customLayoutId
                }
                Cawt Destroy $customLayoutId
            }
            error "GetCustomLayoutId: No custom layout with name $indexOrName"
        }
    }

    proc AddTextbox { slideId left top width height } {
        # Add a text box into a slide.
        #
        # slideId - Identifier of the slide where the text box is inserted.
        # left    - X position of top-left text box position.
        # top     - Y position of top-left text box position.
        # width   - Width of text box.
        # height  - Height of text box.
        #
        # The position and size values may be specified in a format acceptable
        # by procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns the identifier of the new text box.
        #
        # See also: AddTextboxText SetTextboxFontSize

        set msoTextOrientationHorizontal 1
        set textId [$slideId -with { Shapes } AddTextbox $msoTextOrientationHorizontal \
                    [Cawt ValueToPoints $left]  [Cawt ValueToPoints $top] \
                    [Cawt ValueToPoints $width] [Cawt ValueToPoints $height]]
        return $textId
    }

    proc AddTextboxText { textboxId text { addNewline false } } {
        # Add a text string to a text box.
        #
        # textboxId  - Identifier of the text box where the text is inserted.
        # text       - The text to be inserted.
        # addNewline - Add a new line after the text.
        #
        # Returns no value.
        #
        # See also: AddTextbox SetTextboxFontSize

        if { $text ne "" } {
            $textboxId -with { TextFrame TextRange } InsertAfter $text
        }
        if { $addNewline } {
            $textboxId -with { TextFrame TextRange } InsertAfter "\r\n"
        }
    }

    proc SetTextboxFontSize { textboxId fontSize } {
        # Set the font size of the text in a text box.
        #
        # textboxId - Identifier of the text box where the text is inserted.
        # fontSize  - Font size.
        #
        # The size value may be specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: AddTextbox AddTextboxText

        $textboxId -with { TextFrame TextRange Font } Size [Cawt ValueToPoints $fontSize]
    }

    proc GetNumComments { slideId } {
        # Return the number of comments of a slide.
        #
        # slideId - Identifier of the slide.
        #
        # Returns the number of comments of the slide.
        #
        # See also: GetComments GetCommentKeyValue

        return [$slideId -with { Comments } Count]
    }

    proc GetComments { slideId } {
        # Get the comment texts of a slide as a Tcl list.
        #
        # slideId - Identifier of the slide.
        #
        # Returns the comment texts of the slide as a Tcl list.
        # 
        # See also: GetNumComments GetCommentKeyValue

        set numComments [Ppt GetNumComments $slideId]
        set commentList [list]
        set commentsId [$slideId Comments]
        for { set commentInd 1 } { $commentInd <= $numComments } { incr commentInd } {
            set commentId [$commentsId Item $commentInd]
            lappend commentList [$commentId Text]
            Cawt Destroy $commentId
        }
        Cawt Destroy $commentsId
        return $commentList
    }
}
