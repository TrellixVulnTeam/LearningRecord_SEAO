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

    void GetMailAddr(
        EmlInfo &emlInfo,
        const std::wstring &wstrDecodeValue,
        bool isFrom
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
                GetMailAddr(emlInfo, StringUtils::Utf8ToUtf16(emlInfoEx.from), true);
            }

            if (emlInfoEx.to) {
                GetMailAddr(emlInfo, StringUtils::Utf8ToUtf16(emlInfoEx.to), false);
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

    void GetMailAddr(
        EmlInfo &emlInfo,
        const std::wstring &wstrMailAddr,
        bool isFrom
    ) {
        // eg. 张三 <18061474689@163.com> 或者 95555@message.cmbchina.com
        std::wstring wstrAddr, wstrAddrName;

        size_t pos1 = wstrMailAddr.find(L"<");
        if (pos1 != std::wstring::npos) {
            wstrAddrName = wstrMailAddr.substr(0, pos1);

            size_t pos2 = wstrMailAddr.rfind(L">");
            if (pos2 != std::wstring::npos && pos2 > pos1) {
                wstrAddr = wstrMailAddr.substr(pos1 + 1, pos2 - pos1 - 1);
            }
        }

        if (isFrom) {
            if (!wstrAddrName.empty()) {
                emlInfo.wstrFromAddrName = wstrAddrName;
            }

            if (!wstrAddr.empty()) {
                emlInfo.wstrFromAddr = wstrAddr;
            } else {
                emlInfo.wstrFromAddr = wstrMailAddr;
            }
        } else {
            if (!wstrAddrName.empty()) {
                emlInfo.wstrToAddrName = wstrAddrName;
            }

            if (!wstrAddr.empty()) {
                emlInfo.wstrToAddr = wstrAddr;
            } else {
                emlInfo.wstrToAddr = wstrMailAddr;
            }
        }
    }

}
