#pragma once

#ifdef FILEUTILS_EXPORTS
    #define FILEUTILS_API __declspec(dllexport)
#else
    #define FILEUTILS_API __declspec(dllimport)
#endif

#include <string>
#include <list>

namespace FileUtils {

    // �ݹ鴴���ļ���
    FILEUTILS_API void CreateDir(
        const std::wstring &wstrDir,
        const int *stopFlag = NULL
    );

    // �ݹ��ƶ��ļ���
    FILEUTILS_API void MoveDir(
        const std::wstring &wstrSrcDir,
        const std::wstring &wstrDstDir,
        const int *stopFlag = NULL
    );

    // �ݹ鸴���ļ���
    FILEUTILS_API void CopyDir(
        const std::wstring &wstrSrcDir,
        const std::wstring &wstrDstDir,
        const int *stopFlag = NULL
    );

    // �ݹ�ɾ���ļ���
    // ��֧��ȫ·��ɾ��
    // eg. E:\1
    // eg. \\?\E:\1
    FILEUTILS_API void DeleteDir(
        const std::wstring &wstrDir,
        const int *stopFlag = NULL
    );

    // �ж��ļ����ļ����Ƿ����
    FILEUTILS_API bool PathIsExist(
        const std::wstring &wstrFile
    );

    // ��ȡ�ļ����µ�һ������
    FILEUTILS_API std::list<std::wstring> DirEntryList(
        const std::wstring &wstrDir,
        const std::wstring &wstrFilter = L"*.*"
    );

}