# Copyright (c) 2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl binding for libharu (http://libharu.org/) PDF library.

# 10-02-2022 : v1.0   Initial release

package require Tcl 8.6
package require cffi 1.0

set dir [file dirname [file normalize [info script]]]

source [file join $dir haru_enum.tcl]
source [file join $dir haru_struct.tcl]
source [file join $dir haru_error.tcl]
source [file join $dir haru_utils.tcl]

namespace eval haru {

    variable libname "libhpdf"
    variable hpdfversion "2.3.0"
    variable version 1.0

    # constant variables
    variable HPDF_TRUE            1
    variable HPDF_FALSE           0
    variable HPDF_COMP_NONE       0
    variable HPDF_COMP_TEXT       1
    variable HPDF_COMP_IMAGE      2
    variable HPDF_COMP_METADATA   4
    variable HPDF_COMP_ALL        15
    variable HPDF_HIDE_TOOLBAR    1
    variable HPDF_HIDE_MENUBAR    2
    variable HPDF_HIDE_WINDOW_UI  4
    variable HPDF_FIT_WINDOW      8
    variable HPDF_CENTER_WINDOW   16
    variable HPDF_ENABLE_READ     0
    variable HPDF_ENABLE_PRINT    4
    variable HPDF_ENABLE_EDIT_ALL 8
    variable HPDF_ENABLE_COPY     16
    variable HPDF_ENABLE_EDIT     32
}

# Loading the library 
if {[catch {
    cffi::Wrapper create HPDF $::haru::libname-$::haru::hpdfversion[info sharedlibextension]
}]} {
    # Could not find the version-labeled library. Load without version.
    # We will check actual version later.
    cffi::Wrapper create HPDF $::haru::libname[info sharedlibextension]
}

HPDF stdcall HPDF_GetVersion   string      {}
set ::haru::hpdfversion [HPDF_GetVersion]
if {![regexp {^2\.3\.} $::haru::hpdfversion]} {
    error "libhpdf version $::haru::hpdfversion is unsupported. Need 2.3.*"
}

# Define type
cffi::alias define HPDF_Doc          pointer.HPDF_Doc
cffi::alias define HPDF_Page         {pointer.HPDF_Page unsafe}
cffi::alias define HPDF_Destination  pointer.HPDF_Destination
cffi::alias define HPDF_Annotation   pointer.HPDF_Annotation
cffi::alias define HPDF_Font         {pointer.HPDF_Font {onerror haru::NullHandler}}
cffi::alias define HPDF_Outline      pointer.HPDF_Outline
cffi::alias define HPDF_Encoder      pointer.HPDF_Encoder
cffi::alias define HPDF_Image        {pointer.HPDF_Image unsafe {onerror haru::NullHandler}}
cffi::alias define HPDF_Image1       pointer.HPDF_Image1
cffi::alias define HPDF_ExtGState    pointer.HPDF_ExtGState
cffi::alias define HPDF_XObject      HPDF_Image
cffi::alias define HPDF_Dict         pointer.HPDF_Dict
cffi::alias define HPDF_U3D          pointer.HPDF_U3d
cffi::alias define HPDF_3DMeasure    pointer.HPDF_3DMeasure
cffi::alias define HPDF_MMgr         {pointer.HPDF_MMgr   {onerror haru::NullHandler}}
cffi::alias define HPDF_Stream       {pointer.HPDF_Stream {onerror haru::NullHandler}}
cffi::alias define HPDF_Encrypt      pointer.HPDF_Encrypt
cffi::alias define HPDF_FontDef      pointer.HPDF_FontDef
cffi::alias define HPDF_ExData       pointer.HPDF_ExData
cffi::alias define HPDF_EmbeddedFile pointer.HPDF_EmbeddedFile

cffi::alias define HPDF_STATUS           {ulong zero}
cffi::alias define HPDF_BOOL             int
cffi::alias define HPDF_INT              int
cffi::alias define HPDF_UINT             uint
cffi::alias define HPDF_REAL             float        
cffi::alias define HPDF_UINT16           ushort        
cffi::alias define HPDF_INT32            int      
cffi::alias define HPDF_UNICODE          ushort        

# Define struct type
cffi::alias define HPDF_ErrorHandler      {struct.error_handler byref}
cffi::alias define HPDF_Point             struct.hpdfpoint
cffi::alias define HPDF_Point3D           struct.hpdf3Dpoint
cffi::alias define HPDF_TransMatrix       struct.hpdftransmatrix
cffi::alias define HPDF_DashMode          struct.hpdfdashmode
cffi::alias define HPDF_RGBColor          struct.hpdfrgbcolor
cffi::alias define HPDF_CMYKColor         struct.hpdfcmykcolor
cffi::alias define HPDF_Rect              struct.hpdfrect
cffi::alias define HPDF_Box               struct.hpdfbox
cffi::alias define HPDF_TextWidth         struct.hpdftextwidth
cffi::alias define HPDF_Date              struct.hpdfdate

# Define enum type
cffi::alias define HPDF_PageSizes          {int {enum HPdfPageSizes}     {default HPDF_PAGE_SIZE_A4}}
cffi::alias define HPDF_PageDirection      {int {enum HPdfPageDirection} {default HPDF_PAGE_PORTRAIT}}
cffi::alias define HPDF_PageLayout         {int {enum HPdfPageLayout}    {default HPDF_PAGE_LAYOUT_SINGLE}}
cffi::alias define HPDF_PageMode           {int {enum HPdfPageMode}      {default HPDF_PAGE_MODE_USE_NONE}}
cffi::alias define HPDF_PageNumStyle       {int {enum HPdfPageNumStyle}  {default HPDF_PAGE_NUM_STYLE_DECIMAL}}
cffi::alias define HPDF_ColorSpace         {int {enum HPdfColorSpace}    {default HPDF_CS_DEVICE_GRAY}}
cffi::alias define HPDF_InfoType           {int {enum HPdfInfoType}      {default HPDF_INFO_CREATION_DATE}}
cffi::alias define HPDF_EncryptMode        {int {enum HPdfEncryptMode}   {default HPDF_ENCRYPT_R2}}
cffi::alias define HPDF_LineCap            {int {enum HPdfLineCap}}
cffi::alias define HPDF_LineJoin           {int {enum HPdfLineJoin}}
cffi::alias define HPDF_TextRenderingMode  {int {enum HPdfTextRenderingMode}}
cffi::alias define HPDF_TransitionStyle    {int {enum HPdfTransitionStyle}}
cffi::alias define HPDF_TextAlignment      {int {enum HPdfTextAlignment}}
cffi::alias define HPDF_AnnotHighlightMode {int {enum HPdfAnnotHighlightMode}}
cffi::alias define HPDF_AnnotIcon          {int {enum HPdfAnnotIcon}}
cffi::alias define HPDF_BlendMode          {int {enum HPdfBlendMode}}
cffi::alias define HPDF_EncoderType        {int {enum HPdfEncoderType}}
cffi::alias define HPDF_ByteType           {int {enum HPdfByteType}}
cffi::alias define HPDF_WritingMode        {int {enum HPdfWritingMode}}

# Invoke C functions...

# hpdf.h :
# HPDF_GetPageMMgr   HPDF_MMgr       {page HPDF_Page}

HPDF stdcalls {

    HPDF_Free         void        {pdf {HPDF_Doc dispose}}
    HPDF_NewDoc       HPDF_STATUS {pdf HPDF_Doc}
    HPDF_FreeDoc      void        {pdf HPDF_Doc}
    HPDF_FreeDocAll   void        {pdf HPDF_Doc}
    HPDF_HasDoc       HPDF_BOOL   {pdf HPDF_Doc}
    HPDF_SaveToStream HPDF_STATUS {pdf HPDF_Doc}
    HPDF_ResetStream  HPDF_STATUS {pdf HPDF_Doc}

    HPDF_New HPDF_Doc {
        user_error_fn   {pointer {default NULL} nullok} 
        user_error_data {pointer {default NULL} nullok}
    }

    HPDF_SaveToFile HPDF_STATUS {
        pdf      HPDF_Doc
        filename string
    }

    HPDF_GetError       ulong       {pdf HPDF_Doc}
    HPDF_GetErrorDetail HPDF_STATUS {pdf HPDF_Doc}
    HPDF_ResetError     void        {pdf HPDF_Doc}

    HPDF_SetPagesConfiguration HPDF_STATUS {
        pdf            HPDF_Doc
        page_per_pages HPDF_UINT
    }

    HPDF_GetPageByIndex HPDF_Page {
        pdf   HPDF_Doc
        index HPDF_UINT
    }

    HPDF_GetPageLayout HPDF_PageLayout {pdf HPDF_Doc}

    HPDF_SetPageLayout HPDF_STATUS {
        pdf    HPDF_Doc
        layout HPDF_PageLayout
    }

    HPDF_GetPageMode HPDF_PageMode {pdf HPDF_Doc}

    HPDF_SetPageMode HPDF_STATUS {
        pdf  HPDF_Doc
        mode HPDF_PageMode
    }

    HPDF_SetOpenAction HPDF_STATUS {
        pdf         HPDF_Doc
        open_action HPDF_Destination
    }

    HPDF_GetViewerPreference HPDF_UINT {pdf HPDF_Doc}

    HPDF_SetViewerPreference HPDF_STATUS {
        pdf   HPDF_Doc
        value HPDF_UINT
    }

}

# page handling :
HPDF stdcalls {

    HPDF_GetCurrentPage HPDF_Page {pdf HPDF_Doc}
    HPDF_AddPage        HPDF_Page {pdf HPDF_Doc}

    HPDF_InsertPage HPDF_Page {
        pdf  HPDF_Doc
        page HPDF_Page
    }

    HPDF_Page_SetWidth HPDF_STATUS {
        page  HPDF_Page
        value HPDF_REAL
    }
    HPDF_Page_SetHeight HPDF_STATUS {
        page  HPDF_Page
        value HPDF_REAL
    }

    HPDF_Page_SetSize HPDF_STATUS {
        page      HPDF_Page
        size      HPDF_PageSizes
        direction HPDF_PageDirection
    }

    HPDF_Page_SetRotate HPDF_STATUS {
        page  HPDF_Page
        angle HPDF_UINT16
    }

    HPDF_Page_SetZoom HPDF_STATUS {
        page  HPDF_Page
        zoom HPDF_REAL
    }
}

# font handling :
HPDF stdcalls {

    HPDF_UseJPFonts  HPDF_STATUS {pdf HPDF_Doc}
    HPDF_UseKRFonts  HPDF_STATUS {pdf HPDF_Doc}
    HPDF_UseCNSFonts HPDF_STATUS {pdf HPDF_Doc}
    HPDF_UseCNTFonts HPDF_STATUS {pdf HPDF_Doc}

    HPDF_GetFont {HPDF_Font counted} {
        pdf           HPDF_Doc
        font_name     string
        encoding_name {string nullifempty}
    }

    HPDF_LoadType1FontFromFile string {
        pdf         HPDF_Doc
        afmfilename string
        pfmfilename string
    }

    HPDF_GetTTFontDefFromFile HPDF_FontDef {
        pdf       HPDF_Doc
        file_name string
        embedding HPDF_BOOL
    }

    HPDF_LoadTTFontFromFile string {
        pdf       HPDF_Doc
        file_name string
        embedding HPDF_BOOL
    }

    HPDF_LoadTTFontFromFile2 string {
        pdf       HPDF_Doc
        file_name string
        index     HPDF_UINT
        embedding HPDF_BOOL
    }

    HPDF_AddPageLabel HPDF_STATUS {
        pdf        HPDF_Doc
        page_num   HPDF_UINT
        style      HPDF_PageNumStyle
        first_page HPDF_UINT
        prefix     string
    }
}

# Not exported in 2.3.0 on Windows. Ignore if not available
catch {
    HPDF stdcall HPDF_GetFontDef {HPDF_FontDef} {
        pdf       HPDF_Doc
        file_name string
    }
}

# outline :
HPDF stdcalls {

    HPDF_CreateOutline HPDF_Outline {
        pdf     HPDF_Doc
        parent  {HPDF_Outline unsafe nullok}
        title   string
        encoded {HPDF_Encoder unsafe nullok}
    }

    HPDF_Outline_SetOpened HPDF_STATUS {
        houtline HPDF_Outline
        opened   HPDF_BOOL
    }

    HPDF_Outline_SetDestination HPDF_STATUS {
        houtline HPDF_Outline
        hdest    HPDF_Destination
    }
}

# destination :
HPDF stdcalls {

    HPDF_Page_CreateDestination HPDF_Destination {page HPDF_Page}
    HPDF_Destination_SetFit     HPDF_STATUS      {hdest HPDF_Destination}
    HPDF_Destination_SetFitB    HPDF_STATUS      {hdest HPDF_Destination}

    HPDF_Destination_SetXYZ HPDF_STATUS {
        hdest HPDF_Destination
        left  HPDF_REAL
        top   HPDF_REAL
        zoom  HPDF_REAL
    }

    HPDF_Destination_SetFitH HPDF_STATUS {
        hdest HPDF_Destination
        top   HPDF_REAL
    }

    HPDF_Destination_SetFitV HPDF_STATUS {
        hdest HPDF_Destination
        left  HPDF_REAL
    }

    HPDF_Destination_SetFitR HPDF_STATUS {
        hdest  HPDF_Destination
        left   HPDF_REAL
        bottom HPDF_REAL
        right  HPDF_REAL
        top    HPDF_REAL
    }

    HPDF_Destination_SetFitBH HPDF_STATUS {
        hdest HPDF_Destination
        top   HPDF_REAL
    }

    HPDF_Destination_SetFitBV HPDF_STATUS {
        hdest HPDF_Destination
        left  HPDF_REAL
    }

}

# encoder :
HPDF stdcalls {

    HPDF_GetCurrentEncoder      HPDF_Encoder     {pdf HPDF_Doc}
    HPDF_Encoder_GetType        HPDF_EncoderType {hencoder HPDF_Encoder}
    HPDF_Encoder_GetWritingMode HPDF_WritingMode {hencoder HPDF_Encoder}
    HPDF_UseJPEncodings         HPDF_STATUS      {pdf HPDF_Doc}
    HPDF_UseKREncodings         HPDF_STATUS      {pdf HPDF_Doc}
    HPDF_UseCNSEncodings        HPDF_STATUS      {pdf HPDF_Doc}
    HPDF_UseCNTEncodings        HPDF_STATUS      {pdf HPDF_Doc}
    HPDF_UseUTFEncodings        HPDF_STATUS      {pdf HPDF_Doc}

    HPDF_GetEncoder HPDF_Encoder {
        pdf           HPDF_Doc
        encoding_name string
    }

    HPDF_SetCurrentEncoder HPDF_STATUS {
        pdf           HPDF_Doc
        encoding_name string
    }

    HPDF_Encoder_GetByteType HPDF_ByteType {
        hencoder HPDF_Encoder
        text     unistring
        index    HPDF_UINT
    }

    HPDF_Encoder_GetUnicode HPDF_UNICODE {
        hencoder HPDF_Encoder
        code     HPDF_UINT16
    }
}

# annotation :
    # HPDF_Page_CreateWidgetAnnot_WhiteOnlyWhilePrint HPDF_Annotation {
    #     pdf  HPDF_Doc
    #     page HPDF_Page
    #     rect HPDF_Rect
    # }
    # HPDF_Page_CreateWidgetAnnot HPDF_Annotation {
    #     page HPDF_Page
    #     rect HPDF_Rect
    # }

HPDF stdcalls {

    HPDF_Page_Create3DAnnot HPDF_Annotation {
        page HPDF_Page
        rect HPDF_Rect
        u3d  HPDF_U3D
    }

    HPDF_Page_CreateTextAnnot HPDF_Annotation {
        page    HPDF_Page
        rect    HPDF_Rect
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_Page_CreateFreeTextAnnot HPDF_Annotation {
        page    HPDF_Page
        rect    HPDF_Rect
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_Page_CreateLineAnnot HPDF_Annotation {
        page    HPDF_Page
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_Page_CreateLinkAnnot HPDF_Annotation {
        page HPDF_Page
        rect HPDF_Rect
        dst  HPDF_Destination
    }

    HPDF_Page_CreateURILinkAnnot HPDF_Annotation {
        page HPDF_Page
        rect HPDF_Rect
        url  string
    }

    HPDF_Page_CreateHighlightAnnot HPDF_Annotation {
        page    HPDF_Page
        rect    HPDF_Rect
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_Page_CreateUnderlineAnnot HPDF_Annotation {
        page    HPDF_Page
        rect    HPDF_Rect
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_Page_CreateSquigglyAnnot HPDF_Annotation {
        page    HPDF_Page
        rect    HPDF_Rect
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_Page_CreatePopupAnnot HPDF_Annotation {
        page   HPDF_Page
        rect   HPDF_Rect
        parent HPDF_Annotation
    }

    HPDF_Page_CreateProjectionAnnot HPDF_Annotation {
        page    HPDF_Page
        rect    HPDF_Rect
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_Page_CreateSquareAnnot HPDF_Annotation {
        page    HPDF_Page
        rect    HPDF_Rect
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_Page_CreateCircleAnnot HPDF_Annotation {
        page    HPDF_Page
        rect    HPDF_Rect
        text    binary
        encoder {HPDF_Encoder nullok}
    }

    HPDF_LinkAnnot_SetHighlightMode HPDF_STATUS {
        hannot HPDF_Annotation
        mode   HPDF_AnnotHighlightMode
    }

    HPDF_LinkAnnot_SetBorderStyle HPDF_STATUS {
        hannot   HPDF_Annotation
        width    HPDF_REAL
        dash_on  HPDF_UINT16
        dash_off HPDF_UINT16
    }

    HPDF_TextAnnot_SetIcon HPDF_STATUS {
        hannot HPDF_Annotation
        icon   HPDF_AnnotIcon
    }

    HPDF_TextAnnot_SetOpened HPDF_STATUS {
        hannot HPDF_Annotation
        opened HPDF_BOOL
    }

    HPDF_Annot_SetRGBColor HPDF_STATUS {
        hannot HPDF_Annotation
        color  HPDF_RGBColor
    }

    HPDF_Annot_SetCMYKColor HPDF_STATUS {
        hannot HPDF_Annotation
        color  HPDF_CMYKColor
    }

    HPDF_Annot_SetGrayColor HPDF_STATUS {
        hannot HPDF_Annotation
        color  HPDF_REAL
    }

    HPDF_Annot_SetNoColor HPDF_STATUS {
        hannot HPDF_Annotation
    }

    HPDF_MarkupAnnot_SetTitle HPDF_STATUS {
        hannot HPDF_Annotation
        name   string
    }

    HPDF_MarkupAnnot_SetSubject HPDF_STATUS {
        hannot HPDF_Annotation
        name   string
    }

    HPDF_MarkupAnnot_SetCreationDate HPDF_STATUS {
        hannot HPDF_Annotation
        name   HPDF_Date
    }

    HPDF_MarkupAnnot_SetTransparency HPDF_STATUS {
        hannot HPDF_Annotation
        value  HPDF_REAL
    }

    HPDF_MarkupAnnot_SetPopup HPDF_STATUS {
        hannot HPDF_Annotation
        value  HPDF_REAL
    }

    HPDF_MarkupAnnot_SetTransparency HPDF_STATUS {
        hannot HPDF_Annotation
        popup  HPDF_Annotation
    }

    HPDF_MarkupAnnot_SetRectDiff HPDF_STATUS {
        hannot HPDF_Annotation
        rect   HPDF_Rect
    }

    HPDF_MarkupAnnot_SetCloudEffect HPDF_STATUS {
        hannot         HPDF_Annotation
        cloudIntensity HPDF_INT
    }

    HPDF_MarkupAnnot_SetInteriorRGBColor HPDF_STATUS {
        hannot HPDF_Annotation
        color  HPDF_RGBColor
    }

    HPDF_MarkupAnnot_SetInteriorCMYKColor HPDF_STATUS {
        hannot HPDF_Annotation
        color  HPDF_CMYKColor
    }

    HPDF_MarkupAnnot_SetInteriorGrayColor HPDF_STATUS {
        hannot HPDF_Annotation
        color  HPDF_REAL
    }

    HPDF_MarkupAnnot_SetInteriorTransparent HPDF_STATUS {
        hannot HPDF_Annotation
    }

    HPDF_TextMarkupAnnot_SetQuadPoints HPDF_STATUS {
        hannot HPDF_Annotation
        lb     HPDF_Point
        rb     HPDF_Point
        rt     HPDF_Point
        lt     HPDF_Point
    }

    HPDF_Annot_Set3DView HPDF_STATUS {
        mmgr    HPDF_MMgr
        annot   HPDF_Annotation
        annot3d HPDF_Annotation
        view    HPDF_Dict
    }

    HPDF_PopupAnnot_SetOpened HPDF_STATUS {
        hannot HPDF_Annotation
        opened HPDF_BOOL
    }

    HPDF_FreeTextAnnot_Set3PointCalloutLine HPDF_STATUS {
        hannot     HPDF_Annotation
        startPoint HPDF_Point
        kneePoint  HPDF_Point
        endPoint   HPDF_Point
    }

    HPDF_FreeTextAnnot_Set2PointCalloutLine HPDF_STATUS {
        hannot     HPDF_Annotation
        startPoint HPDF_Point
        endPoint   HPDF_Point
    }

    HPDF_FreeTextAnnot_SetDefaultStyle HPDF_STATUS {
        hannot HPDF_Annotation
        style  string
    }

    HPDF_LineAnnot_SetLeader HPDF_STATUS {
        hannot          HPDF_Annotation
        leaderLen       HPDF_INT
        leaderExtLen    HPDF_INT
        leaderOffsetLen HPDF_INT
    }

    HPDF_ProjectionAnnot_SetExData HPDF_STATUS {
        hannot HPDF_Annotation
        exdata HPDF_ExData
    }
}

# 3D Measure
HPDF stdcalls {

    HPDF_Page_Create3DC3DMeasure HPDF_3DMeasure {
        page             HPDF_Page
        firstanchorpoint HPDF_Point3D
        textanchorpoint  HPDF_Point3D
    }

    HPDF_Page_CreatePD33DMeasure HPDF_3DMeasure {
        page                  HPDF_Page
        annotationPlaneNormal HPDF_Point3D
        firstAnchorPoint      HPDF_Point3D
        secondAnchorPoint     HPDF_Point3D
        leaderLinesDirection  HPDF_Point3D
        measurementValuePoint HPDF_Point3D
        textYDirection        HPDF_Point3D
        value                 HPDF_REAL
        unitsString           string
    }

    HPDF_3DMeasure_SetName HPDF_STATUS {
        measure HPDF_3DMeasure
        name    string
    }

    HPDF_3DMeasure_SetColor HPDF_STATUS {
        measure HPDF_3DMeasure
        color   HPDF_RGBColor
    }

    HPDF_3DMeasure_SetTextSize HPDF_STATUS {
        measure  HPDF_3DMeasure
        textsize HPDF_REAL
    }

    HPDF_3DC3DMeasure_SetTextBoxSize HPDF_STATUS {
        measure HPDF_3DMeasure
        x       HPDF_INT32
        y       HPDF_INT32
    }

    HPDF_3DC3DMeasure_SetText HPDF_STATUS {
        measure HPDF_3DMeasure
        text    string
        encoder HPDF_Encoder
    }

    HPDF_3DC3DMeasure_SetProjectionAnotation HPDF_STATUS {
        measure             HPDF_3DMeasure
        projectionanotation HPDF_Annotation
    }
}

# External Data 
HPDF stdcalls {

    HPDF_Page_Create3DAnnotExData HPDF_ExData {
        page HPDF_Page
    }

    HPDF_3DAnnotExData_Set3DMeasurement HPDF_ExData {
        exdata  HPDF_ExData
        measure HPDF_3DMeasure
    }
}

# 3D View
HPDF stdcalls {

    HPDF_Page_Create3DView HPDF_Dict {
        page    HPDF_Page
        u3d     HPDF_U3D
        annot3d HPDF_Annotation
        name    string
    }

    HPDF_3DView_Add3DC3DMeasure HPDF_STATUS {
        view    HPDF_Dict
        measure HPDF_3DMeasure
    }
}

# image data
HPDF stdcalls {

    HPDF_LoadPngImageFromFile HPDF_Image {
        pdf      HPDF_Doc
        filename string
    }

    HPDF_LoadPngImageFromFile2 HPDF_Image {
        pdf      HPDF_Doc
        filename string
    }

    HPDF_LoadJpegImageFromFile HPDF_Image {
        pdf      HPDF_Doc
        filename string
    }

   HPDF_LoadU3DFromFile HPDF_U3D {
        pdf      HPDF_Doc
        filename string
    }

    HPDF_LoadRawImageFromFile HPDF_Image {
        pdf         HPDF_Doc
        filename    string
        width       HPDF_UINT
        height      HPDF_UINT
        color_space HPDF_ColorSpace
    }

    HPDF_LoadRawImageFromMem HPDF_Image {
        pdf                HPDF_Doc
        data               uchar[N]
        width              HPDF_UINT
        height             HPDF_UINT
        color_space        HPDF_ColorSpace
        bits_per_component HPDF_UINT
        N                  int
    }

   HPDF_Image_AddSMask HPDF_STATUS {
        image HPDF_Image
        smask HPDF_Image
    }

    HPDF_Image_GetSize HPDF_STATUS {
        image    HPDF_Image
        position {HPDF_Point out}
    }

    HPDF_Image_GetWidth            HPDF_UINT {image HPDF_Image}
    HPDF_Image_GetHeight           HPDF_UINT {image HPDF_Image}
    HPDF_Image_GetBitsPerComponent HPDF_UINT {image HPDF_Image}
    HPDF_Image_GetColorSpace       string    {image HPDF_Image}

    HPDF_Image_SetColorMask HPDF_STATUS {
        image HPDF_Image
        rmin  HPDF_UINT
        rmax  HPDF_UINT
        gmin  HPDF_UINT
        gmax  HPDF_UINT
        bmin  HPDF_UINT
        bmax  HPDF_UINT
    }

    HPDF_Image_SetMaskImage HPDF_STATUS {
        image      HPDF_Image
        image_mask HPDF_Image
    }

}

# info dictionary
HPDF stdcalls {

    HPDF_SetInfoAttr HPDF_STATUS {
        pdf   HPDF_Doc
        type  HPDF_InfoType
        value string
    }

    HPDF_SetInfoDateAttr HPDF_STATUS {
        pdf   HPDF_Doc
        type  HPDF_InfoType
        value HPDF_Date
    }
    HPDF_GetInfoAttr unistring {
        pdf  HPDF_Doc
        type HPDF_InfoType
    }
}

# encryption
HPDF stdcalls {

    HPDF_SetPassword HPDF_STATUS {
        pdf          HPDF_Doc
        owner_passwd string
        user_passwd  string
    }

    HPDF_SetPermission HPDF_STATUS {
        pdf        HPDF_Doc
        permission HPDF_UINT
    }

    HPDF_SetEncryptionMode HPDF_STATUS {
        pdf     HPDF_Doc
        mode    HPDF_EncryptMode
        key_len HPDF_UINT
    }
}

# compression
HPDF stdcalls {

    HPDF_SetCompressionMode HPDF_STATUS {
        pdf  HPDF_Doc
        mode HPDF_UINT
    }
}

# font
HPDF stdcalls {

    HPDF_Font_GetFontName     string  {hfont HPDF_Font}
    HPDF_Font_GetEncodingName string  {hfont HPDF_Font}

    HPDF_Font_GetUnicodeWidth  HPDF_INT {
        hfont HPDF_Font
        code  HPDF_UNICODE
    }

    HPDF_Font_GetBBox      HPDF_Box {hfont HPDF_Font}
    HPDF_Font_GetAscent    HPDF_INT   {hfont HPDF_Font}
    HPDF_Font_GetDescent   HPDF_INT   {hfont HPDF_Font}
    HPDF_Font_GetXHeight   HPDF_INT   {hfont HPDF_Font}
    HPDF_Font_GetCapHeight HPDF_INT   {hfont HPDF_Font}

    HPDF_Font_TextWidth HPDF_TextWidth {
        hfont     HPDF_Font
        text      string
        len       HPDF_UINT
    }

    HPDF_Font_MeasureText HPDF_UINT {
        hfont       HPDF_Font
        text        string
        len         HPDF_UINT
        width       HPDF_REAL
        font_size   HPDF_REAL
        char_space  HPDF_REAL
        word_space  HPDF_REAL
        wordwrap    HPDF_BOOL
        real_width {HPDF_REAL out}
    }
}

# attachements
HPDF stdcalls {

    HPDF_AttachFile HPDF_EmbeddedFile {
        pdf  HPDF_Doc
        file string
    }
}

# extended graphics state
HPDF stdcalls {

    HPDF_CreateExtGState HPDF_ExtGState {pdf HPDF_Doc}

    HPDF_ExtGState_SetAlphaStroke HPDF_STATUS {
        gstate HPDF_ExtGState
        value  HPDF_REAL
    }

    HPDF_ExtGState_SetAlphaFill HPDF_STATUS {
        gstate HPDF_ExtGState
        value  HPDF_REAL
    }

    HPDF_ExtGState_SetBlendMode HPDF_STATUS {
        gstate HPDF_ExtGState
        mode   HPDF_BlendMode
    }
}

HPDF stdcalls {

    HPDF_Page_TextWidth HPDF_REAL {
        page HPDF_Page
        text binary
    }

    HPDF_Page_MeasureText HPDF_UINT {
        page       HPDF_Page
        text       binary
        width      HPDF_REAL
        wordwrap   HPDF_BOOL
        real_width HPDF_REAL
    }

    HPDF_Page_GetWidth      HPDF_REAL   {page HPDF_Page}
    HPDF_Page_GetHeight     HPDF_REAL   {page HPDF_Page}
    HPDF_Page_GetGMode      HPDF_UINT16 {page HPDF_Page}
    HPDF_Page_GetCurrentPos HPDF_Point  {page HPDF_Page}

    HPDF_Page_GetCurrentPos2 HPDF_STATUS {
        page     HPDF_Page
        position {HPDF_Point out}
    }

    HPDF_Page_GetCurrentTextPos HPDF_Point {
        page      HPDF_Page
    }

    HPDF_Page_GetCurrentTextPos2 HPDF_STATUS {
        page      HPDF_Page
        position {HPDF_Point out}
    }

    HPDF_Page_GetCurrentFont        {HPDF_Font counted}    {page HPDF_Page}
    HPDF_Page_GetCurrentFontSize    HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetTransMatrix        HPDF_TransMatrix       {page HPDF_Page}
    HPDF_Page_GetLineWidth          HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetLineCap            HPDF_LineCap           {page HPDF_Page}
    HPDF_Page_GetLineJoin           HPDF_LineJoin          {page HPDF_Page}
    HPDF_Page_GetMiterLimit         HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetDash               HPDF_DashMode          {page HPDF_Page}
    HPDF_Page_GetFlat               HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetCharSpace          HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetWordSpace          HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetHorizontalScalling HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetTextLeading        HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetTextRenderingMode  HPDF_TextRenderingMode {page HPDF_Page}
    HPDF_Page_GetTextRaise          HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetTextRise           HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetRGBFill            HPDF_RGBColor          {page HPDF_Page}
    HPDF_Page_GetRGBStroke          HPDF_RGBColor          {page HPDF_Page}
    HPDF_Page_GetCMYKFill           HPDF_CMYKColor         {page HPDF_Page}
    HPDF_Page_GetCMYKStroke         HPDF_CMYKColor         {page HPDF_Page}
    HPDF_Page_GetGrayFill           HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetGrayStroke         HPDF_REAL              {page HPDF_Page}
    HPDF_Page_GetStrokingColorSpace HPDF_ColorSpace        {page HPDF_Page}
    HPDF_Page_GetFillingColorSpace  HPDF_ColorSpace        {page HPDF_Page}
    HPDF_Page_GetTextMatrix         HPDF_TransMatrix       {page HPDF_Page}
    HPDF_Page_GetGStateDepth        HPDF_UINT              {page HPDF_Page}

}

# GRAPHICS OPERATORS
#   General graphics state
HPDF stdcalls {

    HPDF_Page_SetLineWidth HPDF_STATUS {
        page       HPDF_Page
        line_width HPDF_REAL
    }

    HPDF_Page_SetLineCap HPDF_STATUS {
        page     HPDF_Page
        line_cap HPDF_LineCap
    }

    HPDF_Page_SetLineJoin HPDF_STATUS {
        page      HPDF_Page
        line_join HPDF_LineJoin
    }
    HPDF_Page_SetMiterLimit HPDF_STATUS {
        page        HPDF_Page
        miter_limit HPDF_REAL
    }

    HPDF_Page_SetDash HPDF_STATUS {
        page      HPDF_Page
        dash_ptn  ushort[5]
        num_param HPDF_UINT
        phase     HPDF_UINT
    }

    HPDF_Page_SetFlat HPDF_STATUS {
        page     HPDF_Page
        flatness HPDF_REAL
    }
    HPDF_Page_SetExtGState HPDF_STATUS {
        page       HPDF_Page
        ext_gstate HPDF_ExtGState
    }
}

#   Special graphic state operator
HPDF stdcalls {

    HPDF_Page_GSave    HPDF_STATUS {page HPDF_Page}
    HPDF_Page_GRestore HPDF_STATUS {page HPDF_Page}

    HPDF_Page_Concat HPDF_STATUS {
        page HPDF_Page
        a    HPDF_REAL
        b    HPDF_REAL
        c    HPDF_REAL
        d    HPDF_REAL
        x    HPDF_REAL
        y    HPDF_REAL
    }
}

#   Path construction operator
HPDF stdcalls {

    HPDF_Page_MoveTo HPDF_STATUS {
        page HPDF_Page
        x    HPDF_REAL
        y    HPDF_REAL
    }

    HPDF_Page_LineTo HPDF_STATUS {
        page HPDF_Page
        x    HPDF_REAL 
        y    HPDF_REAL
    }

    HPDF_Page_CurveTo  HPDF_STATUS {
        page HPDF_Page
        x1   HPDF_REAL
        y1   HPDF_REAL
        x2   HPDF_REAL
        y2   HPDF_REAL
        x3   HPDF_REAL
        y3   HPDF_REAL
    }

    HPDF_Page_CurveTo2 HPDF_STATUS {
        page HPDF_Page
        x2   HPDF_REAL
        y2   HPDF_REAL
        x3   HPDF_REAL
        y3   HPDF_REAL
    }

    HPDF_Page_CurveTo3 HPDF_STATUS {
        page HPDF_Page
        x1   HPDF_REAL
        y1   HPDF_REAL
        x3   HPDF_REAL
        y3   HPDF_REAL
    }

    HPDF_Page_ClosePath HPDF_STATUS {page HPDF_Page}

    HPDF_Page_Rectangle HPDF_STATUS {
        page   HPDF_Page
        x      HPDF_REAL
        y      HPDF_REAL
        width  HPDF_REAL
        height HPDF_REAL
    }
}

#   Path painting operator
HPDF stdcalls {

    HPDF_Page_Stroke                HPDF_STATUS {page HPDF_Page}
    HPDF_Page_ClosePathStroke       HPDF_STATUS {page HPDF_Page}
    HPDF_Page_Fill                  HPDF_STATUS {page HPDF_Page}
    HPDF_Page_Eofill                HPDF_STATUS {page HPDF_Page}
    HPDF_Page_FillStroke            HPDF_STATUS {page HPDF_Page}
    HPDF_Page_EofillStroke          HPDF_STATUS {page HPDF_Page}
    HPDF_Page_ClosePathFillStroke   HPDF_STATUS {page HPDF_Page}
    HPDF_Page_ClosePathEofillStroke HPDF_STATUS {page HPDF_Page}
    HPDF_Page_EndPath               HPDF_STATUS {page HPDF_Page}
}

#   Clipping paths operator
HPDF stdcalls {

    HPDF_Page_Clip   HPDF_STATUS {page HPDF_Page}
    HPDF_Page_Eoclip HPDF_STATUS {page HPDF_Page}
}

#   Text object operator
HPDF stdcalls {

    HPDF_Page_BeginText HPDF_STATUS {page HPDF_Page}
    HPDF_Page_EndText   HPDF_STATUS {page HPDF_Page}
}

#   Text state
HPDF stdcalls {

    HPDF_Page_SetCharSpace HPDF_STATUS {
        page  HPDF_Page
        value HPDF_REAL
    }
    
    HPDF_Page_SetWordSpace HPDF_STATUS {
        page  HPDF_Page
        value HPDF_REAL
    }
    HPDF_Page_SetHorizontalScalling HPDF_STATUS {
        page  HPDF_Page
        value HPDF_REAL
    }
    HPDF_Page_SetTextLeading HPDF_STATUS {
        page  HPDF_Page
        value HPDF_REAL
    }
    HPDF_Page_SetFontAndSize HPDF_STATUS {
        page  HPDF_Page
        hfont HPDF_Font
        size  HPDF_REAL
    }

    HPDF_Page_SetTextRenderingMode HPDF_STATUS {
        page HPDF_Page
        mode HPDF_TextRenderingMode
    }

    HPDF_Page_SetTextRise HPDF_STATUS {
        page HPDF_Page
        value HPDF_REAL
    }

    HPDF_Page_SetTextRaise HPDF_STATUS {
        page HPDF_Page
        value HPDF_REAL
    }
}

#   Text positioning
HPDF stdcalls {

    HPDF_Page_MoveTextPos HPDF_STATUS {
        page HPDF_Page
        x HPDF_REAL
        y HPDF_REAL
    }
    HPDF_Page_MoveTextPos2 HPDF_STATUS {
        page HPDF_Page
        x HPDF_REAL
        y HPDF_REAL
    }
    HPDF_Page_SetTextMatrix HPDF_STATUS {
        page HPDF_Page
        a HPDF_REAL
        b HPDF_REAL
        c HPDF_REAL
        d HPDF_REAL
        x HPDF_REAL
        y HPDF_REAL
    }

    HPDF_Page_MoveToNextLine HPDF_STATUS {page HPDF_Page}

}

#   Text showing
HPDF stdcalls {

    HPDF_Page_ShowText HPDF_STATUS {
        page HPDF_Page
        text binary
    }

    HPDF_Page_ShowTextNextLine HPDF_STATUS {
        page HPDF_Page
        text binary
    }

    HPDF_Page_ShowTextNextLineEx HPDF_STATUS {
        page       HPDF_Page
        word_space HPDF_REAL
        char_space HPDF_REAL
        text       binary
    }
}

#   Color showing
HPDF stdcalls {

    HPDF_Page_SetGrayFill HPDF_STATUS {
        page HPDF_Page
        gray HPDF_REAL
    }

    HPDF_Page_SetGrayStroke HPDF_STATUS {
        page HPDF_Page
        gray HPDF_REAL
    }

    HPDF_Page_SetRGBFill HPDF_STATUS {
        page HPDF_Page
        r    HPDF_REAL
        g    HPDF_REAL
        b    HPDF_REAL
    }

    HPDF_Page_SetRGBStroke HPDF_STATUS {
        page HPDF_Page
        r    HPDF_REAL
        g    HPDF_REAL
        b    HPDF_REAL
    }
    HPDF_Page_SetCMYKFill HPDF_STATUS {
        page HPDF_Page
        c    HPDF_REAL
        m    HPDF_REAL
        y    HPDF_REAL
        k    HPDF_REAL
    }

    HPDF_Page_SetCMYKStroke HPDF_STATUS {
        page HPDF_Page
        c    HPDF_REAL
        m    HPDF_REAL
        y    HPDF_REAL
        k    HPDF_REAL
    }
}

#   XObjects
HPDF stdcalls {

    HPDF_Page_ExecuteXObject HPDF_STATUS {
        page HPDF_Page
        obj  HPDF_XObject
    }
}

#   Geom
HPDF stdcalls {

    HPDF_Page_DrawImage HPDF_STATUS {
        page   HPDF_Page
        image  HPDF_Image
        x      HPDF_REAL
        y      HPDF_REAL
        width  HPDF_REAL
        height HPDF_REAL
    }

    HPDF_Page_Circle HPDF_STATUS {
        page HPDF_Page
        x    HPDF_REAL
        y    HPDF_REAL
        ray  HPDF_REAL
    }

    HPDF_Page_Arc HPDF_STATUS {
        page HPDF_Page
        x    HPDF_REAL
        y    HPDF_REAL
        ray  HPDF_REAL
        ang1 HPDF_REAL
        ang2 HPDF_REAL
    }
    HPDF_Page_Ellipse HPDF_STATUS {
        page HPDF_Page
        x    HPDF_REAL
        y    HPDF_REAL 
        xray HPDF_REAL
        yray HPDF_REAL
    }

    HPDF_Page_TextOut HPDF_STATUS {
        page HPDF_Page
        xpos HPDF_REAL
        ypos HPDF_REAL
        text binary
    }
    HPDF_Page_TextRect HPDF_STATUS {
        page   HPDF_Page
        left   HPDF_REAL
        top    HPDF_REAL
        right  HPDF_REAL
        bottom HPDF_REAL
        text   binary
        align  HPDF_TextAlignment
        len    {HPDF_UINT out}
    }

    HPDF_Page_SetSlideShow HPDF_STATUS {
        page       HPDF_Page
        type       HPDF_TransitionStyle
        disp_time  HPDF_REAL
        trans_time HPDF_REAL
    }
}

# u3d.h
HPDF stdcalls {

    HPDF_3DView_SetBackgroundColor HPDF_STATUS {
        view HPDF_Dict
        r    HPDF_REAL
        g    HPDF_REAL
        b    HPDF_REAL
    }

    HPDF_U3D_Add3DView HPDF_STATUS {
        u3d  HPDF_U3D
        view HPDF_Dict
    }

}

# mmgr.h
# Not exported in 2.3.0 on Windows. Ignore if not available
catch {
    HPDF stdcall HPDF_MMgr_New HPDF_MMgr {
        user_error_fn   {pointer {default NULL} nullok} 
        user_error_data {pointer {default NULL} nullok}
        alloc_fn        {pointer {default NULL} nullok}
        free_fn         {pointer {default NULL} nullok}
    }
}

# stream.h
# Not exported in 2.3.0 on Windows. Ignore if not available
catch {
    HPDF stdcalls {
        HPDF_FileReader_New HPDF_Stream {
            mmgr  HPDF_MMgr
            fname string
        }
        HPDF_FileWriter_New HPDF_Stream {
            mmgr  HPDF_MMgr
            fname string
        }
        HPDF_Stream_WriteToStream HPDF_STATUS {
            src    HPDF_Stream
            dst    HPDF_Stream
            filter HPDF_UINT
            e      {HPDF_Encrypt nullok}
        }

        HPDF_Stream_WriteToStreamWithDeflate HPDF_STATUS {
            src    HPDF_Stream
            dst    HPDF_Stream
            e      {HPDF_Encrypt nullok}
        }
    }
}

package provide haru $::haru::version
