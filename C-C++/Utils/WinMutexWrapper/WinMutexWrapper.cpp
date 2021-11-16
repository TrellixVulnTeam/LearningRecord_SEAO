// WinMutexWrapper.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "WinMutexWrapper.h"
#include "WinMutexWrapperInternal.h"

WinMutexWrapper::WinMutexWrapper(
    const std::wstring &wstrMutexName
)
    : m_impl(std::make_unique<WinMutexWrapperInternal>(wstrMutexName)) {
    lock();
}

WinMutexWrapper::~WinMutexWrapper() {
    unlock();
}

void WinMutexWrapper::lock() {
    if (!m_lockStatus) {
        m_impl->lock();
        m_lockStatus = true;
    }
}

void WinMutexWrapper::unlock() {
    if (m_lockStatus) {
        m_impl->unlock();
        m_lockStatus = false;
    }
}
