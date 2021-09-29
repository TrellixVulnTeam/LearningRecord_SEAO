#include <iconv\iconv.h>
#include "StringUtils.h"

#pragma comment(lib, "libiconv")

namespace StringUtils {

    bool ConvertHelper(
        const char *fromStr,
        size_t fromStrBytes,
        const char *fromcode,
        char **toStr,
        size_t *toStrBytes,
        const char *tocode
    );

    template<class STRING, class CHAR_TYPE>
    STRING ConvertHelper2(
        const char *fromStr,
        size_t fromStrBytes,
        const char *fromcode,
        const char *tocode
    );

    std::wstring GBKToUtf16(const std::string &str) {
        const char *fromStr = str.c_str();
        size_t fromStrBytes = strlen(fromStr);
        return ConvertHelper2<std::wstring, wchar_t>(fromStr, fromStrBytes, "GBK", "UTF-16LE");

        /*const char *fromStr = str.c_str();
        size_t fromStrBytes = strlen(fromStr);
        char *toStr = NULL;
        size_t toStrBytes = 0;
        std::wstring convertStr;

        ConvertHelper(fromStr, fromStrBytes, "GBK", &toStr, &toStrBytes, "UTF-16LE");

        if (toStr)
        {
            convertStr = std::wstring((wchar_t *)toStr);
            delete toStr;
        }

        return convertStr;*/
    }

    std::string Utf16ToGBK(const std::wstring &str) {
        const wchar_t *fromStr = str.c_str();
        size_t fromStrBytes = wcslen(fromStr) * sizeof(wchar_t);

        return ConvertHelper2<std::string, char>((const char*)fromStr, fromStrBytes, "UTF-16LE", "GBK");

        /*const wchar_t *fromStr = str.c_str();
        size_t fromStrBytes = wcslen(fromStr) * sizeof(wchar_t);
        char *toStr = NULL;
        size_t toStrBytes = 0;
        std::string convertStr;

        ConvertHelper((const char*)fromStr, fromStrBytes, "UTF-16LE", &toStr, &toStrBytes, "GBK");

        if (toStr)
        {
            convertStr = std::string(toStr);
            delete toStr;
        }

        return convertStr;*/
    }

    std::string GBKToUtf8(const std::string &str) {
        const char *fromStr = str.c_str();
        size_t fromStrBytes = strlen(fromStr);

        return ConvertHelper2<std::string, char>(fromStr, fromStrBytes, "GBK", "UTF-8");

        /*const char *fromStr = str.c_str();
        size_t fromStrBytes = strlen(fromStr);
        char *toStr = NULL;
        size_t toStrBytes = 0;
        std::string convertStr;

        ConvertHelper(fromStr, fromStrBytes, "GBK", &toStr, &toStrBytes, "UTF-8");

        if (toStr)
        {
            convertStr = std::string(toStr);
            delete [] toStr;
        }

        return convertStr;*/
    }

    std::string Utf8ToGBK(const std::string &str) {
        const char *fromStr = str.c_str();
        size_t fromStrBytes = strlen(fromStr);

        return ConvertHelper2<std::string, char>(fromStr, fromStrBytes, "UTF-8", "GBK");

        /*const char *fromStr = str.c_str();
        size_t fromStrBytes = strlen(fromStr);
        char *toStr = NULL;
        size_t toStrBytes = 0;
        std::string convertStr;

        ConvertHelper(fromStr, fromStrBytes, "UTF-8", &toStr, &toStrBytes, "GBK");

        if (toStr)
        {
            convertStr = std::string(toStr);
            delete toStr;
        }

        return convertStr;*/
    }

    std::string Utf16ToUtf8(const std::wstring &str) {
        const wchar_t *fromStr = str.c_str();
        size_t fromStrBytes = wcslen(fromStr) * sizeof(wchar_t);

        return ConvertHelper2<std::string, char>((const char*)fromStr, fromStrBytes, "UTF-16LE", "UTF-8");

        /*const wchar_t *fromStr = str.c_str();
        size_t fromStrBytes = wcslen(fromStr) * sizeof(wchar_t);
        char *toStr = NULL;
        size_t toStrBytes = 0;
        std::string convertStr;

        ConvertHelper((const char*)fromStr, fromStrBytes, "UTF-16LE", &toStr, &toStrBytes, "UTF-8");

        if (toStr)
        {
            convertStr = std::string(toStr);
            delete toStr;
        }

        return convertStr;*/
    }

    std::wstring Utf8ToUtf16(const std::string &str) {
        const char *fromStr = str.c_str();
        size_t fromStrBytes = strlen(fromStr);

        return ConvertHelper2<std::wstring, wchar_t>(fromStr, fromStrBytes, "UTF-8", "UTF-16LE");

        /*const char *fromStr = str.c_str();
        size_t fromStrBytes = strlen(fromStr);
        char *toStr = NULL;
        size_t toStrBytes = 0;
        std::wstring convertStr;

        ConvertHelper(fromStr, fromStrBytes, "UTF-8", &toStr, &toStrBytes, "UTF-16LE");

        if (toStr)
        {
            convertStr = std::wstring((wchar_t *)toStr);
            delete toStr;
        }

        return convertStr;*/
    }

    bool ConvertHelper(const char *fromStr,
        size_t fromStrBytes,
        const char *fromcode,
        char **toStr,
        size_t *toStrBytes,
        const char *tocode) {
        iconv_t cd = (iconv_t)-1;
        const char *fromStrTmp = fromStr;
        char *toStrTmp = NULL;
        size_t toStrBytesleft = 4096 * 4 - 1;
        size_t ret = 0;

        *toStr = NULL;
        *toStrBytes = toStrBytesleft;

        do {
            cd = iconv_open(tocode, fromcode);
            if ((iconv_t)-1 == cd) {
                break;
            }

            // 多申请1个字节，防止转换溢出
            *toStr = new char[toStrBytesleft + 2]();
            if (!(*toStr)) {
                break;
            }

            toStrTmp = *toStr;
            ret = iconv(cd, (const char**)(&fromStrTmp), &fromStrBytes, &toStrTmp, &toStrBytesleft);
            if ((size_t)-1 != ret) {
                iconv(cd, NULL, NULL, &toStrTmp, &toStrBytesleft);
            }

            *toStrTmp = '\0';
            *toStrBytes -= toStrBytesleft;

        } while (false);

        if ((iconv_t)-1 != cd) {
            iconv_close(cd);
        }

        return 0 == ret;
    }

    template<class STRING, class CHAR_TYPE>
    STRING ConvertHelper2(
        const char *fromStr,
        size_t fromStrBytes,
        const char *fromcode,
        const char *tocode
    ) {
        iconv_t cd = (iconv_t)-1;
        STRING str;
        char *lpBuffer = NULL;

        do {
            cd = iconv_open(tocode, fromcode);
            if ((iconv_t)-1 == cd) {
                break;
            }

            // 预留2个字节
            // why? 给L'\0'用
            size_t bufferSize = 4096 - 2;
            lpBuffer = new char[bufferSize + 2]();
            if (NULL == lpBuffer) {
                break;
            }

            size_t toStrBytesleft = bufferSize;
            const char *fromStrTmp = fromStr;
            char *toStrTmp = lpBuffer;
            char *toStr = lpBuffer;
            errno_t err = 0;

            size_t ret = iconv(cd, (const char**)(&fromStrTmp), &fromStrBytes, &toStrTmp, &toStrBytesleft);
            _get_errno(&err);

            *toStrTmp = '\0';
            str.assign((CHAR_TYPE*)(toStr));

            while ((size_t)-1 == ret && E2BIG == err) {
                memset(lpBuffer, 0, bufferSize);
                toStrTmp = lpBuffer;
                toStr = lpBuffer;
                toStrBytesleft = bufferSize;

                ret = iconv(cd, (const char**)(&fromStrTmp), &fromStrBytes, &toStrTmp, &toStrBytesleft);
                _get_errno(&err);

                *toStrTmp = '\0';
                str.append((CHAR_TYPE*)(toStr));
            }

            iconv(cd, NULL, NULL, &toStrTmp, &toStrBytesleft);

        } while (false);

        if ((iconv_t)-1 != cd) {
            iconv_close(cd);
        }

        if (NULL != lpBuffer) {
            delete[] lpBuffer;
        }

        return str;
    }
	template<typename STRING>
	std::list<STRING> SplitLines(
		const STRING &str,
		const STRING &spliter
	) {
		std::list<STRING> result;

		STRING::size_type begin = 0;
		STRING::size_type end = 0;
		while ((end = str.find(spliter, begin)) != STRING::npos) {
			result.push_back(str.substr(begin, end - begin));
			begin = end + spliter.size();
		}

		if (begin < str.size()) {
			result.push_back(str.substr(begin));
		}

		return result;
	}


	template<typename STRING>
	std::vector<STRING> SplitLinesV(
		const STRING &str,
		const STRING &spliter
	) {
		std::vector<STRING> result;

		STRING::size_type begin = 0;
		STRING::size_type end = 0;
		while ((end = str.find(spliter, begin)) != STRING::npos) {
			result.push_back(str.substr(begin, end - begin));
			begin = end + spliter.size();
		}

		if (begin < str.size()) {
			result.push_back(str.substr(begin));
		}

		return result;
	}

	template<typename STRING>
	STRING ReplaceString(
		STRING &str,
		const STRING &target,
		const STRING &dst
	) {
		STRING::size_type pos = STRING::npos;
		while ((pos = str.find(target)) != STRING::npos) {
            str.replace(pos, target.size(), dst);
		}

		return str;
	}

	std::list<std::wstring> SplitLines(
		const std::wstring &str,
		const std::wstring &spliter
	) {
		return SplitLines<std::wstring>(str, spliter);
	}

	std::list<std::string> SplitLines(
		const std::string &str,
		const std::string &spliter
	) {
		return SplitLines<std::string>(str, spliter);
	}

	STRINGUTILS_API std::vector<std::wstring> SplitLinesV(
		const std::wstring &str,
		const std::wstring &spliter
	)
	{
		return SplitLinesV<std::wstring>(str, spliter);
	}

	STRINGUTILS_API std::vector<std::string> SplitLinesV(
		const std::string &str,
		const std::string &spliter
	)
	{
		return SplitLinesV<std::string>(str, spliter);
	}

    std::wstring ReplaceString(
        std::wstring &str,
        const std::wstring &target,
        const std::wstring &dst
    ) {
        return ReplaceString<std::wstring>(str, target, dst);
    }

    std::string ReplaceString(
        std::string &str,
        const std::string &target,
        const std::string &dst
    ) {
        return ReplaceString<std::string>(str, target, dst);
    }

    std::string HexArrayToHexString(
        const char *hexArray,
        int hexArraySize,
        bool isUpper
    ) {
        std::string strHexString;

        int bufSize = hexArraySize * 2 + 1;
        char *buf = new char[bufSize]();
        if (buf) {
            if (isUpper) {
                for (int i = 0; i < hexArraySize; ++i) {
                    sprintf_s(buf, bufSize, "%s%.2X", buf, (unsigned char)hexArray[i]);
                }
            } else {
                for (int i = 0; i < hexArraySize; ++i) {
                    sprintf_s(buf, bufSize, "%s%.2x", buf, (unsigned char)hexArray[i]);
                }
            }

            strHexString = buf;
            delete[] buf;
        }

        return strHexString;
    }

    void HexStringToHexArray(
        const std::string &strHexString,
        char hexArray[],
        int hexArraySize
    ) {
        do {
            memset(hexArray, 0, hexArraySize);

            size_t hexStringSize = strHexString.size();
            if (hexStringSize % 2 != 0) {
                break;
            }

            if (hexArraySize != hexStringSize / 2) {
                break;
            }

            const char *p = strHexString.c_str();
            for (int i = 0; i < hexArraySize; ++i) {
                sscanf_s(p + i * 2, "%02hhx", &hexArray[i]);
            }

        } while (false);
    }
}