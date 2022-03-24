#pragma once
#include <curl/curl.h>

#include "CurlWrapper.h"

class CurlWrapperImpl {
    friend class CurlWrapper;

public:
    CurlWrapperImpl();
    ~CurlWrapperImpl();
    CurlWrapperImpl(const CurlWrapperImpl&) = delete;
    CurlWrapperImpl& operator=(const CurlWrapperImpl&) = delete;

private:
    std::string GetUrlEncodeString(const std::string &strString);

    CurlWrapper::Response PerformHttpRequest(
        const CurlWrapper::Request &request,
        bool isPost
    );

    CurlWrapper::Response HttpGet(const CurlWrapper::Request &request);

    CurlWrapper::Response HttpPost(const CurlWrapper::Request &request);

    CURL *m_curl;
    std::string m_caFilePath;
    char m_errbuf[CURL_ERROR_SIZE];
};
