#pragma once

#ifdef EMLUTILS_EXPORTS
    #define EMLUTILS_API __declspec(dllexport)
#else
    #define EMLUTILS_API __declspec(dllimport)
#endif

#include <string>

namespace EmlUtils {

    struct EmlInfo {
        std::wstring wstrSubject; // 主题
        std::wstring wstrContent; // 纯文本内容
        std::wstring wstrRichContent; // 富文本内容
        std::wstring wstrFromAddr; // 发件人邮箱地址 eg. 18061474689@163.com
        std::wstring wstrFromAddrName; // 发件人姓名 eg. 张三
        std::wstring wstrToAddr; // 收件人邮箱地址
        std::wstring wstrToAddrName; // 收件人姓名
        long long mailSendTime; // 邮件发送时间(unix时间戳)
    };

    EMLUTILS_API EmlInfo ParseEmlFile(
        const std::wstring &wstrEmlFilePath
    );

};