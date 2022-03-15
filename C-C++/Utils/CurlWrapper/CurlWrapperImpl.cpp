#include "pch.h"

#include <io.h>

#include <WinSock2.h>
#pragma comment(lib,"ws2_32")

#include <Shlwapi.h>
#pragma comment(lib,"Shlwapi")

#include <StringUtils/StringUtils.h>
#pragma comment(lib, "StringUtils")

#ifdef _DEBUG
    #pragma comment(lib, "libcurl_debug")
#else
    #pragma comment(lib, "libcurl")
#endif

#include "CurlWrapperImpl.h"

CurlWrapperImpl::CurlWrapperImpl() {
    char exeDir[MAX_PATH] = { 0 };
    GetModuleFileNameA(NULL, exeDir, sizeof(exeDir) / sizeof(exeDir[0]));
    char *p = strrchr(exeDir, '\\');
    if (NULL != p) {
        *p = 0;
    }

    m_caFilePath = std::string(exeDir) + "\\ssl\\cacert.pem";

    memset(m_errbuf, 0, sizeof(m_errbuf));
}

CurlWrapperImpl::~CurlWrapperImpl() {
    if (m_curl) {
        /* always cleanup */
        curl_easy_cleanup(m_curl);
    }
}

struct UserData {
    HANDLE fileHandle;
    CurlWrapper::Response *response;

    UserData() {
        fileHandle = INVALID_HANDLE_VALUE;
        response = nullptr;
    }
};

static size_t WriteCallback(
    void *buffer,
    size_t size,
    size_t nmemb,
    void *user_p
) {
    size_t retSize = size * nmemb;
    UserData *userData = (UserData*)user_p;
    if (userData && buffer) {
        char *data = (char*)buffer;
        if(userData->fileHandle != INVALID_HANDLE_VALUE) {
            DWORD writeBytes = 0;
            WriteFile(userData->fileHandle, buffer, retSize, &writeBytes, NULL);
        } else if (userData->response) {
            userData->response->strContent.append(data, nmemb);
        }
    }

    return retSize;
}

static int DebugCallback(
    CURL *handle,
    curl_infotype type,
    char *data,
    size_t size,
    void *userptr
) {
    if (!data) {
        return 0;
    }

    switch (type) {
    case curl_infotype::CURLINFO_TEXT:
    {
        OutputDebugStringA(data);
    }
    break;
    case curl_infotype::CURLINFO_HEADER_IN:
    {
        UserData *userData = (UserData*)userptr;
        if (userData && userData->response) {
            std::string str(data, size);
            userData->response->strRawResponseHeader.append(str);

            auto pos = str.rfind("\r\n");
            if (pos != std::string::npos) {
                str.erase(pos);
            }
            auto lines = StringUtils::SplitLinesV(str, ":");
            if (lines.size() == 2) {
                std::string strValue = lines[1];
                if (strValue.front() == ' ') {
                    strValue.erase(0, 1);
                }
                userData->response->responseHeaders.insert({ lines[0], strValue });
            }
        }
    }
    break;
    case curl_infotype::CURLINFO_HEADER_OUT:
    {
        OutputDebugStringA(data);

        UserData *userData = (UserData*)userptr;
        if (userData && userData->response && data) {
            userData->response->strRawRequestHeader.append(data, size);
        }
    }
    break;
    case curl_infotype::CURLINFO_DATA_IN:
    {
        //OutputDebugStringA(data);
    }
    break;
    case curl_infotype::CURLINFO_DATA_OUT:
    {
        //OutputDebugStringA(data);
    }
    break;
    case curl_infotype::CURLINFO_SSL_DATA_IN:
    {

    }
    break;
    case curl_infotype::CURLINFO_SSL_DATA_OUT:
    {

    }
    break;
    default:
        break;
    }

    return 0;
}

std::string CurlWrapperImpl::GetUrlEncodeString(const std::string &strString) {
    std::string strEncodeString;

    if (m_curl) {
        char *encodeString = curl_easy_escape(m_curl, strString.c_str(), strString.size());
        if (encodeString) {
            strEncodeString.assign(encodeString);
            curl_free(encodeString);
        }
    }

    return strEncodeString;
}

CurlWrapper::Response CurlWrapperImpl::PerformHttpRequest(
    const CurlWrapper::Request &request,
    bool isPost
) {
    CurlWrapper::Response response;

    CURLcode res;

    curl_slist *http_headers = NULL;

    curl_mime *mime = NULL;

    UserData userData;

    do {
        /* get a curl handle */
        m_curl = curl_easy_init();
        if (!m_curl) {
            break;
        }

        userData.response = &response;

        if (!request.wstrResponseContentFilePath.empty()) {
            userData.fileHandle = CreateFileW(request.wstrResponseContentFilePath.c_str(), GENERIC_READ | GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
        }

        // see. https://curl.se/libcurl/c/CURLOPT_WRITEFUNCTION.html
        res = curl_easy_setopt(m_curl, CURLOPT_WRITEFUNCTION, &WriteCallback);
        res = curl_easy_setopt(m_curl, CURLOPT_WRITEDATA, &userData);

        // see. https://curl.se/libcurl/c/CURLOPT_DEBUGFUNCTION.html
        res = curl_easy_setopt(m_curl, CURLOPT_VERBOSE, 1);
        res = curl_easy_setopt(m_curl, CURLOPT_DEBUGFUNCTION, &DebugCallback);
        res = curl_easy_setopt(m_curl, CURLOPT_DEBUGDATA, &userData);

        std::string strContentType;

        for (const auto &headerPair : request.headers) {
            if (headerPair.first == "Content-Type") {
                strContentType = headerPair.second;
            }

            http_headers = curl_slist_append(http_headers, (headerPair.first + ": " + headerPair.second).c_str());
        }

        if (http_headers) {
            res = curl_easy_setopt(m_curl, CURLOPT_HTTPHEADER, http_headers);
        }

        std::string strEncodePostData;

        if (isPost) {
            res = curl_easy_setopt(m_curl, CURLOPT_POST, 1);

            if (!request.strPostData.empty()) {
                /* see.https://curl.se/libcurl/c/CURLOPT_POSTFIELDS.html
                This POST is a normal application/x-www-form-urlencoded kind (and libcurl will set that Content-Type by default when this option is used)
                You must make sure that the data is formatted the way you want the server to receive it.
                libcurl will not convert or encode it for you in any way. For example, the web server may assume that this data is url-encoded.
                */
                res = curl_easy_setopt(m_curl, CURLOPT_POSTFIELDS, request.strPostData.c_str());
                res = curl_easy_setopt(m_curl, CURLOPT_POSTFIELDSIZE, request.strPostData.size());
            } else {
                if (!request.forms.empty()) {
                    if (strContentType == "application/x-www-form-urlencoded") {
                        for (const auto& form : request.forms) {
                            if (!form.strContent.empty()) {
                                std::string strEncodeName = GetUrlEncodeString(form.strName);
                                std::string strEncodeContent = GetUrlEncodeString(form.strContent);

                                if (!strEncodePostData.empty()) {
                                    strEncodePostData += "&";
                                }

                                strEncodePostData += strEncodeName + "=" + strEncodeContent;
                            }
                        }

                        res = curl_easy_setopt(m_curl, CURLOPT_POSTFIELDS, strEncodePostData.c_str());
                        res = curl_easy_setopt(m_curl, CURLOPT_POSTFIELDSIZE, strEncodePostData.size());

                    } else if (strContentType == "multipart/form-data") {
                        // curl_formadd is deprecated.
                        // see. https://curl.se/libcurl/c/curl_formadd.html
                        mime = curl_mime_init(m_curl);

                        if (mime) {
                            for (const auto& form : request.forms) {
                                curl_mimepart* part = curl_mime_addpart(mime);

                                std::string strEncodeName = GetUrlEncodeString(form.strName);
                                std::string strEncodeContent = GetUrlEncodeString(form.strContent);

                                res = curl_mime_name(part, strEncodeName.c_str());

                                if (!strEncodeContent.empty()) {
                                    res = curl_mime_data(part, strEncodeContent.c_str(), strEncodeContent.size());
                                }

                                if (!form.strContentType.empty()) {
                                    res = curl_mime_type(part, form.strContentType.c_str());
                                }

                                if (!form.strFileName.empty()) {
                                    res = curl_mime_filedata(part, form.strFileName.c_str());
                                }
                            }

                            curl_easy_setopt(m_curl, CURLOPT_MIMEPOST, mime);
                        }
                    }
                }
            }
        }

        // see. https://curl.se/libcurl/c/CURLOPT_SSL_VERIFYPEER.html
        bool isHttps = 0 == _strnicmp(request.strUrl.c_str(), "https://", strlen("https://"));
        if (isHttps && request.verifyCa) {
            res = curl_easy_setopt(m_curl, CURLOPT_SSL_VERIFYPEER, 1L);
            res = curl_easy_setopt(m_curl, CURLOPT_SSL_VERIFYHOST, 2L);
            res = curl_easy_setopt(m_curl, CURLOPT_CAINFO, m_caFilePath.c_str());
        } else {
            res = curl_easy_setopt(m_curl, CURLOPT_SSL_VERIFYPEER, 0L);
            res = curl_easy_setopt(m_curl, CURLOPT_SSL_VERIFYHOST, 0L);
        }

        // see. https://curl.se/libcurl/c/CURLOPT_FOLLOWLOCATION.html
        if (request.followLocation) {
            curl_easy_setopt(m_curl, CURLOPT_FOLLOWLOCATION, 1);

            /* allow three redirects */
            curl_easy_setopt(m_curl, CURLOPT_MAXREDIRS, request.maxRedirs);
        }

        // see. https://curl.se/libcurl/c/CURLOPT_TIMEOUT.html
        if (request.timeout > 0) {
            curl_easy_setopt(m_curl, CURLOPT_TIMEOUT, 30);
        }

        // see. https://curl.se/libcurl/c/CURLOPT_PROXY.html
        // eg. http://localhost:7890
        if (!request.strProxy.empty()) {
            curl_easy_setopt(m_curl, CURLOPT_PROXY, request.strProxy.c_str());
        }

        // see. https://curl.se/libcurl/c/CURLOPT_ERRORBUFFER.html
        /* provide a buffer to store errors in */
        curl_easy_setopt(m_curl, CURLOPT_ERRORBUFFER, m_errbuf);

        /* set the error buffer as empty before performing a request */
        memset(m_errbuf, 0, sizeof(m_errbuf));

        res = curl_easy_setopt(m_curl, CURLOPT_URL, request.strUrl.c_str());

        res = curl_easy_perform(m_curl);

        if (res == CURLE_OK) {
            curl_easy_getinfo(m_curl, CURLINFO_RESPONSE_CODE, &response.statusCode);
        } else {
            response.wstrErrMsg = StringUtils::Utf8ToUtf16(m_errbuf);

            if (response.wstrErrMsg.empty()) {
                const char *errMsg = curl_easy_strerror(res);
                if (errMsg) {
                    response.wstrErrMsg = StringUtils::Utf8ToUtf16(errMsg);
                }
            }
        }

    } while (false);

    if (http_headers) {
        curl_slist_free_all(http_headers);
    }

    if (mime) {
        curl_mime_free(mime);
    }

    if (userData.fileHandle != INVALID_HANDLE_VALUE) {
        CloseHandle(userData.fileHandle);
    }

    if (m_curl) {
        curl_easy_cleanup(m_curl);
        m_curl = nullptr;
    }

    return response;
}

CurlWrapper::Response CurlWrapperImpl::HttpGet(const CurlWrapper::Request &request) {
    return PerformHttpRequest(request, false);
}

CurlWrapper::Response CurlWrapperImpl::HttpPost(const CurlWrapper::Request &request) {
    return PerformHttpRequest(request, true);
}
