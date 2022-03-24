#pragma once

#ifdef IMAGEUTILS_EXPORTS
    #define IMAGEUTILS_API __declspec(dllexport)
#else
    #define IMAGEUTILS_API __declspec(dllimport)
#endif

#include <string>

namespace ImageUtils {

    /*
    图片文件格式转换

    @params     wstrSrcFilePath 源文件路径
                wstrDstFilePath 目标文件路径
                根据目标文件后缀名决定目标文件图片格式

    @return     bool 成功或失败
    */
    IMAGEUTILS_API bool ConvertFile(
        const std::wstring &wstrSrcFilePath,
        const std::wstring &wstrDstFilePath
    );

}