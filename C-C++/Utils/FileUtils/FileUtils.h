#pragma once

#ifdef FILEUTILS_EXPORTS
    #define FILEUTILS_API __declspec(dllexport)
#else
    #define FILEUTILS_API __declspec(dllimport)
#endif

#include <string>
#include <list>

namespace FileUtils {

    // 递归创建文件夹
    FILEUTILS_API void CreateDir(
        const std::wstring &wstrDir,
        const int *stopFlag = NULL
    );

    // 递归移动文件夹
    FILEUTILS_API void MoveDir(
        const std::wstring &wstrSrcDir,
        const std::wstring &wstrDstDir,
        const int *stopFlag = NULL
    );

    // 递归复制文件夹
    FILEUTILS_API void CopyDir(
        const std::wstring &wstrSrcDir,
        const std::wstring &wstrDstDir,
        const int *stopFlag = NULL
    );

    // 递归删除文件夹
    // 仅支持全路径删除
    // eg. E:\1
    // eg. \\?\E:\1
    FILEUTILS_API void DeleteDir(
        const std::wstring &wstrDir,
        const int *stopFlag = NULL
    );

    // 判断文件、文件夹是否存在
    FILEUTILS_API bool PathIsExist(
        const std::wstring &wstrFile
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
        const std::wstring& wstrDir,
        const std::wstring& wstrFilter = L"*.*",
        Filter filter = Filter::ALL
    );

    FILEUTILS_API std::list<WIN32_FIND_DATAW> DirEntryInfoList(
        const std::wstring& wstrDir,
        const std::wstring& wstrFilter = L"*.*",
        Filter filter = Filter::ALL
    );

}