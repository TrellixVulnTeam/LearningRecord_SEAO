#define WIN32_LEAN_AND_MEAN             // 从 Windows 头中排除极少使用的资料
#include <windows.h>

#define STATIC_MAGICK
#include <Magick++/Magick++.h>

#include <StringUtils/StringUtils.h>
#pragma comment(lib, "StringUtils")

#include "ImageUtils.h"

namespace ImageUtils {

    bool ConvertFile(
        const std::wstring &wstrSrcFilePath,
        const std::wstring &wstrDstFilePath
    ) {
        using namespace Magick;

        bool isSuccess = false;
        std::string strErr;

        //InitializeMagick("");

        // Construct the image object. Seperating image construction from the 
        // the read operation ensures that a failure to read the image file 
        // doesn't render the image object useless. 
        Image image;
        try {
            // Read a file into image object 
            image.read(StringUtils::Utf16ToUtf8(wstrSrcFilePath));

            // Crop the image to specified size (width, height, xOffset, yOffset)
            //image.crop(Geometry(100, 100, 100, 100));

            // Write the image to a file 
            DeleteFileW(wstrDstFilePath.c_str());

            image.write(StringUtils::Utf16ToUtf8(wstrDstFilePath));

            isSuccess = true;
        }
        catch (Exception &error_) {
            strErr = error_.what();
        }

        return isSuccess;
    }

}