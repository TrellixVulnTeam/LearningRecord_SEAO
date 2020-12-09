#include "WinProcessUtils.h"
#include <DebugLog.h>

WinProcessUtils::WinProcessUtils() {
    m_pfunNtQuerySystemInformation = NULL;
    m_pfunNtQueryObject = NULL;
    m_pfunZwQueryInformationFile = NULL;
}


WinProcessUtils::~WinProcessUtils() {
}

BOOL WinProcessUtils::GetUndocumentedFunctionAddress() {
    m_pfunNtQuerySystemInformation = (_NtQuerySystemInformation)GetProcAddress(
        GetModuleHandleW(L"ntdll.dll"),
        "NtQuerySystemInformation");

    m_pfunNtQueryObject = (_NtQueryObject)GetProcAddress(
        GetModuleHandleW(L"ntdll.dll"),
        "NtQueryObject");

    m_pfunZwQueryInformationFile = (_ZwQueryInformationFile)GetProcAddress(
        GetModuleHandleW(L"ntdll.dll"), "ZwQueryInformationFile");

    return (m_pfunNtQuerySystemInformation != NULL
        && m_pfunNtQueryObject != NULL
        && m_pfunZwQueryInformationFile != NULL);
}

BOOL WinProcessUtils::CloseProcessFileHandles(DWORD pid) {
    PSYSTEM_HANDLE_INFORMATION pSysHandleInfo = NULL;
    size_t HandleInfoSize = 0x1000;  //4K
    NTSTATUS status;
    BOOL ret = FALSE;
    DWORD errCode = 0;

    do {
        pSysHandleInfo = (PSYSTEM_HANDLE_INFORMATION)malloc(HandleInfoSize);
        do {
            status = m_pfunNtQuerySystemInformation(SystemHandleInformation,
                pSysHandleInfo, HandleInfoSize, NULL);

            if (status == STATUS_INFO_LENGTH_MISMATCH) {
                HandleInfoSize *= 2;
                pSysHandleInfo = (PSYSTEM_HANDLE_INFORMATION)realloc(pSysHandleInfo, HandleInfoSize);
            } else {
                break;
            }
        } while (TRUE);

        if (!pSysHandleInfo) {
            break;
        }

        ret = TRUE;

        for (ULONG i = 0; i < pSysHandleInfo->HandleCount; i++) {
            PSYSTEM_HANDLE SystemHandle = &pSysHandleInfo->Handles[i];
            if (SystemHandle->ProcessId == pid) {
                HANDLE duplicatedHandle = NULL;
                PPUBLIC_OBJECT_TYPE_INFORMATION objectTypeInfo = NULL;
                PVOID objectNameInfo = NULL;
                HANDLE hProcess = NULL;

                do {
                    hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
                    if (NULL == hProcess) {
                        break;
                    }

                    /*if (!DuplicateHandle(hProcess,
                    (HANDLE)SystemHandle->Handle,
                    GetCurrentProcess(),
                    &duplicatedHandle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    break;
                    }*/

                    /* Query the object type. */
                    objectTypeInfo = (PPUBLIC_OBJECT_TYPE_INFORMATION)malloc(ONEPAGESIZE);
                    status = m_pfunNtQueryObject((HANDLE)SystemHandle->Handle,
                        ObjectTypeInformation,
                        objectTypeInfo,
                        ONEPAGESIZE,
                        NULL
                    );

                    if (status != STATUS_SUCCESS) {
                        DebugLog::LogW(L"[handle:", SystemHandle->Handle, L"] NtQueryObject error!");
                        break;
                    }

                    DebugLog::LogW(L"[handle:", SystemHandle->Handle, L"] type:", objectTypeInfo->TypeName.Buffer);

                    if (_wcsicmp(objectTypeInfo->TypeName.Buffer, L"File") == 0) {
                        WCHAR filePath[MAX_PATH];
                        memset(&filePath, 0, sizeof(filePath));
                        GetFilePathFromHandle((HANDLE)SystemHandle->Handle, filePath, sizeof(filePath) / sizeof(filePath[0]));

                        if (filePath[0]) {
                            if (_wcsicmp(filePath, LR"(\\?\C:\Windows)") != 0
                                && _wcsicmp(filePath, LR"(\\?\F:\projects\VSProjects\VS2015\test\ConsoleApplication1)") != 0) {
                                WIN32_FILE_ATTRIBUTE_DATA fileAttr = { 0 };
                                if (GetFileAttributesExW(filePath, GetFileExInfoStandard, &fileAttr)) {
                                    CloseHandle((HANDLE)SystemHandle->Handle);
                                }
                            }
                        }

                        //// 获取文件属性 方法1
                        //IO_STATUS_BLOCK isb = { 0 };
                        //FILE_BASIC_INFORMATION fileBasicInfo = { 0 };
                        //status = m_pfunZwQueryInformationFile((HANDLE)SystemHandle->Handle, &isb, &fileBasicInfo, sizeof(FILE_BASIC_INFORMATION), 4);
                        //if (status == STATUS_SUCCESS) {
                        //    if ((fileBasicInfo.FileAttributes & FILE_ATTRIBUTE_ARCHIVE)
                        //        || (fileBasicInfo.FileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {

                        //        if (fileBasicInfo.FileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                        //            FindClose((HANDLE)SystemHandle->Handle);
                        //        } else {
                        //            CloseHandle((HANDLE)SystemHandle->Handle);
                        //        }
                        //    }
                        //}

                        //// 获取文件属性 方法2
                        //BY_HANDLE_FILE_INFORMATION fileInfo;
                        //memset(&fileInfo, 0, sizeof(BY_HANDLE_FILE_INFORMATION));
                        //if (GetFileInformationByHandle((HANDLE)SystemHandle->Handle, &fileInfo)) {
                        //    if ((fileInfo.dwFileAttributes & FILE_ATTRIBUTE_ARCHIVE)
                        //        || (fileInfo.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                        //        
                        //        if (fileInfo.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                        //            FindClose((HANDLE)SystemHandle->Handle);
                        //        } else {
                        //            CloseHandle((HANDLE)SystemHandle->Handle);
                        //        }
                        //    }
                        //} else {
                        //    errCode = GetLastError();
                        //    errCode = 0;
                        //}
                    }

                } while (false);

                if (hProcess) {
                    CloseHandle(hProcess);
                }

                if (objectTypeInfo) {
                    free(objectTypeInfo);
                }

                if (objectNameInfo) {
                    free(objectNameInfo);
                }

                if (duplicatedHandle) {
                    CloseHandle(duplicatedHandle);
                }
            }
        }

    } while (false);

    if (pSysHandleInfo) {
        free(pSysHandleInfo);
    }

    return ret;
}

BOOL WinProcessUtils::GetFilePathFromHandle(HANDLE hFile, LPWSTR path, UINT cchPath) {
    BOOL bResult = FALSE;

    do {
        if (INVALID_HANDLE_VALUE == hFile || NULL == path || 0 == cchPath) {
            break;
        }

        if (GetFinalPathNameByHandleW(hFile, path, cchPath, FILE_NAME_NORMALIZED) > 0) {
            bResult = TRUE;
        }

    } while (FALSE);

    return bResult;
}