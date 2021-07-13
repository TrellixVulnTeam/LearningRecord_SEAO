// HttpDemo.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"


int main() {
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

