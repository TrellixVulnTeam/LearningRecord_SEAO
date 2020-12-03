#include "ImageConverter.h"
#include "..\StringConvertor\StringConvertor.h"

#define STATIC_MAGICK
//#define MAGICKCORE_BUILD_MODULES
#include <iostream>
#include <Magick++/Magick++.h>

#pragma comment(lib, "StringConvertor")

#ifdef _DEBUG
#pragma comment(lib, "CORE_DB_Magick++_")
#pragma comment(lib, "CORE_DB_MagickWand_")
#pragma comment(lib, "CORE_DB_MagickCore_")
#pragma comment(lib, "CORE_DB_croco_")
#else
#pragma comment(lib, "CORE_RL_Magick++_")
#pragma comment(lib, "CORE_RL_MagickWand_")
#pragma comment(lib, "CORE_RL_MagickCore_")
#pragma comment(lib, "CORE_RL_croco_")
#endif // _DEBUG

void ConvertImage(const std::wstring &srcFile, const std::wstring &dstFile)
{
    // Construct the image object. Seperating image construction from the 
    // the read operation ensures that a failure to read the image file 
    // doesn't render the image object useless. 
    Magick::Image image;
    std::string srcFile2 = Utf16ToUtf8(srcFile);
    std::string dstFile2 = Utf16ToUtf8(dstFile);

    try
    {
        // Read a file into image object 
        image.read(srcFile2);

        // Write the image to a file 
        image.write(dstFile2);
    }
    catch (Magick::Exception &error_)
    {
       
    }

    return;
}