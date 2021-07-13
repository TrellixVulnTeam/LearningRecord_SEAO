// QuotedPrintableUtils.cpp : ���� DLL Ӧ�ó���ĵ���������
//

#include "stdafx.h"
#include "QuotedPrintableUtils.h"
#include "Poco/QuotedPrintableEncoder.h"
#include "Poco/QuotedPrintableDecoder.h"

namespace QuotedPrintableUtils {

    std::string QuotedPrintableEncode(
        const std::string &strSrc
    ) {
        std::string strEncode;

        std::ostringstream ostr;
        Poco::QuotedPrintableEncoder encoder(ostr);

        encoder << strSrc;
        encoder.close();

        strEncode = ostr.str();

        return strEncode;
    }

    std::string QuotedPrintableDecode(
        const std::string &strSrc
    ) {
        std::string strDecode;
        
        std::istringstream istr(strSrc);
        Poco::QuotedPrintableDecoder decoder(istr);

        int c = decoder.get();
        while (c != -1) {
            strDecode += (char)c;
            c = decoder.get();
        }

        return strDecode;
    }

    std::string QuotedPrintableDecode2(
        const std::string &strSrc
    ) {
        std::string strDst;
        const unsigned char *src = (const unsigned char*)strSrc.c_str();
        int srcSize = strSrc.size();

        unsigned char *dst = new unsigned char[srcSize]();
        if (!dst) {
            return strDst;
        }

        unsigned char *dst_real = dst;

        int i = 0;
        int dstSize = 0;

        while (i < srcSize) {
            if (strncmp((const char*)src, "=\r\n", 3) == 0) {
                // ��س�������
                src += 3;
                i += 3;
            } else if (strncmp((const char*)src, "=\n=", 3) == 0) {
                //=\nAA���������û����
                src += 2;
                i += 2;
            } else if (strncmp((const char*)src, "==", 2) == 0) {
                src += 1;
                i += 1;
            } else {
                if (*src == '=') {
                    // �Ǳ����ֽ�
                    sscanf_s((const char*)src, "=%02hhX", dst);
                    dst++;

                    src += 3;
                    i += 3;
                } else {
                    // �Ǳ����ֽ�
                    *dst++ = *src++;
                    i++;
                }

                dstSize++;
            }
        }

        // ����Ӹ�������
        *dst = '\0';

        strDst.assign((char*)dst_real, dstSize);
        delete[] dst_real;

        return strDst;
    }

};