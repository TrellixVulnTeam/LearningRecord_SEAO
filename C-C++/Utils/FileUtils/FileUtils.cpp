#include "pch.h"
#include <io.h>
#include <algorithm>
#include "FileUtils.h"

namespace FileUtils {

    static std::wstring GetFormatFilePath(const std::wstring& wstrFilePath) {
        std::wstring wstrFormatFilePath = wstrFilePath;

        if (wstrFormatFilePath.find(LR"(\\?\)") == 0) {
            wstrFormatFilePath.erase(0, 4);
        }

        // 移除连续 \ eg. E:\\1
        wstrFormatFilePath.erase(std::unique(wstrFormatFilePath.begin(), wstrFormatFilePath.end(), [](const auto& lhs, const auto& rhs)->bool {
            return lhs == rhs && lhs == L'\\';
            }), wstrFormatFilePath.end());

        // 拼接路径前缀
        wstrFormatFilePath = LR"(\\?\)" + wstrFormatFilePath;

        return wstrFormatFilePath;
    }

    void CreateDir(
        const std::wstring& wstrDirPath,
        const int* stopFlag
    ) {
        do {
            if (wstrDirPath.empty()) {
                break;
            }

            std::wstring wstrTmpDirPath = GetFormatFilePath(wstrDirPath);

            if (PathIsExist(wstrTmpDirPath)) {
                break;
            }

            // 文件路径长度必须>=8 如：\\?\C:\1 
            if (wstrTmpDirPath.size() < 8 || wstrTmpDirPath[5] != L':') {
                break;
            }

            BOOL ret = FALSE;
            DWORD errCode = 0;

            std::wstring::size_type pos = wstrTmpDirPath.find(L'\\', 4);
            while (std::wstring::npos != pos) {
                if (stopFlag && *stopFlag != 0) {
                    break;
                }

                std::wstring wstrSubDirPath = wstrTmpDirPath.substr(0, pos);
                ret = CreateDirectoryW(wstrSubDirPath.c_str(), NULL);
                if (!ret) {
                    errCode = GetLastError();
                }

                pos = wstrTmpDirPath.find(L'\\', pos + 1);
            }

            ret = CreateDirectoryW(wstrTmpDirPath.c_str(), NULL);
            if (!ret) {
                errCode = GetLastError();
            }
        } while (false);
    }

    void MoveDirEx(
        const std::wstring& wstrSrcDirPath,
        const std::wstring& wstrDstDirPath,
        const int* stopFlag
    ) {
        do {
            BOOL ret = FALSE;
            DWORD errCode = 0;
            std::wstring wstrTmpSrcDirPath, wstrTmpDstDirPath;
            std::wstring wstrFileName;
            std::wstring wstrFindStr = wstrSrcDirPath + L"*.*";
            HANDLE fileHandle = INVALID_HANDLE_VALUE;
            WIN32_FIND_DATAW findFileData;
            memset(&findFileData, 0, sizeof(WIN32_FIND_DATAW));

            do {
                fileHandle = ::FindFirstFileW(wstrFindStr.c_str(), &findFileData);
                if (INVALID_HANDLE_VALUE == fileHandle) {
                    break;
                }

                if (!PathIsExist(wstrDstDirPath)) {
                    CreateDir(wstrDstDirPath, stopFlag);

                    if (!PathIsExist(wstrDstDirPath)) {
                        break;
                    }
                }

                do {
                    if (stopFlag && *stopFlag != 0) {
                        break;
                    }

                    wstrFileName = findFileData.cFileName;
                    if (L"." == wstrFileName || L".." == wstrFileName) {
                        continue;
                    }

                    wstrTmpSrcDirPath = wstrSrcDirPath + wstrFileName;
                    wstrTmpDstDirPath = wstrDstDirPath + wstrFileName;

                    if ((findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                        wstrTmpSrcDirPath.append(L"\\");
                        wstrTmpDstDirPath.append(L"\\");
                        MoveDirEx(wstrTmpSrcDirPath, wstrTmpDstDirPath, stopFlag);
                    } else {
                        ret = DeleteFileW(wstrTmpDstDirPath.c_str());
                        if (!ret) {
                            errCode = GetLastError();
                        }

                        ret = MoveFileW(wstrTmpSrcDirPath.c_str(), wstrTmpDstDirPath.c_str());
                        if (!ret) {
                            errCode = GetLastError();
                        }
                    }

                } while (FindNextFileW(fileHandle, &findFileData));

                FindClose(fileHandle);
                fileHandle = INVALID_HANDLE_VALUE;

            } while (false);

            if (INVALID_HANDLE_VALUE != fileHandle) {
                FindClose(fileHandle);
            }

            ret = RemoveDirectoryW(wstrSrcDirPath.c_str());
            if (!ret) {
                errCode = GetLastError();
            }
        } while (false);
    }

    void MoveDir(
        const std::wstring& wstrSrcDirPath,
        const std::wstring& wstrDstDirPath,
        const int* stopFlag
    ) {
        do {
            if (wstrSrcDirPath.empty()
                || wstrDstDirPath.empty()) {
                break;
            }

            std::wstring wstrTmpSrcDirPath = GetFormatFilePath(wstrSrcDirPath);

            if (L'\\' != wstrTmpSrcDirPath.back()) {
                wstrTmpSrcDirPath.append(L"\\");
            }

            if (!PathIsExist(wstrTmpSrcDirPath)) {
                break;
            }

            // 文件路径长度必须>=9 如：\\?\C:\1\ 
            if (wstrTmpSrcDirPath.size() < 9 || wstrTmpSrcDirPath[5] != L':') {
                break;
            }

            std::wstring wstrTmpDstDirPath = GetFormatFilePath(wstrDstDirPath);

            if (L'\\' != wstrTmpDstDirPath.back()) {
                wstrTmpDstDirPath.append(L"\\");
            }

            // 文件路径长度必须>=7 如：\\?\C:\ 
            if (wstrTmpDstDirPath.size() < 7 || wstrTmpDstDirPath[5] != L':') {
                break;
            }

            // MoveFile支持同分区移动文件夹，跨分区时会失败
            if (MoveFileW(wstrTmpSrcDirPath.c_str(), wstrTmpDstDirPath.c_str())) {
                break;
            }

            MoveDirEx(wstrTmpSrcDirPath, wstrTmpDstDirPath, stopFlag);

        } while (false);
    }

    void CopyDirEx(
        const std::wstring& wstrSrcDirPath,
        const std::wstring& wstrDstDirPath,
        const int* stopFlag
    ) {
        do {
            BOOL ret = FALSE;
            DWORD errCode = 0;
            std::wstring wstrTmpSrcDirPath, wstrTmpDstDirPath;
            std::wstring wstrFileName;
            std::wstring wstrFindStr = wstrSrcDirPath + L"*.*";
            HANDLE fileHandle = INVALID_HANDLE_VALUE;
            WIN32_FIND_DATAW findFileData;
            memset(&findFileData, 0, sizeof(WIN32_FIND_DATAW));

            do {
                fileHandle = ::FindFirstFileW(wstrFindStr.c_str(), &findFileData);
                if (INVALID_HANDLE_VALUE == fileHandle) {
                    break;
                }

                if (!PathIsExist(wstrDstDirPath.c_str())) {
                    CreateDir(wstrDstDirPath, stopFlag);

                    if (!PathIsExist(wstrDstDirPath.c_str())) {
                        break;
                    }
                }

                do {
                    if (stopFlag && *stopFlag != 0) {
                        break;
                    }

                    wstrFileName = findFileData.cFileName;
                    if (L"." == wstrFileName || L".." == wstrFileName) {
                        continue;
                    }

                    wstrTmpSrcDirPath = wstrSrcDirPath + wstrFileName;
                    wstrTmpDstDirPath = wstrDstDirPath + wstrFileName;

                    if ((findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                        wstrTmpSrcDirPath.append(L"\\");
                        wstrTmpDstDirPath.append(L"\\");
                        CopyDirEx(wstrTmpSrcDirPath, wstrTmpDstDirPath, stopFlag);
                    } else {
                        ret = CopyFileW(wstrTmpSrcDirPath.c_str(), wstrTmpDstDirPath.c_str(), FALSE);
                        if (!ret) {
                            errCode = GetLastError();
                        }
                    }

                } while (FindNextFileW(fileHandle, &findFileData));

            } while (false);

            if (INVALID_HANDLE_VALUE != fileHandle) {
                FindClose(fileHandle);
            }
        } while (false);
    }

    void CopyDir(
        const std::wstring& wstrSrcDirPath,
        const std::wstring& wstrDstDirPath,
        const int* stopFlag
    ) {
        do {
            if (wstrSrcDirPath.empty()
                || wstrDstDirPath.empty()) {
                break;
            }

            std::wstring wstrTmpSrcDirPath = GetFormatFilePath(wstrSrcDirPath);

            if (L'\\' != wstrTmpSrcDirPath.back()) {
                wstrTmpSrcDirPath.append(L"\\");
            }

            if (!PathIsExist(wstrTmpSrcDirPath)) {
                break;
            }

            // 文件路径长度必须>=9 如：\\?\C:\1\ 
            if (wstrTmpSrcDirPath.size() < 9 || wstrTmpSrcDirPath[5] != L':') {
                break;
            }

            std::wstring wstrTmpDstDirPath = GetFormatFilePath(wstrDstDirPath);

            if (L'\\' != wstrTmpDstDirPath.back()) {
                wstrTmpDstDirPath.append(L"\\");
            }

            // 文件路径长度必须>=7 如：\\?\C:\ 
            if (wstrTmpDstDirPath.size() < 7 || wstrTmpDstDirPath[5] != L':') {
                break;
            }

            CopyDirEx(wstrTmpSrcDirPath, wstrTmpDstDirPath, stopFlag);

        } while (false);
    }

    void DeleteDirEx(
        const std::wstring& wstrDirPath,
        const int* stopFlag
    ) {
        do {
            BOOL ret = FALSE;
            DWORD errCode = 0;
            std::wstring wstrFileName;
            std::wstring wstrTmpDirPath;
            std::wstring wstrFindStr = wstrDirPath + L"*.*";
            WIN32_FIND_DATAW findFileData;
            memset(&findFileData, 0, sizeof(WIN32_FIND_DATAW));

            HANDLE fileHandle = ::FindFirstFileW(wstrFindStr.c_str(), &findFileData);
            if (INVALID_HANDLE_VALUE != fileHandle) {
                do {
                    if (stopFlag && *stopFlag != 0) {
                        break;
                    }

                    wstrFileName = findFileData.cFileName;
                    if (L"." == wstrFileName || L".." == wstrFileName) {
                        continue;
                    }

                    wstrTmpDirPath = wstrDirPath + wstrFileName;

                    if (findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                        wstrTmpDirPath.append(L"\\");
                        DeleteDirEx(wstrTmpDirPath, stopFlag);
                    } else {
                        int iTimes = 3;
                        do {
                            if (DeleteFileW(wstrTmpDirPath.c_str())) {
                                break;
                            }
                            // 文件被另一个进程占用
                            if (ERROR_SHARING_VIOLATION == GetLastError()) {
                                Sleep(200);
                                iTimes--;
                            } else if (ERROR_ACCESS_DENIED == GetLastError()) {
                                //只读文件属性修改
                                if (!SetFileAttributesW(wstrTmpDirPath.c_str(), FILE_ATTRIBUTE_NORMAL)) {
                                    break;
                                }
                                Sleep(200);
                                iTimes--;
                            } else {
                                break;
                            }
                        } while (iTimes > 0);
                    }

                } while (FindNextFileW(fileHandle, &findFileData));

                FindClose(fileHandle);
            }

            ret = RemoveDirectoryW(wstrDirPath.c_str());
            if (!ret) {
                errCode = GetLastError();
            }
        } while (false);
    }

    void DeleteDir(
        const std::wstring& wstrDirPath,
        const int* stopFlag
    ) {
        do {
            if (wstrDirPath.empty()) {
                break;
            }

            std::wstring wstrTmpDirPath = GetFormatFilePath(wstrDirPath);

            if (L'\\' != wstrTmpDirPath.back()) {
                wstrTmpDirPath.append(L"\\");
            }

            if (!PathIsExist(wstrTmpDirPath)) {
                break;
            }

            // 文件路径长度必须>=9 如：\\?\C:\1\ 
            if (wstrTmpDirPath.size() < 9 || wstrTmpDirPath[5] != L':') {
                break;
            }

            DeleteDirEx(wstrTmpDirPath, stopFlag);

        } while (false);
    }

    bool PathIsExist(
        const std::wstring& wstrPath
    ) {
        DWORD dwResult = GetFileAttributesW(wstrPath.c_str());
        if (dwResult == -1) {
            return false;
        }

        if (INVALID_FILE_ATTRIBUTES == dwResult
            && ERROR_FILE_NOT_FOUND == GetLastError()) {
            return false;
        }

        return true;
    }

    void GetPathDataSizeEx(
        const std::wstring& wstrPath,
        unsigned long long& dataSize,
        const int* stopFlag
    ) {
        do {
            std::wstring wstrFileName;
            std::wstring wstrTmpPath;
            std::wstring wstrFindStr = wstrPath + L"*.*";
            WIN32_FIND_DATAW findFileData;
            memset(&findFileData, 0, sizeof(WIN32_FIND_DATAW));

            HANDLE fileHandle = ::FindFirstFileW(wstrFindStr.c_str(), &findFileData);
            if (INVALID_HANDLE_VALUE != fileHandle) {
                do {
                    if (stopFlag && *stopFlag != 0) {
                        break;
                    }

                    wstrFileName = findFileData.cFileName;
                    if (L"." == wstrFileName || L".." == wstrFileName) {
                        continue;
                    }

                    wstrTmpPath = wstrPath + wstrFileName;

                    if (findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                        wstrTmpPath.append(L"\\");
                        GetPathDataSizeEx(wstrTmpPath, dataSize, stopFlag);
                    } else {
                        unsigned long long tmpDataSize = findFileData.nFileSizeHigh;
                        tmpDataSize <<= 32;
                        tmpDataSize |= findFileData.nFileSizeLow;
                        dataSize += tmpDataSize;
                    }

                } while (FindNextFileW(fileHandle, &findFileData));

                FindClose(fileHandle);
            }
        } while (false);
    }

    unsigned long long GetPathDataSize(
        const std::wstring& wstrPath,
        const int* stopFlag
    ) {
        unsigned long long dataSize = 0;

        do {
            if (wstrPath.empty()) {
                break;
            }

            std::wstring wstrTmpPath = GetFormatFilePath(wstrPath);

            if (!PathIsExist(wstrTmpPath)) {
                break;
            }

            // 文件路径长度必须>=8 如：\\?\C:\1 
            if (wstrTmpPath.size() < 8 || wstrTmpPath[5] != L':') {
                break;
            }

            WIN32_FILE_ATTRIBUTE_DATA fileInfo;
            memset(&fileInfo, 0, sizeof(WIN32_FILE_ATTRIBUTE_DATA));
            if (GetFileAttributesEx(wstrTmpPath.c_str(), GetFileExInfoStandard, &fileInfo)) {
                if (fileInfo.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                    if (L'\\' != wstrTmpPath.back()) {
                        wstrTmpPath.append(L"\\");
                    }

                    GetPathDataSizeEx(wstrTmpPath, dataSize, stopFlag);
                } else {
                    dataSize = fileInfo.nFileSizeHigh;
                    dataSize <<= 32;
                    dataSize |= fileInfo.nFileSizeLow;
                }
            }

        } while (false);

        return dataSize;
    }

    std::list<std::wstring> DirEntryList(
        const std::wstring& wstrDirPath,
        const std::wstring& wstrFilter,
        Filter filter
    ) {
        std::list<std::wstring> entryList;

        do {
            if (wstrDirPath.empty()) {
                break;
            }

            std::wstring wstrTmpDirPath = GetFormatFilePath(wstrDirPath);

            if (wstrTmpDirPath.back() != L'\\') {
                wstrTmpDirPath.append(L"\\");
            }

            // 文件路径长度必须>=9 如：\\?\C:\1\ 
            if (wstrTmpDirPath.size() < 9 || wstrTmpDirPath[5] != L':') {
                break;
            }

            std::wstring wstrFindStr = wstrTmpDirPath + wstrFilter;
            std::wstring wstrFileName;
            WIN32_FIND_DATAW findFileData;
            memset(&findFileData, 0, sizeof(WIN32_FIND_DATAW));

            HANDLE fileHandle = FindFirstFileW(wstrFindStr.c_str(), &findFileData);
            if (INVALID_HANDLE_VALUE != fileHandle) {
                do {
                    wstrFileName = findFileData.cFileName;

                    if (L"." == wstrFileName || L".." == wstrFileName) {
                        continue;
                    }

                    if (findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                        if (filter & Filter::DIR) {
                            entryList.push_back(std::move(wstrFileName));
                        }
                    } else {
                        if (filter & Filter::FILE) {
                            entryList.push_back(std::move(wstrFileName));
                        }
                    }

                } while (FindNextFileW(fileHandle, &findFileData));

                FindClose(fileHandle);
                fileHandle = INVALID_HANDLE_VALUE;
            }
        } while (false);

        return entryList;
    }

    std::list<WIN32_FIND_DATAW> DirEntryInfoList(
        const std::wstring& wstrDirPath,
        const std::wstring& wstrFilter,
        Filter filter
    ) {
        std::list<WIN32_FIND_DATAW> entryInfoList;

        do {
            if (wstrDirPath.empty()) {
                break;
            }

            std::wstring wstrTmpDirPath = GetFormatFilePath(wstrDirPath);

            if (wstrTmpDirPath.back() != L'\\') {
                wstrTmpDirPath.append(L"\\");
            }

            // 文件路径长度必须>=9 如：\\?\C:\1\ 
            if (wstrTmpDirPath.size() < 9 || wstrTmpDirPath[5] != L':') {
                break;
            }

            std::wstring wstrFindStr = wstrTmpDirPath + wstrFilter;
            std::wstring wstrFileName;
            WIN32_FIND_DATAW findFileData;
            memset(&findFileData, 0, sizeof(WIN32_FIND_DATAW));

            HANDLE fileHandle = FindFirstFileW(wstrFindStr.c_str(), &findFileData);
            if (INVALID_HANDLE_VALUE != fileHandle) {
                do {
                    wstrFileName = findFileData.cFileName;

                    if (L"." == wstrFileName || L".." == wstrFileName) {
                        continue;
                    }

                    if (findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                        if (filter & Filter::DIR) {
                            entryInfoList.push_back(findFileData);
                        }
                    } else {
                        if (filter & Filter::FILE) {
                            entryInfoList.push_back(findFileData);
                        }
                    }

                } while (FindNextFileW(fileHandle, &findFileData));

                FindClose(fileHandle);
                fileHandle = INVALID_HANDLE_VALUE;
            }
        } while (false);

        return entryInfoList;
    }

    std::wstring GetExeDirPath() {
        wchar_t dirPath[MAX_PATH] = { 0 };

        GetModuleFileNameW(NULL, dirPath, MAX_PATH);
        wchar_t* p = wcsrchr(dirPath, L'\\');
        if (p) {
            *p = L'\0';
        }

        return std::wstring(dirPath);
    }

    char* ReadFileContent(
        const std::wstring& wstrFilePath,
        int* fileSize
    ) {
        FILE* fp = nullptr;
        char* buffer = nullptr;

        do {
            if (fileSize) {
                *fileSize = 0;
            }

            _wfopen_s(&fp, wstrFilePath.c_str(), L"rb");
            if (!fp) {
                break;
            }

            int fileSize_ = 0;
            if (fseek(fp, 0, SEEK_END) != 0) {
                break;
            }

            fileSize_ = ftell(fp);
            if (fileSize) {
                *fileSize = fileSize_;
            }

            if (fseek(fp, 0, SEEK_SET) != 0) {
                break;
            }

            if (fileSize_ <= 0) {
                break;
            }

            buffer = new char[fileSize_ + 1];
            if (!buffer) {
                break;
            }

            buffer[fileSize_] = 0;
            if (fread(buffer, 1, fileSize_, fp) != fileSize_) {
                break;
            }

        } while (false);

        if (fp) {
            fclose(fp);
        }

        return buffer;
    }

    bool SaveContentToFile(
        const std::wstring& wstrFilePath,
        const char* data,
        int dataSize
    ) {
        FILE* fp = nullptr;
        bool isSuccess = false;

        do {
            if (!data || dataSize <= 0) {
                break;
            }

            DeleteFileW(wstrFilePath.c_str());

            _wfopen_s(&fp, wstrFilePath.c_str(), L"wb");
            if (!fp) {
                break;
            }

            int writeSize = fwrite(data, 1, dataSize, fp);
            if (writeSize != dataSize) {
                break;
            }

            int fileID = _fileno(fp);
            _commit(fileID);

            isSuccess = true;

        } while (false);

        if (fp) {
            fclose(fp);
        }

        return isSuccess;
    }

}