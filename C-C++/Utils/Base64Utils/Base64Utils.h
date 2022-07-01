#pragma once

#ifdef BASE64UTILS_EXPORTS
    #define BASE64UTILS_API __declspec(dllexport)
#else
    #define BASE64UTILS_API __declspec(dllimport)
#endif

#include <string>

namespace Base64Utils {
    BASE64UTILS_API std::string Base64EncodeString(
        const std::string& strSrc
    );

    BASE64UTILS_API std::string Base64DecodeString(
        const std::string& strSrc
    );

    BASE64UTILS_API std::string Base64EncodeString(
        const char* in,
        int inSize
    );

    BASE64UTILS_API std::string Base64DecodeString(
        const char* in,
        int inSize
    );

    BASE64UTILS_API char* Base64EncodeData(
        const char* in,
        int inSize,
        int* outSize = nullptr
    );

    BASE64UTILS_API char* Base64DecodeData(
        const char* in,
        int inSize,
        int* outSize = nullptr
    );

    BASE64UTILS_API void FreeData(void* p);
};