// stdafx.h : ��׼ϵͳ�����ļ��İ����ļ���
// ���Ǿ���ʹ�õ��������ĵ�
// �ض�����Ŀ�İ����ļ�
//

#pragma once
#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             // �� Windows ͷ���ų�����ʹ�õ�����
// Windows ͷ�ļ�: 
#include <WinSock2.h>
#include <windows.h>


#pragma comment(lib,"ws2_32.lib")
// TODO:  �ڴ˴����ó�����Ҫ������ͷ�ļ�
#include <StringConvertor/StringConvertor.h>
#include <curl/curl.h>
#include <list>
#include <io.h>
#include <thread>
#include <chrono>
#include <atomic>

#pragma comment(lib, "libcurl")
#pragma comment(lib, "StringConvertor")