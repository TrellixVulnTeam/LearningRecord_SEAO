// ImageUtils.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
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