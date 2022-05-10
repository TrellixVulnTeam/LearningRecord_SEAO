// ConsoleApplication1.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include <iostream>

#include <WindowsUtils/WindowsUtils.h>
#pragma comment(lib, "WindowsUtils")

#include <EmlUtils/EmlUtils.h>
#pragma comment(lib, "EmlUtils")

int main(int argc, char *argv[])
{
    auto usbDevices = WindowsUtils::EnumUsbDevices();

    std::wstring wstrEmlFilePath = LR"(E:\test\MCloudData\outlook\转发_ 测试附件.eml)";
    auto emlInfo = EmlUtils::ParseEmlFile(wstrEmlFilePath);

    return 0;
}