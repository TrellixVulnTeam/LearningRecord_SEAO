// ProcessUtils.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "ProcessUtils.h"
#include "pscmd.h"
#include <strsafe.h>

namespace ProcessUtils {

    DWORD GetProcessPid(
        const std::wstring &wstrProcessName
    ) {
        DWORD pid = 0;

        do {
            const wchar_t *processName = wstrProcessName.c_str();
            if (!processName || wcslen(processName) <= 0) {
                break;
            }

            HANDLE hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, NULL);
            if (hProcessSnap != INVALID_HANDLE_VALUE) {
                PROCESSENTRY32W processInfo = { 0 };
                processInfo.dwSize = sizeof(PROCESSENTRY32W);

                if (Process32First(hProcessSnap, &processInfo)) {
                    do {
                        if (!_wcsicmp(processName, processInfo.szExeFile)) {
                            pid = processInfo.th32ProcessID;
                            break;
                        }
                    } while (Process32Next(hProcessSnap, &processInfo));

                    CloseHandle(hProcessSnap);
                }
            }
        } while (false);

        return pid;
    }

    std::wstring GbkToUtf16(std::string& str) {
        int wideSize = MultiByteToWideChar(CP_ACP, 0, str.c_str(), -1, NULL, 0);
        if (ERROR_NO_UNICODE_TRANSLATION == wideSize)
            return L"";

        if (0 == wideSize)
            return L"";

        std::vector<wchar_t> resultVec(wideSize);
        int resultSize = MultiByteToWideChar(CP_ACP, 0, str.c_str(), -1, &resultVec[0], wideSize);
        if (resultSize != wideSize)
            return L"";

        return std::wstring(&resultVec[0]);
    }

    DWORD GetProcessPid(
        const std::wstring &wstrProcessName,
        const std::wstring &wstrCmdLineStr
    ) {
        DWORD pid = 0;

        do {
            const wchar_t *processName = wstrProcessName.c_str();
            if (!processName || wcslen(processName) <= 0) {
                break;
            }

            HANDLE hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, NULL);
            if (hProcessSnap != INVALID_HANDLE_VALUE) {
                PROCESSENTRY32W processInfo = { 0 };
                processInfo.dwSize = sizeof(PROCESSENTRY32W);

                if (Process32First(hProcessSnap, &processInfo)) {
                    do {
                        if (!_wcsicmp(processName, processInfo.szExeFile)) {
                            if (!wstrCmdLineStr.empty()) {
                                std::wstring wstrCmdLine = GetProcessCmdLine(processInfo.th32ProcessID);
                                if (wstrCmdLine.find(wstrCmdLineStr) != std::wstring::npos) {
									pid = processInfo.th32ProcessID;
                                    break;
                                }
								else
								{
									// 通过命令行方式获取
									std::string strCmdLine = GetProcessCmdLineByCmd(processInfo.th32ProcessID);
                                    std::wstring wstrCmdLine = GbkToUtf16(strCmdLine);
									if (wstrCmdLine.find(wstrCmdLineStr) != std::wstring::npos) {
										pid = processInfo.th32ProcessID;
										break;
									}
								}

                            } else {
                                pid = processInfo.th32ProcessID;
                                break;
                            }
                        }
                    } while (Process32Next(hProcessSnap, &processInfo));

                    CloseHandle(hProcessSnap);
                }
            }
        } while (false);

        return pid;
    }

    bool KillProcess(
        const std::wstring &wstrProcessName,
        const std::wstring &wstrCmdLineStr
    ) {
        bool isSuccess = false;

        do {
            const wchar_t *processName = wstrProcessName.c_str();
            if (!processName || wcslen(processName) <= 0) {
                break;
            }

            HANDLE hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, NULL);
            if (hProcessSnap != INVALID_HANDLE_VALUE) {
                PROCESSENTRY32W processInfo = { 0 };
                processInfo.dwSize = sizeof(PROCESSENTRY32W);

                if (Process32First(hProcessSnap, &processInfo)) {
                    do {
                        if (!_wcsicmp(processName, processInfo.szExeFile)) {
                            if (!wstrCmdLineStr.empty()) {
                                std::wstring wstrCmdLine = GetProcessCmdLine(processInfo.th32ProcessID);
                                if (wstrCmdLine.find(wstrCmdLineStr) != std::wstring::npos) {
                                    HANDLE processHandle = OpenProcess(PROCESS_ALL_ACCESS, FALSE, processInfo.th32ProcessID);
                                    if (processHandle) {
                                        isSuccess = !!TerminateProcess(processHandle, 0);
                                        CloseHandle(processHandle);
                                    }
                                }
                            }
                            else {
                                HANDLE processHandle = OpenProcess(PROCESS_ALL_ACCESS, FALSE, processInfo.th32ProcessID);
                                if (processHandle) {
                                    isSuccess = !!TerminateProcess(processHandle, 0);
                                    CloseHandle(processHandle);
                                }
                            }
                        }
                    } while (Process32Next(hProcessSnap, &processInfo));

                    CloseHandle(hProcessSnap);
                }
            }
        } while (false);

        return isSuccess;
    }

    std::wstring GetProcessCmdLine(
        DWORD pid
    ) {
        std::wstring wstrCmdLine;
        HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
        if (hProcess) {
            SIZE_T nCommandLineSize = NULL;

            // 将 lpcBuffer 和 nSize 设置为 NULL 以获取建议缓冲区大小（nCommandLineSize）
            if (GetProcessCommandLineW(hProcess, NULL, NULL, &nCommandLineSize)) {
                /* 在堆上分配建议大小的 Unicode 缓冲区 */
                wchar_t *lpUnicodeBuffer = (wchar_t*)malloc(nCommandLineSize);
                if (lpUnicodeBuffer) {
                    memset(lpUnicodeBuffer, NULL, nCommandLineSize);

                    /* 再次调用  GetProcessCommandLine 并传入所分配的 Unicode 缓冲区，以取得实际数据 */
                    if (GetProcessCommandLineW(hProcess, lpUnicodeBuffer, nCommandLineSize, &nCommandLineSize)) {
                        wstrCmdLine = lpUnicodeBuffer;
                    }

                    free(lpUnicodeBuffer);
                }
            }

            CloseHandle(hProcess);
        }

        return wstrCmdLine;
    }

	bool ExcuteCommand(const wchar_t *lpCmd, std::string &output, const int *lpStopFlag, bool bWait)
	{
		if (NULL == lpCmd)
		{
			return false;
		}

		HANDLE hRead = NULL;
		HANDLE hWrite = NULL;
		DWORD dwExitCode = STILL_ACTIVE;
		DWORD dwRead = 0;
		SECURITY_ATTRIBUTES sa = { 0 };
		bool bRet = false;
		wchar_t *lpCmdLine = NULL;

		do
		{
			output.clear();

			sa.nLength = sizeof(SECURITY_ATTRIBUTES);
			sa.lpSecurityDescriptor = NULL;
			sa.bInheritHandle = TRUE;

			if (!CreatePipe(&hRead, &hWrite, &sa, 10240))
			{
				break;
			}

			PROCESS_INFORMATION piProcInfo = { 0 };
			STARTUPINFOW siStartInfo = { 0 };

			ZeroMemory(&piProcInfo, sizeof(PROCESS_INFORMATION));
			ZeroMemory(&siStartInfo, sizeof(STARTUPINFOW));

			siStartInfo.cb = sizeof(STARTUPINFOW);
			siStartInfo.hStdOutput = hWrite;
			/*siStartInfo.hStdInput = hRead;*/
			siStartInfo.hStdError = hWrite;
			siStartInfo.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
			siStartInfo.wShowWindow = SW_HIDE;

			lpCmdLine = new wchar_t[1024 * 1024]();
			if (NULL == lpCmdLine)
			{
				break;
			}

			StringCchPrintfW(lpCmdLine, 1024 * 1024, L"cmd /c \"%s\"", lpCmd);
			if (!CreateProcessW(NULL, lpCmdLine, NULL, NULL, TRUE, CREATE_NEW_CONSOLE, NULL, NULL, &siStartInfo, &piProcInfo))
			{
				break;
			}

			int iTimes = 0;

			while (true)
			{
				if (NULL != lpStopFlag && *lpStopFlag != 0)
				{
					break;
				}

				if (bWait)
				{
					if (100 <= iTimes)
					{
						TerminateProcess(piProcInfo.hProcess, 0);
						break;
					}

					dwRead = 0;
					PeekNamedPipe(hRead, NULL, 0, NULL, &dwRead, NULL);
					if (dwRead > 0)
					{
						iTimes = 0;

						char* buffer = new char[dwRead + 1]();
						ReadFile(hRead, buffer, dwRead, &dwRead, NULL);
						output += buffer;
						delete[] buffer;
					}

					DWORD dExitRet = GetExitCodeProcess(piProcInfo.hProcess, &dwExitCode);
					if (STILL_ACTIVE != dwExitCode)
					{
						//如果之前没有读到数据再尝试最后一次
						if (output.empty())
						{
							PeekNamedPipe(hRead, NULL, 0, NULL, &dwRead, NULL);
							if (dwRead > 0)
							{
								char* buffer = new char[dwRead + 1]();
								ReadFile(hRead, buffer, dwRead, &dwRead, NULL);
								output += buffer;
								delete[] buffer;
							}
						}
						break;
					}

					Sleep(100);
					iTimes++;
				}
				else
				{
					break;
				}
			}

			while (bWait && STILL_ACTIVE == dwExitCode)
			{
				Sleep(20);
				GetExitCodeProcess(piProcInfo.hProcess, &dwExitCode);

				if (NULL != lpStopFlag && *lpStopFlag != 0)
				{
					TerminateProcess(piProcInfo.hProcess, 0);
				}
			}

			CloseHandle(piProcInfo.hProcess);
			CloseHandle(piProcInfo.hThread);

			bRet = true;

		} while (false);

		if (NULL != lpCmdLine)
		{
			delete[] lpCmdLine;
		}

		if (NULL != hRead)
		{
			CloseHandle(hRead);
		}

		if (NULL != hWrite)
		{
			CloseHandle(hWrite);
		}

		return bRet;
	}


	std::string GetProcessCmdLineByCmd(
		DWORD pid
	) {
		std::string strCmdLine;
		if (pid > 0)
		{
			WCHAR wzSysDir[MAX_PATH] = { 0 };
			WCHAR wzCmd[MAX_PATH] = { 0 };

			GetSystemDirectoryW(wzSysDir, MAX_PATH);
			StringCbPrintfW(wzCmd, sizeof(wzCmd), L"%s\\wbem\\wmic process %d ", wzSysDir, pid);
			ExcuteCommand(wzCmd, strCmdLine, nullptr, true);
			
		}

		return strCmdLine;
	}

    bool CheckProcessModuleExist(
        DWORD pid,
        const std::wstring &wstrModuleName
    ) {
        bool isExist = false;

        do {
            const wchar_t *moduleName = wstrModuleName.c_str();
            if (!moduleName || wcslen(moduleName) <= 0) {
                break;
            }

            MODULEENTRY32W me32 = { sizeof(MODULEENTRY32W) };

            HANDLE hModuleSnap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, pid);
            if (hModuleSnap != INVALID_HANDLE_VALUE) {

                if (Module32FirstW(hModuleSnap, &me32)) {
                    do {
                        if (!_wcsicmp(me32.szModule, moduleName)) {
                            isExist = true;
                            break;
                        }

                    } while (Module32NextW(hModuleSnap, &me32));
                }

                CloseHandle(hModuleSnap);
            }

        } while (false);

        return isExist;
    }

    const DWORD MS_VC_EXCEPTION = 0x406D1388;
#pragma pack(push,8)
    typedef struct tagTHREADNAME_INFO {
        DWORD dwType; // Must be 0x1000.
        LPCSTR szName; // Pointer to name (in user addr space).
        DWORD dwThreadID; // Thread ID (-1=caller thread).
        DWORD dwFlags; // Reserved for future use, must be zero.
    } THREADNAME_INFO;
#pragma pack(pop)
    void SetThreadName(
        DWORD tid,
        const char *threadName
    ) {
        THREADNAME_INFO info;
        info.dwType = 0x1000;
        info.szName = threadName;
        info.dwThreadID = tid;
        info.dwFlags = 0;
#pragma warning(push)
#pragma warning(disable: 6320 6322)
        __try {
            RaiseException(MS_VC_EXCEPTION, 0, sizeof(info) / sizeof(ULONG_PTR), (ULONG_PTR*)&info);
        }
        __except (EXCEPTION_EXECUTE_HANDLER) {}
#pragma warning(pop)
    }

}