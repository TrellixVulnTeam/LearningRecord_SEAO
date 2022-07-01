#include "pch.h"
#include "StringUtils.h"

#ifndef USE_ICONV
    /* 
        see https://docs.microsoft.com/en-us/windows/win32/intl/international-components-for-unicode--icu- 
        and https://en.wikipedia.org/wiki/Windows_10
		Windows 10 Version 1903 is NTDDI_WIN10_19H1
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

#include <openssl/md5.h>
#include <openssl/sha.h>
#pragma comment(lib, "libcrypto")

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
            str.assign((typename STRING::value_type*)(toStr));

            while ((size_t)-1 == ret && E2BIG == err) {
                memset(lpBuffer, 0, bufferSize);
                toStrTmp = lpBuffer;
                toStr = lpBuffer;
                toStrBytesleft = bufferSize;

                ret = iconv(cd, (const char**)(&fromStrTmp), &fromStrBytes, &toStrTmp, &toStrBytesleft);
                _get_errno(&err);

                *toStrTmp = '\0';
                str.append((typename STRING::value_type*)(toStr));
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

            target.assign((typename STRING::value_type*)buf);

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

        typename STRING::size_type begin = 0;
        typename STRING::size_type end = 0;
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

        typename STRING::size_type begin = 0;
        typename STRING::size_type end = 0;
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
        typename STRING::size_type pos = STRING::npos;
        typename STRING::size_type off = 0;
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
            const char *format = isUpper ? "%s%.2X" : "%s%.2x";

            for (int i = 0; i < hexArraySize; ++i) {
                sprintf_s(buf, bufSize, format, buf, (unsigned char)hexArray[i]);
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

            int hexStringSize = strHexString.size();
            if (hexStringSize % 2 != 0) {
                break;
            }

            if (hexArraySize < hexStringSize / 2) {
                break;
            }

            const char *p = strHexString.c_str();
            for (int i = 0; i < hexStringSize / 2; ++i) {
                sscanf_s(p + i * 2, "%02hhx", &hexArray[i]);
            }

        } while (false);
    }

    std::wstring HexArrayToHexString(
        const wchar_t *hexArray,
        int hexArraySize,
        bool isUpper
    ) {
        std::wstring wstrHexString;

        int bufSize = hexArraySize * 4 + 1;
        wchar_t *buf = new wchar_t[bufSize]();
        if (buf) {
            const wchar_t *format = isUpper ? L"%s%.2X" : L"%s%.2x";

            for (int i = 0; i < hexArraySize; ++i) {
                swprintf_s(buf, bufSize, format, buf, hexArray[i]);

                // 高位字节为0的情况
                if (hexArray[i] >> 8 == 0) {
                    int len = wcslen(buf);
                    buf[len] = buf[len - 2];
                    buf[len + 1] = buf[len - 1];
                    buf[len + 2] = L'\0';
                    buf[len - 2] = L'0';
                    buf[len - 1] = L'0';
                }
            }

            wstrHexString = buf;
            delete[] buf;
        }

        return wstrHexString;
    }

    // "517B" -> {0x51, 0x7B}
    void HexStringToHexArray(
        const std::wstring &wstrHexString,
        wchar_t hexArray[],
        int hexArraySize
    ) {
        do {
            memset(hexArray, 0, hexArraySize);

            int hexStringSize = wstrHexString.size();
            if (hexStringSize % 4 != 0) {
                break;
            }

            if (hexArraySize < hexStringSize / 4) {
                break;
            }

            const wchar_t *p = wstrHexString.c_str();
            for (int i = 0; i < hexStringSize / 4; ++i) {
                swscanf_s(p + i * 4, L"%04hx", &hexArray[i]);
            }

        } while (false);
    }

    std::string GetMD5String(
        const std::string& strSrc,
        bool isUpper
    ) {
        unsigned char md5[MD5_DIGEST_LENGTH] = { 0 };

        MD5_CTX ctx = { 0 };
        MD5_Init(&ctx);
        MD5_Update(&ctx, strSrc.c_str(), strSrc.size());
        MD5_Final(md5, &ctx);

        const char* format = isUpper ? "%s%.2X" : "%s%.2x";

        char hexString[128] = { 0 };
        for (int i = 0; i < MD5_DIGEST_LENGTH; ++i) {
            sprintf_s(hexString, sizeof(hexString) / sizeof(hexString[0]), format, hexString, md5[i]);
        }

        return hexString;
    }

    std::string GetMD5String(
        const std::wstring& wstrSrc,
        bool isUpper
    ) {
        return GetMD5String(StringUtils::Utf16ToUtf8(wstrSrc), isUpper);
    }

    std::wstring GetMD5WString(
        const std::string& strSrc,
        bool isUpper
    ) {
        return StringUtils::Utf8ToUtf16(GetMD5String(strSrc, isUpper));
    }

    std::wstring GetMD5WString(
        const std::wstring& wstrSrc,
        bool isUpper
    ) {
        return StringUtils::Utf8ToUtf16(GetMD5String(wstrSrc, isUpper));
    }

    std::string GetSHA256String(
        const std::string& strSrc,
        bool isUpper
    ) {
        unsigned char sha256[SHA256_DIGEST_LENGTH] = { 0 };

        SHA256_CTX ctx = { 0 };
        SHA256_Init(&ctx);
        SHA256_Update(&ctx, strSrc.c_str(), strSrc.size());
        SHA256_Final(sha256, &ctx);

        const char* format = isUpper ? "%s%.2X" : "%s%.2x";

        char hexString[128] = { 0 };
        for (int i = 0; i < SHA256_DIGEST_LENGTH; ++i) {
            sprintf_s(hexString, sizeof(hexString) / sizeof(hexString[0]), format, hexString, sha256[i]);
        }

        return hexString;
    }

    std::string GetSHA256String(
        const std::wstring& wstrSrc,
        bool isUpper
    ) {
        return GetSHA256String(StringUtils::Utf16ToUtf8(wstrSrc), isUpper);
    }

    std::wstring GetSHA256WString(
        const std::string& strSrc,
        bool isUpper
    ) {
        return StringUtils::Utf8ToUtf16(GetSHA256String(strSrc, isUpper));
    }

    std::wstring GetSHA256WString(
        const std::wstring& wstrSrc,
        bool isUpper
    ) {
        return StringUtils::Utf8ToUtf16(GetSHA256String(wstrSrc, isUpper));
    }

    template<typename NUM_TYPE>
    NUM_TYPE GetBitsNum(
        const unsigned char *data,
        int bits,
        bool isBigEndian
    ) {
        NUM_TYPE num = 0;

        if (isBigEndian) {
            for (int i = bits - 1; i >= 0; --i) {
                num += (NUM_TYPE)data[i] << ((bits - i - 1) * 8);
            }
        } else {
            for (int i = 0; i < bits; ++i) {
                num += (NUM_TYPE)data[i] << (i * 8);
            }
        }

        return num;
    }

    unsigned short Get16BitsNum(
        const char *data,
        bool isBigEndian
    ) {
        return GetBitsNum<unsigned short>((const unsigned char*)data, 2, isBigEndian);
    }

    unsigned int Get32BitsNum(
        const char *data,
        bool isBigEndian
    ) {
        return GetBitsNum<unsigned int>((const unsigned char*)data, 4, isBigEndian);
    }

    unsigned long long Get64BitsNum(
        const char *data,
        bool isBigEndian
    ) {
        return GetBitsNum<unsigned long long>((const unsigned char*)data, 8, isBigEndian);
    }

    double GetDoubleNum(
        const char *data,
        bool isBigEndian
    ) {
        unsigned char buffer[8] = { 0 };

        if (isBigEndian) {
            buffer[7] = data[0];
            buffer[6] = data[1];
            buffer[5] = data[2];
            buffer[4] = data[3];
            buffer[3] = data[4];
            buffer[2] = data[5];
            buffer[1] = data[6];
            buffer[0] = data[7];
        } else {
            for (int i = 0; i < 8; i++) {
                buffer[i] = data[i];
            }
        }

        return *((double*)buffer);
    }

    std::string GetFormatFileSize(
        long long fileSize
    ) {
        double doubleFileSize = (double)fileSize;
        char buf[32] = { 0 };

        if (fileSize < 1024) {
            sprintf_s(buf, sizeof(buf) / sizeof(buf[0]), "%.2lfB", doubleFileSize);
        } else if (fileSize < 1024 * 1024) {
            sprintf_s(buf, sizeof(buf) / sizeof(buf[0]), "%.2lfKB", doubleFileSize / 1024);
        } else if (fileSize < 1024 * 1024 * 1024) {
            sprintf_s(buf, sizeof(buf) / sizeof(buf[0]), "%.2lfMB", doubleFileSize / 1024 / 1024);
        } else {
            sprintf_s(buf, sizeof(buf) / sizeof(buf[0]), "%.2lfGB", doubleFileSize / 1024 / 1024 / 1024);
        }

        return buf;
    }

}