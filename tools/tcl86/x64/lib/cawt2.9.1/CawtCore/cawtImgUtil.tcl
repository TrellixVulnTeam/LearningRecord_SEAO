# Copyright: 2007-2022 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Cawt {

    namespace ensemble create

    namespace export ClipboardToImg
    namespace export ImgToClipboard
    namespace export SetClipboardWaitTime
    namespace export WaitClipboardReady

    # sizeof(BITMAPFILEHEADER)
    variable sBmpHeaderSize 14

    variable sWaitTime 200

    proc ClipboardToImg {} {
        # Copy the clipboard content into a photo image.
        #
        # The photo image identifier is returned, if the clipboard
        # content could be read correctly. Otherwise an error is thrown.
        #
        # **Note:**
        # The image data in the clipboard must be in `BMP` format.
        # Therefore it needs the `Img` extension.
        # The image must be freed by the caller with `image delete`,
        # if not needed anymore.
        #
        # Returns the photo image identifier.
        #
        # See also: ImgToClipboard

        variable sBmpHeaderSize

        set retVal [catch { package require Img } version]
        if { $retVal != 0 } {
            error "ClipboardToImg: Package Img not available."
        }

        twapi::open_clipboard

        # Assume clipboard content is in format 8 (CF_DIB)
        set retVal [catch { twapi::read_clipboard 8 } clipData]
        if { $retVal != 0 } {
            error "ClipboardToImg: Invalid or no content in clipboard"
        }

        # First parse the bitmap data to collect header information
        binary scan $clipData "iiissiiiiii" \
               size width height planes bitcount compression sizeimage \
               xpelspermeter ypelspermeter clrused clrimportant

        # We only handle BITMAPINFOHEADER right now (size must be 40)
        if { $size != 40 } {
            error "ClipboardToImg: Unsupported bitmap format. Header size=$size"
        }

        # We need to figure out the offset to the actual bitmap data
        # from the start of the file header. For this we need to know the
        # size of the color table which directly follows the BITMAPINFOHEADER
        if { $bitcount == 0 } {
            error "ClipboardToImg: Unsupported format: implicit JPEG or PNG"
        } elseif { $bitcount == 1 } {
            set color_table_size 2
        } elseif { $bitcount == 4 } {
            # TBD - Not sure if this is the size or the max size
            set color_table_size 16
        } elseif { $bitcount == 8 } {
            # TBD - Not sure if this is the size or the max size
            set color_table_size 256
        } elseif { $bitcount == 16 || $bitcount == 32 } {
            if { $compression == 0 } {
                # BI_RGB
                set color_table_size $clrused
            } elseif { $compression == 3 } {
                # BI_BITFIELDS
                set color_table_size 3
            } else {
                error "ClipboardToImg: Unsupported compression type '$compression' for bitcount value $bitcount"
            }
        } elseif { $bitcount == 24 } {
            set color_table_size $clrused
        } else {
            error "ClipboardToImg: Unsupported value '$bitcount' in bitmap bitcount field"
        }

        set phImg [image create photo]
        set bitmap_file_offset [expr {$sBmpHeaderSize + $size + ($color_table_size * 4)}]
        set filehdr [binary format "a2 i x2 x2 i" \
                     "BM" [expr {$sBmpHeaderSize + [string length $clipData]}] \
                     $bitmap_file_offset]

        append filehdr $clipData
        $phImg put $filehdr -format bmp

        twapi::close_clipboard
        return $phImg
    }

    proc ImgToClipboard { phImg } {
        # Copy a photo image into the clipboard.
        #
        # phImg - The photo image identifier.
        #
        # If the image could not be copied to the clipboard correctly,
        # an error is thrown.
        #
        # **Note:**
        # The image data is copied to the clipboard in `BMP` format.
        # Therefore it needs the `Img` and `base64` extensions.
        #
        # Returns no value.
        #
        # See also: ClipboardToImg

        variable sBmpHeaderSize

        set retVal [catch {package require Img} version]
        if { $retVal != 0 } {
            error "ImgToClipboard: Package Img not available."
        }
        set retVal [catch {package require base64} version]
        if { $retVal != 0 } {
            error "ImgToClipboard: Package Base64 not available."
        }

        # First 14 bytes are bitmapfileheader.
        set data [string range [base64::decode [$phImg data -format bmp]] $sBmpHeaderSize end]
        twapi::open_clipboard
        twapi::empty_clipboard
        twapi::write_clipboard 8 $data
        twapi::close_clipboard
        Cawt::WaitClipboardReady
    }

    proc SetClipboardWaitTime { waitTime } {
        # Set the time to wait until clipboard content is ready.
        #
        # waitTime - Wait time in milliseconds.
        #
        # Returns no value.
        #
        # See also: WaitClipboardReady

        variable sWaitTime

        set sWaitTime [expr int($waitTime)]
    }

    proc WaitClipboardReady {} {
        # Wait until clipboard content is ready.
        #
        # **Note:**
        # Currently this is simply implemented by waiting a specified amount
        # of milliseconds, which can be specified by [SetClipboardWaitTime].
        # Default value is 200 milliseconds.
        #
        # Returns no value.
        #
        # See also: SetClipboardWaitTime

        variable sWaitTime

        after $sWaitTime
    }
}
