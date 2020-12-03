#include <libiconv\iconv\iconv.h>
#include "StringConvertor.h"

#pragma comment(lib, "libiconv")

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

std::wstring GBKToUtf16(const std::string &str)
{
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

std::string Utf16ToGBK(const std::wstring &str)
{
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

std::string GBKToUtf8(const std::string &str)
{
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

std::string Utf8ToGBK(const std::string &str)
{
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

std::string Utf16ToUtf8(const std::wstring &str)
{
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

std::wstring Utf8ToUtf16(const std::string &str)
{
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
                   const char *tocode)
{
    iconv_t cd = (iconv_t)-1;
    const char *fromStrTmp = fromStr;
    char *toStrTmp = NULL;
    size_t toStrBytesleft = 4096 * 4 - 1;
    size_t ret = 0;

    *toStr = NULL;
    *toStrBytes = toStrBytesleft;

    do 
    {
        cd = iconv_open(tocode, fromcode);
        if ((iconv_t)-1 == cd)
        {
            break;
        }

        // 多申请1个字节，防止转换溢出
        *toStr = new char[toStrBytesleft + 2]();
        if (!(*toStr))
        {
            break;
        }

        toStrTmp = *toStr;
        ret = iconv(cd, (const char**)(&fromStrTmp), &fromStrBytes, &toStrTmp, &toStrBytesleft);
        if ((size_t)-1 != ret)
        {
            iconv(cd, NULL, NULL, &toStrTmp, &toStrBytesleft);
        }

        *toStrTmp = '\0';
        *toStrBytes -= toStrBytesleft;

    } while (false);

    if ((iconv_t)-1 != cd)
    {
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
)
{
    iconv_t cd = (iconv_t)-1;
    STRING str;
    char *lpBuffer = NULL;

    do
    {
        cd = iconv_open(tocode, fromcode);
        if ((iconv_t)-1 == cd)
        {
            break;
        }

        // 预留2个字节
        // why? 给L'\0'用
        size_t bufferSize = 4096 - 2;
        lpBuffer = new char[bufferSize + 2]();
        if (NULL == lpBuffer)
        {
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

        while ((size_t)-1 == ret && E2BIG == err)
        {
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

    if ((iconv_t)-1 != cd)
    {
        iconv_close(cd);
    }

    if (NULL != lpBuffer)
    {
        delete[] lpBuffer;
    }

    return str;
}