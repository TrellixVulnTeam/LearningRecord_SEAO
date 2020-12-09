#pragma once

#ifdef WINPROCESSUTILS_EXPORTS
#define WINPROCESSUTILS_API __declspec(dllexport)
#else
#define WINPROCESSUTILS_API __declspec(dllimport)
#endif

#include "intermal.h"

class WINPROCESSUTILS_API WinProcessUtils {
public:
    WinProcessUtils();
    ~WinProcessUtils();

public:
    BOOL GetUndocumentedFunctionAddress();
    BOOL CloseProcessFileHandles(DWORD PID = -1);
    BOOL GetFilePathFromHandle(HANDLE hFile, LPWSTR path, UINT cchPath);
private:
    _NtQuerySystemInformation m_pfunNtQuerySystemInformation;
    _NtQueryObject m_pfunNtQueryObject;
    _ZwQueryInformationFile m_pfunZwQueryInformationFile;
};
