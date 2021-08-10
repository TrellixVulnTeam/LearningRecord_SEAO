#pragma once

#ifdef IMAGEUTILS_EXPORTS
    #define IMAGEUTILS_API __declspec(dllexport)
#else
    #define IMAGEUTILS_API __declspec(dllimport)
#endif

#include <string>

namespace ImageUtils {

    /*
    ͼƬ�ļ���ʽת��

    @params     wstrSrcFilePath Դ�ļ�·��
                wstrDstFilePath Ŀ���ļ�·��
                ����Ŀ���ļ���׺������Ŀ���ļ�ͼƬ��ʽ

    @return     bool �ɹ���ʧ��
    */
    IMAGEUTILS_API bool ConvertFile(
        const std::wstring &wstrSrcFilePath,
        const std::wstring &wstrDstFilePath
    );

}