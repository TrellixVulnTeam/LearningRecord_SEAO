
#include "framework.h"
#include "WindowsUtils.h"

namespace WindowsUtils {

    WinVer CheckWindowsVersion() {
        WinVer winver = WinVer::Unknown;

        do {
            typedef LONG(__stdcall* FN_RtlGetVersion)(PRTL_OSVERSIONINFOW);
            HINSTANCE instance = LoadLibrary(TEXT("ntdll.dll"));
            if (!instance) {
                break;
            }

            FN_RtlGetVersion fnRtlGetVersion = (FN_RtlGetVersion)GetProcAddress(instance, "RtlGetVersion");
            if (!fnRtlGetVersion) {
                break;
            }

            RTL_OSVERSIONINFOEXW verInfo;
            memset(&verInfo, 0, sizeof(RTL_OSVERSIONINFOEXW));
            verInfo.dwOSVersionInfoSize = sizeof(RTL_OSVERSIONINFOEXW);
            fnRtlGetVersion((PRTL_OSVERSIONINFOW)&verInfo);

            if (verInfo.dwMajorVersion == 10 &&
                verInfo.dwMinorVersion == 0 &&
                verInfo.dwBuildNumber >= 22000 &&
                verInfo.wProductType == VER_NT_WORKSTATION
                ) {
                winver = WinVer::Win11;
            } else if (verInfo.dwMajorVersion == 10 &&
                verInfo.dwMinorVersion == 0 &&
                verInfo.dwBuildNumber <= 20348 &&
                verInfo.dwBuildNumber > 17763 &&
                verInfo.wProductType != VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinServer_2022;
            } else if (verInfo.dwMajorVersion == 10 &&
                verInfo.dwMinorVersion == 0 &&
                verInfo.dwBuildNumber <= 17763 &&
                verInfo.dwBuildNumber > 14393 &&
                verInfo.wProductType != VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinServer_2019;
            } else if (verInfo.dwMajorVersion == 10 &&
                verInfo.dwMinorVersion == 0 &&
                verInfo.dwBuildNumber <= 14393 &&
                verInfo.wProductType != VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinServer_2016;
            } else if (verInfo.dwMajorVersion == 10 &&
                verInfo.dwMinorVersion == 0 &&
                verInfo.dwBuildNumber < 22000 &&
                verInfo.wProductType == VER_NT_WORKSTATION
                ) {
                winver = WinVer::Win10;
            } else if (verInfo.dwMajorVersion == 6 &&
                verInfo.dwMinorVersion == 3 &&
                verInfo.wProductType != VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinServer_2012_R2;
            } else if (verInfo.dwMajorVersion == 6 &&
                verInfo.dwMinorVersion == 3 &&
                verInfo.wProductType == VER_NT_WORKSTATION
                ) {
                winver = WinVer::Win8_1;
            } else if (verInfo.dwMajorVersion == 6 &&
                verInfo.dwMinorVersion == 2 &&
                verInfo.wProductType != VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinServer_2012;
            } else if (verInfo.dwMajorVersion == 6 &&
                verInfo.dwMinorVersion == 2 &&
                verInfo.wProductType == VER_NT_WORKSTATION
                ) {
                winver = WinVer::Win8;
            } else if (verInfo.dwMajorVersion == 6 &&
                verInfo.dwMinorVersion == 1 &&
                verInfo.wProductType != VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinServer_2008_R2;
            } else if (verInfo.dwMajorVersion == 6 &&
                verInfo.dwMinorVersion == 1 &&
                verInfo.wProductType == VER_NT_WORKSTATION
                ) {
                winver = WinVer::Win7;
            } else if (verInfo.dwMajorVersion == 6 &&
                verInfo.dwMinorVersion == 0 &&
                verInfo.wProductType != VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinServer_2008;
            } else if (verInfo.dwMajorVersion == 6 &&
                verInfo.dwMinorVersion == 0 &&
                verInfo.wProductType == VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinVista;
            } else if (verInfo.dwMajorVersion == 5 &&
                verInfo.dwMinorVersion == 2 &&
                verInfo.wProductType != VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinServer_2003;
            } else if (verInfo.dwMajorVersion == 5 &&
                verInfo.dwMinorVersion == 2 &&
                verInfo.wProductType == VER_NT_WORKSTATION
                ) {
                winver = WinVer::WinXP_Professional_x64;
            } else if (verInfo.dwMajorVersion == 5 &&
                verInfo.dwMinorVersion == 1
                ) {
                winver = WinVer::WinXP;
            } else if (verInfo.dwMajorVersion == 5 &&
                verInfo.dwMinorVersion == 0) {
                winver = WinVer::Win2000;
            }
        } while (false);

        return winver;
    }

    static HINSTANCE s_shell32Instance = NULL;
    bool GUIDFromString(const wchar_t *guidString, GUID *guid) {
        bool ret = false;

        do {
            if (guid) {
                memset(guid, 0, sizeof(GUID));
            } else {
                break;
            }

            if (!guidString) {
                break;
            }

            if (!s_shell32Instance) {
                s_shell32Instance = LoadLibrary(TEXT("Shell32.dll"));
            }

            if (!s_shell32Instance) {
                break;
            }

            typedef BOOL(__stdcall* FN_GUIDFromStringW)(LPCTSTR, LPGUID);
            DWORD ordinal = 704;
            FN_GUIDFromStringW fnGUIDFromString = (FN_GUIDFromStringW)GetProcAddress(s_shell32Instance, MAKEINTRESOURCEA(ordinal));
            if (!fnGUIDFromString) {
                break;
            }

            ret = !!fnGUIDFromString(guidString, guid);

        } while (false);

        return ret;
    }

    std::wstring GUIDToString(const GUID &guid) {
        wchar_t guidString[64];
        memset(guidString, 0, sizeof(guidString));
        auto ret = StringFromGUID2(guid, guidString, sizeof(guidString) / sizeof(guidString[0]));

        return guidString;
    }

    std::wstring GetLastErrorMsg(DWORD errCode) {
        std::wstring wstrErrMsg;

        LPVOID msgBuf = NULL;

        DWORD ret = FormatMessageW(
            FORMAT_MESSAGE_ALLOCATE_BUFFER |
            FORMAT_MESSAGE_FROM_SYSTEM |
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            errCode,
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            (LPWSTR)&msgBuf,
            0, NULL);

        if (msgBuf) {
            wstrErrMsg = (const wchar_t*)msgBuf;
            LocalFree(msgBuf);
        }

        return wstrErrMsg;
    }

    std::vector<UsbDevice> EnumUsbDevices(bool getDetailData) {
        std::vector<UsbDevice> usbDevices;

        do {
            LIST_ENTRY listHead;
            InitializeListHead(&listHead);
            EnumerateHostControllers(&listHead, (getDetailData ? 1 : 0));

            if (!IsListEmpty(&listHead)) {
                PLIST_ENTRY pEntry = listHead.Flink;

                while (pEntry != &listHead) {
                    PDEVICE_INFO devInfo = CONTAINING_RECORD(pEntry,
                        DEVICE_INFO,
                        listEntry);

                    pEntry = pEntry->Flink;

                    if (devInfo) {
                        UsbDevice usbDevice;
                        usbDevice.devInst = devInfo->devInst;

                        switch (devInfo->deviceType) {
                        case 0:
                            usbDevice.deviceType = DeviceType::keyboard;
                            break;
                        case 1:
                            usbDevice.deviceType = DeviceType::mouse;
                            break;
                        case 2:
                            usbDevice.deviceType = DeviceType::bluetooth;
                            break;
                        case 3:
                            usbDevice.deviceType = DeviceType::android_device;
                            break;
                        case 4:
                            usbDevice.deviceType = DeviceType::apple_device;
                            break;
                        default:
                            break;
                        }

                        if (devInfo->portChain) {
                            usbDevice.wstrPortChain = devInfo->portChain;
                            FREE(devInfo->portChain);
                        }

                        if (devInfo->companionPortChain) {
                            usbDevice.wstrCompanionPortChain = devInfo->companionPortChain;
                            FREE(devInfo->companionPortChain);
                        }

                        if (devInfo->manufacturer) {
                            usbDevice.wstrManufacturer = devInfo->manufacturer;
                            FREE(devInfo->manufacturer);
                        }

                        if (devInfo->deviceId) {
                            usbDevice.wstrDeviceID = devInfo->deviceId;
                            FREE(devInfo->deviceId);
                        }

                        if (!IsListEmpty(&devInfo->listEntryDeviceDriver)) {
                            PLIST_ENTRY listEntryDeviceDriver = devInfo->listEntryDeviceDriver.Flink;

                            while (listEntryDeviceDriver != &devInfo->listEntryDeviceDriver) {
                                PDEVICE_DRIVER_INFO deviceDriverInfo = CONTAINING_RECORD(listEntryDeviceDriver,
                                    DEVICE_DRIVER_INFO,
                                    listEntry);

                                listEntryDeviceDriver = listEntryDeviceDriver->Flink;

                                if (!deviceDriverInfo) {
                                    continue;
                                }

                                DeviceDriverInfo driverInfo;

                                if (!IsListEmpty(&deviceDriverInfo->listEntryDeviceInterface)) {
                                    PLIST_ENTRY listEntryDeviceInterface = deviceDriverInfo->listEntryDeviceInterface.Flink;

                                    while (listEntryDeviceInterface != &deviceDriverInfo->listEntryDeviceInterface) {
                                        PDEVICE_INTERFACE_INFO deviceInterfaceInfo = CONTAINING_RECORD(listEntryDeviceInterface,
                                            DEVICE_INTERFACE_INFO,
                                            listEntry);

                                        listEntryDeviceInterface = listEntryDeviceInterface->Flink;

                                        if (!deviceInterfaceInfo) {
                                            continue;
                                        }

                                        DeviceInterfaceInfo interfaceInfo;

                                        if (deviceInterfaceInfo->devicePath) {
                                            interfaceInfo.wstrDevicePath = deviceInterfaceInfo->devicePath;
                                            FREE(deviceInterfaceInfo->devicePath);
                                        }

                                        if (deviceInterfaceInfo->interfaceClassGUID) {
                                            interfaceInfo.wstrInterfaceClassGUID = deviceInterfaceInfo->interfaceClassGUID;
                                            FREE(deviceInterfaceInfo->interfaceClassGUID);
                                        }

                                        if (!interfaceInfo.wstrDevicePath.empty()) {
                                            driverInfo.deviceInterfaceInfoMap.insert({ interfaceInfo.wstrDevicePath, interfaceInfo });
                                        }

                                        FREE(deviceInterfaceInfo);
                                    }
                                }

                                if (deviceDriverInfo->driverKeyName) {
                                    driverInfo.wstrDriveKeyName = deviceDriverInfo->driverKeyName;
                                    FREE(deviceDriverInfo->driverKeyName);
                                }

                                if (deviceDriverInfo->instanceId) {
                                    driverInfo.wstrDeviceInstanceId = deviceDriverInfo->instanceId;
                                    FREE(deviceDriverInfo->instanceId);
                                }

                                if (deviceDriverInfo->desc) {
                                    driverInfo.wstrDescription = deviceDriverInfo->desc;
                                    FREE(deviceDriverInfo->desc);
                                }

                                if (deviceDriverInfo->friendlyName) {
                                    if (driverInfo.wstrDescription.empty()) {
                                        driverInfo.wstrDescription = deviceDriverInfo->friendlyName;
                                    }
                                    FREE(deviceDriverInfo->friendlyName);
                                }

                                if (deviceDriverInfo->locationInfo) {
                                    driverInfo.wstrLocationInfo = deviceDriverInfo->locationInfo;
                                    FREE(deviceDriverInfo->locationInfo);
                                }

                                if (deviceDriverInfo->className) {
                                    driverInfo.wstrClassName = deviceDriverInfo->className;
                                    FREE(deviceDriverInfo->className);
                                }

                                if (deviceDriverInfo->classGUID) {
                                    WCHAR *p = deviceDriverInfo->classGUID;
                                    while (*p) {
                                        *p = ::towlower(*p);
                                        p++;
                                    }

                                    driverInfo.wstrClassGUID = deviceDriverInfo->classGUID;
                                }

                                FREE(deviceDriverInfo);

                                usbDevice.driverInfoMap.insert({ driverInfo.wstrDriveKeyName, driverInfo });
                            }
                        }

                        if (devInfo->deviceType != -2) {
                            usbDevices.push_back(std::move(usbDevice));
                        }

                        FREE(devInfo);
                    }
                }
            }

        } while (false);

        return usbDevices;
    }

}