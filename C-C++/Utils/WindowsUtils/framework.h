// header.h: 标准系统包含文件的包含文件，
// 或特定于项目的包含文件
//

#pragma once

#define WIN32_LEAN_AND_MEAN             // 从 Windows 头文件中排除极少使用的内容
#define _INTSAFE_H_INCLUDED_
#include <windows.h>
#define NOMINMAX
#include <Shlwapi.h>
#include <Dbt.h>
#include <SetupAPI.h>
#include <devioctl.h>
#include <usbioctl.h>
#include <usbiodef.h>
#include <strsafe.h>

#pragma comment(lib, "SetupAPI")
#pragma comment(lib, "Shlwapi")

#ifdef __cplusplus
extern "C"
{
#endif
#include "uvcview.h"
#ifdef __cplusplus
}
#endif