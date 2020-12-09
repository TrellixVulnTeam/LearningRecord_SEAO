#ifndef _DEBUG_LOG_H
#define _DEBUG_LOG_H


#include <Windows.h>
#include <Strsafe.h>
#include <assert.h>
#include <sstream>

namespace DebugLog {
    //    inline void LogA(const char *format, ...)
    //    {	
    //        if (!format)
    //        {
    //            return;
    //        }
    //
    //        char buffer[4096] = {0};
    //
    //        // time
    //        SYSTEMTIME sysTime = {0};
    //        GetSystemTime(&sysTime);
    //        StringCbPrintfA(buffer, sizeof(buffer), "[%04u/%02u/%02u %02u:%02u:%02u]", sysTime.wYear,
    //            sysTime.wMonth, sysTime.wDay, sysTime.wHour + 8, sysTime.wMinute, sysTime.wSecond);
    //
    //#ifdef _CONSOLE
    //        printf(buffer);
    //#else
    //        OutputDebugStringA(buffer);
    //#endif
    //
    //        // log
    //        memset(buffer, 0, sizeof(buffer));
    //        va_list marker;
    //        va_start(marker, format);
    //        StringCbVPrintfA(buffer, sizeof(buffer), format, marker);
    //        va_end(marker);
    //        StringCbCatA(buffer, sizeof(buffer), "\r\n");
    //
    //#ifdef _CONSOLE
    //        printf(buffer);
    //#else
    //        OutputDebugStringA(buffer);
    //#endif
    //    }
    //
    //    inline void LogW(const wchar_t *format, ...)
    //    {	
    //        if (!format)
    //        {
    //            return;
    //        }
    //
    //        wchar_t buffer[4096] = {0};
    //
    //        // time
    //        SYSTEMTIME sysTime = {0};
    //        GetSystemTime(&sysTime);
    //        StringCbPrintfW(buffer, sizeof(buffer), L"[%04u/%02u/%02u %02u:%02u:%02u]", sysTime.wYear,
    //            sysTime.wMonth, sysTime.wDay, sysTime.wHour + 8, sysTime.wMinute, sysTime.wSecond);
    //
    //#ifdef _CONSOLE
    //        wprintf(buffer);
    //#else
    //        OutputDebugStringW(buffer);
    //#endif
    //
    //        // log
    //        memset(buffer, 0, sizeof(buffer));
    //        va_list marker;
    //        va_start(marker, format);
    //        StringCbVPrintfW(buffer, sizeof(buffer), format, marker);
    //        va_end(marker);
    //        StringCbCatW(buffer, sizeof(buffer), L"\r\n");
    //
    //#ifdef _CONSOLE
    //        wprintf(buffer);
    //#else
    //        OutputDebugStringW(buffer);
    //#endif
    //    }
    //
    //    inline void LogToFileA(const char *logFile, const char *format, ...)
    //    {	
    //        if (!logFile || !format)
    //        {
    //            return;
    //        }
    //
    //        DWORD writeBytes = 0;
    //        HANDLE fileHandle = CreateFileA(logFile, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    //        if (fileHandle == INVALID_HANDLE_VALUE)
    //        {
    //            return;
    //        }
    //
    //        SetFilePointer(fileHandle, 0, 0, FILE_END);
    //        char buffer[4096] = {0};
    //
    //        // time
    //        SYSTEMTIME sysTime = {0};
    //        GetSystemTime(&sysTime);
    //        StringCbPrintfA(buffer, sizeof(buffer), "[%04u/%02u/%02u %02u:%02u:%02u]", sysTime.wYear,
    //            sysTime.wMonth, sysTime.wDay, sysTime.wHour + 8, sysTime.wMinute, sysTime.wSecond);
    //        WriteFile(fileHandle, buffer, strlen(buffer), &writeBytes, NULL);
    //
    //        // log
    //        memset(buffer, 0, sizeof(buffer));
    //        va_list marker;
    //        va_start(marker, format);
    //        StringCbVPrintfA(buffer, sizeof(buffer), format, marker);
    //        va_end(marker);
    //        StringCbCatA(buffer, sizeof(buffer), "\r\n");
    //        WriteFile(fileHandle, buffer, strlen(buffer), &writeBytes, NULL);
    //
    //        CloseHandle(fileHandle);
    //    }
    //
    //    inline void LogToFileW(const wchar_t *logFile, const wchar_t *format, ...)
    //    {	
    //        if (!logFile || !format)
    //        {
    //            return;
    //        }
    //
    //        unsigned char head[] = {0xFF, 0xFE};
    //        DWORD writeBytes = 0;
    //        HANDLE fileHandle = CreateFileW(logFile, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    //        if (fileHandle == INVALID_HANDLE_VALUE)
    //        {
    //            return;
    //        }
    //        else
    //        {
    //            // 首次创建文件写入UTF16 BOM头
    //            if (0 == ::GetLastError())
    //            {
    //                ::WriteFile(fileHandle, head, sizeof(head), &writeBytes, NULL);
    //            }
    //        }
    //        
    //        SetFilePointer(fileHandle, 0, 0, FILE_END);
    //        wchar_t buffer[4096] = {0};
    //
    //        // time
    //        SYSTEMTIME sysTime = {0};
    //        GetSystemTime(&sysTime);
    //        StringCbPrintfW(buffer, sizeof(buffer), L"[%04u/%02u/%02u %02u:%02u:%02u]", sysTime.wYear,
    //            sysTime.wMonth, sysTime.wDay, sysTime.wHour + 8, sysTime.wMinute, sysTime.wSecond);
    //        WriteFile(fileHandle, buffer, wcslen(buffer) * sizeof(buffer[0]), &writeBytes, NULL);
    //
    //        // log
    //        memset(buffer, 0, sizeof(buffer));
    //        va_list marker;
    //        va_start(marker, format);
    //        StringCbVPrintfW(buffer, sizeof(buffer), format, marker);
    //        va_end(marker);
    //        StringCbCatW(buffer, sizeof(buffer), L"\r\n");
    //        WriteFile(fileHandle, buffer, wcslen(buffer) * sizeof(buffer[0]), &writeBytes, NULL);
    //
    //        CloseHandle(fileHandle);
    //    }

    // 宽字节版本 utf16-le --begin
    inline void LogW(
        std::wostringstream &sStream
    ) {
    }

    template <class T, class ...Args>
    inline void LogW(
        std::wostringstream &sStream,
        T first,
        Args... rest
    ) {
        sStream << first;
        LogW(sStream, rest...);
    }

    template <class T, class ...Args>
    inline void LogW(
        T first,
        Args... rest
    ) {
        std::wostringstream sStream;

        // time
        SYSTEMTIME timeInfo;
        ZeroMemory(&timeInfo, sizeof(SYSTEMTIME));
        GetLocalTime(&timeInfo);

        wchar_t timeBuffer[32] = { 0 };
        StringCbPrintfW(timeBuffer, sizeof(timeBuffer), L"[%04d/%02d/%02d %02d:%02d:%02d]", timeInfo.wYear,
            timeInfo.wMonth, timeInfo.wDay, timeInfo.wHour, timeInfo.wMinute, timeInfo.wSecond);

        sStream << timeBuffer;

        LogW(sStream, first, rest...);

        sStream << L"\r\n";

        OutputDebugStringW(sStream.str().c_str());
    }

    template <class T, class ...Args>
    inline void LogToFileW(
        T first,
        Args... rest
    ) {
        std::wstring wstrLogFile = first;

        std::wostringstream sStream;

        LogW(sStream, rest...);

        sStream << L"\r\n";

        unsigned char head[] = { 0xFF, 0xFE };
        DWORD writeBytes = 0;
        HANDLE fileHandle = CreateFileW(wstrLogFile.c_str(), GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
        if (fileHandle != INVALID_HANDLE_VALUE) {
            // 首次创建文件写入utf16 BOM头
            if (0 == ::GetLastError()) {
                ::WriteFile(fileHandle, head, sizeof(head), &writeBytes, NULL);
            }

            SetFilePointer(fileHandle, 0, 0, FILE_END);

            // time
            SYSTEMTIME timeInfo;
            ZeroMemory(&timeInfo, sizeof(SYSTEMTIME));
            GetLocalTime(&timeInfo);

            wchar_t timeBuffer[32] = { 0 };
            StringCbPrintfW(timeBuffer, sizeof(timeBuffer), L"[%04d/%02d/%02d %02d:%02d:%02d]", timeInfo.wYear,
                timeInfo.wMonth, timeInfo.wDay, timeInfo.wHour, timeInfo.wMinute, timeInfo.wSecond);

            WriteFile(fileHandle, timeBuffer, wcslen(timeBuffer) * sizeof(timeBuffer[0]), &writeBytes, NULL);

            // log
            const std::wstring wstrLogStr = sStream.str();
            WriteFile(fileHandle, wstrLogStr.c_str(), wstrLogStr.size() * sizeof(std::wstring::value_type), &writeBytes, NULL);

            CloseHandle(fileHandle);
        }
    }
    // 宽字节版本 utf16-le --end

    // 窄字节版本 gbk --begin
    inline void LogA(
        std::ostringstream &sStream
    ) {
    }

    template <class T, class ...Args>
    inline void LogA(
        std::ostringstream &sStream,
        T first,
        Args... rest
    ) {
        sStream << first;
        LogA(sStream, rest...);
    }

    template <class T, class ...Args>
    inline void LogA(
        T first,
        Args... rest
    ) {
        std::ostringstream sStream;

        // time
        SYSTEMTIME timeInfo;
        ZeroMemory(&timeInfo, sizeof(SYSTEMTIME));
        GetLocalTime(&timeInfo);

        char timeBuffer[32] = { 0 };
        StringCbPrintfA(timeBuffer, sizeof(timeBuffer), "[%04d/%02d/%02d %02d:%02d:%02d]", timeInfo.wYear,
            timeInfo.wMonth, timeInfo.wDay, timeInfo.wHour, timeInfo.wMinute, timeInfo.wSecond);

        sStream << timeBuffer;

        LogA(sStream, first, rest...);

        sStream << "\r\n";

        OutputDebugStringA(sStream.str().c_str());
    }

    template <class T, class ...Args>
    inline void LogToFileA(
        T first,
        Args... rest
    ) {
        std::string strLogFile = first;

        std::ostringstream sStream;

        LogA(sStream, rest...);

        sStream << "\r\n";

        DWORD writeBytes = 0;
        HANDLE fileHandle = CreateFileA(strLogFile.c_str(), GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
        if (fileHandle != INVALID_HANDLE_VALUE) {
            SetFilePointer(fileHandle, 0, 0, FILE_END);

            SYSTEMTIME timeInfo;
            ZeroMemory(&timeInfo, sizeof(SYSTEMTIME));
            GetLocalTime(&timeInfo);

            char timeBuffer[32] = { 0 };
            StringCbPrintfA(timeBuffer, sizeof(timeBuffer), "[%04d/%02d/%02d %02d:%02d:%02d]", timeInfo.wYear,
                timeInfo.wMonth, timeInfo.wDay, timeInfo.wHour, timeInfo.wMinute, timeInfo.wSecond);

            WriteFile(fileHandle, timeBuffer, strlen(timeBuffer) * sizeof(timeBuffer[0]), &writeBytes, NULL);

            // log
            const std::string strLogStr = sStream.str();
            WriteFile(fileHandle, strLogStr.c_str(), strLogStr.size() * sizeof(std::string::value_type), &writeBytes, NULL);

            CloseHandle(fileHandle);
        }
    }
    // 窄字节版本 gbk --end
}


#endif //_DEBUG_LOG_H