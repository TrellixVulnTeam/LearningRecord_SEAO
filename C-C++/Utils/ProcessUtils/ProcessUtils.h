#pragma once

#ifdef PROCESSUTILS_EXPORTS
#define PROCESSUTILS_API __declspec(dllexport)
#else
#define PROCESSUTILS_API __declspec(dllimport)
#endif

#include <minwindef.h>
#include <string>


namespace ProcessUtils {

    /**
    * 获取进程ID
    *
    * @param wstrProcessName [in] 进程名
    * @param wstrCmdLineStr [in] 进程命令行参数
    * @return 进程ID
    */
    PROCESSUTILS_API DWORD GetProcessPid(
        const std::wstring &wstrProcessName,
        const std::wstring &wstrCmdLineStr = L""
    );

    /**
    * 杀死进程
    *
    * @param wstrProcessName [in] 进程名
    * @param wstrCmdLineStr [in] 进程命令行参数
    * @return true on success, false on failure
    */
    PROCESSUTILS_API bool KillProcess(
        const std::wstring &wstrProcessName,
        const std::wstring &wstrCmdLineStr = L""
    );

    /**
    * 获取进程命令行参数
    *
    * @param wstrProcessName [in] 进程ID
    * @return 进程命令行参数
    */
    PROCESSUTILS_API std::wstring GetProcessCmdLine(
        DWORD pid
    );

    /**
    * 检查进程中模块是否存在
    *
    * @param wstrProcessName [in] 进程ID
    * @param wstrModuleName [in] 模块名
    * @return true on exist, false on not
    */
	PROCESSUTILS_API bool CheckProcessModuleExist(
		DWORD pid,
		const std::wstring &wstrModuleName
	);

    /**
    * 设置线程名称
    *
    * @param tid [in] 线程ID -1时表示当前线程
    * @param threadName [in] 线程名称
    */
    PROCESSUTILS_API void SetThreadName(
        DWORD tid,
        const char *threadName
    );
};