#include "StringUtils.h"

#ifndef USE_ICONV
    /* 
        see https://docs.microsoft.com/en-us/windows/win32/intl/international-components-for-unicode--icu- 
        and https://en.wikipedia.org/wiki/Windows_10 Windows 10 Version 1903 is NTDDI_WIN10_19H1
    */
    #if (NTDDI_VERSION < NTDDI_WIN10_19H1) 
        #define USE_ICONV
    #endif
#endif


#include <iconv\iconv.h>
#pragma comment(lib, "libiconv")

#ifndef USE_ICONV
    #include <icu.h>
    #pragma comment(lib, "icu")
#endif

namespace StringUtils {

    template<class STRING>
    STRING iconv_convert_helper(
        const char *fromcode,
        const char *tocode,
        const char *fromStr,
        size_t fromStrBytes
    ) {
        iconv_t cd = (iconv_t)-1;
        STRING str;
        char *lpBuffer = NULL;

        do {
            cd = iconv_open(tocode, fromcode);
            if ((iconv_t)-1 == cd) {
                break;
            }

            size_t bufferSize = 4096 - 2 /* resvered for L'\0' */;
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
            str.assign((STRING::value_type*)(toStr));

            while ((size_t)-1 == ret && E2BIG == err) {
                memset(lpBuffer, 0, bufferSize);
                toStrTmp = lpBuffer;
                toStr = lpBuffer;
                toStrBytesleft = bufferSize;

                ret = iconv(cd, (const char**)(&fromStrTmp), &fromStrBytes, &toStrTmp, &toStrBytesleft);
                _get_errno(&err);

                *toStrTmp = '\0';
                str.append((STRING::value_type*)(toStr));
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

    std::wstring iconv_utf8_to_utf16(
        const std::string &strUtf8
    ) {
        return iconv_convert_helper<std::wstring>("UTF-8", "UTF-16LE", strUtf8.c_str(), strUtf8.size());
    }

    std::string iconv_utf16_to_utf8(
        const std::wstring &wstrUtf16
    ) {
        return iconv_convert_helper<std::string>
            ("UTF-16LE", "UTF-8", (const char*)wstrUtf16.c_str(), wstrUtf16.size() * sizeof(std::wstring::size_type));
    }

    std::wstring iconv_gbk_to_utf16(
        const std::string &strGbk
    ) {
        return iconv_convert_helper<std::wstring>("GBK", "UTF-16LE", strGbk.c_str(), strGbk.size());
    }

    std::string iconv_utf16_to_gbk(
        const std::wstring &wstrUtf16
    ) {
        return iconv_convert_helper<std::string>
            ("UTF-16LE", "GBK", (const char*)wstrUtf16.c_str(), wstrUtf16.size() * sizeof(std::wstring::size_type));
    }

    std::string iconv_utf8_to_gbk(
        const std::string &strUtf8
    ) {
        return iconv_convert_helper<std::string>("UTF-8", "GBK", strUtf8.c_str(), strUtf8.size());
    }

    std::string iconv_gbk_to_utf8(
        const std::string &strGbk
    ) {
        return iconv_convert_helper<std::string>("GBK", "UTF-8", strGbk.c_str(), strGbk.size());
    }

    bool icu_detect_encoding(
        const char *data,
        int32_t len,
        char **detected
    ) {
        UCharsetDetector* csd;
        const UCharsetMatch** csm;
        int32_t match, matchCount = 0;

        UErrorCode status = U_ZERO_ERROR;

        csd = ucsdet_open(&status);
        if (status != U_ZERO_ERROR)
            return false;

        ucsdet_setText(csd, data, len, &status);
        if (status != U_ZERO_ERROR)
            return false;

        csm = ucsdet_detectAll(csd, &matchCount, &status);
        if (status != U_ZERO_ERROR)
            return false;

#if 0
        for (match = 0; match < matchCount; match += 1) {
            const char* name = ucsdet_getName(csm[match], &status);
            const char* lang = ucsdet_getLanguage(csm[match], &status);
            int32_t confidence = ucsdet_getConfidence(csm[match], &status);

            if (lang == NULL || strlen(lang) == 0)
                lang = "**";

            printf("%s (%s) %d\n", name, lang, confidence);
        }
#endif

        if (matchCount > 0) {
            *detected = _strdup(ucsdet_getName(csm[0], &status));
            if (status != U_ZERO_ERROR)
                return false;
        }

        //printf("charset = %s\n", *detected);

        ucsdet_close(csd);
        return true;
    }

    template <typename STRING>
    STRING icu_convert_helper(
        const char *fromConverterName,
        const char *toConverterName,
        const char *src,
        int32_t srcLen
    ) {
        STRING target;

        char *detected = nullptr;

        do {
            if (!toConverterName || !src || srcLen <= 0) {
                break;
            }

            if (!fromConverterName) {
                if (!icu_detect_encoding(src, srcLen, &detected)) {
                    break;
                }

                fromConverterName = detected;
            }

            UErrorCode error = U_ZERO_ERROR;
            int32_t targetLen = ucnv_convert(toConverterName, fromConverterName, nullptr, 0, src, srcLen, &error);
            if (targetLen <= 0 || error != U_BUFFER_OVERFLOW_ERROR) {
                break;
            }

            targetLen = (targetLen + 1) * 2;
            char* buf = new char[targetLen];
            if (!buf) {
                break;
            }

            memset(buf, 0, targetLen);
            error = U_ZERO_ERROR;
            ucnv_convert(toConverterName, fromConverterName, buf, targetLen, src, srcLen, &error);

            target.assign((STRING::value_type*)buf);

            delete[] buf;

        } while (false);

        if (detected) {
            delete[] detected;
        }

        return target;
    }

    std::wstring icu_utf8_to_utf16(
        const std::string &strUtf8
    ) {
        return icu_convert_helper<std::wstring>("UTF-8", "UTF-16LE", strUtf8.c_str(), strUtf8.size());
    }

    std::string icu_utf16_to_utf8(
        const std::wstring &wstrUtf16
    ) {
        return icu_convert_helper<std::string>
            ("UTF-16LE", "UTF-8", (const char*)wstrUtf16.c_str(), wstrUtf16.size() * sizeof(std::wstring::size_type));
    }

    std::wstring icu_gbk_to_utf16(
        const std::string &strGbk
    ) {
        return icu_convert_helper<std::wstring>("GB18030", "UTF-16LE", strGbk.c_str(), strGbk.size());
    }

    std::string icu_utf16_to_gbk(
        const std::wstring &wstrUtf16
    ) {
        return icu_convert_helper<std::string>
            ("UTF-16LE", "GB18030", (const char*)wstrUtf16.c_str(), wstrUtf16.size() * sizeof(std::wstring::size_type));
    }

    std::string icu_utf8_to_gbk(
        const std::string &strUtf8
    ) {
        return icu_convert_helper<std::string>("UTF-8", "GB18030", strUtf8.c_str(), strUtf8.size());
    }

    std::string icu_gbk_to_utf8(
        const std::string &strGbk
    ) {
        return icu_convert_helper<std::string>("GB18030", "UTF-8", strGbk.c_str(), strGbk.size());
    }

    std::wstring GBKToUtf16(const std::string& str) {
#ifdef USE_ICONV
        return iconv_gbk_to_utf16(str);
#else
        return icu_gbk_to_utf16(str);
#endif
    }

    std::string Utf16ToGBK(const std::wstring& str) {
#ifdef USE_ICONV
        return iconv_utf16_to_gbk(str);
#else
        return icu_utf16_to_gbk(str);
#endif        
    }

    std::string GBKToUtf8(const std::string& str) {
#ifdef USE_ICONV
        return iconv_gbk_to_utf8(str);
#else
        return icu_gbk_to_utf8(str);
#endif  
    }

    std::string Utf8ToGBK(const std::string& str) {
#ifdef USE_ICONV
        return iconv_utf8_to_gbk(str);
#else
        return icu_utf8_to_gbk(str);
#endif
    }

    std::string Utf16ToUtf8(const std::wstring& str) {
#ifdef USE_ICONV
        return iconv_utf16_to_utf8(str);
#else
        return icu_utf16_to_utf8(str);
#endif
    }

    std::wstring Utf8ToUtf16(const std::string& str) {
#ifdef USE_ICONV
        return iconv_utf8_to_utf16(str);
#else
        return icu_utf8_to_utf16(str);
#endif
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
        STRING::size_type off = 0;
		while ((pos = str.find(target, off)) != STRING::npos) {
            str.replace(pos, target.size(), dst);
            off = pos + dst.size();
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

	std::vector<std::wstring> SplitLinesV(
		const std::wstring &str,
		const std::wstring &spliter
	)
	{
		return SplitLinesV<std::wstring>(str, spliter);
	}

	std::vector<std::string> SplitLinesV(
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