# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Ppt {
    namespace ensemble create

    namespace export AddShape
    namespace export ConfigureConnector
    namespace export ConfigureShape
    namespace export ConnectShapes
    namespace export GetNumShapes
    namespace export GetNumSites
    namespace export GetShapeId
    namespace export GetShapeMediaType
    namespace export GetShapeName
    namespace export GetShapeType
    namespace export SetHyperlinkToSlide
    namespace export SetShapeName
    namespace export SetMediaPlaySettings

    proc AddShape { slideId shapeType left top width height args } {
        # Add a new shape to a slide.
        #
        # slideId   - Identifier of the slide.
        # shapeType - Value of enumeration type [::Office::Enum::MsoAutoShapeType].
        #             Typical values: `msoShapeRectangle`, `msoShapeBalloon`, `msoShapeOval`.
        # left      - Left corner of the shape.
        # top       - Top corner of the shape.
        # width     - Width of the shape.
        # height    - Height of the shape.
        # args      - List of shape configure options and its values.
        #
        # For a description of the configure options see [ConfigureShape].
        #
        # The position and size values are specified in a format acceptable by
        # procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.
        #
        # Returns the identifier of the new shape.
        #
        # See also: ConnectShapes ConfigureShape GetNumSites

        set shapeId [$slideId -with { Shapes } AddShape [Office GetEnum $shapeType] \
                    [Cawt ValueToPoints $left]  [Cawt ValueToPoints $top] \
                    [Cawt ValueToPoints $width] [Cawt ValueToPoints $height]]
        Ppt::ConfigureShape $shapeId {*}$args
        return $shapeId
    }

    proc GetNumShapes { slideId } {
        # Return the number of shapes of a slide.
        #
        # slideId - Identifier of the slide.
        #
        # Returns the number of shapes of the slide.
        #
        # See also: AddShape GetShapeId ConfigureShape ConnectShapes

        return [$slideId -with { Shapes } Count]
    }

    proc GetShapeId { slideId shapeIndex } {
        # Get shape identifier from shape index.
        #
        # slideId    - Identifier of the slide.
        # shapeIndex - Index of the shape. Shape indices start at 1.
        #              If negative or `end`, use last shape.
        #
        # Returns the identifier of the shape.
        #
        # See also: AddShape GetNumShapes GetShapeType

        if { $shapeIndex eq "end" || $shapeIndex < 0 } {
            set shapeIndex [GetNumShapes $slideId]
        }
        set shapeId [$slideId -with { Shapes } Item $shapeIndex]
        return $shapeId
    }

    proc GetShapeType { shapeId { useString false } } {
        # Return the type of a shape.
        #
        # shapeId   - Identifier of the shape.
        # useString - If set to true, return the enumeration as string.
        #             Otherwise return the enumeration as integer.
        #
        # Returns the type of the shape as enumeration [::Office::Enum::MsoShapeType].
        # Typical values: `msoMedia`, `msoTextBox`, `msoGraphic`.
        #
        # See also: AddShape GetShapeId GetNumShapes GetShapeMediaType GetShapeName

        set type [$shapeId Type]
        if { $useString } {
            return [Office GetEnumName MsoShapeType $type]
        } else {
            return $type
        }
    }

    proc GetShapeMediaType { shapeId { useString false } } {
        # Return the media type of a shape.
        #
        # shapeId   - Identifier of the shape.
        # useString - If set to true, return the enumeration as string.
        #             Otherwise return the enumeration as integer.
        #
        # Returns the media type of the shape as enumeration [Enum::PpMediaType].
        # Typical values: `ppMediaTypeMovie` `ppMediaTypeSound`.
        #
        # See also: AddShape GetShapeId GetNumShapes GetShapeType GetShapeName

        set type [$shapeId MediaType]
        if { $useString } {
            return [Ppt GetEnumName PpMediaType $type]
        } else {
            return $type
        }
    }

    proc GetShapeName { shapeId } {
        # Return the name of a shape.
        #
        # shapeId - Identifier of the shape.
        #
        # Returns the name of the shape as string.
        #
        # See also: SetShapeName AddShape GetShapeId GetNumShapes
        # GetShapeType GetShapeMediaType

        return [$shapeId Name]
    }

    proc SetShapeName { shapeId name } {
        # Set the name of a shape.
        #
        # shapeId - Identifier of the shape.
        # name    - Name of the shape.
        #
        # Returns no value.
        #
        # See also: GetShapeName AddShape GetShapeId GetNumShapes
        # GetShapeType GetShapeMediaType

        $shapeId Name $name
    }

    proc SetHyperlinkToSlide { srcShapeId destSlideIdOrNum { screenTip "" } } {
        # Create a hyperlink from a shape to a slide.
        #
        # srcShapeId       - Identifier of the source shape.
        # destSlideIdOrNum - Identifier or number of the destination slide.
        # screenTip        - Text to be displayed when hovering over the source shape.
        #
        # Returns no value.
        #
        # See also: AddShape ConfigureShape

        if { [string is integer $destSlideIdOrNum] } {
            set slideIndex $destSlideIdOrNum
        } else {
            set slideIndex [Ppt GetSlideIndex $destSlideIdOrNum]
        }
        set actionSettingId [$srcShapeId -with { ActionSettings } Item $Ppt::ppMouseClick]
        $actionSettingId Action $Ppt::ppActionHyperlink
        $actionSettingId -with { Hyperlink } Address    ""
        $actionSettingId -with { Hyperlink } SubAddress $slideIndex
        if { $screenTip ne "" } {
            $actionSettingId -with { Hyperlink } ScreenTip $screenTip
        }
        Cawt Destroy $actionSettingId
    }

    proc _SetShapeFillColor { shapeId args } {
        $shapeId -with { Fill } Visible $::Office::msoTrue 
        $shapeId -with { Fill } Solid
        $shapeId -with { Fill ForeColor } RGB [Cawt GetColor {*}$args]
    }

    proc _SetShapeText { shapeId text } {
        $shapeId -with { TextFrame TextRange } Text $text
    }

    proc _SetShapeTextVAlign { shapeId verticalAlign } {
        $shapeId -with { TextFrame } VerticalAnchor [Office GetEnum $verticalAlign]
    }

    proc _SetShapeTextColor { shapeId args } {
        $shapeId -with { TextFrame TextRange Font } Color [Cawt GetColor {*}$args]
    }

    proc _SetShapeTextSize { shapeId size } {
        $shapeId -with { TextFrame TextRange Font } Size [Cawt ValueToPoints $size]
    }

    proc GetNumSites { shapeId } {
        # Return the number of sites of a shape.
        #
        # shapeId - Identifier of the shape.
        #
        # A site is the anchor point of a shape, where the connectors are attached.
        #
        # Returns the number of sites of the shape.
        #
        # See also: AddShape ConfigureShape ConnectShapes

        return [$shapeId ConnectionSiteCount]
    }

    proc ConfigureShape { shapeId args } {
        # Configure a shape.
        #
        # shapeId - Identifier of the shape.
        # args    - Options described below.
        #
        # -fillcolor <color>          - Set the fill color of the shape.
        # -text <string>              - Set the text displayed inside the shape.
        # -textsize <size>            - Set the font size of the shape text.
        # -textcolor <color>          - Set the text color of the shape.
        # -valign <MsoVerticalAnchor> - Set the vertical alignment a the shape.
        #                               Typical values: `msoAnchorTop`, `msoAnchorMiddle`, `msoAnchorBottom`.
        #
        # * Color can be specified in a format acceptable by procedure [::Cawt::GetColor],
        #   i.e. color name, hexadecimal string, Office color number or a list of 3 integer RGB values.<br/>
        # * Size can be specified in a format acceptable by procedure [::Cawt::ValueToPoints],
        #   i.e. centimeters, inches or points.
        #
        # Returns no value.
        #
        # See also: AddShape GetNumSites

        foreach { key value } $args {
            if { $value eq "" } {
                error "ConfigureShape: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-text"      { Ppt::_SetShapeText       $shapeId $value }
                "-textsize"  { Ppt::_SetShapeTextSize   $shapeId $value }
                "-textcolor" { Ppt::_SetShapeTextColor  $shapeId {*}$value }
                "-fillcolor" { Ppt::_SetShapeFillColor  $shapeId {*}$value }
                "-valign"    { Ppt::_SetShapeTextVAlign $shapeId $value }
                default      { error "ConfigureShape: Unknown configure option \"$key\"." }
            }
        }
    }

    proc ConnectShapes { slideId fromShapeId toShapeId args } {
        # Add a new connector connecting two shapes.
        #
        # slideId     - Identifier of the slide.
        # fromShapeId - Identifier of the source shape.
        # toShapeId   - Identifier of the target shape.
        # args        - List of connector configure options and its values.
        #
        # For a description of the configure options see [ConfigureConnector].
        #
        # * Default is a straight line connector (`msoConnectorStraight`) with an end arrow 
        #   of type `msoArrowheadTriangle`.
        # * The connector is automatically placed by Office using RerouteConnections.
        #
        # Returns the identifier of the new connector.
        #
        # See also: AddShape ConfigureConnector

        # AddConnector(Type As MsoConnectorType, BeginX As Single, BeginY As Single, EndX As Single, EndY As Single) 
        set connId [$slideId -with { Shapes } AddConnector $::Office::msoConnectorStraight 0 0 0 0]
        $connId -with { Line } EndArrowHeadStyle $::Office::msoArrowheadTriangle

        # ConnectionSite 1 seems to be the top connection and continues counter clockwise.
        # BeginConnect(ConnectedShape, ConnectionSite)
        $connId -with { ConnectorFormat } BeginConnect $fromShapeId 1
        $connId -with { ConnectorFormat } EndConnect   $toShapeId   1
        $connId RerouteConnections
        Ppt::ConfigureConnector $connId {*}$args
        return $connId
    }

    proc _SetConnectorType { connId type } {
        $connId -with { ConnectorFormat } Type [Office GetEnum $type]
    }

    proc _SetConnectorBeginSite { connId site } {
        set shapeId [$connId -with { ConnectorFormat } BeginConnectedShape]
        $connId -with { ConnectorFormat } BeginConnect $shapeId [expr int($site)]
    }

    proc _SetConnectorEndSite { connId site } {
        set shapeId [$connId -with { ConnectorFormat } EndConnectedShape]
        $connId -with { ConnectorFormat } EndConnect $shapeId [expr int($site)]
    }

    proc _SetConnectorBeginArrow { connId arrowStyle } {
        $connId -with { Line } BeginArrowHeadStyle [Office GetEnum $arrowStyle]
    }

    proc _SetConnectorEndArrow { connId arrowStyle } {
        $connId -with { Line } EndArrowHeadStyle [Office GetEnum $arrowStyle]
    }

    proc _SetConnectorWeight { connId weight } {
        $connId -with { Line } Weight [Cawt ValueToPoints $weight]
    }

    proc _SetConnectorFillColor { connId args } {
        $connId -with { Line } Visible $::Office::msoTrue 
        $connId -with { Line ForeColor } RGB [Cawt GetColor {*}$args]
    }

    proc ConfigureConnector { connId args } {
        # Configure a connector.
        #
        # connId - Identifier of the connector.
        # args   - Options described below.
        #
        # -beginarrow <MsoArrowheadStyle> - Set the type of the begin arrow.
        #                                   Typical values: `msoArrowheadTriangle`, `msoArrowheadNone`, `msoArrowheadDiamond`.
        # -endarrow <MsoArrowheadStyle>   - Set the type of the end arrow.
        #                                   Typical values: `msoArrowheadTriangle`, `msoArrowheadNone`, `msoArrowheadDiamond`.
        # -beginsite <int>                - Set the begin site of the connector.
        #                                   1 is the top site and continues counter clockwise.
        # -endsite <int>                  - Set the end site of the connector.
        #                                   1 is the top site and continues counter clockwise.
        # -weight <size>                  - Set the weight (thickness) of the connector line.
        # -fillcolor <color>              - Set the fill color of the connector.
        # -type <MsoConnectorType>        - Set the type of the connector.
        #                                   Typical values: `msoConnectorStraight`, `msoConnectorElbow`, `msoConnectorCurve`.
        #
        # * Size can be specified in a format acceptable by
        #   procedure [::Cawt::ValueToPoints], i.e. centimeters, inches or points.<br/>
        # * Color can be specified in a format acceptable by procedure [::Cawt::GetColor],
        #   i.e. color name, hexadecimal string, Office color number or a list of 3 integer RGB values.
        #
        # Returns no value.
        #
        # See also: ConnectShapes GetNumSites

        foreach { key value } $args {
            if { $value eq "" } {
                error "ConfigureConnector: No value specified for key \"$key\""
            }
            switch -exact -nocase -- $key {
                "-beginarrow" { Ppt::_SetConnectorBeginArrow $connId $value }
                "-endarrow"   { Ppt::_SetConnectorEndArrow   $connId $value }
                "-beginsite"  { Ppt::_SetConnectorBeginSite  $connId $value }
                "-endsite"    { Ppt::_SetConnectorEndSite    $connId $value }
                "-weight"     { Ppt::_SetConnectorWeight     $connId $value }
                "-fillcolor"  { Ppt::_SetConnectorFillColor  $connId {*}$value }
                "-type"       { Ppt::_SetConnectorType       $connId $value }
                default       { error "ConfigureConnector: Unknown configure option \"$key\"." }
            }
        }
    }

    proc SetMediaPlaySettings { shapeId args } {
        # Set the play settings of a media (audio or video).
        #
        # shapeId - Identifier of the media shape.
        # args    - Options described below.
        #
        # -endless <bool> - Determines whether the specified video or sound loops continuously
        #                   until either the next video or sound starts, the user clicks the slide,
        #                   or a slide transition occurs.
        #                   Default: false.
        # -hide <bool>    - Determines whether the specified media clip is hidden during a slide
        #                   show except when it is playing.
        #                   Default: false.
        # -pause <bool>   - Determines whether the slide show pauses until the specified media clip
        #                   is finished playing.
        #                   Default: false.
        # -play <bool>    - Determines whether the specified video or sound is played automatically
        #                   when it is animated.
        #                   Default: false.
        # -rewind <bool>  - Determines whether the first frame of the specified video is automatically
        #                   redisplayed as soon as the video has finished playing.
        #                   Default: false
        #
        # Returns no value.
        #
        # See also: InsertVideo GetPresVideos

        if { [Ppt GetShapeType $shapeId] == $::Office::msoMedia && \
             ( [Ppt GetShapeMediaType $shapeId] == $::Ppt::ppMediaTypeMovie || \
               [Ppt GetShapeMediaType $shapeId] == $::Ppt::ppMediaTypeSound ) } {
            set playId [$shapeId -with { AnimationSettings } PlaySettings]
            foreach { key value } $args {
                if { $value eq "" } {
                    error "SetMediaPlaySettings: No value specified for key \"$key\""
                }
                switch -exact -nocase -- $key {
                    "-endless" { $playId LoopUntilStopped    [Cawt TclInt $value] }
                    "-hide"    { $playId HideWhileNotPlaying [Cawt TclInt $value] }
                    "-pause"   { $playId PauseAnimation      [Cawt TclInt $value] }
                    "-play"    { $playId PlayOnEntry         [Cawt TclInt $value] }
                    "-rewind"  { $playId RewindMovie         [Cawt TclInt $value] }
                    default    { error "SetMediaPlaySettings: Unknown configure option \"$key\"." }
                }
            }
            Cawt Destroy $playId
        } else {
            error "SetMediaPlaySettings: Shape is not a video or audio."
        }
    }
}
