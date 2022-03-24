#pragma once

#ifdef BASE64UTILS_EXPORTS
    #define BASE64UTILS_API __declspec(dllexport)
#else
    #define BASE64UTILS_API __declspec(dllimport)
#endif

#include <string>

namespace Base64Utils
{
    BASE64UTILS_API std::string Base64EncodeString(
        const std::string &strSrc
    );

    BASE64UTILS_API std::string Base64DecodeString(
        const std::string &strSrc
    );

    BASE64UTILS_API std::string Base64EncodeString(
        const unsigned char *in,
        int inSize
    );

    BASE64UTILS_API std::string Base64DecodeString(
        const unsigned char *in,
        int inSize
    );

    BASE64UTILS_API unsigned char * Base64EncodeData(
        const unsigned char *in,
        int inSize,
        int *outSize = nullptr
    );

    BASE64UTILS_API unsigned char * Base64DecodeData(
        const unsigned char *in,
        int inSize,
        int *outSize = nullptr
    );

    BASE64UTILS_API void FreeData(void *p);
};