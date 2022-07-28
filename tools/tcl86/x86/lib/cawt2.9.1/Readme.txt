CAWT is a high-level Tcl interface for scripting Microsoft Windows® 
applications having a COM interface.
It uses Twapi for automation via the COM interface.
Currently packages for Microsoft Excel, Word, PowerPoint, OneNote, 
Outlook, SAPI and Internet Explorer, as well as for Adobe Reader,
MathWorks Matlab and Google Earth are available.

Note, that only Microsoft Office packages Excel, Word, PowerPoint
and Outlook are in active developement.
The other packages are proof-of-concept examples only.

CAWT sources are available at https://sourceforge.net/projects/cawt/
The CAWT homepage is at http://www.cawt.tcl3d.org.
CAWT is also available via BAWT (Build Automation With Tcl) at
http://www.bawt.tcl3d.org

The CAWT user distribution contains the Tcl sources, documentation (user 
and reference manual), several test programs showing the use of the CAWT
functionality and external libraries Twapi, TkImg, Base64 and Tablelist.

The CAWT developer distribution additionally contains scripts for 
generating the documentation, the distribution packages and the CAWT
Starkit. It also includes the external packages Ruff! and textutil.
The developer distribution is intended for programmers who want to
extend the CAWT package.

Release history:
================

2.9.1   2022-04-09
    Maintenance release.

    CawtExcel:  
        Added option "-selection" to procedure WorksheetToTablelist to transfer
        the selected Excel cell range.
        Corrected regexp in procedures GetRangeAsIndex and GetCellValueA1.

    CawtOutlook:  
        Improved GetFoldersRecursive.

    New procedures in CawtWord:  
        GetHeadingsAsDict, PrintHeadingDict

2.9.0   2021-12-19
    Added functionality for interpolation curves.

    CawtCore:  
        Added oo:class to interpolate between control points.

    CawtWord:  
        GetHyperlinksAsDict:
          Improved speed of URL validity check.
          Added support for URL's with subaddress (ex. www.tcl3d.org/doc.html#Index).

    New procedures in CawtCore:  
        IsValidUrlAddress, SetClipboardWaitTime, WaitClipboardReady

    New procedures in CawtPpt:  
        IsValidPresId, GetCurrentSlideIndex

    External packages:
        Updated Ruff! to version 2.0.
        Updated Tablelist to version 6.16.
        Updated Twapi to version 4.6.0.

2.8.2   2021-08-20
    Maintenance release.

    CawtWord:  
        Corrected behaviour of GetHyperlinksAsDict, if link points to an URL with spaces.
        Extended SetTableOptions with new option -width.
        Extended SetColumnWidth to specify width in percent.

2.8.1   2021-07-22
    Maintenance release.

    CawtExcel:  
        Added automatic mapping of worksheet names to Excel constraints
        regarding invalid characters and maximum length

    CawtWord:  
        Corrected behaviour of GetHyperlinksAsDict, if link points to an invalid domain.

2.8.0   2021-06-27
    Added functionality for embedding applications.

    CawtExcel:  
        Extended procedure OpenWorkbook to embed the application into a Tk frame.

    CawtPpt:  
        Extended procedure OpenPres to embed the application into a Tk frame.

    CawtReader:  
        Extended procedure Open to embed the application into a Tk frame.

    CawtWord:  
        Extended procedure OpenDocument to embed the application into a Tk frame.

    New procedures in CawtCore:  
        EmbedApp, SetEmbedTimeout

    New procedures in CawtExcel:  
        GetNumStyles, GetStyleId

    New procedures in CawtWord:  
        GetNumPages, SetViewParameters

    External packages:
        Updated Tablelist to version 6.14.
        Updated Ruff! to version 1.2.

2.7.0   2021-02-27
    Enhanced functionality for handling Outlook contacts.

    CawtCore:
        Extended procedure CountWords to additionally sort by 
        increasing or decreasing counts.

    CawtExcel:
        Changes in procedure WorksheetToTablelist:
        Improved speed when handling worksheets with large number of columns.
        Tablelist column headers are labeled like in Excel: A, B, C, ...
        Added options -header, -rownumber, -maxrows, -maxcols.

    CawtWord:
        Extended GetHyperlinksAsDict to be used as a coroutine.

    New procedures in CawtOutlook:  
        AddContact, AddContactFolder, DeleteContactByIndex,
        DeleteContactFolder, GetContactByIndex, GetContactFolderId,
        GetContactFolderNames, GetContactProperties, GetNumContactFolders,
        GetContactReadOnlyPropertyNames, GetContactReadWritePropertyNames,
        GetNumContacts, HaveContactFolder, SetContactProperties

    New procedures in CawtPpt:  
        GetNumSlideImages, GetNumSlideVideos, GetSlideIdByName,
        GetSlideImages, GetSlideName, GetSlideVideos, SetSlideName

    New procedures in CawtWord:  
        GetBookmarkNames, GetHyperlinksAsDict, PrintHyperlinkDict,
        GetNumHyperlinks

    External packages:
        Updated Tablelist to version 6.12.
        Updated Ruff! to version 1.1.


2.6.0   2021-01-06
    New module CawtSapi adding support for Microsoft Speech API.

    New procedures in CawtCore:
        SetEventCallback

    External packages:
        Updated Twapi to version 4.5.2.
        Updated Tablelist to version 6.11.
        Updated tDOM to version 0.9.2.
        Updated Img to version 1.4.12.


2.5.0   2020-07-25
    Enhanced functionality for handling Office document properties.

    CawtOffice:
        Extended to support all types of document properties:
        bool, int, float, date and string.

    New procedures in CawtOffice:  
        AddProperty, DeleteProperty, GetProperty,
        GetPropertyName, GetPropertyType, GetPropertyValue,
        SetPropertyValue


2.4.9   2020-06-09
    Enhanced functionality in Excel module

    All modules:
        Compare procedure options with -nocase.

    CawtExcel:
        Fixed bug when reading CSV files with Unix line endings.

    New procedures in CawtExcel:  
        SetRangeFontAttributes, GetRangeFontAttributes


2.4.8   2020-03-08
    Support for Office macro execution.

    CawtExcel:
        Fixed bugs in DiffExcelFiles.

    CawtWord:
        Fixed COM object leak in IsValidCell.

    New procedures in CawtCore:
        GetTmpDir

    New procedures in CawtOffice:
        AddMacro, RunMacro

    New procedures in CawtExcel:
        GetCellValueA1

    New procedures in CawtWord:
        GetRangeScreenPos


2.4.7   2019-11-03
    Enhanced functionality in Ppt and Word modules.

    CawtPpt:
        Extended InsertImage to support both image file names as well as photo images.
        Corrected procedure ExportPptFile.
        Added additional "-check" option to proc CreateVideo to specify the check interval.

    New procedures in CawtPpt:
        GetPptImageFormat, GetSupportedImageFormats, 
        GetCreateVideoStatus, IsImageFormatSupported

    New procedures in CawtWord:
        SetPageSetup, GetCrossReferenceItems, GetHeadingRanges,
        GetRangeText, SetRangeFontColor, GetRangeFont, SetRangeFont

2.4.6   2019-10-12
    Enhanced reference documentation.

    CawtCore:
        Extended test suite for complete test coverage.
        Fixed bug in procedure GetColorNames.

    Office modules:
        Added procedures for each enumeration type.

    CawtPpt:
        Added new option "-fit" to proc InsertImage.

    New procedures in CawtPpt:
        CheckCreateVideoStatus, CreateVideo, SetSlideShowTransition,
        GetPresPageHeight, GetPresPageWidth

    External packages:
        Updated Ruff! to version 1.0b3.

2.4.5   2019-08-13
    Enhanced functionality in Word module.

    CawtWord:
        Corrected procedures FindString and Search, when called
        with a docId.

    New procedures in CawtWord:
        GetFooterText, GetHeaderText,
        DeleteSubdocumentLinks, ExpandSubdocuments, 
        GetNumSubdocuments, GetSubdocumentPath

    External packages:
        Updated Tablelist to version 6.6.
        Updated Twapi to version 4.3.7.

2.4.4   2019-06-08
    Enhanced functionality in several modules.

    CawtCore:
        Added new utility procedures *OfficeDate*. 
        Declared old *OutlookDate* procedures as obsolete.

    CawtExcel:
        Extended procedure GetCellRange to allow specification
        of a cell range, not only a single cell.
        Extended procedure AddSeriesTrendLine with option keys
        -linewidth and -linecolor.

    New procedure in CawtExcel:
        SetSeriesAttributes

    New procedures in CawtWord:
        SetTableAlignment, SetTableOptions, SetTableVerticalAlignment

    External packages:
        Updated Tablelist to version 6.5.
        Updated Img to version 1.4.9.

2.4.3   2018-12-27
    Support for Office 2019.

    CawtOffice:
        Added script DocumentInfo.tcl to retrieve information about
        Office documents.

    CawtWord:
        Extended procedure GetRowRange to use start and end rows.
        Extended procedure GetNumImages to consider both InlineShapes as
        well as Shapes.

    New procedure in CawtOffice:
        GetOfficeType

    New procedure in CawtExcel:
        AddSeriesTrendLine

    New procedures in CawtPpt:
        GetCommentKeyTopPosition, GetNumShapes, GetPresImages, GetPresVideos,
        GetShapeId, GetShapeMediaType, GetShapeName, GetShapeType,
        InsertVideo, SetShapeName, SetMediaPlaySettings

    New procedures in CawtWord:
        CollapseRange, CopyRange, DeleteTable, GetImageList,
        GetPageSetup, GetRowId, GetTableIdByName, GetTableName,
        IsVisible, MergeCells, ScreenUpdate, SetCellVerticalAlignment,
        SetHeadingFormat, SetRowHeight, SetTableName

    External packages:
        Updated Tablelist to version 6.3.
        Updated Img to version 1.4.8.
        Updated Twapi to version 4.3.5.
        Updated tDOM to version 0.9.1.

2.4.2   2018-04-26
    Enhanced functionality in several modules.

    CawtPpt:
        Added new configure options for shapes: -beginsite, -endsite
        Added new configure option for connectors: -weight

    CawtWord:
        Corrected procedure SetDocumentProperty.

    New procedures in CawtExcel:
        Import, CopyColumn, SetChartSourceByIndex, SetChartTitle,
        GetChartNumSeries, GetChartSeries, SetSeriesLineWidth

    New procedures in CawtPpt:
        SetPresPageSetup, SetHyperlinkToSlide, GetNumSites

    New procedures in CawtWord:
        DeleteRow, SetRangeMergeCells

2.4.1   2017-12-30
    Enhanced functionality in Outlook module.

    CawtOutlook:
        Added handling of appointments, calendars and categories.
        Added ability to read and apply Outlook holiday files.

    CawtExcel:
        Added ability to save CSV files in UTF-8 format.

    New procedures in CawtExcel:
        CreateRangeString, SetChartTicks

    New procedures in CawtWord:
        AddImageTable, GetImageId, GetImageName, GetNumImages,
        ReplaceImage, SetImageName, CountWords

    External packages:
        Updated Tablelist to version 6.0.
        Updated Twapi to version 4.2.12.
        Updated tDOM to version 0.9.
        Updated Img to version 1.4.7.


2.4.0   2017-06-18
    New module CawtReader.

    Compatibility issue:
        Excel::ExcelFileToHtmlFile has changed signature.
        Now uses parameter args for extended options.

    CawtReader:
        Added basic functionality for Acrobat Reader (not via COM).

    CawtExcel:
        Extended module excelHtml to convert Excel hyperlinks.

    New procedures in CawtWord:
        IsValidCell

    External packages:
        Updated Tablelist to version 5.17.
        Updated Twapi to version 4.2a5.


2.3.1   2016-12-10
    Enhanced functionality in Core and Office modules.

    CawtExcel:
        Extended Excel module excelImgRaw to support 16-bit integer images.

    New procedures in CawtCore:
        CheckBoolean

    New procedures in CawtExcel:
        GetCellComment

    New procedures in CawtWord:
        Search SetRangeFontBackgroundColor

    External packages:
        Updated Img (32 and 64 bit) to version 1.4.6.
        Updated Tablelist to version 5.16.

2.3.0   2016-08-16
    New module CawtOneNote.

    Compatibility issue:
        Excel::GetRangeAsIndex now returns a 2-element (cell)
        or 4-element (range) list.
        Previous behaviour was to always return a 4 element list.

    CawtOneNote:
        Added basic functionality for Microsoft OneNote.
        Added script OneNoteInfo.tcl to retrieve information from OneNote.

    New procedures in CawtExcel:
        DuplicateColumn, DuplicateRow, 
        GetHiddenRows, HideRow,
        InsertColumn, InsertRow,
        GetColumnNumber, ShowWorksheet, IsWorksheetEmpty,
        GetRangeWrapText, SetRangeWrapText,
        SetRangeValues, GetRangeValues,
        IsWorkbookId, GetWorkbookIdByName, IsWorkbookOpen,
        SetNamedRange, GetNamedRange, GetNamedRangeNames

    New procedures in CawtOutlook:
        CreateHtmlMail

    External packages:
        Updated Tablelist to version 5.15.
        Updated Twapi to version 4.2a3.
        New package tDOM 0.8.3 (needed for CawtOneNote).

2.2.0   2015-12-12
    Enhanced functionality in Core and Office modules.

    Compatibility issue:
        AddWorksheet now adds the new sheet at the end,
        as was already written in the documentation.
        Previous behaviour was to insert before active worksheet.

    New module CawtOffice:
        Moved basic Office procedures into namespace Office.
        Added aliases in namespace Cawt for backwards compatibility.
        Added new enumeration constants file for basic Office types
        based on type library in mso.dll.

    CawtCore:
        Colors can now be specified in hex notation, Tcl color names,
        RGB or as Office color numbers.

    CawtExcel:
        Extended SetLinkToCell to copy number format when linking.
        Extended SetRangeFormat to accept Excel style number formats.
        Extended SetHyperlinkToFile to accept relative path names.
        Corrected hyperlinking to relative file names.

    New procedures in CawtCore:
        GetColor, GetColorNames, 
        IsHexColor, IsNameColor, IsOfficeColor, IsRgbColor
        OfficeColorToRgb, RgbToOfficeColor

    New procedures in CawtExcel:
        CopyRange, GetCurrencyFormat, GetRangeFormat

    New procedures in CawtPpt:
        AddShape, ConfigureShape, ConnectShapes, ConfigureConnector

    New procedures in CawtWord:
        SetHyperlinkToFile

2.1.2   2015-11-10
    Extended support for Excel page setup.
    Changed all Office procedures with size parameters to accept 
    inches, centimeters or points.

    CawtExcel:
        Corrected SetWorksheetFitToPages to accept zero as values for
        wide and tall parameters. Zero indicates automatic determination
        of number of pages.
    New procedures in CawtCore:
        SetPrinterCommunication,
        ValueToPoints, PointsToCentiMeters, PointsToInches.
    New procedures in CawtExcel:
        SetWorksheetPrintOptions, SetWorksheetPaperSize,
        SetWorksheetMargins, SetWorksheetFooter, SetWorksheetHeader.

2.1.1   2015-10-31
    Support for Office 2016.

    External packages:
        Updated Tablelist to version 5.14.

2.1.0   2015-09-01
    Updated Twapi to version 4.2.a1, because of new Twapi functionality
    "tclcast bstr" and bug fix to retrieve document properties.
    Added support to generate a CAWT starpack.
    CawtExcel:
        Take hidden flag of both Excel and tablelist columns into account 
        in procedures TablelistToWorksheet and WorksheetToTablelist.
        Fixed SetCellValue and SetRangeFormat using new TclString
        procedure.
    CawtPpt:
        Extended functionality of ExportPptFile and ExportSlides to take
        into account slide comments regarding export file names.
    New procedures in CawtCore:
        TclString.
    New procedures in CawtExcel:
        DeleteColumn, DeleteRow, HideColumn, GetHiddenColumns,
        GetDecimalSeparator (replacing GetFloatSeparator), 
        GetThousandsSeparator,
        GetNumberFormat (replacing GetLangNumberFormat).
    New procedures in CawtPpt:
        AddTextbox, AddTextboxText, SetTextboxFontSize,
        GetNumComments, GetComments, GetCommentKeyValue.
    New procedures in CawtWord:
        AddContentControl, SetContentControlDropdown, 
        SetContentControlText, GetDocumentProperties,
        GetDocumentProperty, SetDocumentProperty.

2.0.0   2015-03-31
    Ensembled all CAWT namespaces.
    All Office enumerations are stored in module specific hash tables.
    Updated and extended user manual.
    Added application EnumExplorer.tcl to display Office enumerations.
    New module excelHtml.tcl for HTML export of Excel tables.
    External packages:
        Updated Twapi to version 4.1.27.
        Updated Img (32 and 64 bit) to version 1.4.3.
        Updated Tablelist to version 5.13.
    CawtExcel:
        New implementation of InsertImage.
    CawtWord:
        Extended procedure UpdateFields to update TablesOfContents and 
        TablesOfFigures of a document.
    New procedures in CawtCore:
        GetApplicationVersion, IsApplicationId, 
        PushComObjects, PopComObjects, 
        PrintNumComObjects, CheckComObjects, 
        GetComObjects, GetNumComObjects
        Replaced procedure IsValidId with IsComObject
    New procedures in CawtExcel:
        GetRangeAsIndex, GetRangeAsString, GetRangeTextColor
    New procedures in CawtWord:
        ScaleImage, SetInternalHyperlink, InsertFile, DiffWordFile

1.2.0   2014-12-14
    Compatibility issue: Incompatible changes in module CawtWord.
        Removed parameter docId from all procedures, which had both
        docId and rangeId parameters:
            SetRangeStartIndex, SetRangeEndIndex, ExtendRange,
            AddText, SetHyperlink, AddTable.
    CawtExcel: Added optional startRow parameter to TablelistToWorksheet.
    Extended test suite for changed and new procedures.
    New procedures in CawtWord:
        GetDocumentId, SetRangeFontUnderline, CreateRangeAfter,
        InsertCaption, ConfigureCaption,
        AddBookmark, GetBookmarkName, SetLinkToBookmark,
        GetListGalleryId, GetListTemplateId, InsertList

1.1.0   2014-08-30
    Compatibility issue: Incompatible changes in module CawtWord.
        Unified signatures of AddText, AppendText, 
        AddParagraph, AppendParagraph.
        Changed handling of text ranges.
    New module CawtOutlook to control Microsoft Outlook applications.
        Currently only functionality for creating and sending mails.
    Extended test suite for changed and new procedures.
    New procedures in CawtExcel:
        FreezePanes, ScreenUpdate
    New procedures in CawtWord:
        SelectRange, GetRangeInformation, CreateRange, SetRangeFontName, 
        SetRangeStyle, SetRangeFontSize,
        InsertText, AddText, GetNumCharacters,
        AddPageBreak, ToggleSpellCheck

1.0.7   2014-06-14
    Updated Twapi version to official 4.0.61.
    Extended test suite for changed and new procedures.
    CawtExcel:
        Added support for CSV files with multi-line cells.
    CawtPpt:
       Extended CopySlide to copy slides between presentations.
       Extended AddPres with optional parameter for template file.
       Extended AddSlide to supply custom layout object as type parameter.
    New procedures in CawtCore:
        ColorToRgb
    New procedures in CawtExcel:
        UseImgTransparency, WorksheetToImg, ImgToWorksheet,
        SetRowHeight, SetRowsHeight, GetRangeFillColor,
        SetHyperlinkToFile, SetHyperlinkToCell, SetLinkToCell,
        SetRangeTooltip
    New procedures in CawtPpt:
        MoveSlide, GetTemplateExtString, GetNumCustomLayouts,
        GetCustomLayoutName, GetCustomLayoutId

1.0.6   2014-04-21
    Improved and extended test suite.
    Updated Twapi version to 4.0b53 to fix a bug with sparse matrices as
    well as core dumps with Word 2013.
    Improved and corrected handling of sparse matrices in Excel.
    Bug fix in excelCsv module.
    Possible incompatibility in GetRowValues and GetColumnValues:
        Changed startRow resp. startCol to default value 0 instead of 1.
    New procedures in CawtExcel:
        GetWorksheetAsMatrix, GetMaxRows, GetMaxColumns, GetFirstUsedRow,
        GetLastUsedRow, GetFirstUsedColumn, GetLastUsedColumn.

1.0.5   2014-01-26
    New procedures in CawtExcel:
        SetCommentDisplayMode, SetRangeComment, SetRangeMergeCells, 
        SetRangeFontSubscript, SetRangeFontSuperscript, GetRangeCharacters.

1.0.4   2013-11-23
    Improved test suite.
    Added support for Office 2013.
    Added support for 64-bit Office.
    Updated Img extension to version 1.4.2 (32-bit and 64-bit).
    Update Tablelist to version 5.10.
    New procedures in CawtWord:
        SaveAsPdf, UpdateFields, CropImage.
    New procedures in CawtExcel:
        CopyWorksheetBefore, CopyWorksheetAfter, 
        GetWorksheetIndexByName, IsWorksheetProtected, 
        IsWorksheetVisible, SetWorksheetTabColor,
        UnhideWorksheet, DiffExcelFiles.

1.0.3   2013-08-30
    New procedures in CawtExcel:
        ExcelFileToMediaWikiFile, ExcelFileToWikitFile,
        ExcelFileToRawImageFile, RawImageFileToExcelFile,
        ExcelFileToMatlabFile, MatlabFileToExcelFile,
        GetTablelistValues, SetTablelistValues.

1.0.2   2013-07-28
    Updated Twapi version to 4.0b22.
    Updated Img version to 1.4.1.
    Added new module CawtOcr. 
    New procedures in CawtCore:
        Clipboard2Img, Img2Clipboard
    New procedures in CawtExcel: 
        SetRangeBorder 

1.0.1   2013-04-28
    Extended Excel chart generation. 
    Updated Twapi version to 4.0a16. 
    Added support to generate a CAWT starkit.

1.0.0   2012-12-23
    Replaced Tcom with Twapi for COM access.
    Added support for PowerPoint, InternetExplorer, GoogleEarth and Matlab.
    Added user and reference manual.
    Unification of procedure names.
    Support for Microsoft Office versions 2003, 2007, 2010.
