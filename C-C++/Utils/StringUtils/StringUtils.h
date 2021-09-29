#pragma once

#ifdef STRINGUTILS_EXPORTS
    #define STRINGUTILS_API __declspec(dllexport)
#else
    #define STRINGUTILS_API __declspec(dllimport)
#endif

#include <string>
#include <list>
#include <vector>

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
    STRINGUTILS_API std::list<std::wstring> SplitLines(
        const std::wstring &str,
        const std::wstring &spliter
    );

    STRINGUTILS_API std::list<std::string> SplitLines(
        const std::string &str,
        const std::string &spliter
	);

	STRINGUTILS_API std::vector<std::wstring> SplitLinesV(
		const std::wstring &str,
		const std::wstring &spliter
	);

	STRINGUTILS_API std::vector<std::string> SplitLinesV(
		const std::string &str,
		const std::string &spliter
	);

    STRINGUTILS_API std::wstring ReplaceString(
        std::wstring &str,
        const std::wstring &target,
        const std::wstring &dst
    );

    STRINGUTILS_API std::string ReplaceString(
        std::string &str,
        const std::string &target,
        const std::string &dst
    );

    // {0x51, 0x7B} -> "517B"
    STRINGUTILS_API std::string HexArrayToHexString(
        const char *hexArray,
        int hexArraySize,
        bool isUpper = true
    );

    // "517B" -> {0x51, 0x7B}
    STRINGUTILS_API void HexStringToHexArray(
        const std::string &strHexString,
        char hexArray[],
        int hexArraySize
    );
}
