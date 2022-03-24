#pragma once

#include <string>
#include <mutex>

#define WIN32_LEAN_AND_MEAN             // 从 Windows 头中排除极少使用的资料
// Windows 头文件: 
#include <windows.h>

class WinMutexWrapperInternal {
public:
    WinMutexWrapperInternal(
        const std::wstring &wstrMutexName
    );

    ~WinMutexWrapperInternal();

    void lock();

    void unlock();

private:
    WinMutexWrapperInternal();

private:
    HANDLE m_hMutex;
};