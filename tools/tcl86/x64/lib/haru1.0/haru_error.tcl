# Copyright (c) 2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl binding for libharu (http://libharu.org/) PDF library.

namespace eval haru {}

proc haru::NullHandler {callinfo} {
    # Credit to Ashok P. Nadkarni https://www.magicsplat.com
    #
    #
    # The $callinfo dictionary contains the information about call failure.
    # This handler is intended to be used for functions that take a HPDF_Doc
    # as an input parameter and return another handle which is NULL on failure.
    # The detail error code has then to be retrieved from the HPDF_Doc. By
    # *convention* the input parameter holding the HPDF_Doc handle should be
    # called hpdf so this handler knows how to get hold of it.

    # The In element of the $callinfo dictionary holds input arguments.
    if {[dict exists $callinfo In pdf]} {
        set hpdf [dict get $callinfo In pdf]
        # Ensure the HPDF_Doc is itself not NULL.
        if {![cffi::pointer isnull $hpdf]} {
            set error_status [HPDF_GetError $hpdf]
            catch {HPDF_ResetError $hpdf}

            set status    [format "0x%X" $error_status]
            set dicterror [haru::errorlist]

            if {[dict exists $callinfo Command]} {                
                set cmd [dict get $callinfo Command]
            } else {
                set cmd ""
            }

            if {[dict exists $dicterror $status]} {
                set message [concat $status [dict get $dicterror $status] "From function $cmd"]
            } else {
                set message "Error code $status returned from function $cmd"
            }

            throw [list HPDFStatus $status] $message

        }
    }
    # Fallback in cases where the hpdf name convention not followed or hpdf
    # itself is NULL. If the Command key exists, it is the name of the
    # function that was called.
    if {[dict exists $callinfo Command]} {
        throw HPDFNull "Null pointer returned from function [dict get $callinfo Command]."
    } else {
        throw HPDFNull "Null pointer returned from function."
    }
}

proc haru::errorlist {} {
    # error list http://libharu.sourceforge.net/error_handling.html
    #
    # Returns error message...
    set herror {

        0x1001 {HPDF_ARRAY_COUNT_ERR               : Internal error. The consistency of the data was lost. }
        0x1002 {HPDF_ARRAY_ITEM_NOT_FOUND          : Internal error. The consistency of the data was lost.}
        0x1003 {HPDF_ARRAY_ITEM_UNEXPECTED_TYPE    : Internal error. The consistency of the data was lost.}
        0x1004 {HPDF_BINARY_LENGTH_ERR             : The length of the data exceeds HPDF_LIMIT_MAX_STRING_LEN.}
        0x1005 {HPDF_CANNOT_GET_PALLET             : Cannot get a pallet data from PNG image.}
        0x1006 {HPDF_CANNOT_GET_PALLET             : Cannot get a pallet data from PNG image.}
        0x1007 {HPDF_DICT_COUNT_ERR                : The count of elements of a dictionary exceeds HPDF_LIMIT_MAX_DICT_ELEMENT}
        0x1008 {HPDF_DICT_ITEM_NOT_FOUND           : Internal error. The consistency of the data was lost.}
        0x1009 {HPDF_DICT_ITEM_UNEXPECTED_TYPE     : Internal error. The consistency of the data was lost.}
        0x100A {HPDF_DICT_STREAM_LENGTH_NOT_FOUND  : Internal error. The consistency of the data was lost.}
        0x100B {HPDF_DOC_ENCRYPTDICT_NOT_FOUND     : HPDF_SetPermission() OR HPDF_SetEncryptMode() was called before a password is set.}
        0x100C {HPDF_DOC_INVALID_OBJECT            : Internal error. The consistency of the data was lost.}
        0x100D {HPDF_DOC_INVALID_OBJECT            : Internal error. The consistency of the data was lost.}
        0x100E {HPDF_DUPLICATE_REGISTRATION        : Tried to register a font that has been registered. }
        0x100F {HPDF_EXCEED_JWW_CODE_NUM_LIMIT     : Cannot register a character to the japanese word wrap characters list.}
        0x1010 {HPDF_EXCEED_JWW_CODE_NUM_LIMIT     : Cannot register a character to the japanese word wrap characters list.}
        0x1011 {HPDF_ENCRYPT_INVALID_PASSWORD      : Tried to set the owner password to NULL. The owner password and user password is the same.}
        0x1013 {HPDF_ERR_UNKNOWN_CLASS             : Internal error. The consistency of the data was lost.}
        0x1014 {HPDF_EXCEED_GSTATE_LIMIT           : The depth of the stack exceeded HPDF_LIMIT_MAX_GSTATE.}
        0x1015 {HPDF_FAILD_TO_ALLOC_MEM            : Memory allocation failed.}
        0x1016 {HPDF_FILE_IO_ERROR                 : File processing failed. (A detailed code is set.)}
        0x1017 {HPDF_FILE_OPEN_ERROR               : Cannot open a file. (A detailed code is set.)}
        0x1018 {HPDF_FILE_OPEN_ERROR               : Cannot open a file. (A detailed code is set.)}
        0x1019 {HPDF_FONT_EXISTS                   : Tried to load a font that has been registered.}
        0x101A {HPDF_FONT_INVALID_WIDTHS_TABLE     : The format of a font-file is invalid .Internal error. The consistency of the data was lost.}
        0x101B {HPDF_INVALID_AFM_HEADER            : Cannot recognize a header of an afm file.}
        0x101C {HPDF_INVALID_ANNOTATION            : The specified annotation handle is invalid. }
        0x101D {HPDF_INVALID_ANNOTATION            : The specified annotation handle is invalid.}
        0x101E {HPDF_INVALID_BIT_PER_COMPONENT     : Bit-per-component of a image which was set as mask-image is invalid.}
        0x101F {HPDF_INVALID_CHAR_MATRICS_DATA     : Cannot recognize char-matrics-data of an afm file.}
        0x1020 {HPDF_INVALID_COLOR_SPACE           : 1. The color_space parameter of HPDF_LoadRawImage is invalid.
                                                     2. Color-space of a image which was set as mask-image is invalid.
                                                     3. The function which is invalid in the present color-space was invoked.}
        0x1021 {HPDF_INVALID_COMPRESSION_MODE      : Invalid value was set when invoking HPDF_SetCommpressionMode().}
        0x1022 {HPDF_INVALID_DATE_TIME             : An invalid date-time value was set.}
        0x1023 {HPDF_INVALID_DESTINATION           : An invalid destination handle was set.}
        0x1024 {HPDF_INVALID_DESTINATION           : An invalid destination handle was set.}
        0x1025 {HPDF_INVALID_DOCUMENT              : An invalid document handle is set.}
        0x1026 {HPDF_INVALID_DOCUMENT_STATE        : The function which is invalid in the present state was invoked.}
        0x1027 {HPDF_INVALID_ENCODER               : An invalid encoder handle is set.}
        0x1028 {HPDF_INVALID_ENCODER_TYPE          : A combination between font and encoder is wrong.}
        0x1029 {HPDF_INVALID_ENCODER_TYPE          : A combination between font and encoder is wrong.}
        0x102A {HPDF_INVALID_ENCODER_TYPE          : A combination between font and encoder is wrong.}
        0x102B {HPDF_INVALID_ENCODING_NAME         : An Invalid encoding name is specified.}
        0x102C {HPDF_INVALID_ENCRYPT_KEY_LEN       : The lengh of the key of encryption is invalid.}
        0x102D {HPDF_INVALID_FONTDEF_DATA          : 1. An invalid font handle was set. 2. Unsupported font format.}
        0x102E {HPDF_INVALID_FONTDEF_TYPE          : Internal error. The consistency of the data was lost.}
        0x102F {HPDF_INVALID_FONT_NAME             : A font which has the specified name is not found.}
        0x1030 {HPDF_INVALID_IMAGE                 : Unsupported image format.}
        0x1031 {HPDF_INVALID_JPEG_DATA             : Unsupported image format.}
        0x1032 {HPDF_INVALID_N_DATA                : Cannot read a postscript-name from an afm file.}
        0x1033 {HPDF_INVALID_OBJECT                : 1. An invalid object is set. 2. Internal error. The consistency of the data was lost.}
        0x1034 {HPDF_INVALID_OBJ_ID                : Internal error. The consistency of the data was lost.}
        0x1035 {HPDF_INVALID_OPERATION             : 1. Invoked HPDF_Image_SetColorMask() against the image-object which was set a mask-image.}
        0x1036 {HPDF_INVALID_OUTLINE               : An invalid outline-handle was specified.}
        0x1037 {HPDF_INVALID_PAGE                  : An invalid page-handle was specified.}
        0x1038 {HPDF_INVALID_PAGES                 : An invalid pages-handle was specified. (internel error)}
        0x1039 {HPDF_INVALID_PARAMETER             : An invalid value is set.}
        0x103A {HPDF_INVALID_PARAMETER             : An invalid value is set.}
        0x103B {HPDF_INVALID_PNG_IMAGE             : Invalid PNG image format.}
        0x103C {HPDF_INVALID_STREAM                : Internal error. The consistency of the data was lost.}
        0x103D {HPDF_MISSING_FILE_NAME_ENTRY       : Internal error. The "_FILE_NAME" entry for delayed loading is missing.}
        0x103E {HPDF_MISSING_FILE_NAME_ENTRY       : Internal error. The "_FILE_NAME" entry for delayed loading is missing.}
        0x103F {HPDF_INVALID_TTC_FILE              : Invalid .TTC file format.}
        0x1040 {HPDF_INVALID_TTC_INDEX             : The index parameter was exceed the number of included fonts}
        0x1041 {HPDF_INVALID_WX_DATA               : Cannot read a width-data from an afm file.}
        0x1042 {HPDF_ITEM_NOT_FOUND                : Internal error. The consistency of the data was lost.}
        0x1043 {HPDF_LIBPNG_ERROR                  : An error has returned from PNGLIB while loading an image.}
        0x1044 {HPDF_NAME_INVALID_VALUE            : Internal error. The consistency of the data was lost.}
        0x1045 {HPDF_NAME_OUT_OF_RANGE             : Internal error. The consistency of the data was lost.}
        0x1046 {HPDF_NAME_OUT_OF_RANGE             : Internal error. The consistency of the data was lost.}
        0x1047 {HPDF_NAME_OUT_OF_RANGE             : Internal error. The consistency of the data was lost.}
        0x1048 {HPDF_NAME_OUT_OF_RANGE             : Internal error. The consistency of the data was lost.}
        0x1049 {HPDF_PAGES_MISSING_KIDS_ENTRY      : Internal error. The consistency of the data was lost.}
        0x104A {HPDF_PAGE_CANNOT_FIND_OBJECT       : Internal error. The consistency of the data was lost.}
        0x104B {HPDF_PAGE_CANNOT_GET_ROOT_PAGES    : Internal error. The consistency of the data was lost.}
        0x104C {HPDF_PAGE_CANNOT_RESTORE_GSTATE    : There are no graphics-states to be restored.}
        0x104D {HPDF_PAGE_CANNOT_SET_PARENT        : Internal error. The consistency of the data was lost.}
        0x104E {HPDF_PAGE_FONT_NOT_FOUND           : The current font is not set.}
        0x104F {HPDF_PAGE_INVALID_FONT             : An invalid font-handle was spacified.}
        0x1050 {HPDF_PAGE_INVALID_FONT_SIZE        : An invalid font-size was set.}
        0x1051 {HPDF_PAGE_INVALID_GMODE            : See Graphics mode.}
        0x1052 {HPDF_PAGE_INVALID_INDEX            : Internal error. The consistency of the data was lost.}
        0x1053 {HPDF_PAGE_INVALID_ROTATE_VALUE     : The specified value is not a multiple of . }
        0x1054 {HPDF_PAGE_INVALID_SIZE             : An invalid page-size was set.}
        0x1055 {HPDF_PAGE_INVALID_XOBJECT          : An invalid image-handle was set.}
        0x1056 {HPDF_PAGE_OUT_OF_RANGE             : The specified value is out of range.}
        0x1057 {HPDF_REAL_OUT_OF_RANGE             : The specified value is out of range.}
        0x1058 {HPDF_STREAM_EOF                    : Unexpected EOF marker was detected.}
        0x1059 {HPDF_STREAM_READLN_CONTINUE        : Internal error. The consistency of the data was lost.}
        0x105A {HPDF_STREAM_READLN_CONTINUE        : Internal error. The consistency of the data was lost.}
        0x105B {HPDF_STRING_OUT_OF_RANGE           : The length of the specified text is too long.}
        0x105C {HPDF_THIS_FUNC_WAS_SKIPPED         : The execution of a function was skipped because of other errors.}
        0x105D {HPDF_TTF_CANNOT_EMBEDDING_FONT     : This font cannot be embedded. (restricted by license)}
        0x105E {HPDF_TTF_INVALID_CMAP              : Unsupported ttf format. (cannot find unicode cmap.)}
        0x105F {HPDF_TTF_INVALID_FOMAT             : Unsupported ttf format.}
        0x1060 {HPDF_TTF_MISSING_TABLE             : Unsupported ttf format. (cannot find a necessary table)}
        0x1061 {HPDF_UNSUPPORTED_FONT_TYPE         : Internal error. The consistency of the data was lost.}
        0x1062 {HPDF_UNSUPPORTED_FUNC              : 1. The library is not configured to use PNGLIB. 2. Internal error. The consistency of the data was lost.}
        0x1063 {HPDF_UNSUPPORTED_JPEG_FORMAT       : Unsupported Jpeg format.}
        0x1064 {HPDF_UNSUPPORTED_TYPE1_FONT        : Failed to parse .PFB file.}
        0x1065 {HPDF_XREF_COUNT_ERR                : Internal error. The consistency of the data was lost.}
        0x1066 {HPDF_ZLIB_ERROR                    : An error has occurred while executing a function of Zlib.}
        0x1067 {HPDF_INVALID_PAGE_INDEX            : An error returned from Zlib.}
        0x1068 {HPDF_INVALID_URI                   : An invalid URI was set.}
        0x1069 {HPDF_PAGELAYOUT_OUT_OF_RANGE       : An invalid page-layout was set.}
        0x1070 {HPDF_PAGEMODE_OUT_OF_RANGE         : An invalid page-mode was set.}
        0x1071 {HPDF_PAGENUM_STYLE_OUT_OF_RANGE    : An invalid page-num-style was set.}
        0x1072 {HPDF_ANNOT_INVALID_ICON            : An invalid icon was set.}
        0x1073 {HPDF_ANNOT_INVALID_BORDER_STYLE    : An invalid border-style was set.}
        0x1074 {HPDF_PAGE_INVALID_DIRECTION        : An invalid page-direction was set.}
        0x1075 {HPDF_INVALID_FONT                  : An invalid font-handle was specified.}
    }

    return [dict create {*}$herror]

}
