#include "pch.h"
#include "CurlWrapperImpl.h"

CurlWrapper::CurlWrapper()
    : m_impl(new CurlWrapperImpl()) {}

CurlWrapper::~CurlWrapper() {
    if (m_impl) {
        delete m_impl;
    }
}

CurlWrapper::Response CurlWrapper::HttpGet(const CurlWrapper::Request &request) {
    return m_impl->HttpGet(request);
}

CurlWrapper::Response CurlWrapper::HttpPost(const CurlWrapper::Request &request) {
    return m_impl->HttpPost(request);
}

static unsigned WINAPI CheckNetThreadFunc(void *param) {

    unsigned networkConnect = 0;

    WSADATA wd = { 0 };
    struct addrinfo *result = NULL;
    struct addrinfo hints;

    do {
        if (0 != WSAStartup(MAKEWORD(2, 2), &wd)) {
            break;
        }

        if (LOBYTE(wd.wHighVersion) != 2 || HIBYTE(wd.wHighVersion) != 2) {
            WSACleanup();
            break;
        }

        const char *host = "www.baidu.com";
        const char *hostPort = "80";
        ZeroMemory(&hints, sizeof(hints));
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_protocol = IPPROTO_TCP;

        // Resolve the server address and port
        INT ret = getaddrinfo(host, hostPort, &hints, &result);
        if (ret == 0) {
            networkConnect = 1;
        }

        if (result) {
            freeaddrinfo(result);
        }

        WSACleanup();

    } while (false);

    _endthreadex(networkConnect);
    return networkConnect;
}

bool CurlWrapper::CheckNetworkConnect() {
    unsigned long networkConnect = 0;
    HANDLE threadHandle = (HANDLE)_beginthreadex(nullptr, 0, CheckNetThreadFunc, nullptr, 0, nullptr);

    if (threadHandle) {
        if (WaitForSingleObject(threadHandle, 2000) == WAIT_OBJECT_0) {
            GetExitCodeThread(threadHandle, &networkConnect);
        }
    }

    return networkConnect == 1;
}
