// stdafx.h : ��׼ϵͳ�����ļ��İ����ļ���
// ���Ǿ���ʹ�õ��������ĵ�
// �ض�����Ŀ�İ����ļ�
//

#pragma once

#include "targetver.h"

#include <stdio.h>
#include <tchar.h>



// TODO:  �ڴ˴����ó�����Ҫ������ͷ�ļ�
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <strsafe.h>
#include <Shlwapi.h>

#define CPPHTTPLIB_OPENSSL_SUPPORT
#include "httplib.h"
#pragma comment(lib, "libeay32")
#pragma comment(lib, "ssleay32")

#include <HttpHelper/HttpHelper.h>
#pragma comment(lib, "HttpHelper")