#ifndef IMAGECONVERTER_H
#define IMAGECONVERTER_H

#ifdef IMAGECONVERTER_EXPORTS
    #define IMAGECONVERTER_API extern "C" __declspec(dllexport)
#else
    #define IMAGECONVERTER_API extern "C" __declspec(dllimport)
#endif // IMAGECONVERTER_EXPORTS

#include <string>

IMAGECONVERTER_API void ConvertImage(const std::wstring &srcFile, const std::wstring &dstFile);

#endif // IMAGECONVERTER_H