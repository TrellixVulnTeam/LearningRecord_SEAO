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
    * ��ȡ����ID
    *
    * @param wstrProcessName [in] ������
    * @return ����ID
    */
    PROCESSUTILS_API DWORD GetProcessPid(
        const std::wstring &wstrProcessName
    );

    /**
    * ��ȡ����ID
    *
    * @param wstrProcessName [in] ������
    * @param wstrCmdLineStr [in] ���������в���
    * @return ����ID
    */
    PROCESSUTILS_API DWORD GetProcessPid(
        const std::wstring &wstrProcessName,
        const std::wstring &wstrCmdLineStr
    );

    /**
    * ɱ������
    *
    * @param wstrProcessName [in] ������
    * @param wstrCmdLineStr [in] ���������в���
    * @return true on success, false on failure
    */
    PROCESSUTILS_API bool KillProcess(
        const std::wstring &wstrProcessName,
        const std::wstring &wstrCmdLineStr = L""
    );

    /**
    * ��ȡ���������в���
    *
    * @param wstrProcessName [in] ����ID
    * @return ���������в���
    */
    PROCESSUTILS_API std::wstring GetProcessCmdLine(
        DWORD pid
    );

    /**
    * ��ȡ���������в���
    *
    * @param wstrProcessName [in] ����ID
    * @return ���������в���
    */
	PROCESSUTILS_API std::string GetProcessCmdLineByCmd(
		DWORD pid
	);

    /**
    * ��������ģ���Ƿ����
    *
    * @param wstrProcessName [in] ����ID
    * @param wstrModuleName [in] ģ����
    * @return true on exist, false on not
    */
	PROCESSUTILS_API bool CheckProcessModuleExist(
		DWORD pid,
		const std::wstring &wstrModuleName
	);

    /**
    * �����߳�����
    *
    * @param tid [in] �߳�ID -1ʱ��ʾ��ǰ�߳�
    * @param threadName [in] �߳�����
    */
    PROCESSUTILS_API void SetThreadName(
        DWORD tid,
        const char *threadName
    );
};