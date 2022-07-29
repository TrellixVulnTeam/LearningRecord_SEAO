#include "pch.h"
#include "EmlUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "EmlUtilsInternal.h"

#ifdef __cplusplus
}
#endif

#pragma comment(lib, "CORE_ffi")
#pragma comment(lib, "CORE_zlib")
#pragma comment(lib, "CORE_glib")
#pragma comment(lib, "gmime")

#include <StringUtils/StringUtils.h>
#pragma comment(lib, "StringUtils")

namespace EmlUtils {

    std::wstring GetFormatMailAddr(
        const std::wstring &wstrValue
    );

    EmlInfo ParseEmlFile(
        const std::wstring &wstrEmlFilePath
    ) {
        EmlInfo emlInfo;
        EmlInfoEx emlInfoEx;

        do {
            memset(&emlInfoEx, 0, sizeof(EmlInfoEx));
            emlInfoEx = ParseEmlFileEx(wstrEmlFilePath.c_str());

            if (emlInfoEx.from) {
                emlInfo.wstrFromAddr = GetFormatMailAddr(StringUtils::Utf8ToUtf16(emlInfoEx.from));
            }

            if (emlInfoEx.fromWithName) {
                emlInfo.wstrFromAddrName = GetFormatMailAddr(StringUtils::Utf8ToUtf16(emlInfoEx.fromWithName));
            }

            if (emlInfoEx.to) {
                emlInfo.wstrToAddr = GetFormatMailAddr(StringUtils::Utf8ToUtf16(emlInfoEx.to));
            }

            if (emlInfoEx.toWithName) {
                emlInfo.wstrToAddrName = GetFormatMailAddr(StringUtils::Utf8ToUtf16(emlInfoEx.toWithName));
            }

            if (emlInfoEx.subject) {
                emlInfo.wstrSubject = StringUtils::Utf8ToUtf16(emlInfoEx.subject);
            }

            if (emlInfo.wstrSubject.empty()) {
                emlInfo.wstrSubject = L"无主题";
            }

            if (emlInfoEx.body) {
                emlInfo.wstrContent = StringUtils::Utf8ToUtf16(emlInfoEx.body);
            }

            if (emlInfoEx.richbody) {
                emlInfo.wstrRichContent = StringUtils::Utf8ToUtf16(emlInfoEx.richbody);
            }

            emlInfo.mailSendTime = emlInfoEx.date;

        } while (false);

        FreeGPointer(emlInfoEx);

        return emlInfo;
    }

    std::wstring GetFormatMailAddr(
        const std::wstring& wstrValue
    ) {
        std::wstring wstrAddr = wstrValue;

        if (!wstrAddr.empty()) {
            while (!wstrAddr.empty()) {
                if (wstrAddr.back() == L'\r' ||
                    wstrAddr.back() == L'\n' ||
                    wstrAddr.back() == L' ' ||
                    wstrAddr.back() == L'\"') {
                    wstrAddr.pop_back();
                } else {
                    break;
                }
            }

            while (!wstrAddr.empty()) {
                if (wstrAddr.front() == L'\r' ||
                    wstrAddr.front() == L'\n' ||
                    wstrAddr.front() == L' ' ||
                    wstrAddr.front() == L'\"') {
                    wstrAddr.erase(0, 1);
                } else {
                    break;
                }
            }
        }

        return wstrAddr;
    }

}
