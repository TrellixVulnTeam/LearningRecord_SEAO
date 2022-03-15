#pragma once

#ifdef WINMUTEXWRAPPER_EXPORTS
    #define WINMUTEXWRAPPER_API __declspec(dllexport)
#else
    #define WINMUTEXWRAPPER_API __declspec(dllimport)
#endif

#include <string>
#include <atomic>
#include <memory>

class WinMutexWrapperInternal;
class WINMUTEXWRAPPER_API WinMutexWrapper {
public:
    WinMutexWrapper(
        const std::wstring &wstrMutexName
    );

    WinMutexWrapper(const WinMutexWrapper &) = delete;
    WinMutexWrapper & operator=(const WinMutexWrapper &) = delete;

    ~WinMutexWrapper();

    void lock();

    void unlock();

private:
    WinMutexWrapperInternal *m_impl;
    std::atomic<bool> m_lockStatus;
};