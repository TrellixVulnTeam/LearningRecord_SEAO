#pragma once

#ifdef PROCESSUTILS_EXPORTS
#define PROCESSUTILS_API __declspec(dllexport)
#else
#define PROCESSUTILS_API __declspec(dllimport)
#endif

#include <minwindef.h>
#include <string>


namespace ProcessUtils {

    PROCESSUTILS_API DWORD GetProcessPid(
        const std::wstring &wstrProcessName
    );

    PROCESSUTILS_API DWORD GetProcessPid(
        const std::wstring &wstrProcessName,
        const std::wstring &wstrCmdLineStr
    );

    PROCESSUTILS_API bool KillProcess(
        const std::wstring &wstrProcessName,
        const std::wstring &wstrCmdLineStr = L""
    );

    PROCESSUTILS_API std::wstring GetProcessCmdLine(
        DWORD pid
    );
	PROCESSUTILS_API std::string GetProcessCmdLineByCmd(
		DWORD dwPID
	);
	PROCESSUTILS_API bool CheckProcessModuleExist(
		DWORD pid,
		const std::wstring &wstrModuleName
	);

};