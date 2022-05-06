// ConsoleApplication1.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include <iostream>

#include <WindowsUtils/WindowsUtils.h>
#pragma comment(lib, "WindowsUtils")

int main(int argc, char *argv[])
{
    auto usbDevices = WindowsUtils::EnumUsbDevices();

    return 0;
}