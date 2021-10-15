#include "Base64Utils.h"

#include <openssl/evp.h>
#include <openssl/ossl_typ.h>
#pragma comment(lib,"libcrypto")

namespace Base64Utils {

    std::string Base64EncodeString(
        const std::string &strSrc
    ) {
        return Base64EncodeString((const unsigned char*)strSrc.c_str(), strSrc.size());
    }

    std::string Base64DecodeString(
        const std::string &strSrc
    ) {
        return Base64DecodeString((const unsigned char*)strSrc.c_str(), strSrc.size());
    }

    std::string Base64EncodeString(
        const unsigned char *in,
        int inSize
    ) {
        EVP_ENCODE_CTX *ectx = nullptr;
        unsigned char *buffer = nullptr;
        std::string strEncode;

        do {
            int size = inSize * 2;
            size = size > 64 ? size : 64;

            buffer = new unsigned char[size]();
            if (!buffer) {
                break;
            }

            ectx = EVP_ENCODE_CTX_new();
            if (!ectx) {
                break;
            }

            EVP_EncodeInit(ectx);

            int outlen = 0;
            int encodeSize = 0;

            if (!EVP_EncodeUpdate(ectx, buffer, &outlen, in, inSize)) {
                break;
            }

            encodeSize += outlen;
            EVP_EncodeFinal(ectx, buffer + encodeSize, &outlen);
            encodeSize += outlen;

            strEncode.assign((char*)buffer, encodeSize);

        } while (false);

        if (ectx) {
            EVP_ENCODE_CTX_free(ectx);
        }

        if (buffer) {
            delete[] buffer;
        }

        return strEncode;
    }

    std::string Base64DecodeString(
        const unsigned char *in,
        int inSize
    ) {
        EVP_ENCODE_CTX *ectx = nullptr;
        unsigned char *buffer = nullptr;
        std::string strDecode;

        do {
            int size = inSize * 2;
            size = size > 64 ? size : 64;

            buffer = new unsigned char[size]();
            if (!buffer) {
                break;
            }

            ectx = EVP_ENCODE_CTX_new();
            if (!ectx) {
                break;
            }

            EVP_DecodeInit(ectx);

            int outlen = 0;
            int encodeSize = 0;

            if (EVP_DecodeUpdate(ectx, buffer, &outlen, in, inSize) == -1) {
                break;
            }

            encodeSize = outlen;

            if (EVP_DecodeFinal(ectx, buffer + outlen, &outlen) == -1) {
                break;
            }

            encodeSize += outlen;

            strDecode.assign((char*)buffer, encodeSize);

        } while (false);

        if (ectx) {
            EVP_ENCODE_CTX_free(ectx);
        }

        if (buffer) {
            delete[] buffer;
        }

        return strDecode;
    }

    unsigned char * Base64EncodeData(
        const unsigned char *in,
        int inSize,
        int &outSize
    ) {
        EVP_ENCODE_CTX *ectx = nullptr;
        unsigned char *buffer = nullptr;

        do {
            outSize = inSize * 2;
            outSize = outSize > 64 ? outSize : 64;

            buffer = new unsigned char[outSize]();
            if (!buffer) {
                break;
            }

            ectx = EVP_ENCODE_CTX_new();
            if (!ectx) {
                break;
            }

            EVP_EncodeInit(ectx);

            int outlen = 0;
            outSize = 0;

            if (EVP_EncodeUpdate(ectx, buffer, &outlen, in, inSize) == -1) {
                break;
            }

            outSize = outlen;

            EVP_EncodeFinal(ectx, buffer + outlen, &outlen);

            outSize += outlen;

        } while (false);

        if (ectx) {
            EVP_ENCODE_CTX_free(ectx);
        }

        return buffer;
    }

    unsigned char * Base64DecodeData(
        const unsigned char *in,
        int inSize,
        int &outSize
    ) {
        EVP_ENCODE_CTX *ectx = nullptr;
        unsigned char *buffer = nullptr;

        do {
            outSize = inSize * 2;
            outSize = outSize > 64 ? outSize : 64;

            buffer = new unsigned char[outSize]();
            if (!buffer) {
                break;
            }

            ectx = EVP_ENCODE_CTX_new();
            if (!ectx) {
                break;
            }

            EVP_DecodeInit(ectx);

            int outlen = 0;
            outSize = 0;

            if (EVP_DecodeUpdate(ectx, buffer, &outlen, in, inSize) == -1) {
                break;
            }

            outSize = outlen;

            if (EVP_DecodeFinal(ectx, buffer + outlen, &outlen) == -1) {
                break;
            }

            outSize += outlen;

        } while (false);

        if (ectx) {
            EVP_ENCODE_CTX_free(ectx);
        }

        return buffer;
    }

    void FreeData(void *p) {
        if (p) {
            free(p);
        }
    }

}