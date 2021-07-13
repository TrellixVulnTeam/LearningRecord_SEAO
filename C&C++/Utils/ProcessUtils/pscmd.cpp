/*
	Pscmd
	--------
	License     	Apache 2.0 License
	--------
	Copyright 2018 SMALLSO Studios.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	------
	E-mail      	xiaoyy@altca.cn
	WorkQQ   	20177621
	Website   	https://www.xiaoyy.org/
	------
	SMALLSO Studios.
	2018/5/17 22:08
*/

#include "stdafx.h"
#include <winternl.h>
#include "pscmd.h"

/* Defining the request result status code in NTSTATUS */
#define STATUS_SUCCESS ((NTSTATUS)0x00000000L)

/* NTAPI ZwQueryInformationProcess */
typedef NTSTATUS(NTAPI * Typedef_ZwQueryInformationProcess)(HANDLE, PROCESSINFOCLASS, PVOID, ULONG, PULONG);
Typedef_ZwQueryInformationProcess pNTAPI_ZwQueryInformationProcess =
(Typedef_ZwQueryInformationProcess)GetProcAddress(GetModuleHandle(L"ntdll.dll"), "ZwQueryInformationProcess");

/*
	��ȡָ�������������ַ�����ʧ�ܷ��� FALSE��Unicode Version��
	--------
	HANDLE hProcess							���ȡ���������ַ����Ľ��̾�����þ��Ӧ���� PROCESS_QUERY_INFORMATION �� PROCESS_VM_READ ����Ȩ��
	LPCWSTR lpcBuffer							ָ������������ַ����Ŀ��ַ�������ָ�룬������Ӧʹ�� memset ��ʼ��Ϊ zero���ò�������Ϊ NULL
	SIZE_T nSize										���� lpcBuffer ָ��Ŀ��ַ���������Ч��С��Bytes�����ò�������Ϊ NULL
	SIZE_T* lpNumberOfBytesCopied	ʵ�ʸ��Ƶ� lpcBuffer ָ��Ŀ��ַ��������е��ֽ�����Bytes������ lpcBuffer Ϊ NULL �� nSize ̫С���ò������������軺�����Ľ����С��Bytes�����ò�������Ϊ NULL
*/
bool GetProcessCommandLineW(HANDLE hProcess, LPCWSTR lpcBuffer, SIZE_T nSize, SIZE_T* lpNumberOfBytesCopied)
{
	bool result = false;
	if (pNTAPI_ZwQueryInformationProcess)
	{
		PROCESS_BASIC_INFORMATION BasicInfo; memset(&BasicInfo, NULL, sizeof(BasicInfo));
		PEB PebBaseInfo; memset(&PebBaseInfo, NULL, sizeof(PebBaseInfo));
		RTL_USER_PROCESS_PARAMETERS ProcessParameters; memset(&ProcessParameters, NULL, sizeof(ProcessParameters));
		if (pNTAPI_ZwQueryInformationProcess(hProcess, PROCESSINFOCLASS::ProcessBasicInformation, &BasicInfo, sizeof(BasicInfo), NULL) == STATUS_SUCCESS)
		{
			if (ReadProcessMemory(hProcess, BasicInfo.PebBaseAddress, &PebBaseInfo, sizeof(PebBaseInfo), NULL)
				&& ReadProcessMemory(hProcess, PebBaseInfo.ProcessParameters, &ProcessParameters, sizeof(ProcessParameters), NULL))
			{
				if (lpcBuffer && nSize >= ProcessParameters.CommandLine.Length + 2)
                    result = !!ReadProcessMemory(hProcess, ProcessParameters.CommandLine.Buffer, (LPVOID)lpcBuffer,
						ProcessParameters.CommandLine.Length, lpNumberOfBytesCopied);
				else if (lpNumberOfBytesCopied) { *lpNumberOfBytesCopied = ProcessParameters.CommandLine.Length + 2; result = true; }
			}
		}
	}
	return result;
}
