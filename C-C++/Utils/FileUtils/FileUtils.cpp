#define WIN32_LEAN_AND_MEAN             // 从 Windows 头中排除极少使用的资料
#include <windows.h>
#include <io.h>
#include "FileUtils.h"

namespace FileUtils {

    void CreateDir(
        const std::wstring &wstrDir,
        const int *stopFlag
    ) {
        if (wstrDir.empty()) {
            return;
        }

        std::wstring wstrTmpDir = wstrDir;
        for (std::wstring::iterator iter = wstrTmpDir.begin();
            iter != wstrTmpDir.end();
            ++iter) {
            if (L'/' == *iter) {
                *iter = L'\\';
            }
        }

        BOOL bRet = FALSE;
        DWORD dwError = 0;

        size_t pos = wstrTmpDir.find(L'\\');
        while (std::wstring::npos != pos) {
            if (stopFlag && *stopFlag != 0) {
                break;
            }

            std::wstring subStr = wstrTmpDir.substr(0, pos);
            bRet = CreateDirectoryW(subStr.c_str(), NULL);
            if (!bRet) {
                dwError = GetLastError();
            }

            pos = wstrTmpDir.find(L'\\', pos + 1);
        }

        bRet = CreateDirectoryW(wstrTmpDir.c_str(), NULL);
        if (!bRet) {
            dwError = GetLastError();
        }

        return;
    }

    void MoveDir(
        const std::wstring &wstrSrcDir,
        const std::wstring &wstrDstDir,
        const int *stopFlag
    ) {
        // MoveFile支持同分区移动文件夹，跨分区时会失败
        if (MoveFileW(wstrSrcDir.c_str(), wstrDstDir.c_str())) {
            return;
        }

        if (wstrSrcDir.empty() || wstrDstDir.empty()) {
            return;
        }

        WIN32_FIND_DATAW findFileData = { 0 };
        std::wstring wstrFindStr(wstrSrcDir);
        std::wstring wstrRealSrcDir(wstrSrcDir);
        std::wstring wstrRealDstDir(wstrDstDir);

        if (L'\\' != *wstrRealSrcDir.rbegin()) {
            wstrRealSrcDir.append(L"\\");
            wstrFindStr.append(L"\\");
        }

        if (L'\\' != *wstrRealDstDir.rbegin()) {
            wstrRealDstDir.append(L"\\");
        }

        wstrFindStr.append(L"*.*");

        BOOL bRet = FALSE;
        DWORD dwError = 0;
        std::wstring wstrSrcDir2;
        std::wstring wstrDstDir2;
        std::wstring wstrFileName;
        HANDLE fileHandle = INVALID_HANDLE_VALUE;

        do {
            fileHandle = ::FindFirstFileW(wstrFindStr.c_str(), &findFileData);
            if (INVALID_HANDLE_VALUE == fileHandle) {
                break;
            }

            if (!PathIsExist(wstrDstDir)) {
                CreateDir(wstrDstDir, stopFlag);

                if (!PathIsExist(wstrDstDir.c_str())) {
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

                wstrSrcDir2 = wstrRealSrcDir + wstrFileName;
                wstrDstDir2 = wstrRealDstDir + wstrFileName;

                if ((findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                    MoveDir(wstrSrcDir2, wstrDstDir2, stopFlag);
                }
                else {
                    bRet = DeleteFileW(wstrDstDir2.c_str());
                    if (!bRet) {
                        dwError = GetLastError();
                    }

                    bRet = MoveFileW(wstrSrcDir2.c_str(), wstrDstDir2.c_str());
                    if (!bRet) {
                        dwError = GetLastError();
                    }
                }

            } while (FindNextFileW(fileHandle, &findFileData));

            FindClose(fileHandle);
            fileHandle = INVALID_HANDLE_VALUE;

        } while (false);

        if (INVALID_HANDLE_VALUE != fileHandle) {
            FindClose(fileHandle);
        }

        bRet = RemoveDirectoryW(wstrSrcDir.c_str());
        if (!bRet) {
            dwError = GetLastError();
        }

        return;
    }

    void CopyDir(
        const std::wstring &wstrSrcDir,
        const std::wstring &wstrDstDir,
        const int *stopFlag
    ) {
        if (wstrSrcDir.empty() || wstrDstDir.empty()) {
            return;
        }

        WIN32_FIND_DATAW findFileData = { 0 };
        std::wstring wstrFindStr(wstrSrcDir);

        std::wstring wstrRealSrcDir(wstrSrcDir);
        std::wstring wstrRealDstDir(wstrDstDir);

        if (L'\\' != *wstrRealSrcDir.rbegin()) {
            wstrRealSrcDir.append(L"\\");
            wstrFindStr.append(L"\\");
        }

        if (L'\\' != *wstrRealDstDir.rbegin()) {
            wstrRealDstDir.append(L"\\");
        }

        wstrFindStr.append(L"*.*");

        BOOL bRet = FALSE;
        DWORD dwError = 0;
        std::wstring wstrSrcDir2;
        std::wstring wstrDstDir2;
        std::wstring wstrFileName;
        HANDLE fileHandle = INVALID_HANDLE_VALUE;

        do {
            fileHandle = ::FindFirstFileW(wstrFindStr.c_str(), &findFileData);
            if (INVALID_HANDLE_VALUE == fileHandle) {
                break;
            }

            if (!PathIsExist(wstrDstDir.c_str())) {
                CreateDir(wstrDstDir, stopFlag);

                if (!PathIsExist(wstrDstDir.c_str())) {
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

                wstrSrcDir2 = wstrRealSrcDir + wstrFileName;
                wstrDstDir2 = wstrRealDstDir + wstrFileName;

                if ((findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                    CopyDir(wstrSrcDir2, wstrDstDir2, stopFlag);
                }
                else {
                    bRet = CopyFileW(wstrSrcDir2.c_str(), wstrDstDir2.c_str(), FALSE);
                    if (!bRet) {
                        dwError = GetLastError();
                    }
                }

            } while (FindNextFileW(fileHandle, &findFileData));

            FindClose(fileHandle);
            fileHandle = INVALID_HANDLE_VALUE;

        } while (false);

        if (INVALID_HANDLE_VALUE != fileHandle) {
            FindClose(fileHandle);
        }

        return;
    }

    void DeleteDir(
        const std::wstring &wstrDir,
        const int *stopFlag
    ) {
        if (wstrDir.size() < 4) {
            return;
        }

        if (wstrDir.compare(0, 4, LR"(\\?\)") == 0) {
            if (wstrDir.size() < 8 || wstrDir[5] != L':') {
                return;
            }
        }
        else {
            if (wstrDir[1] != L':') {
                return;
            }
        }

        WIN32_FIND_DATAW findFileData = { 0 };
        std::wstring wstrFindStr(wstrDir);

        std::wstring wstrRealDir(wstrDir);
        if (L'\\' != *wstrRealDir.rbegin()) {
            wstrRealDir.append(L"\\");
            wstrFindStr.append(L"\\");
        }

        wstrFindStr.append(L"*.*");

        BOOL bRet = FALSE;
        DWORD dwError = 0;
        std::wstring wstrFileName;
        std::wstring wstrDir2;
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

                wstrDir2 = wstrRealDir + wstrFileName;

                if (findFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                    DeleteDir(wstrDir2, stopFlag);
                }
                else {
                    int iTimes = 3;
                    do {
                        if (DeleteFileW(wstrDir2.c_str())) {
                            break;
                        }
                        // 文件被另一个进程占用
                        if (ERROR_SHARING_VIOLATION == GetLastError()) {
                            Sleep(200);
                            iTimes--;
                        }
                        else {
                            break;
                        }
                    } while (iTimes > 0);
                }

            } while (FindNextFileW(fileHandle, &findFileData));

            FindClose(fileHandle);
        }

        bRet = RemoveDirectoryW(wstrDir.c_str());
        if (!bRet) {
            dwError = GetLastError();
        }

        return;
    }

    bool PathIsExist(
        const std::wstring &wstrPath
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
    
    std::list<std::wstring> DirEntryList(
        const std::wstring& wstrDir,
        const std::wstring& wstrFilter,
        Filter filter
    ) {
        WIN32_FIND_DATAW findFileData;
        memset(&findFileData, 0, sizeof(WIN32_FIND_DATAW));

        std::wstring wstrFindPath = wstrDir;
        if (wstrFindPath.back() != L'\\') {
            wstrFindPath.append(L"\\");
        }

        std::wstring wstrFindStr = wstrFindPath + wstrFilter;
        std::list<std::wstring> entryList;
        std::wstring wstrFileName;

        HANDLE fileHandle = FindFirstFileW(wstrFindStr.c_str(), &findFileData);
        if (INVALID_HANDLE_VALUE != fileHandle) {
            do {
                wstrFileName.clear();

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

        return entryList;
    }

    std::list<WIN32_FIND_DATAW> DirEntryInfoList(
        const std::wstring& wstrDir,
        const std::wstring& wstrFilter,
        Filter filter
    ) {
        WIN32_FIND_DATAW findFileData;
        memset(&findFileData, 0, sizeof(WIN32_FIND_DATAW));

        std::wstring wstrFindPath = wstrDir;
        if (wstrFindPath.back() != L'\\') {
            wstrFindPath.append(L"\\");
        }

        std::wstring wstrFindStr = wstrFindPath + wstrFilter;
        std::list<WIN32_FIND_DATAW> entryInfoList;
        std::wstring wstrFileName;

        HANDLE fileHandle = FindFirstFileW(wstrFindStr.c_str(), &findFileData);
        if (INVALID_HANDLE_VALUE != fileHandle) {
            do {
                wstrFileName.clear();

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

        return entryInfoList;
    }

	std::wstring GetExeDirPath()
	{
		wchar_t dirPath[MAX_PATH] = { 0 };

		GetModuleFileNameW(NULL, dirPath, MAX_PATH);
		wchar_t *p = wcsrchr(dirPath, L'\\');
		if (p)
		{
			*p = L'\0';
		}

		return std::wstring(dirPath);
	}

	// 此函数读取文件全部内容, 注意使用场景
	char * ReadFileContent(
		const std::wstring &wstrFilePath,
        int *fileSize
	) {
		FILE *fp = nullptr;
		char *buffer = nullptr;

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
        const std::wstring &wstrFilePath,
        const char *data,
        int dataSize
    ) {
        FILE *fp = nullptr;
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

            int iFileID = _fileno(fp);
            _commit(iFileID);

            isSuccess = true;

        } while (false);

        if (fp) {
            fclose(fp);
        }

        return isSuccess;
    }
	
}