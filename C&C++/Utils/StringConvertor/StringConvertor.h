#ifndef STRING_CONVERTOR_H
#define STRING_CONVERTOR_H

#ifdef STRINGCONVERTOR_EXPORTS
#define STRINGCONVERTOR_API __declspec(dllexport)
#else
#define STRINGCONVERTOR_API __declspec(dllimport)
#endif

#include <string>

/**
* All Utf16 in this project is default utf16 little endian.
*/

STRINGCONVERTOR_API std::wstring GBKToUtf16(const std::string &str);

STRINGCONVERTOR_API std::string Utf16ToGBK(const std::wstring &str);

STRINGCONVERTOR_API std::string GBKToUtf8(const std::string &str);

STRINGCONVERTOR_API std::string Utf8ToGBK(const std::string &str);

STRINGCONVERTOR_API std::string Utf16ToUtf8(const std::wstring &str);

STRINGCONVERTOR_API std::wstring Utf8ToUtf16(const std::string &str);

#endif // STRING_CONVERTOR_H