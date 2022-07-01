// ParseAppleCookieFile.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#define WIN32_LEAN_AND_MEAN             // 从 Windows 头中排除极少使用的资料
// Windows 头文件: 
#include <windows.h>
#include <shellapi.h>
#pragma comment(lib, "Shell32")

#include <iostream>
#include <FileUtils/FileUtils.h>
#pragma comment(lib, "FileUtils")

#include <StringUtils/StringUtils.h>
#pragma comment(lib, "StringUtils")

void ParseCookies(const std::wstring& wstrCookieFilePath);

int main(int argc, char *argv[])
{
    int argCount = 0;
    wchar_t** arglist = CommandLineToArgvW(GetCommandLineW(), &argCount);
    if (!arglist || argCount != 2) {
        return -1;
    }

    ParseCookies(arglist[1]);

	LocalFree(arglist);
	
    getchar();
	
	return 0;
}

std::string GetTimeString(long long time) {
    if (time <= 0) {
        return "";
    }

    if (std::to_string(time).size() == 13) {
        time /= 1000;
    }

    time_t t = time;
    struct tm timeInfo = { 0 };
    _localtime64_s(&timeInfo, &t);

    char buffer[32] = { 0 };
    sprintf_s(buffer, _countof(buffer), "%.4d-%.2d-%.2d %.2d:%.2d:%.2d",
        timeInfo.tm_year + 1900, timeInfo.tm_mon + 1, timeInfo.tm_mday, timeInfo.tm_hour, timeInfo.tm_min, timeInfo.tm_sec);
    return buffer;
}

void ParseCookies(const std::wstring& wstrCookieFilePath) {
    std::string strCookie;
    char* fileContent = nullptr;

    do {
        // 文件格式
        // https://github.com/interstateone/BinaryCookies
        if (!FileUtils::PathIsExist(wstrCookieFilePath)) {
            break;
        }

        int fileSize = 0;
        fileContent = FileUtils::ReadFileContent(wstrCookieFilePath, &fileSize);
        if (!fileContent) {
            break;
        }

        int pos = 0;

        // skip magic
        pos += 4;

        // page count
        int pageCount = StringUtils::Get32BitsNum(fileContent + pos, true);
        pos += 4;

        // get page data size
        std::vector<int> pageDataSizes;
        for (int i = 0; i < pageCount; ++i) {
            pageDataSizes.push_back(StringUtils::Get32BitsNum(fileContent + pos, true));
            pos += 4;
        }

        // get page data
        std::vector<std::string> pageDatas;
        for (int i = 0; i < pageCount; ++i) {
            pageDatas.push_back(std::move(std::string(fileContent + pos, pageDataSizes[i])));
            pos += pageDataSizes[i];
        }

        int pageIndex = 0;
        for (const auto& pageData : pageDatas) {
            int pageDataPos = 0;
            const char* pageDataPtr = pageData.c_str();

            // skip Header
            pageDataPos += 4;

            // cookie count
            int cookieCount = StringUtils::Get32BitsNum(pageDataPtr + pageDataPos);
            pageDataPos += 4;

            // get cookie data offset
            std::vector<size_t> cookieDataOffsets;
            for (int i = 0; i < cookieCount; ++i) {
                cookieDataOffsets.push_back(StringUtils::Get32BitsNum(pageDataPtr + pageDataPos));
                pageDataPos += 4;
            }

            // skip Footer
            pageDataPos += 4;

            // parse cookie data
            for (int i = 0; i < cookieCount; ++i) {
                printf("======================================================\r\nPage %d Cookie %d\r\n\r\n", pageIndex + 1, i + 1);

                const char* cookieDataPtr = pageDataPtr + cookieDataOffsets[i];
                int cookieDataPos = 0;

                // cookie data size
                unsigned int cookieDataSize = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Version 0 or 1
                unsigned int version = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Flags
                // isSecure = 1, isHTTPOnly = 1 << 2, unknown1 = 1 << 3, unknown2 = 1 << 4
                unsigned int flags = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Has port 0 or 1
                unsigned int hasPort = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // URL Offset
                // Offset from the start of the cookie
                unsigned int urlOffset = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Name Offset
                // Offset from the start of the cookie
                unsigned int nameOffset = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Path Offset
                // Offset from the start of the cookie
                unsigned int pathOffset = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Value Offset
                // Offset from the start of the cookie
                unsigned int valueOffset = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Comment Offset
                // Offset from the start of the cookie, 0x00000000 if not present
                unsigned int commentOffset = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Comment URL Offset
                // Offset from the start of the cookie, 0x00000000 if not present
                unsigned int commentUrlOffset = StringUtils::Get32BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 4;

                // Expiration
                // Number of seconds since 00:00:00 UTC on 1 January 2001
                double expiration = StringUtils::GetDoubleNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 8;
                printf("Expiration:    %s\r\n", GetTimeString((long long)(expiration + 978307200)).c_str());

                // Creation
                // Number of seconds since 00:00:00 UTC on 1 January 2001
                double creation = StringUtils::GetDoubleNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 8;
                printf("Creation:    %s\r\n", GetTimeString((long long)(creation + 978307200)).c_str());

                // Port
                // Only present if the "Has port" field is 1
                unsigned short Port = StringUtils::Get16BitsNum(cookieDataPtr + cookieDataPos);
                cookieDataPos += 2;

                // Comment
                std::string strComment;
                if (commentOffset > 0 && commentOffset < cookieDataSize) {
                    strComment.assign(cookieDataPtr + commentOffset);
                }

                // Comment URL
                std::string strCommentURL;
                if (commentUrlOffset > 0 && commentUrlOffset < cookieDataSize) {
                    strCommentURL.assign(cookieDataPtr + commentUrlOffset);
                }

                // URL
                std::string strUrl;
                if (urlOffset > 0 && urlOffset < cookieDataSize) {
                    strUrl.assign(cookieDataPtr + urlOffset);
                    printf("URL:    %s\r\n", strUrl.c_str());
                }

                // Name
                std::string strName;
                if (nameOffset > 0 && nameOffset < cookieDataSize) {
                    strName.assign(cookieDataPtr + nameOffset);
                    printf("Name:    %s\r\n", strName.c_str());
                }

                // Path
                std::string strPath;
                if (pathOffset > 0 && pathOffset < cookieDataSize) {
                    strPath.assign(cookieDataPtr + pathOffset);
                    printf("Path:    %s\r\n", strPath.c_str());
                }

                // Value
                std::string strValue;
                if (valueOffset > 0 && valueOffset < cookieDataSize) {
                    strValue.assign(cookieDataPtr + valueOffset);
                    printf("Value:    %s\r\n", strValue.c_str());
                }

                printf("======================================================\r\n");
            }

            ++pageIndex;
        }

        // Checksum
        pos += 4;

        // Footer
        pos += 8;

    } while (false);

    if (fileContent) {
        delete[] fileContent;
    }
}
