#pragma once

#ifdef BASE64UTILS_EXPORTS
#define BASE64UTILS_API __declspec(dllexport)
#else
#define BASE64UTILS_API __declspec(dllimport)
#endif

#include <string>

class BASE64UTILS_API Base64Utils
{
public:
    Base64Utils& operator=(Base64Utils &) = delete;
    Base64Utils& operator=(Base64Utils &&) = delete;

    static char * Base64Encode(const unsigned char *dataIn, size_t dataInLength);

    static unsigned char * Base64Decode(const char *dataIn, size_t dataInLength, size_t *dataOutLength);

    static void FreeData(void *p);
};