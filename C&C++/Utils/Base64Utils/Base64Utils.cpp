#include "Base64Utils.h"
#include "b64.h"

char * Base64Utils::Base64Encode(const unsigned char *dataIn, size_t dataInLength)
{
    if (dataIn && dataInLength > 0)
    {
        return b64_encode(dataIn, dataInLength);
    }

    return nullptr;
}

unsigned char * Base64Utils::Base64Decode(const char *dataIn, size_t dataInLength, size_t *dataOutLength)
{
    if (dataIn && dataInLength > 0)
    {
        return b64_decode_ex(dataIn, dataInLength, dataOutLength);
    }

    return nullptr;
}

void Base64Utils::FreeData(void *p)
{
    if (p)
    {
        free(p);
    }
}
