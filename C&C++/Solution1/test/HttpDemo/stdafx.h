// stdafx.h : 标准系统包含文件的包含文件，
// 或是经常使用但不常更改的
// 特定于项目的包含文件
//

#pragma once

#include "targetver.h"

#include <stdio.h>
#include <tchar.h>



// TODO:  在此处引用程序需要的其他头文件
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