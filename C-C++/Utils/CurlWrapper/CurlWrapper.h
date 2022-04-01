#pragma once

#ifdef CURLWRAPPER_EXPORTS
    #define CURLWRAPPER_API __declspec(dllexport)
#else
    #define CURLWRAPPER_API __declspec(dllimport)
#endif

#include <string>
#include <vector>
#include <map>

namespace CurlWrapper {

    // 表单信息
    struct Form {
        std::string strName;

        // 字符串数据时可以直接使用
        // 二进制数据时存在\0截断问题，需要结合使用strContent.c_str()和 strContent.size()
        std::string strContent;

        // 上传文件全路径（GBK编码）
        std::string strFileName;

        // eg. text/html
        std::string strContentType;

        Form(
            const std::string &strName,
            const std::string &strContent
        ) {
            this->strName = strName;
            this->strContent = strContent;
        }

        Form(
            const std::string &strName,
            const std::string &strFileName,
            const std::string &strContentType
        ) {
            this->strName = strName;
            this->strFileName = strFileName;
            this->strContentType = strContentType;
        }
    };

    struct Request {
        // 请求url eg. https://www.baidu.com/
        std::string strUrl;

        // 请求头
        std::map<std::string, std::string> headers;

        // 表单数据
        std::vector<Form> forms;

        // POST相关
        // 字符串数据时可以直接使用
        // 二进制数据时存在\0截断问题，需要结合使用strPostData.c_str()和 strPostData.size()
        std::string strPostData;

        // 是否检验ssl证书，https模式使用
        bool verifyCa;

        // 是否使用代理 eg. localhost:7890，不使用时置为空
        std::string strProxy;

        // 超时秒数
        int timeout;

        // 重定向相关
        // {
        // 是否自动重定向
        bool followLocation;

        // 自动重定向最大次数
        long maxRedirs;

        // }

        // 保存响应内容至文件，可为空
        std::wstring wstrResponseContentFilePath;

        Request() {
            verifyCa = false;
            timeout = 0;
            followLocation = false;
            maxRedirs = 3;
        }

        void Clear() {
            strUrl.clear();
            headers.clear();
            forms.clear();
            strPostData.clear();
            verifyCa = false;
            strProxy.clear();
            timeout = 0;
            followLocation = false;
            maxRedirs = 3;
        }
    };

    struct Response {
        // 状态码
        long statusCode;

        // 错误信息
        std::wstring wstrErrMsg;

        // 请求头
        std::string strRawRequestHeader;

        // 响应头
        std::map<std::string, std::string> responseHeaders;
        std::string strRawResponseHeader;

        // 响应内容
        // 字符串数据时可以直接使用
        // 二进制数据时存在\0截断问题，需要结合使用strContent.c_str()和 strContent.size()
        std::string strContent;

        Response() {
            statusCode = -1;
        }

        void Clear() {
            statusCode = -1;
            wstrErrMsg.clear();
            strRawRequestHeader.clear();
            responseHeaders.clear();
            strRawResponseHeader.clear();
            strContent.clear();
        }
    };

    CURLWRAPPER_API Response HttpGet(const Request &request);

    CURLWRAPPER_API Response HttpPost(const Request &request);

    CURLWRAPPER_API bool CheckNetworkConnect();

}