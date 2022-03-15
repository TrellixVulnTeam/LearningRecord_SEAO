#include "pch.h"
#include "WinMutexWrapperInternal.h"

WinMutexWrapperInternal::WinMutexWrapperInternal(
    const std::wstring &wstrMutexName
) {
    m_hMutex = ::CreateMutexW(NULL, FALSE, wstrMutexName.c_str());
}

WinMutexWrapperInternal::~WinMutexWrapperInternal() {
    if (m_hMutex) {
        ::CloseHandle(m_hMutex);
    }
}

void WinMutexWrapperInternal::lock() {
    if (m_hMutex) {
        ::WaitForSingleObject(m_hMutex, INFINITE);
    }
}

void WinMutexWrapperInternal::unlock() {
    if (m_hMutex) {
        ::ReleaseMutex(m_hMutex);
    }
}
