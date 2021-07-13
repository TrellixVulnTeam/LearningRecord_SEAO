#pragma once

#ifdef STRINGUTILS_EXPORTS
    #define STRINGUTILS_API __declspec(dllexport)
#else
    #define STRINGUTILS_API __declspec(dllimport)
#endif

#include <string>

/**
* All Utf16 in this project is default utf16 little endian.
*/

namespace StringUtils {

    STRINGUTILS_API std::wstring GBKToUtf16(const std::string &str);

    STRINGUTILS_API std::string Utf16ToGBK(const std::wstring &str);

    STRINGUTILS_API std::string GBKToUtf8(const std::string &str);

    STRINGUTILS_API std::string Utf8ToGBK(const std::string &str);

    STRINGUTILS_API std::string Utf16ToUtf8(const std::wstring &str);

    STRINGUTILS_API std::wstring Utf8ToUtf16(const std::string &str);
}
