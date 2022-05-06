#pragma once

#ifdef WINDOWSUTILS_EXPORTS
    #define WINDOWSUTILS_API __declspec(dllexport)
#else
    #define WINDOWSUTILS_API __declspec(dllimport)
#endif

#include <string>
#include <vector>
#include <map>
#include <guiddef.h>

namespace WindowsUtils {

    /*
    https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/ns-wdm-_osversioninfoexw
    Operating system                                   	Version number  dwMajorVersion  dwMinorVersion  Other
    Windows 11                                          10.0            10              0               wProductType == VER_NT_WORKSTATION
    Windows Server 2022                                 10.0            10              0               wProductType != VER_NT_WORKSTATION
    Windows Server 2019                                 10.0            10              0               wProductType != VER_NT_WORKSTATION
    Windows 10 (all releases)                           10.0            10              0               wProductType == VER_NT_WORKSTATION
    Windows Server 2016                                 10.0            10              0               wProductType != VER_NT_WORKSTATION
    Windows Server 2012 R2                              6.3             6               3               wProductType != VER_NT_WORKSTATION
    Windows 8.1                                         6.3             6               3               wProductType == VER_NT_WORKSTATION
    Windows 8                                           6.2             6               2               wProductType == VER_NT_WORKSTATION
    Windows Server 2012                                 6.2             6               2               wProductType != VER_NT_WORKSTATION
    Windows 7                                           6.1             6               1               wProductType == VER_NT_WORKSTATION
    Windows Server 2008 R2                              6.1             6               1               wProductType != VER_NT_WORKSTATION
    Windows Server 2008                                 6.0             6               0               wProductType != VER_NT_WORKSTATION
    Windows Vista                                       6.0             6               0               wProductType == VER_NT_WORKSTATION
    Windows Home Server                                 5.2             5               2               wSuiteMask == VER_SUITE_WH_SERVER
    Windows Server 2003                                 5.2             5               2               Not applicable
    Windows XP Professional x64 Edition (see note)      5.2             5               2               wProductType == VER_NT_WORKSTATION
    Windows XP                                          5.1             5               1               Not applicable
    Windows 2000                                        5.0             5               0               Not applicable

    https://en.wikipedia.org/wiki/Microsoft_Windows
    Table of Windows versions
    Product name                                                Latest version
    Windows 1.0                                                 1.01
    Windows 2.0                                                 2.03
    Windows 2.1                                                 2.11
    Windows 3.0                                                 3
    Windows 3.1                                                 3.1
    Windows For Workgroups 3.1                                  3.1
    Windows NT 3.1                                              NT 3.1.528
    Windows For Workgroups 3.11                                 3.11
    Windows 3.2                                                 3.2
    Windows NT 3.5                                              NT 3.5.807
    Windows NT 3.51                                             NT 3.51.1057
    Windows 95                                                  4.0.950
    Windows NT 4.0                                              NT 4.0.1381
    Windows 98                                                  4-Oct-98
    Windows 98 SE                                               4.10.2222
    Windows 2000                                                NT 5.0.2195
    Windows Me                                                  4.90.3000
    Windows XP                                                  NT 5.1.2600
    Windows XP 64-bit Edition                                   NT 5.2.3790
    Windows Server 2003                                         NT 5.2.3790
    Windows XP Professional x64 Edition                         NT 5.2.3790
    Windows Fundamentals for Legacy PCs                         NT 5.1.2600
    Windows Vista                                               NT 6.0.6003
    Windows Home Server                                         NT 5.2.4500
    Windows Server 2008                                         NT 6.0.6003
    Windows 7                                                   NT 6.1.7601
    Windows Server 2008 R2                                      NT 6.1.7601
    Windows Home Server 2011                                    NT 6.1.8400
    Windows Server 2012                                         NT 6.2.9200
    Windows 8                                                   NT 6.2.9200
    Windows 8.1                                                 NT 6.3.9600
    Windows Server 2012 R2                                      NT 6.3.9600
    Windows 10                                                  NT 10.0.19044
    Windows Server 2016                                         NT 10.0.14393
    Windows Server 2019                                         NT 10.0.17763
    Windows Server 2022                                         NT 10.0.20348
    Windows 11                                                  NT 10.0.22000
    */

    /*
    https://en.wikipedia.org/wiki/Windows_10
    Windows 10 versions
    Version Build
    1507    10240
    1511    10586
    1607    14393
    1703    15063
    1709    16299
    1803    17134
    1809    17763
    1903    18362
    1909    18363
    2004    19041
    20H2    19042
    21H1    19043
    21H2    19044
    */

    enum class WinVer {
        Unknown,
        Win2000,
        WinXP,
        WinXP_Professional_x64,
        WinServer_2003,
        WinVista,
        WinServer_2008,
        WinServer_2008_R2,
        Win7,
        WinServer_2012,
        Win8,
        Win8_1,
        WinServer_2012_R2,
        WinServer_2016,
        Win10,
        WinServer_2019,
        WinServer_2022,
        Win11
    };

    WINDOWSUTILS_API WinVer CheckWindowsVersion();

    // eg. guidString = {3f966bd9-fa04-4ec5-991c-d326973b5128} or {3F966BD9-FA04-4EC5-991C-D326973B5128}
    WINDOWSUTILS_API bool GUIDFromString(const wchar_t *guidString, GUID *guid);

    // eg. output = {3F966BD9-FA04-4EC5-991C-D326973B5128}
    WINDOWSUTILS_API std::wstring GUIDToString(const GUID &guid);

    struct DeviceInterfaceInfo {
        // eg. {a5dcbf10-6530-11d2-901f-00c04fb951ed} GUID_DEVINTERFACE_USB_DEVICE
        std::wstring wstrInterfaceClassGUID;

        // eg. \\?\USB#VID_12D1&PID_107E#RKK0218103000878#{a5dcbf10-6530-11d2-901f-00c04fb951ed}
        std::wstring wstrDevicePath;
    };

    // https://github.com/microsoft/Windows-driver-samples/tree/master/usb/usbview
    struct DeviceDriverInfo {
        // device interface info
        // eg. <\\?\USB#VID_12D1&PID_107E#RKK0218103000878#{a5dcbf10-6530-11d2-901f-00c04fb951ed}, {a5dcbf10-6530-11d2-901f-00c04fb951ed}>
        std::map<std::wstring, DeviceInterfaceInfo> deviceInterfaceInfoMap;

        std::wstring wstrDeviceInstanceId;

        // eg. {745a17a0-74d3-11d0-b6fe-00a0c90f57da}\0040
        std::wstring wstrDriveKeyName;

        // device class
        // eg. USB AndroidUsbDeviceClass
        std::wstring wstrClassName;

        // device class guid
        // eg. {36fc9e60-c465-11cf-8056-444553540000} = USB
        // eg. {3f966bd9-fa04-4ec5-991c-d326973b5128} = AndroidUsbDeviceClass
        std::wstring wstrClassGUID;

        // device description
        // eg. Apple Mobile Device USB Composite Device, Android ADB Interface
        std::wstring wstrDescription;

        // eg. Port_#0012.Hub_#0001
        std::wstring wstrLocationInfo;
    };

    enum class DeviceType {
        other_device = -1,
        keyboard = 0,
        mouse,
        android_device,
        apple_device,
    };

    struct UsbDevice {
        UsbDevice() {
            deviceType = DeviceType::other_device;
        }

        DeviceType deviceType;

        // port chain
        // eg. 1-6
        std::wstring wstrPortChain;

        // companion port chain
        // eg. 1-6
        std::wstring wstrCompanionPortChain;

        // device manufacturer eg. Apple, Inc., HUAWEI
        std::wstring wstrManufacturer;

        // android adb device Id eg. HATSAQEALBZ9RG4P
        // apple device uuid eg. 147B1866BFCD57A80E14A288233ECE1804587C53
        // other device type is empty
        std::wstring wstrDeviceID;

        // <driverKeyName, driverInfo>
        std::map<std::wstring, DeviceDriverInfo> driverInfoMap;
    };

    WINDOWSUTILS_API std::vector<UsbDevice> EnumUsbDevices();

}