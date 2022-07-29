#include <openssl\evp.h>
#include <openssl\rand.h>
#include <openssl\hmac.h>
#include <openssl\md5.h>
#include <openssl\sha.h>
#include <openssl\aes.h>
#pragma comment(lib, "libcrypto")

#include <sqlite3/sqlite3.h>
#pragma comment(lib, "sqlite3")

#include <Shlwapi.h>
#pragma comment(lib, "Shlwapi")

#include "AESUtils.h"

namespace AESUtils {

    const EVP_CIPHER* GetCipherFromAlgorithmType(
        AesAlgorithm aesAlgorithm
    );

    int GetPaddingModeFromPaddingType(
        PaddingMode paddingMode
    );

    const EVP_MD* GetDigestCipherFromDigestType(
        DigestAlgorithm digestAlgorithm
    );

    int GetDigestAlgorithmSize(
        DigestAlgorithm digestAlgorithm
    );

    EVP_CIPHER_CTX* InitCipherCtx(
        const DecryptParam& param
    );

    bool IsSqliteDb(
        const std::wstring& wstrDbFile
    );

    void SqliteMergeWalFile(
        const std::wstring& wstrDbFile
    );

    const EVP_CIPHER* GetCipherFromAlgorithmType(
        AesAlgorithm aesAlgorithm
    ) {
        const EVP_CIPHER* cipher = nullptr;
        switch (aesAlgorithm) {
        case AesAlgorithm::AES_128_ECB:
            cipher = EVP_aes_128_ecb();
            break;
        case AesAlgorithm::AES_192_ECB:
            cipher = EVP_aes_192_ecb();
            break;
        case AesAlgorithm::AES_256_ECB:
            cipher = EVP_aes_256_ecb();
            break;
        case AesAlgorithm::AES_128_CFB:
            cipher = EVP_aes_128_cfb();
            break;
        case AesAlgorithm::AES_192_CFB:
            cipher = EVP_aes_192_cfb();
            break;
        case AesAlgorithm::AES_256_CFB:
            cipher = EVP_aes_256_cfb();
            break;
        case AesAlgorithm::AES_128_CTR:
            cipher = EVP_aes_128_ctr();
            break;
        case AesAlgorithm::AES_192_CTR:
            cipher = EVP_aes_192_ctr();
            break;
        case AesAlgorithm::AES_256_CTR:
            cipher = EVP_aes_256_ctr();
            break;
        case AesAlgorithm::AES_128_OFB:
            cipher = EVP_aes_128_ofb();
            break;
        case AesAlgorithm::AES_192_OFB:
            cipher = EVP_aes_192_ofb();
            break;
        case AesAlgorithm::AES_256_OFB:
            cipher = EVP_aes_256_ofb();
            break;
        case AesAlgorithm::AES_128_CBC:
            cipher = EVP_aes_128_cbc();
            break;
        case AesAlgorithm::AES_192_CBC:
            cipher = EVP_aes_192_cbc();
            break;
        case AesAlgorithm::AES_256_CBC:
            cipher = EVP_aes_256_cbc();
            break;
        case AesAlgorithm::AES_128_CCM:
            cipher = EVP_aes_128_ccm();
            break;
        case AesAlgorithm::AES_192_CCM:
            cipher = EVP_aes_192_ccm();
            break;
        case AesAlgorithm::AES_256_CCM:
            cipher = EVP_aes_256_ccm();
            break;
        case AesAlgorithm::AES_128_GCM:
            cipher = EVP_aes_128_gcm();
            break;
        case AesAlgorithm::AES_192_GCM:
            cipher = EVP_aes_192_gcm();
            break;
        case AesAlgorithm::AES_256_GCM:
            cipher = EVP_aes_256_gcm();
            break;
        case AesAlgorithm::AES_128_XTS:
            cipher = EVP_aes_128_xts();
            break;
        case AesAlgorithm::AES_256_XTS:
            cipher = EVP_aes_256_xts();
            break;
        case AesAlgorithm::AES_128_WRAP:
            cipher = EVP_aes_128_wrap();
            break;
        case AesAlgorithm::AES_192_WRAP:
            cipher = EVP_aes_192_wrap();
            break;
        case AesAlgorithm::AES_256_WRAP:
            cipher = EVP_aes_256_wrap();
            break;
        default:
            break;
        }

        return cipher;
    }

    int GetPaddingModeFromPaddingType(
        PaddingMode paddingMode
    ) {
        int realPaddingMode = 0;
        switch (paddingMode) {
        case PaddingMode::PKCS7:
            realPaddingMode = EVP_PADDING_PKCS7;
            break;
        case PaddingMode::ISO7816_4:
            realPaddingMode = EVP_PADDING_ISO7816_4;
            break;
        case PaddingMode::ANSI923:
            realPaddingMode = EVP_PADDING_ANSI923;
            break;
        case PaddingMode::ISO10126:
            realPaddingMode = EVP_PADDING_ISO10126;
            break;
        case PaddingMode::ZERO:
            realPaddingMode = EVP_PADDING_ZERO;
            break;
        default:
            break;
        }

        return realPaddingMode;
    }

    const EVP_MD* GetDigestCipherFromDigestType(
        DigestAlgorithm digestAlgorithm
    ) {
        const EVP_MD* digest = nullptr;
        switch (digestAlgorithm) {
        case DigestAlgorithm::SHA1:
            digest = EVP_sha1();
            break;
        case DigestAlgorithm::SHA224:
            digest = EVP_sha224();
            break;
        case DigestAlgorithm::SHA256:
            digest = EVP_sha256();
            break;
        case DigestAlgorithm::SHA384:
            digest = EVP_sha384();
            break;
        case DigestAlgorithm::SHA512:
            digest = EVP_sha512();
            break;
        default:
            break;
        }

        return digest;
    }

    int GetDigestAlgorithmSize(DigestAlgorithm digestAlgorithm) {
        int size = 0;

        switch (digestAlgorithm) {
        case DigestAlgorithm::SHA1:
            size = SHA_DIGEST_LENGTH;
            break;
        case DigestAlgorithm::SHA224:
            size = SHA224_DIGEST_LENGTH;
            break;
        case DigestAlgorithm::SHA256:
            size = SHA256_DIGEST_LENGTH;
            break;
        case DigestAlgorithm::SHA384:
            size = SHA384_DIGEST_LENGTH;
            break;
        case DigestAlgorithm::SHA512:
            size = SHA512_DIGEST_LENGTH;
            break;
        default:
            break;
        }

        return size;
    }

    EVP_CIPHER_CTX* InitCipherCtx(const DecryptParam& param) {
        EVP_CIPHER_CTX* ctx = nullptr;
        bool isSuccess = false;
        unsigned char* realKey = nullptr;

        do {
            const EVP_CIPHER* cipher = GetCipherFromAlgorithmType(param.aesAlgorithm);
            if (!cipher) {
                break;
            }

            ctx = EVP_CIPHER_CTX_new();
            if (!ctx) {
                break;
            }

            if (!EVP_CipherInit_ex(ctx, cipher, nullptr, nullptr, nullptr, 0)) {
                break;
            }

            OPENSSL_assert(EVP_CIPHER_CTX_key_length(ctx) == param.keySize);
            // OPENSSL_assert(EVP_CIPHER_CTX_iv_length(ctx) == param.ivSize);

            /*
            EVP_CIPHER_CTX_set_padding() enables or disables padding.
            This function should be called after the context is set up for encryption or decryption with EVP_EncryptInit_ex()
            */
            int paddingMode = GetPaddingModeFromPaddingType(param.paddingMode);
            EVP_CIPHER_CTX_set_padding(ctx, paddingMode);

            realKey = new unsigned char[param.keySize]();
            if (!realKey) {
                break;
            }

            const EVP_MD* digest = GetDigestCipherFromDigestType(param.digestAlgorithm);
            if (digest) {
                if (!PKCS5_PBKDF2_HMAC(param.key, param.keySize, (const unsigned char*)param.salt, param.saltSize, param.kdfIter, digest, param.keySize, realKey)) {
                    break;
                }
            } else {
                memcpy(realKey, param.key, param.keySize);
            }

            if (!EVP_CipherInit_ex(ctx, nullptr, nullptr, realKey, (const unsigned char*)param.iv, 0)) {
                break;
            }

            isSuccess = true;

        } while (false);

        if (!isSuccess && ctx) {
            EVP_CIPHER_CTX_free(ctx);
        }

        if (realKey) {
            delete[] realKey;
        }

        return ctx;
    }

    bool DecryptData(
        const DecryptParam& param,
        const char* inBuf,
        int inLen,
        char* outBuf,
        int* outLen,
        bool handlePadding
    ) {
        bool isSuccess = false;

        EVP_CIPHER_CTX* ctx = nullptr;

        do {
            if (!inBuf || inLen <= 0 || !outBuf || !outLen) {
                break;
            }

            ctx = InitCipherCtx(param);
            if (!ctx) {
                break;
            }

            int tmpOutLen = 0;
            if (!EVP_CipherUpdate(ctx, (unsigned char*)outBuf, &tmpOutLen, (const unsigned char*)inBuf, inLen)) {
                /* Error */
                break;
            }

            *outLen += tmpOutLen;

            if (!EVP_CipherFinal_ex(ctx, (unsigned char*)outBuf + tmpOutLen, &tmpOutLen)) {
                /* Error */
                break;
            }

            *outLen += tmpOutLen;
            isSuccess = true;

            // 不填充模式下去除最后填充的字节
            if (param.paddingMode == PaddingMode::NONE && handlePadding) {
                int paddingSize = outBuf[*outLen - 1];
                if (paddingSize > 0 && paddingSize <= AES_BLOCK_SIZE) {
                    for (int i = 0; i < paddingSize; ++i) {
                        if (outBuf[*outLen - i - 1] != paddingSize) {
                            paddingSize = 0;
                            break;
                        }
                    }
                } else {
                    paddingSize = 0;
                }

                *outLen -= paddingSize;
            }

        } while (false);

        if (ctx) {
            EVP_CIPHER_CTX_free(ctx);
        }

        return isSuccess;
    }

    bool DecryptFile(
        const std::wstring& wstrSrcFilePath,
        const std::wstring& wstrDstFilePath,
        const DecryptParam& param
    ) {
        bool isSuccess = false;

        EVP_CIPHER_CTX* ctx = nullptr;

        do {
            if (GetFileAttributesW(wstrSrcFilePath.c_str()) == -1) {
                break;
            }

            DeleteFileW(wstrDstFilePath.c_str());

            ctx = InitCipherCtx(param);
            if (!ctx) {
                break;
            }

            FILE* fpIn = nullptr;
            FILE* fpOut = nullptr;

            _wfopen_s(&fpIn, wstrSrcFilePath.c_str(), L"rb");
            _wfopen_s(&fpOut, wstrDstFilePath.c_str(), L"wb");

            if (fpIn && fpOut) {
                const int pageSize = 4096;
                int inlen = pageSize;
                int outlen = pageSize + EVP_MAX_BLOCK_LENGTH;
                int readSize = 0;
                int paddingSize = 0;
                int tmpOutLen = 0;

                unsigned char* inbuf = new unsigned char[inlen];
                unsigned char* outbuf = new unsigned char[outlen];
                if (inbuf && outbuf) {
                    unsigned char tag[16];
                    memset(tag, 0, sizeof(tag));

                    unsigned char aad[16];
                    memset(aad, 0, sizeof(aad));

                    long long fileSize = 0;

                    do {
                        if (_fseeki64(fpIn, 0, SEEK_END) != 0) {
                            break;
                        }

                        fileSize = _ftelli64(fpIn);
                        if (fileSize <= 16) {
                            break;
                        }

                        if (_fseeki64(fpIn, fileSize - 16, SEEK_SET) != 0) {
                            break;
                        }

                        // 尾部16字节为tag, GCM模式时使用
                        readSize = (int)fread(tag, 1, sizeof(tag), fpIn);

                        if (_fseeki64(fpIn, 0, SEEK_SET) != 0) {
                            break;
                        }

                    } while (false);

                    fileSize -= 16;
                    long long count = (fileSize / pageSize) + (fileSize % pageSize ? 1 : 0);
                    for (long long index = 0; index < count; ++index) {
                        memset(inbuf, 0, sizeof(inbuf));
                        memset(outbuf, 0, sizeof(outbuf));

                        if (param.aesAlgorithm == AesAlgorithm::AES_128_GCM
                            || param.aesAlgorithm == AesAlgorithm::AES_192_GCM
                            || param.aesAlgorithm == AesAlgorithm::AES_256_GCM) {
                            if (index == 0) {
                                inlen = pageSize;/* - 16;
                                readSize = fread(aad, 1, sizeof(aad), in);*/
                            } else if ((index + 1) == count) {
                                inlen = pageSize - 16;
                            } else {
                                inlen = pageSize;
                            }

                            readSize = (int)fread(inbuf, 1, inlen, fpIn);
                            if (readSize <= 0) {
                                break;
                            }

                            /* Zero or more calls to specify any AAD */
                            //EVP_DecryptUpdate(ctx, NULL, &outlen, nullptr, 0);

                            tmpOutLen = 0;
                            if (!EVP_CipherUpdate(ctx, outbuf, &tmpOutLen, inbuf, readSize)) {
                                /* Error */
                                break;
                            }

                            outlen += tmpOutLen;

                            //EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, sizeof(tag), tag);

                            if (!EVP_CipherFinal_ex(ctx, outbuf + tmpOutLen, &tmpOutLen)) {
                                /* Error */
                                //break;
                            }

                            outlen += tmpOutLen;

                            fwrite(outbuf, 1, outlen, fpOut);

                        } else {
                            inlen = pageSize;

                            readSize = (int)fread(inbuf, 1, inlen, fpIn);
                            if (readSize <= 0) {
                                break;
                            }

                            tmpOutLen = 0;

                            if (!EVP_CipherUpdate(ctx, outbuf, &tmpOutLen, inbuf, readSize)) {
                                /* Error */
                                break;
                            }

                            outlen += tmpOutLen;

                            if (!EVP_CipherFinal_ex(ctx, outbuf + tmpOutLen, &tmpOutLen)) {
                                /* Error */
                                break;
                            }

                            outlen += tmpOutLen;

                            if ((index + 1) == count) {
                                // 不填充模式下去除最后填充的字节
                                if (param.paddingMode == PaddingMode::NONE) {
                                    paddingSize = outbuf[readSize - 1];
                                    if (paddingSize > 0 && paddingSize <= AES_BLOCK_SIZE) {
                                        for (int i = 0; i < paddingSize; ++i) {
                                            if (outbuf[readSize - i - 1] != paddingSize) {
                                                paddingSize = 0;
                                                break;
                                            }
                                        }
                                    } else {
                                        paddingSize = 0;
                                    }

                                    outlen -= paddingSize;
                                }
                            }

                            fwrite(outbuf, 1, outlen, fpOut);
                        }

                        isSuccess = true;
                    }
                }

                if (inbuf) {
                    delete[] inbuf;
                }

                if (outbuf) {
                    delete[] outbuf;
                }
            }

            if (fpIn) {
                fclose(fpIn);
                fpIn = nullptr;
            }

            if (fpOut) {
                fclose(fpOut);
                fpOut = nullptr;
            }

        } while (false);

        if (ctx) {
            EVP_CIPHER_CTX_free(ctx);
        }

        return isSuccess;
    }

    bool DecryptSqlcipherDb(
        const std::wstring& wstrSrcFilePath,
        const std::wstring& wstrDstFilePath,
        const char* key,
        int keySize,
        int pageSize,
        int kdfIter,
        DigestAlgorithm digestAlgorithm
    ) {
        bool isSuccess = false;
        EVP_CIPHER_CTX* ctx = nullptr;
        unsigned char* realKey = nullptr;

        do {
            const EVP_CIPHER* cipher = EVP_aes_256_cbc();
            if (!cipher) {
                break;
            }

            ctx = EVP_CIPHER_CTX_new();
            if (!ctx) {
                break;
            }

            if (!EVP_CipherInit_ex(ctx, cipher, nullptr, nullptr, nullptr, 0)) {
                break;
            }

            EVP_CIPHER_CTX_set_padding(ctx, 0);

            realKey = new unsigned char[keySize]();
            if (!realKey) {
                break;
            }

            // 每页最后必须有iv(16字节)和sha1(20字节)，且必须对齐到16的倍数
            // 每页最后48字节组成
            // |16|    20    |  12   |
            // |iv|sha1校验值|填充字节|
            int reserveSize = AES_BLOCK_SIZE + GetDigestAlgorithmSize(digestAlgorithm)/*hmac-sha1*/;

            // 对齐到16的倍数
            reserveSize = ((reserveSize % AES_BLOCK_SIZE) == 0) ? reserveSize :
                ((reserveSize / AES_BLOCK_SIZE) + 1) * AES_BLOCK_SIZE;

            FILE* fpIn = nullptr;
            FILE* fpOut = nullptr;

            _wfopen_s(&fpIn, wstrSrcFilePath.c_str(), L"rb");
            _wfopen_s(&fpOut, wstrDstFilePath.c_str(), L"wb");

            if (fpIn && fpOut) {
                int inLen = 0;
                int outLen = 0;
                unsigned char iv[AES_BLOCK_SIZE] = { 0 };
                unsigned char salt[AES_BLOCK_SIZE] = { 0 };

                unsigned char* inBuf = new unsigned char[pageSize];
                unsigned char* outBuf = new unsigned char[pageSize];
                if (inBuf && outBuf) {
                    for (long long i = 0; ; ++i) {
                        memset(inBuf, 0, pageSize);
                        memset(outBuf, 0, pageSize);

                        inLen = (int)fread(inBuf, 1, pageSize, fpIn);
                        if (inLen <= 0) {
                            break;
                        }

                        int offset = 0;

                        if (0 == i) {
                            offset = 16;

                            // salt是文件的前16字节
                            memcpy(salt, inBuf, sizeof(salt));
                            PKCS5_PBKDF2_HMAC(key, keySize, salt, sizeof(salt), kdfIter, GetDigestCipherFromDigestType(digestAlgorithm), keySize, realKey);

                            memcpy(outBuf, "SQLite format 3", 16);
                        }

                        // 每页最后保留字节的前16字节是iv
                        memset(iv, 0, sizeof(iv));
                        memcpy(iv, inBuf + pageSize - reserveSize, sizeof(iv));

                        if (!EVP_CipherInit_ex(ctx, nullptr, nullptr, realKey, iv, 0)) {
                            break;
                        }

                        if (!EVP_CipherUpdate(ctx, outBuf + offset, &outLen, inBuf + offset, inLen - reserveSize - offset)) {
                            /* Error */
                            break;
                        }

                        if (!EVP_CipherFinal_ex(ctx, outBuf + offset + outLen, &outLen)) {
                            /* Error */
                            break;
                        }

                        // 每页最后保留字节直接写入解密数据库
                        memcpy(outBuf + pageSize - reserveSize, inBuf + pageSize - reserveSize, reserveSize);

                        fwrite(outBuf, 1, inLen, fpOut);
                    }
                }

                if (inBuf) {
                    delete[] inBuf;
                }

                if (outBuf) {
                    delete[] outBuf;
                }
            }

            if (fpIn) {
                fclose(fpIn);
                fpIn = nullptr;
            }

            if (fpOut) {
                fclose(fpOut);
                fpOut = nullptr;
            }

        } while (false);

        if (ctx) {
            EVP_CIPHER_CTX_free(ctx);
        }

        if (realKey) {
            delete[] realKey;
        }

        isSuccess = IsSqliteDb(wstrDstFilePath);
        return isSuccess;
    }

    bool DecryptSqlcipherDbWalFile(
        const std::wstring& wstrSrcFilePath,
        const std::wstring& wstrDstFilePath,
        const char* key,
        int keySize,
        int pageSize,
        int kdfIter,
        DigestAlgorithm digestAlgorithm
    ) {
        bool isSuccess = false;
        EVP_CIPHER_CTX* ctx = nullptr;
        unsigned char* realKey = nullptr;

        do {
            const EVP_CIPHER* cipher = EVP_aes_256_cbc();
            if (!cipher) {
                break;
            }

            ctx = EVP_CIPHER_CTX_new();
            if (!ctx) {
                break;
            }

            if (!EVP_CipherInit_ex(ctx, cipher, nullptr, nullptr, nullptr, 0)) {
                break;
            }

            EVP_CIPHER_CTX_set_padding(ctx, 0);

            realKey = new unsigned char[keySize]();
            if (!realKey) {
                break;
            }

            // 每页最后16字节为iv
            int reserveSize = 16;

            FILE* fpIn = nullptr;
            FILE* fpOut = nullptr;

            _wfopen_s(&fpIn, wstrSrcFilePath.c_str(), L"rb");
            _wfopen_s(&fpOut, wstrDstFilePath.c_str(), L"wb");

            if (fpIn && fpOut) {
                unsigned char* inBuf = new unsigned char[pageSize];
                unsigned char* outBuf = new unsigned char[pageSize];
                if (inBuf && outBuf) {
                    int inLen = 0;
                    int outLen = 0;
                    unsigned char iv[AES_BLOCK_SIZE] = { 0 };
                    unsigned char salt[AES_BLOCK_SIZE] = { 0 };

                    /*
                    wal文件格式
                    |    32    |     24     |page   size|     24     |page   size|
                    |wal header|frame header|page1  data|frame header|page2  data|
                    */
                    unsigned char walHead[32];
                    unsigned char frameHead[24];

                    // 读取wal头部
                    memset(walHead, 0, sizeof(walHead));
                    fread(walHead, 1, sizeof(walHead), fpIn);

                    // 写入wal头部至解密后文件
                    fwrite(walHead, 1, sizeof(walHead), fpOut);

                    for (long long i = 0; ; ++i) {
                        // 读取24字节帧头部
                        memset(frameHead, 0, sizeof(frameHead));
                        fread(frameHead, 1, sizeof(frameHead), fpIn);

                        // 写入帧头部至解密后文件
                        fwrite(frameHead, 1, sizeof(frameHead), fpOut);

                        memset(inBuf, 0, sizeof(pageSize));
                        memset(outBuf, 0, sizeof(pageSize));

                        inLen = (int)fread(inBuf, 1, pageSize, fpIn);
                        if (inLen <= 0) {
                            break;
                        }

                        int offset = 0;

                        if (0 == i) {
                            offset = 16;

                            // salt是文件的前16字节
                            memcpy(salt, inBuf, sizeof(salt));
                            PKCS5_PBKDF2_HMAC(key, keySize, salt, sizeof(salt), kdfIter, GetDigestCipherFromDigestType(digestAlgorithm), keySize, realKey);
                        }

                        // 每页最后保留字节的前16字节是iv
                        memset(iv, 0, sizeof(iv));
                        memcpy(iv, inBuf + pageSize - reserveSize, sizeof(iv));

                        if (!EVP_CipherInit_ex(ctx, nullptr, nullptr, realKey, iv, 0)) {
                            break;
                        }

                        if (!EVP_CipherUpdate(ctx, outBuf + offset, &outLen, inBuf + offset, inLen - reserveSize - offset)) {
                            /* Error */
                            break;
                        }

                        if (!EVP_CipherFinal_ex(ctx, outBuf + offset + outLen, &outLen)) {
                            /* Error */
                            break;
                        }

                        isSuccess = true;

                        // 每页最后保留字节直接写入解密数据库
                        memcpy(outBuf + pageSize - reserveSize, inBuf + pageSize - reserveSize, reserveSize);

                        fwrite(outBuf, 1, inLen, fpOut);
                    }
                }

                if (inBuf) {
                    delete[] inBuf;
                }

                if (outBuf) {
                    delete[] outBuf;
                }
            }

            if (fpIn) {
                fclose(fpIn);
                fpIn = nullptr;
            }

            if (fpOut) {
                fclose(fpOut);
                fpOut = nullptr;
            }

        } while (false);

        if (ctx) {
            EVP_CIPHER_CTX_free(ctx);
        }

        if (realKey) {
            delete[] realKey;
        }

        return isSuccess;
    }

    bool IsSqliteDb(
        const std::wstring& wstrDbFile
    ) {
        bool yes = false;
        if (PathFileExistsW(wstrDbFile.c_str())) {
            sqlite3* db = nullptr;
            int ret = sqlite3_open16(wstrDbFile.c_str(), &db);
            if (ret == SQLITE_OK) {
                sqlite3_stmt* stmt = nullptr;
                ret = sqlite3_prepare(db, "select * from sqlite_master;", -1, &stmt, nullptr);
                if (ret == SQLITE_OK) {
                    while ((ret = sqlite3_step(stmt)) == SQLITE_ROW) {
                        yes = true;
                        break;
                    }
                    sqlite3_finalize(stmt);
                }

                sqlite3_close(db);
            }
        }

        return yes;
    }

    void SqliteMergeWalFile(
        const std::wstring& wstrDbFile
    ) {
        sqlite3* dbHandler = nullptr;
        int ret = sqlite3_open16(wstrDbFile.c_str(), &dbHandler);
        if (ret == SQLITE_OK) {
            sqlite3_stmt* stmt = nullptr;
            ret = sqlite3_exec(dbHandler, "select * from sqlite_master;", nullptr, nullptr, nullptr);
            sqlite3_close(dbHandler);
        }
    }

}