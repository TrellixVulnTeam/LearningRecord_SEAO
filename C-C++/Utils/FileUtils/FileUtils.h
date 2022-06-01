#pragma once

#ifdef FILEUTILS_EXPORTS
    #define FILEUTILS_API __declspec(dllexport)
#else
    #define FILEUTILS_API __declspec(dllimport)
#endif

#define WIN32_LEAN_AND_MEAN             // 从 Windows 头中排除极少使用的资料
#include <windows.h>
#include <string>
#include <list>

namespace FileUtils {

    // 递归创建文件夹
    FILEUTILS_API void CreateDir(
        const std::wstring& wstrDirPath,
        const int* stopFlag = nullptr
    );

    // 递归移动文件夹
    FILEUTILS_API void MoveDir(
        const std::wstring& wstrSrcDirPath,
        const std::wstring& wstrDstDirPath,
        const int* stopFlag = nullptr
    );

    // 递归复制文件夹
    FILEUTILS_API void CopyDir(
        const std::wstring& wstrSrcDirPath,
        const std::wstring& wstrDstDirPath,
        const int* stopFlag = nullptr
    );

    // 递归删除文件夹
    FILEUTILS_API void DeleteDir(
        const std::wstring& wstrDirPath,
        const int* stopFlag = nullptr
    );

    // 判断文件、文件夹是否存在
    FILEUTILS_API bool PathIsExist(
        const std::wstring &wstrPath
    );

    FILEUTILS_API unsigned long long GetPathDataSize(
        const std::wstring& wstrPath,
        const int* stopFlag = NULL
    );

    enum class Filter {
        DIR = 1,
        FILE = 2,
        ALL = 3
    };

    inline bool operator&(const Filter& lhs, const Filter& rhs) {
        return ((int)lhs & (int)rhs) != 0;
    }

    // 获取文件夹下第一层内容
    FILEUTILS_API std::list<std::wstring> DirEntryList(
        const std::wstring& wstrDirPath,
        const std::wstring& wstrFilter = L"*.*",
        Filter filter = Filter::ALL
    );

    FILEUTILS_API std::list<WIN32_FIND_DATAW> DirEntryInfoList(
        const std::wstring& wstrDirPath,
        const std::wstring& wstrFilter = L"*.*",
        Filter filter = Filter::ALL
    );

    FILEUTILS_API std::wstring GetExeDirPath();

    // 此函数读取文件全部内容, 注意使用场景
    FILEUTILS_API char* ReadFileContent(
        const std::wstring& wstrFilePath,
        int* fileSize = nullptr
    );

    // 保存数据至新文件
    FILEUTILS_API bool SaveContentToFile(
        const std::wstring& wstrFilePath,
        const char* data,
        int dataSize
    );
}