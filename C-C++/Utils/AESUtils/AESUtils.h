#pragma once

#ifdef AESUTILS_EXPORTS
    #define AESUTILS_API __declspec(dllexport)
#else
    #define AESUTILS_API __declspec(dllimport)
#endif

#define WIN32_LEAN_AND_MEAN             // 从 Windows 头中排除极少使用的资料
#include <windows.h>
#include <string>

namespace AESUtils {

    enum class DigestAlgorithm {
        NONE = -1,
        SHA1 = 0,
        SHA224,
        SHA256,
        SHA384,
        SHA512,
    };

    enum class AesAlgorithm {
        NONE = -1,
        AES_128_ECB = 0,
        AES_192_ECB,
        AES_256_ECB,

        AES_128_CFB,
        AES_192_CFB,
        AES_256_CFB,

        AES_128_CTR,
        AES_192_CTR,
        AES_256_CTR,

        AES_128_OFB,
        AES_192_OFB,
        AES_256_OFB,

        AES_128_CBC,
        AES_192_CBC,
        AES_256_CBC,

        AES_128_CCM,
        AES_192_CCM,
        AES_256_CCM,

        AES_128_GCM,
        AES_192_GCM,
        AES_256_GCM,

        AES_128_XTS,
        AES_256_XTS,

        AES_128_WRAP,
        AES_192_WRAP,
        AES_256_WRAP,
    };

    /* Padding modes */
    enum class PaddingMode {
        NONE = -1,
        PKCS7 = 0,
        ISO7816_4,
        ANSI923,
        ISO10126,
        ZERO
    };

    struct DecryptParam {
        DecryptParam() {
            key = nullptr;
            keySize = 0;
            iv = nullptr;
            ivSize = 0;
            salt = nullptr;
            saltSize = 0;
            kdfIter = 0;
            digestAlgorithm = DigestAlgorithm::NONE;
            aesAlgorithm = AesAlgorithm::AES_256_CBC;
            paddingMode = PaddingMode::NONE;
        }

        const char* key;
        int keySize;
        const char* iv;
        int ivSize;
        const char* salt;
        int saltSize;
        int kdfIter;
        DigestAlgorithm digestAlgorithm;
        AesAlgorithm aesAlgorithm;
        PaddingMode paddingMode;
    };

    AESUTILS_API bool DecryptData(
        const DecryptParam& param,
        const char* inBuf,
        int inLen,
        char* outBuf,
        int* outLen,
        bool handlePadding = false
    );

    AESUTILS_API bool DecryptFile(
        const std::wstring& wstrSrcFilePath,
        const std::wstring& wstrDstFilePath,
        const DecryptParam& param
    );

    AESUTILS_API bool DecryptSqlcipherDb(
        const std::wstring& wstrSrcFilePath,
        const std::wstring& wstrDstFilePath,
        const char* key,
        int keySize,
        int pageSize = 4096,
        int kdfIter = 64000,
        DigestAlgorithm digestAlgorithm = DigestAlgorithm::SHA1
    );

    AESUTILS_API bool DecryptSqlcipherDbWalFile(
        const std::wstring& wstrSrcFilePath,
        const std::wstring& wstrDstFilePath,
        const char* key,
        int keySize,
        int pageSize = 4096,
        int kdfIter = 64000,
        DigestAlgorithm digestAlgorithm = DigestAlgorithm::SHA1
    );

}