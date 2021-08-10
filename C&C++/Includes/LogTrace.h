#ifndef LOGTRACE_H
#define LOGTRACE_H

#define WIN32_LEAN_AND_MEAN             // 从 Windows 头中排除极少使用的资料
#include <Windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

namespace LogTrace
{
    inline void LogA(const char *format, ...)
    {	
        // log
        va_list args;
        va_start(args, format);
        int len = _vscprintf(format, args)
            + 1 // _vscprintf doesn't count terminating '\0'
            + 32 // time
            + 2 // \r\n
            ;

        char *buffer = (char *)calloc(len * sizeof(char), sizeof(char));
        if (NULL != buffer) {
            // time
            SYSTEMTIME sysTime;
            memset(&sysTime, 0, sizeof(SYSTEMTIME));
            GetSystemTime(&sysTime);

            char timeBuffer[32] = { 0 };
            memset(timeBuffer, 0, sizeof(timeBuffer));
            sprintf_s(timeBuffer, sizeof(timeBuffer) / sizeof(timeBuffer[0]), "[%04u/%02u/%02u %02u:%02u:%02u] ", sysTime.wYear,
                sysTime.wMonth, sysTime.wDay, sysTime.wHour + 8, sysTime.wMinute, sysTime.wSecond);

            strcpy_s(buffer, len, timeBuffer);

            vsprintf_s(buffer + strlen(timeBuffer), len - strlen(timeBuffer), format, args);

            strcat_s(buffer, len, "\r\n");

#ifdef _CONSOLE
            printf(buffer);
            OutputDebugStringA(buffer);
#else
            OutputDebugStringA(buffer);
#endif
            free(buffer);
        }
    }

    inline void LogW(const wchar_t *format, ...)
    {	
        // log
        va_list args;
        va_start(args, format);
        int len = _vscwprintf(format, args)
            + 1 // _vscprintf doesn't count terminating '\0'
            + 32 // time
            + 2 // \r\n
            ;

        wchar_t *buffer = (wchar_t *)calloc(len * sizeof(wchar_t), sizeof(wchar_t));
        if (NULL != buffer) {
            // time
            SYSTEMTIME sysTime;
            memset(&sysTime, 0, sizeof(SYSTEMTIME));
            GetSystemTime(&sysTime);

            wchar_t timeBuffer[32] = { 0 };
            memset(timeBuffer, 0, sizeof(timeBuffer));
            swprintf_s(timeBuffer, sizeof(timeBuffer) / sizeof(timeBuffer[0]), L"[%04u/%02u/%02u %02u:%02u:%02u] ", sysTime.wYear,
                sysTime.wMonth, sysTime.wDay, sysTime.wHour + 8, sysTime.wMinute, sysTime.wSecond);

            wcscpy_s(buffer, len, timeBuffer);

            vswprintf_s(buffer + wcslen(timeBuffer), len - wcslen(timeBuffer), format, args);

            wcscat_s(buffer, len, L"\r\n");

#ifdef _CONSOLE
            wprintf(buffer);
            OutputDebugStringW(buffer);
#else
            OutputDebugStringW(buffer);
#endif
            free(buffer);
        }
    }

    inline void LogToFileA(const char *logFile, const char *format, ...)
    {	
        DWORD writeBytes = 0;
        HANDLE fileHandle = CreateFileA(logFile, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
        if (fileHandle == INVALID_HANDLE_VALUE)
        {
            return;
        }

        SetFilePointer(fileHandle, 0, 0, FILE_END);
        
        // log
        va_list args;
        va_start(args, format);
        int len = _vscprintf(format, args)
            + 1 // _vscprintf doesn't count terminating '\0'
            + 32 // time
            + 2 // \r\n
            ;

        char *buffer = (char *)calloc(len * sizeof(char), sizeof(char));
        if (NULL != buffer) {
            // time
            SYSTEMTIME sysTime;
            memset(&sysTime, 0, sizeof(SYSTEMTIME));
            GetSystemTime(&sysTime);

            char timeBuffer[32] = { 0 };
            memset(timeBuffer, 0, sizeof(timeBuffer));
            sprintf_s(timeBuffer, sizeof(timeBuffer) / sizeof(timeBuffer[0]), "[%04u/%02u/%02u %02u:%02u:%02u] ", sysTime.wYear,
                sysTime.wMonth, sysTime.wDay, sysTime.wHour + 8, sysTime.wMinute, sysTime.wSecond);

            strcpy_s(buffer, len, timeBuffer);

            vsprintf_s(buffer + strlen(timeBuffer), len - strlen(timeBuffer), format, args);

            strcat_s(buffer, len, "\r\n");

            WriteFile(fileHandle, buffer, strlen(buffer), &writeBytes, NULL);

            free(buffer);
        }

        CloseHandle(fileHandle);
    }

    inline void LogToFileW(const wchar_t *logFile, const wchar_t *format, ...)
    {	
        if (!logFile || !format)
        {
            return;
        }

        unsigned char head[] = {0xFF, 0xFE};
        DWORD writeBytes = 0;
        HANDLE fileHandle = CreateFileW(logFile, GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
        if (fileHandle != INVALID_HANDLE_VALUE)
        {
            // 首次创建文件写入UTF16 BOM头
            if (0 == GetLastError()) {
                WriteFile(fileHandle, head, sizeof(head), &writeBytes, NULL);
            }
        }
        else
        {
            return;
        }
        
        SetFilePointer(fileHandle, 0, 0, FILE_END);
        
        va_list args;
        va_start(args, format);
        int len = _vscwprintf(format, args)
            + 1 // _vscprintf doesn't count terminating '\0'
            + 32 // time
            + 2 // \r\n
            ;

        wchar_t *buffer = (wchar_t *)calloc(len * sizeof(wchar_t), sizeof(wchar_t));
        if (NULL != buffer) {
            // time
            SYSTEMTIME sysTime;
            memset(&sysTime, 0, sizeof(SYSTEMTIME));
            GetSystemTime(&sysTime);

            wchar_t timeBuffer[32] = { 0 };
            memset(timeBuffer, 0, sizeof(timeBuffer));
            swprintf_s(timeBuffer, sizeof(timeBuffer) / sizeof(timeBuffer[0]), L"[%04u/%02u/%02u %02u:%02u:%02u] ", sysTime.wYear,
                sysTime.wMonth, sysTime.wDay, sysTime.wHour + 8, sysTime.wMinute, sysTime.wSecond);

            wcscpy_s(buffer, len, timeBuffer);

            vswprintf_s(buffer + wcslen(timeBuffer), len - wcslen(timeBuffer), format, args);

            wcscat_s(buffer, len, L"\r\n");

            WriteFile(fileHandle, buffer, wcslen(buffer) * sizeof(buffer[0]), &writeBytes, NULL);

            free(buffer);
        }

        CloseHandle(fileHandle);
    }
}


#endif //LOGTRACE_H