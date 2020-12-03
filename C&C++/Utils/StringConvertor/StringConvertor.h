#ifndef STRING_CONVERTOR_H
#define STRING_CONVERTOR_H

#include <string>

/**
* All Utf16 in this project is default utf16 little endian.
*/

std::wstring GBKToUtf16(const std::string &str);

std::string Utf16ToGBK(const std::wstring &str);

std::string GBKToUtf8(const std::string &str);

std::string Utf8ToGBK(const std::string &str);

std::string Utf16ToUtf8(const std::wstring &str);

std::wstring Utf8ToUtf16(const std::string &str);

#endif // STRING_CONVERTOR_H