#pragma once

#include <string>
#include <mutex>

#define WIN32_LEAN_AND_MEAN             // �� Windows ͷ���ų�����ʹ�õ�����
// Windows ͷ�ļ�: 
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