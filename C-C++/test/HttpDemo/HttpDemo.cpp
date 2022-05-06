// HttpDemo.cpp : 定义控制台应用程序的入口点。
//

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <strsafe.h>
#include <Shlwapi.h>

#define CPPHTTPLIB_OPENSSL_SUPPORT
#include "httplib.h"
#pragma comment(lib, "libcrypto")
#pragma comment(lib, "libssl")

#include <CurlWrapper/CurlWrapper.h>
#pragma comment(lib, "CurlWrapper")

int main() {
    CurlWrapper::Request request;
    CurlWrapper::Response response;

    /*request.strUrl = "https://down.sandai.net/thunder11/XunLeiWebSetup11.3.8.1890gw.exe";
    request.wstrResponseContentFilePath = LR"(E:\\新建文件夹\迅雷.exe)";
    response = curlWrapper.HttpGet(request);*/

    request.Clear();

    request.strUrl = "http://addressapi.meituan.com/v1/address/list";
    request.headers.insert({ "Content-Type", "application/x-www-form-urlencoded" });
    request.forms.emplace_back(CurlWrapper::Form("login_token", "SRuHFn47QclLERcs7HSt9cI4VwQAAAAAUxAAAHiICv9McQunzW4t4K5kU5ckN_S3vcImzyB7M_vRxYHeGR7moBQb7QNK7nCCEmunyw"));
    request.forms.emplace_back(CurlWrapper::Form("uuid", "0000000000000A8A46FD6A3254B8ABA29DA92B9C45B16A163380505914414663"));
    request.forms.emplace_back(CurlWrapper::Form("biz_id", "1101"));
    request.forms.emplace_back(CurlWrapper::Form("login_token_type", "0"));
    request.forms.emplace_back(CurlWrapper::Form("client_id", "6"));
    request.forms.emplace_back(CurlWrapper::Form("client_version", "1.0"));
    request.forms.emplace_back(CurlWrapper::Form("address_sdk_version", "1.0.2"));
    request.forms.emplace_back(CurlWrapper::Form("device_version", "25_7.1.1"));
    request.forms.emplace_back(CurlWrapper::Form("device_type", "ONEPLUS%20A5000"));
    request.forms.emplace_back(CurlWrapper::Form("data", "{\"address_type\":2,\"extra\":\"\"}"));
    request.wstrResponseContentFilePath = LR"(E:\新建文件夹\address.json)";
    response = CurlWrapper::HttpPost(request);
    return 0;

    // IMPORTANT: 1st parameter must be a hostname or an IP adress string.
    {
        httplib::Client cli("down.sandai.net");

        FILE* fp = nullptr;
        _wfopen_s(&fp, L"1.exe", L"wb");
        httplib::ContentReceiver receiver = [&fp](const char* data, size_t data_length)->bool {
            if (fp) {
                fwrite(data, 1, data_length, fp);
            }

            return true;
        };

        auto res = cli.Get("/thunderx/XunLeiWebSetup10.1.33.770gw.exe", receiver);

        if (fp) {
            fclose(fp);
        }
    }

    {
        httplib::SSLClient cli("images2015.cnblogs.com");

        FILE* fp = nullptr;
        _wfopen_s(&fp, L"1.png", L"wb");
        httplib::ContentReceiver receiver = [&fp](const char* data, size_t data_length)->bool {
            if (fp) {
                fwrite(data, 1, data_length, fp);
            }

            return true;
        };

        auto res = cli.Get("/blog/1076878/201707/1076878-20170703202756112-1194548421.png", receiver);

        if (fp) {
            fclose(fp);
        }
    }

    return 0;
}

