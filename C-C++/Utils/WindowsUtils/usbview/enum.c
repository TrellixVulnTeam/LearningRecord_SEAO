/*++

Copyright (c) 1997-2011 Microsoft Corporation

Module Name:

    ENUM.C

Abstract:

    This source file contains the routines which enumerate the USB bus
    and populate the TreeView control.

    The enumeration process goes like this:

    (1) Enumerate Host Controllers and Root Hubs
    EnumerateHostControllers()
    EnumerateHostController()
    Host controllers currently have symbolic link names of the form HCDx,
    where x starts at 0.  Use CreateFile() to open each host controller
    symbolic link.  Create a node in the TreeView to represent each host
    controller.

    GetRootHubName()
    After a host controller has been opened, send the host controller an
    IOCTL_USB_GET_ROOT_HUB_NAME request to get the symbolic link name of
    the root hub that is part of the host controller.

    (2) Enumerate Hubs (Root Hubs and External Hubs)
    EnumerateHub()
    Given the name of a hub, use CreateFile() to map the hub.  Send the
    hub an IOCTL_USB_GET_NODE_INFORMATION request to get info about the
    hub, such as the number of downstream ports.  Create a node in the
    TreeView to represent each hub.

    (3) Enumerate Downstream Ports
    EnumerateHubPorts()
    Given an handle to an open hub and the number of downstream ports on
    the hub, send the hub an IOCTL_USB_GET_NODE_CONNECTION_INFORMATION_EX
    request for each downstream port of the hub to get info about the
    device (if any) attached to each port.  If there is a device attached
    to a port, send the hub an IOCTL_USB_GET_NODE_CONNECTION_NAME request
    to get the symbolic link name of the hub attached to the downstream
    port.  If there is a hub attached to the downstream port, recurse to
    step (2).

    GetAllStringDescriptors()
    GetConfigDescriptor()
    Create a node in the TreeView to represent each hub port
    and attached device.


Environment:

    user mode

Revision History:

    04-25-97 : created

--*/

//*****************************************************************************
// I N C L U D E S
//*****************************************************************************

#include "uvcview.h"

//*****************************************************************************
// D E F I N E S
//*****************************************************************************

#define NUM_STRING_DESC_TO_GET 32

//*****************************************************************************
// L O C A L    F U N C T I O N    P R O T O T Y P E S
//*****************************************************************************

VOID
EnumerateHostController(
    HANDLE                   hHCDev,
    _Inout_ PWCHAR            leafName,
    _In_    HANDLE           deviceInfo,
    _In_    PSP_DEVINFO_DATA deviceInfoData,
    PLIST_ENTRY listHead,
    _Inout_ PWCHAR portChain,
    _In_ size_t cbPortChain
);

VOID
EnumerateHub(
    _In_reads_(cbHubName) PWCHAR                     HubName,
    _In_ size_t                                     cbHubName,
    _In_opt_ PUSB_NODE_CONNECTION_INFORMATION_EX    ConnectionInfo,
    _In_opt_ PUSB_NODE_CONNECTION_INFORMATION_EX_V2 ConnectionInfoV2,
    _In_opt_ PUSB_PORT_CONNECTOR_PROPERTIES         PortConnectorProps,
    _In_opt_ PSTRING_DESCRIPTOR_NODE                StringDescs,
    PLIST_ENTRY                                     listHead,
    _Inout_ PWCHAR                                  portChain,
    _In_ size_t                                     cbPortChain
);

VOID
EnumerateHubPorts(
    HANDLE      hHubDevice,
    ULONG       NumPorts,
    PLIST_ENTRY listHead,
    _Inout_ PWCHAR portChain,
    _In_ size_t cbPortChain
);

PWCHAR GetRootHubName(
    HANDLE HostController
);

PWCHAR GetExternalHubName(
    HANDLE  Hub,
    ULONG   ConnectionIndex
);

PWCHAR GetHCDDriverKeyName(
    HANDLE  HCD
);

PWCHAR GetDriverKeyName(
    HANDLE  Hub,
    ULONG   ConnectionIndex
);

DWORD
GetHostControllerPowerMap(
    HANDLE hHCDev,
    PUSBHOSTCONTROLLERINFO hcInfo);

DWORD
GetHostControllerInfo(
    HANDLE hHCDev,
    PUSBHOSTCONTROLLERINFO hcInfo);

PCHAR WideStrToMultiStr(
    _In_reads_bytes_(cbWideStr) PWCHAR WideStr,
    _In_ size_t                   cbWideStr
);

PWCHAR MultiStrToWideStr(
    _In_reads_bytes_(cbMultiStr) PCHAR MultiStr,
    _In_ size_t                   cbMultiStr
);

DWORD
GetHostControllerPowerMap(
    HANDLE hHCDev,
    PUSBHOSTCONTROLLERINFO hcInfo);

DWORD
GetHostControllerInfo(
    HANDLE hHCDev,
    PUSBHOSTCONTROLLERINFO hcInfo);

PSTRING_DESCRIPTOR_NODE
GetAllStringDescriptors(
    HANDLE                          hHubDevice,
    ULONG                           ConnectionIndex,
    PUSB_DEVICE_DESCRIPTOR          DeviceDesc
);

HRESULT
GetStringDescriptors(
    _In_ HANDLE                         hHubDevice,
    _In_ ULONG                          ConnectionIndex,
    _In_ UCHAR                          DescriptorIndex,
    _In_ ULONG                          NumLanguageIDs,
    _In_reads_(NumLanguageIDs) USHORT  *LanguageIDs,
    _In_ PSTRING_DESCRIPTOR_NODE        StringDescNodeHead
);

PSTRING_DESCRIPTOR_NODE
GetStringDescriptor(
    HANDLE  hHubDevice,
    ULONG   ConnectionIndex,
    UCHAR   DescriptorIndex,
    USHORT  LanguageID
);

//*****************************************************************************
//
// EnumerateHostControllers()
//
// should be added.
//
//*****************************************************************************

VOID
EnumerateHostControllers(PLIST_ENTRY listHead) {
    HANDLE                           hHCDev = NULL;
    HDEVINFO                         deviceInfo = NULL;
    SP_DEVINFO_DATA                  deviceInfoData;
    SP_DEVICE_INTERFACE_DATA         deviceInterfaceData;
    PSP_DEVICE_INTERFACE_DETAIL_DATA_W deviceDetailData = NULL;
    ULONG                            index = 0;
    ULONG                            requiredLength = 0;
    BOOL                             success;

    do {
        // Iterate over host controllers using the new GUID based interface
        //
        deviceInfo = SetupDiGetClassDevsW((LPGUID)&GUID_CLASS_USB_HOST_CONTROLLER,
            NULL,
            NULL,
            (DIGCF_PRESENT | DIGCF_DEVICEINTERFACE));

        if (INVALID_HANDLE_VALUE == deviceInfo) {
            break;
        }

        deviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

        for (index = 0;
            SetupDiEnumDeviceInfo(deviceInfo,
                index,
                &deviceInfoData);
            index++) {
            do {
                deviceInterfaceData.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

                success = SetupDiEnumDeviceInterfaces(deviceInfo,
                    0,
                    (LPGUID)&GUID_CLASS_USB_HOST_CONTROLLER,
                    index,
                    &deviceInterfaceData);

                if (!success) {
                    OOPS();
                    break;
                }

                success = SetupDiGetDeviceInterfaceDetailW(deviceInfo,
                    &deviceInterfaceData,
                    NULL,
                    0,
                    &requiredLength,
                    NULL);

                if (!success && GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
                    OOPS();
                    break;
                }

                deviceDetailData = ALLOC(requiredLength);
                if (deviceDetailData == NULL) {
                    OOPS();
                    break;
                }

                deviceDetailData->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA_W);

                success = SetupDiGetDeviceInterfaceDetailW(deviceInfo,
                    &deviceInterfaceData,
                    deviceDetailData,
                    requiredLength,
                    &requiredLength,
                    NULL);

                if (!success) {
                    OOPS();
                    break;
                }

                hHCDev = CreateFileW(deviceDetailData->DevicePath,
                    GENERIC_WRITE,
                    FILE_SHARE_WRITE,
                    NULL,
                    OPEN_EXISTING,
                    0,
                    NULL);

                // If the handle is valid, then we've successfully opened a Host
                // Controller.  Display some info about the Host Controller itself,
                // then enumerate the Root Hub attached to the Host Controller.
                //
                if (hHCDev != INVALID_HANDLE_VALUE) {
                    size_t cbPortChain = 512;
                    PWCHAR portChain = ALLOC(cbPortChain);
                    if (portChain) {
                        StringCbPrintfW(portChain, cbPortChain, L"%d", index + 1);

                        EnumerateHostController(hHCDev,
                            deviceDetailData->DevicePath,
                            deviceInfo,
                            &deviceInfoData,
                            listHead,
                            portChain,
                            cbPortChain);
                    }

                    if (portChain) {
                        FREE(portChain);
                    }

                    CloseHandle(hHCDev);
                }
            } while (0);

            if (NULL != deviceDetailData) {
                FREE(deviceDetailData);
            }
        }

    } while (0);

    if (INVALID_HANDLE_VALUE == deviceInfo) {
        SetupDiDestroyDeviceInfoList(deviceInfo);
    }

    return;
}

//*****************************************************************************
//
// EnumerateHostController()
//
//*****************************************************************************

VOID
EnumerateHostController(
    HANDLE                   hHCDev,
    _Inout_ PWCHAR           leafName,
    _In_    HANDLE           deviceInfo,
    _In_    PSP_DEVINFO_DATA deviceInfoData,
    PLIST_ENTRY listHead,
    _Inout_ PWCHAR portChain,
    _In_ size_t cbPortChain
) {
    PWCHAR                   driverKeyName = NULL;
    PWCHAR                   rootHubName = NULL;
    PUSBHOSTCONTROLLERINFO  hcInfo = NULL;
    PUSBHOSTCONTROLLERINFO  hcInfoInList = NULL;
    DWORD                   dwSuccess;
    BOOL                    success = FALSE;
    ULONG                   deviceAndFunction = 0;
    PUSB_DEVICE_PNP_STRINGS DevProps = NULL;


    // Allocate a structure to hold information about this host controller.
    //
    hcInfo = (PUSBHOSTCONTROLLERINFO)ALLOC(sizeof(USBHOSTCONTROLLERINFO));

    // just return if could not alloc memory
    if (NULL == hcInfo)
        return;

    hcInfo->DeviceInfoType = HostControllerInfo;

    // Obtain the driver key name for this host controller.
    //
    driverKeyName = GetHCDDriverKeyName(hHCDev);

    if (NULL == driverKeyName) {
        // Failure obtaining driver key name.
        OOPS();
        FREE(hcInfo);
        return;
    }

    // Obtain host controller device properties
    {
        size_t cbDriverName = 0;
        HRESULT hr = S_OK;

        hr = StringCbLengthW(driverKeyName, MAX_DRIVER_KEY_NAME * sizeof(WCHAR), &cbDriverName);
        if (SUCCEEDED(hr)) {
            DevProps = DriverNameToDeviceProperties(driverKeyName, cbDriverName);
        }
    }

    hcInfo->DriverKey = driverKeyName;

    if (DevProps) {
        ULONG   ven, dev, subsys, rev;
        ven = dev = subsys = rev = 0;

        if (swscanf_s(DevProps->DeviceId,
            L"PCI\\VEN_%x&DEV_%x&SUBSYS_%x&REV_%x",
            &ven, &dev, &subsys, &rev) != 4) {
            OOPS();
        }

        hcInfo->VendorID = ven;
        hcInfo->DeviceID = dev;
        hcInfo->SubSysID = subsys;
        hcInfo->Revision = rev;
        hcInfo->UsbDeviceProperties = DevProps;
    } else {
        OOPS();
    }

    if (DevProps != NULL && DevProps->DeviceDesc != NULL) {
        leafName = DevProps->DeviceDesc;
    } else {
        OOPS();
    }

    // Get the USB Host Controller power map
    dwSuccess = GetHostControllerPowerMap(hHCDev, hcInfo);

    if (ERROR_SUCCESS != dwSuccess) {
        OOPS();
    }


    // Get bus, device, and function
    //
    hcInfo->BusDeviceFunctionValid = FALSE;

    success = SetupDiGetDeviceRegistryPropertyW(deviceInfo,
        deviceInfoData,
        SPDRP_BUSNUMBER,
        NULL,
        (PBYTE)&hcInfo->BusNumber,
        sizeof(hcInfo->BusNumber),
        NULL);

    if (success) {
        success = SetupDiGetDeviceRegistryPropertyW(deviceInfo,
            deviceInfoData,
            SPDRP_ADDRESS,
            NULL,
            (PBYTE)&deviceAndFunction,
            sizeof(deviceAndFunction),
            NULL);
    }

    if (success) {
        hcInfo->BusDevice = deviceAndFunction >> 16;
        hcInfo->BusFunction = deviceAndFunction & 0xffff;
        hcInfo->BusDeviceFunctionValid = TRUE;
    }

    // Get the USB Host Controller info
    dwSuccess = GetHostControllerInfo(hHCDev, hcInfo);

    if (ERROR_SUCCESS != dwSuccess) {
        OOPS();
    }

    // Get the name of the root hub for this host
    // controller and then enumerate the root hub.
    //
    rootHubName = GetRootHubName(hHCDev);

    if (rootHubName != NULL) {
        size_t cbHubName = 0;
        HRESULT hr = S_OK;

        hr = StringCbLengthW(rootHubName, MAX_DRIVER_KEY_NAME * sizeof(WCHAR), &cbHubName);
        if (SUCCEEDED(hr)) {
            EnumerateHub(rootHubName,
                cbHubName,
                NULL,       // ConnectionInfo
                NULL,       // ConnectionInfoV2
                NULL,       // PortConnectorProps
                NULL,       // StringDescs
                listHead,
                portChain,
                cbPortChain);
        }
    } else {
        // Failure obtaining root hub name.

        OOPS();
    }

    return;
}


//*****************************************************************************
//
// EnumerateHub()
//
// HubName - Name of this hub.  This pointer is kept so the caller can neither
// free nor reuse this memory.
//
// ConnectionInfo - NULL if this is a root hub, else this is the connection
// info for an external hub.  This pointer is kept so the caller can neither
// free nor reuse this memory.
//
// ConfigDesc - NULL if this is a root hub, else this is the Configuration
// Descriptor for an external hub.  This pointer is kept so the caller can
// neither free nor reuse this memory.
//
// StringDescs - NULL if this is a root hub.
//
// DevProps - Device properties of the hub
//
//*****************************************************************************

VOID
EnumerateHub(
    _In_reads_(cbHubName) PWCHAR                     HubName,
    _In_ size_t                                     cbHubName,
    _In_opt_ PUSB_NODE_CONNECTION_INFORMATION_EX    ConnectionInfo,
    _In_opt_ PUSB_NODE_CONNECTION_INFORMATION_EX_V2 ConnectionInfoV2,
    _In_opt_ PUSB_PORT_CONNECTOR_PROPERTIES         PortConnectorProps,
    _In_opt_ PSTRING_DESCRIPTOR_NODE                StringDescs,
    PLIST_ENTRY listHead,
    _In_ PWCHAR portChain,
    _In_ size_t cbPortChain
) {
    // Initialize locals to not allocated state so the error cleanup routine
    // only tries to cleanup things that were successfully allocated.
    //
    PUSB_NODE_INFORMATION    hubInfo = NULL;
    PUSB_HUB_INFORMATION_EX  hubInfoEx = NULL;
    PUSB_HUB_CAPABILITIES_EX hubCapabilityEx = NULL;
    HANDLE                  hHubDevice = INVALID_HANDLE_VALUE;
    PVOID                   info = NULL;
    PWCHAR                  deviceName = NULL;
    ULONG                   nBytes = 0;
    BOOL                    success = 0;
    HRESULT                 hr = S_OK;
    size_t                  cchHeader = 0;
    size_t                  cchFullHubName = 0;

    do {
        // Allocate some space for a USBDEVICEINFO structure to hold the
        // hub info, hub name, and connection info pointers.  GPTR zero
        // initializes the structure for us.
        //
        info = ALLOC(sizeof(USBEXTERNALHUBINFO));
        if (info == NULL) {
            OOPS();
            break;
        }

        // Allocate some space for a USB_NODE_INFORMATION structure for this Hub
        //
        hubInfo = (PUSB_NODE_INFORMATION)ALLOC(sizeof(USB_NODE_INFORMATION));
        if (hubInfo == NULL) {
            OOPS();
            break;
        }

        hubInfoEx = (PUSB_HUB_INFORMATION_EX)ALLOC(sizeof(USB_HUB_INFORMATION_EX));
        if (hubInfoEx == NULL) {
            OOPS();
            break;
        }

        hubCapabilityEx = (PUSB_HUB_CAPABILITIES_EX)ALLOC(sizeof(USB_HUB_CAPABILITIES_EX));
        if (hubCapabilityEx == NULL) {
            OOPS();
            break;
        }

        // Keep copies of the Hub Name, Connection Info, and Configuration
        // Descriptor pointers
        //
        ((PUSBROOTHUBINFO)info)->HubInfo = hubInfo;
        ((PUSBROOTHUBINFO)info)->HubName = HubName;

        if (ConnectionInfo != NULL) {
            ((PUSBEXTERNALHUBINFO)info)->DeviceInfoType = ExternalHubInfo;
            ((PUSBEXTERNALHUBINFO)info)->ConnectionInfo = ConnectionInfo;
            ((PUSBEXTERNALHUBINFO)info)->StringDescs = StringDescs;
            ((PUSBEXTERNALHUBINFO)info)->PortConnectorProps = PortConnectorProps;
            ((PUSBEXTERNALHUBINFO)info)->HubInfoEx = hubInfoEx;
            ((PUSBEXTERNALHUBINFO)info)->HubCapabilityEx = hubCapabilityEx;
            ((PUSBEXTERNALHUBINFO)info)->ConnectionInfoV2 = ConnectionInfoV2;
        } else {
            ((PUSBROOTHUBINFO)info)->DeviceInfoType = RootHubInfo;
            ((PUSBROOTHUBINFO)info)->HubInfoEx = hubInfoEx;
            ((PUSBROOTHUBINFO)info)->HubCapabilityEx = hubCapabilityEx;
            ((PUSBROOTHUBINFO)info)->PortConnectorProps = PortConnectorProps;
        }

        // Allocate a temp buffer for the full hub device name.
        //
        hr = StringCbLengthW(L"\\\\.\\", MAX_DEVICE_PROP * sizeof(WCHAR), &cchHeader);
        if (FAILED(hr)) {
            break;
        }
        cchFullHubName = cchHeader + cbHubName + 1;
        deviceName = (PWCHAR)ALLOC((DWORD)cchFullHubName);
        if (deviceName == NULL) {
            OOPS();
            break;
        }

        // Create the full hub device name
        //
        hr = StringCchCopyNW(deviceName, cchFullHubName, L"\\\\.\\", cchHeader);
        if (FAILED(hr)) {
            break;
        }
        hr = StringCchCatNW(deviceName, cchFullHubName, HubName, cbHubName);
        if (FAILED(hr)) {
            break;
        }

        // Try to hub the open device
        //
        hHubDevice = CreateFileW(deviceName,
            GENERIC_WRITE,
            FILE_SHARE_WRITE,
            NULL,
            OPEN_EXISTING,
            0,
            NULL);

        // Done with temp buffer for full hub device name
        //
        FREE(deviceName);

        if (hHubDevice == INVALID_HANDLE_VALUE) {
            OOPS();
            break;
        }

        //
        // Now query USBHUB for the USB_NODE_INFORMATION structure for this hub.
        // This will tell us the number of downstream ports to enumerate, among
        // other things.
        //
        success = DeviceIoControl(hHubDevice,
            IOCTL_USB_GET_NODE_INFORMATION,
            hubInfo,
            sizeof(USB_NODE_INFORMATION),
            hubInfo,
            sizeof(USB_NODE_INFORMATION),
            &nBytes,
            NULL);

        if (!success) {
            OOPS();
            break;
        }

        success = DeviceIoControl(hHubDevice,
            IOCTL_USB_GET_HUB_INFORMATION_EX,
            hubInfoEx,
            sizeof(USB_HUB_INFORMATION_EX),
            hubInfoEx,
            sizeof(USB_HUB_INFORMATION_EX),
            &nBytes,
            NULL);

        //
        // Fail gracefully for downlevel OS's from Win8
        //
        if (!success || nBytes < sizeof(USB_HUB_INFORMATION_EX)) {
            FREE(hubInfoEx);
            hubInfoEx = NULL;
            if (ConnectionInfo != NULL) {
                ((PUSBEXTERNALHUBINFO)info)->HubInfoEx = NULL;
            } else {
                ((PUSBROOTHUBINFO)info)->HubInfoEx = NULL;
            }
        }

        //
        // Obtain Hub Capabilities
        //
        success = DeviceIoControl(hHubDevice,
            IOCTL_USB_GET_HUB_CAPABILITIES_EX,
            hubCapabilityEx,
            sizeof(USB_HUB_CAPABILITIES_EX),
            hubCapabilityEx,
            sizeof(USB_HUB_CAPABILITIES_EX),
            &nBytes,
            NULL);

        //
        // Fail gracefully
        //
        if (!success || nBytes < sizeof(USB_HUB_CAPABILITIES_EX)) {
            FREE(hubCapabilityEx);
            hubCapabilityEx = NULL;
            if (ConnectionInfo != NULL) {
                ((PUSBEXTERNALHUBINFO)info)->HubCapabilityEx = NULL;
            } else {
                ((PUSBROOTHUBINFO)info)->HubCapabilityEx = NULL;
            }
        }

        // Now recursively enumerate the ports of this hub.
        //
        EnumerateHubPorts(
            hHubDevice,
            hubInfo->u.HubInformation.HubDescriptor.bNumberOfPorts,
            listHead,
            portChain,
            cbPortChain);

    } while (0);

    //
    // Clean up any stuff that got allocated
    //

    if (hHubDevice != INVALID_HANDLE_VALUE) {
        CloseHandle(hHubDevice);
        hHubDevice = INVALID_HANDLE_VALUE;
    }

    if (hubInfo) {
        FREE(hubInfo);
    }

    if (hubInfoEx) {
        FREE(hubInfoEx);
    }

    if (info) {
        FREE(info);
    }

    if (HubName) {
        FREE(HubName);
    }
}

void CopyString(WCHAR **dstString, WCHAR *srcString, int freeSrcString) {
    if (!dstString || !srcString) {
        return;
    }

    int stringByteSize = (wcslen(srcString) + 1) * sizeof(WCHAR);
    *dstString = ALLOC(stringByteSize);
    if (*dstString != NULL) {
        StringCbCopy(*dstString, stringByteSize, srcString);
    }

    if (freeSrcString != 0) {
        FREE(srcString);
    }
}

void GetDeviceNodeRegistryProperty(
    DEVINST devInst,
    ULONG ulProperty,
    PWCHAR *property
) {
    if (!property) {
        return;
    }

    *property = NULL;

    ULONG pulLength = 0;
    CONFIGRET ret = CM_Get_DevNode_Registry_PropertyW(devInst, ulProperty, NULL, NULL, &pulLength, 0);
    if (pulLength > 0) {
        *property = (PWCHAR)ALLOC(pulLength);
        if (*property) {
            ret = CM_Get_DevNode_Registry_PropertyW(devInst, ulProperty, NULL, *property, &pulLength, 0);
            if (ret != CR_SUCCESS) {
                FREE(*property);
                *property = NULL;
            }
        }
    }
}

static void GUIDFromString(const WCHAR *guidString, GUID *guid) {
    if (!guidString || !guid) {
        return;
    }

    memset(guid, 0, sizeof(GUID));

    HINSTANCE shell32Instance = LoadLibrary(TEXT("Shell32.dll"));

    typedef BOOL(__stdcall *FN_GUIDFromStringW)(LPCTSTR, LPGUID);
    int ordinal = 704;
    FN_GUIDFromStringW fnGUIDFromString = (FN_GUIDFromStringW)GetProcAddress(shell32Instance, MAKEINTRESOURCEA(ordinal));
    if (fnGUIDFromString) {
        fnGUIDFromString(guidString, guid);
    }
}

static PWCHAR s_systemInterfaceGUIDs[] = {
    GUID_ADB_STRING,
    GUID_HDB_STRING,
    GUID_DEVICE_APPLICATIONLAUNCH_BUTTON_STRING,
    GUID_DEVICE_BATTERY_STRING,
    GUID_DEVICE_LID_STRING,
    GUID_DEVICE_MEMORY_STRING,
    GUID_DEVICE_MESSAGE_INDICATOR_STRING,
    GUID_DEVICE_PROCESSOR_STRING,
    GUID_DEVICE_SYS_BUTTON_STRING,
    GUID_DEVICE_THERMAL_ZONE_STRING,
    GUID_DEVINTERFACE_BRIGHTNESS_STRING,
    GUID_DEVINTERFACE_CDCHANGER_STRING,
    GUID_DEVINTERFACE_CDROM_STRING,
    GUID_DEVINTERFACE_COMPORT_STRING,
    GUID_DEVINTERFACE_DISK_STRING,
    GUID_DEVINTERFACE_DISPLAY_ADAPTER_STRING,
    GUID_DEVINTERFACE_FLOPPY_ADAPTER_STRING,
    GUID_DEVINTERFACE_HID_STRING,
    GUID_DEVINTERFACE_I2C_STRING,
    GUID_DEVINTERFACE_IMAGE_STRING,
    GUID_DEVINTERFACE_KEYBOARD_STRING,
    GUID_DEVINTERFACE_MEDIUMCHANGER_STRING,
    GUID_DEVINTERFACE_MODEM_STRING,
    GUID_DEVINTERFACE_MONITOR_STRING,
    GUID_DEVINTERFACE_MOUSE_STRING,
    GUID_DEVINTERFACE_NET_STRING,
    GUID_DEVINTERFACE_OPM_STRING,
    GUID_DEVINTERFACE_PARALLEL_STRING,
    GUID_DEVINTERFACE_PARCLASS_STRING,
    GUID_DEVINTERFACE_PARTITION_STRING,
    GUID_DEVINTERFACE_SERENUM_BUS_ENUMERATOR_STRING,
    GUID_DEVINTERFACE_SIDESHOW_STRING,
    GUID_DEVINTERFACE_STORAGEPORT_STRING,
    GUID_DEVINTERFACE_TAPE_STRING,
    GUID_DEVINTERFACE_USB_DEVICE_STRING,
    GUID_DEVINTERFACE_USB_HOST_CONTROLLER_STRING,
    GUID_DEVINTERFACE_USB_HUB_STRING,
    GUID_DEVINTERFACE_VIDEO_OUTPUT_ARRIVAL_STRING,
    GUID_DEVINTERFACE_VOLUME_STRING,
    GUID_DEVINTERFACE_WPD_STRING,
    GUID_DEVINTERFACE_WPD_PRIVATE_STRING,
    GUID_DEVINTERFACE_WRITEONCEDISK_STRING,
    GUID_DEVINTERFACE_WINUSB_STRING
};

BOOL IsTargetDevice(
    DEVINST cmpDevInst,
    DEVINST devInst
) {
    BOOL isTarget = FALSE;
    CONFIGRET ret = -1;
    DEVINST childDevInst;

    ret = CM_Get_Child(&childDevInst, devInst, 0);
    if (ret == CR_SUCCESS) {
        do {
            if (cmpDevInst == childDevInst) {
                isTarget = TRUE;
                break;
            }

            isTarget = IsTargetDevice(cmpDevInst, childDevInst);
            if (isTarget) {
                break;
            }
        } while ((ret = CM_Get_Sibling(&childDevInst, childDevInst, 0) == CR_SUCCESS));
    }

    return isTarget;
}

void GetDeviceInfoDetail(
    DEVINST devInst,
    PDEVICE_DRIVER_INFO deviceDriverInfo
) {
    if (!deviceDriverInfo) {
        return;
    }

    HDEVINFO deviceInfoSet = INVALID_HANDLE_VALUE;
    PSP_DEVINFO_DATA deviceInfoData = NULL;
    PSP_DEVINFO_DATA tmpDeviceInfoData = NULL;
    PSP_DEVICE_INTERFACE_DATA deviceInterfaceData = NULL;
    DWORD errCode = 0;
    BOOL ret = 0;
    DWORD requiredSize = 0;
    size_t systemInterfaceGuidCount = sizeof(s_systemInterfaceGUIDs) / sizeof(PWCHAR);
    WCHAR guidString[64];

    do {
        GetDeviceNodeRegistryProperty(devInst, CM_DRP_CLASS, &deviceDriverInfo->className);
        GetDeviceNodeRegistryProperty(devInst, CM_DRP_CLASSGUID, &deviceDriverInfo->classGUID);
        GetDeviceNodeRegistryProperty(devInst, CM_DRP_DRIVER, &deviceDriverInfo->driverKeyName);
        GetDeviceNodeRegistryProperty(devInst, CM_DRP_DEVICEDESC, &deviceDriverInfo->desc);
        GetDeviceNodeRegistryProperty(devInst, CM_DRP_FRIENDLYNAME, &deviceDriverInfo->friendlyName);
        GetDeviceNodeRegistryProperty(devInst, CM_DRP_LOCATION_INFORMATION, &deviceDriverInfo->locationInfo);

        CONFIGRET configRet = CM_Get_Device_ID_Size(&requiredSize, devInst, 0);
        if (configRet == CR_SUCCESS && requiredSize > 0) {
            requiredSize += 1;
            PWCHAR deviceInstanceId = (PWCHAR)ALLOC(requiredSize * sizeof(WCHAR));
            if (deviceInstanceId) {
                configRet = CM_Get_Device_IDW(devInst, deviceInstanceId, requiredSize, 0);
                if (configRet == CR_SUCCESS) {
                    CopyString(&deviceDriverInfo->instanceId, deviceInstanceId, 0);
                }

                FREE(deviceInstanceId);
                deviceInstanceId = NULL;
            }
        }

        deviceInfoSet = SetupDiGetClassDevsW(
            NULL,
            NULL,
            NULL,
            (DIGCF_ALLCLASSES | DIGCF_PRESENT | DIGCF_DEVICEINTERFACE)
        );

        if (deviceInfoSet == INVALID_HANDLE_VALUE) {
            break;
        }

        deviceInfoData = (PSP_DEVINFO_DATA)ALLOC(sizeof(SP_DEVINFO_DATA));
        if (!deviceInfoData) {
            break;
        }

        deviceInfoData->cbSize = sizeof(SP_DEVINFO_DATA);

        tmpDeviceInfoData = (PSP_DEVINFO_DATA)ALLOC(sizeof(SP_DEVINFO_DATA));
        if (!tmpDeviceInfoData) {
            break;
        }

        tmpDeviceInfoData->cbSize = sizeof(SP_DEVINFO_DATA);

        deviceInterfaceData = (PSP_DEVICE_INTERFACE_DATA)ALLOC(sizeof(SP_DEVICE_INTERFACE_DATA));
        if (!deviceInterfaceData) {
            break;
        }

        deviceInterfaceData->cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

        BOOL findTarget = FALSE;

        for (DWORD deviceIndex = 0; ; ++deviceIndex) {
            if (!SetupDiEnumDeviceInfo(deviceInfoSet, deviceIndex, deviceInfoData)) {
                break;
            }

            if (IsTargetDevice(devInst, deviceInfoData->DevInst)) {
                findTarget = TRUE;

                GUID systemInterfaceGuid = { 0 };

                for (size_t guidIndex = 0; guidIndex < systemInterfaceGuidCount; ++guidIndex) {
                    ZeroMemory(&systemInterfaceGuid, sizeof(GUID));
                    GUIDFromString(s_systemInterfaceGUIDs[guidIndex], &systemInterfaceGuid);

                    for (DWORD interfaceIndex = 0; ; ++interfaceIndex) {
                        ZeroMemory(deviceInterfaceData, sizeof(SP_DEVICE_INTERFACE_DATA));
                        deviceInterfaceData->cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

                        if (!SetupDiEnumDeviceInterfaces(deviceInfoSet, NULL, &systemInterfaceGuid, interfaceIndex, deviceInterfaceData)) {
                            errCode = GetLastError();
                            break;
                        }

                        ZeroMemory(tmpDeviceInfoData, sizeof(SP_DEVINFO_DATA));
                        tmpDeviceInfoData->cbSize = sizeof(SP_DEVINFO_DATA);

                        requiredSize = 0;
                        ret = SetupDiGetDeviceInterfaceDetailW(deviceInfoSet, deviceInterfaceData, NULL, 0, &requiredSize, tmpDeviceInfoData);
                        errCode = GetLastError();
                        if (errCode == ERROR_INSUFFICIENT_BUFFER) {
                            ZeroMemory(guidString, sizeof(guidString));
                            StringFromGUID2(&tmpDeviceInfoData->ClassGuid, guidString, sizeof(guidString) / sizeof(guidString[0]));

                            PWCHAR driverKeyName = NULL;
                            ret = GetDeviceProperty(deviceInfoSet,
                                tmpDeviceInfoData,
                                SPDRP_DRIVER,
                                &driverKeyName);

                            if (driverKeyName &&
                                !_wcsicmp(deviceDriverInfo->classGUID, guidString) &&
                                !_wcsicmp(deviceDriverInfo->driverKeyName, driverKeyName)) {
                                /*requiredSize = 0;
                                ret = SetupDiGetDeviceInstanceIdW(deviceInfoSet, tmpDeviceInfoData, NULL, 0, &requiredSize);
                                errCode = GetLastError();
                                if (errCode == ERROR_INSUFFICIENT_BUFFER) {
                                    PWCHAR deviceInstanceId = (PWCHAR)ALLOC(requiredSize * sizeof(WCHAR));
                                    if (deviceInstanceId) {
                                        ret = SetupDiGetDeviceInstanceIdW(deviceInfoSet, tmpDeviceInfoData, deviceInstanceId, requiredSize, NULL);
                                        if (ret) {
                                            CopyString(&deviceDriverInfo->instanceId, deviceInstanceId, 0);
                                        }

                                        FREE(deviceInstanceId);
                                        deviceInstanceId = NULL;
                                    }
                                }*/

                                requiredSize = 0;
                                ret = SetupDiGetDeviceInterfaceDetailW(deviceInfoSet, deviceInterfaceData, NULL, 0, &requiredSize, deviceInfoData);
                                errCode = GetLastError();
                                if (errCode == ERROR_INSUFFICIENT_BUFFER) {
                                    PSP_DEVICE_INTERFACE_DETAIL_DATA deviceInterfaceDetailData = (PSP_DEVICE_INTERFACE_DETAIL_DATA)ALLOC(requiredSize);
                                    if (deviceInterfaceDetailData) {
                                        deviceInterfaceDetailData->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);
                                        ret = SetupDiGetDeviceInterfaceDetailW(deviceInfoSet, deviceInterfaceData, deviceInterfaceDetailData, requiredSize, NULL, deviceInfoData);
                                        if (ret) {
                                            PDEVICE_INTERFACE_INFO deviceInterfaceInfo = (PDEVICE_INTERFACE_INFO)ALLOC(sizeof(DEVICE_INTERFACE_INFO));
                                            if (deviceInterfaceInfo) {
                                                CopyString(&deviceInterfaceInfo->interfaceClassGUID, s_systemInterfaceGUIDs[guidIndex], 0);
                                                CopyString(&deviceInterfaceInfo->devicePath, deviceInterfaceDetailData->DevicePath, 0);
                                                InsertTailList(&deviceDriverInfo->listEntryDeviceInterface, &deviceInterfaceInfo->listEntry);
                                            }
                                        }

                                        FREE(deviceInterfaceDetailData);
                                        deviceInterfaceDetailData = NULL;
                                    }
                                }
                            }

                            if (driverKeyName) {
                                FREE(driverKeyName);
                            }
                        }
                    }
                }
            }
        }

        if (!findTarget) {
            int a = 0;
        }

    } while (0);

    if (deviceInfoSet != INVALID_HANDLE_VALUE) {
        SetupDiDestroyDeviceInfoList(deviceInfoSet);
    }

    if (deviceInfoData != NULL) {
        FREE(deviceInfoData);
    }

    if (tmpDeviceInfoData != NULL) {
        FREE(tmpDeviceInfoData);
    }

    if (deviceInterfaceData != NULL) {
        FREE(deviceInterfaceData);
    }
}

void RecursiveGetDeviceInfo(
    PLIST_ENTRY listEntry,
    DEVINST devInst
) {
    PDEVICE_DRIVER_INFO deviceDriverInfo = (PDEVICE_DRIVER_INFO)ALLOC(sizeof(DEVICE_DRIVER_INFO));
    if (deviceDriverInfo) {
        InitializeListHead(&deviceDriverInfo->listEntryDeviceInterface);

        GetDeviceInfoDetail(devInst, deviceDriverInfo);

        InsertTailList(listEntry, &deviceDriverInfo->listEntry);
    }

    CONFIGRET ret = -1;
    DEVINST childDevInst;

    ret = CM_Get_Child(&childDevInst, devInst, 0);
    if (ret == CR_SUCCESS) {
        do {
            RecursiveGetDeviceInfo(listEntry, childDevInst);

        } while ((ret = CM_Get_Sibling(&childDevInst, childDevInst, 0) == CR_SUCCESS));
    }
}

//*****************************************************************************
//
// EnumerateHubPorts()
//
// hTreeParent - Handle of the TreeView item under which the hub port should
// be added.
//
// hHubDevice - Handle of the hub device to enumerate.
//
// NumPorts - Number of ports on the hub.
//
//*****************************************************************************

VOID
EnumerateHubPorts(
    HANDLE      hHubDevice,
    ULONG       NumPorts,
    PLIST_ENTRY listHead,
    _In_ PWCHAR portChain,
    _In_ size_t cbPortChain
) {
    ULONG       index = 0;
    BOOL        success = 0;
    HRESULT     hr = S_OK;
    PUSB_DEVICE_PNP_STRINGS DevProps;

    PUSB_NODE_CONNECTION_INFORMATION_EX    connectionInfoEx;
    PUSB_PORT_CONNECTOR_PROPERTIES         pPortConnectorProps;
    USB_PORT_CONNECTOR_PROPERTIES          portConnectorProps;
    PSTRING_DESCRIPTOR_NODE                stringDescs;
    PUSB_NODE_CONNECTION_INFORMATION_EX_V2 connectionInfoExV2;

    // Loop over all ports of the hub.
    //
    // Port indices are 1 based, not 0 based.
    //

    for (index = 1; index <= NumPorts; index++) {
        USHORT companionIndex = 0;
        USHORT companionPortNumber = 0;
        USB_PROTOCOLS supportedUsbProtocols;
        supportedUsbProtocols.ul = 0;

        ULONG nBytesEx;
        ULONG nBytes = 0;

        DevProps = NULL;
        connectionInfoEx = NULL;
        pPortConnectorProps = NULL;
        ZeroMemory(&portConnectorProps, sizeof(portConnectorProps));
        stringDescs = NULL;
        connectionInfoExV2 = NULL;

        //
        // Allocate space to hold the connection info for this port.
        // For now, allocate it big enough to hold info for 30 pipes.
        //
        // Endpoint numbers are 0-15.  Endpoint number 0 is the standard
        // control endpoint which is not explicitly listed in the Configuration
        // Descriptor.  There can be an IN endpoint and an OUT endpoint at
        // endpoint numbers 1-15 so there can be a maximum of 30 endpoints
        // per device configuration.
        //
        // Should probably size this dynamically at some point.
        //

        nBytesEx = sizeof(USB_NODE_CONNECTION_INFORMATION_EX) +
            (sizeof(USB_PIPE_INFO) * 30);

        connectionInfoEx = (PUSB_NODE_CONNECTION_INFORMATION_EX)ALLOC(nBytesEx);

        if (connectionInfoEx == NULL) {
            OOPS();
            break;
        }

        connectionInfoExV2 = (PUSB_NODE_CONNECTION_INFORMATION_EX_V2)
            ALLOC(sizeof(USB_NODE_CONNECTION_INFORMATION_EX_V2));

        if (connectionInfoExV2 == NULL) {
            OOPS();
            FREE(connectionInfoEx);
            connectionInfoEx = NULL;
            break;
        }

        //
        // Now query USBHUB for the structures
        // for this port.  This will tell us if a device is attached to this
        // port, among other things.
        // The fault tolerate code is executed first.
        //

        portConnectorProps.ConnectionIndex = index;

        success = DeviceIoControl(hHubDevice,
            IOCTL_USB_GET_PORT_CONNECTOR_PROPERTIES,
            &portConnectorProps,
            sizeof(USB_PORT_CONNECTOR_PROPERTIES),
            &portConnectorProps,
            sizeof(USB_PORT_CONNECTOR_PROPERTIES),
            &nBytes,
            NULL);

        if (success && nBytes == sizeof(USB_PORT_CONNECTOR_PROPERTIES)) {
            pPortConnectorProps = (PUSB_PORT_CONNECTOR_PROPERTIES)
                ALLOC(portConnectorProps.ActualLength);

            if (pPortConnectorProps != NULL) {
                pPortConnectorProps->ConnectionIndex = index;

                success = DeviceIoControl(hHubDevice,
                    IOCTL_USB_GET_PORT_CONNECTOR_PROPERTIES,
                    pPortConnectorProps,
                    portConnectorProps.ActualLength,
                    pPortConnectorProps,
                    portConnectorProps.ActualLength,
                    &nBytes,
                    NULL);

                if (!success || nBytes < portConnectorProps.ActualLength) {
                    FREE(pPortConnectorProps);
                    pPortConnectorProps = NULL;
                }

                if (pPortConnectorProps) {
                    companionIndex = pPortConnectorProps->CompanionIndex;
                    companionPortNumber = pPortConnectorProps->CompanionPortNumber;
                }
            }
        }

        connectionInfoExV2->ConnectionIndex = index;
        connectionInfoExV2->Length = sizeof(USB_NODE_CONNECTION_INFORMATION_EX_V2);
        connectionInfoExV2->SupportedUsbProtocols.Usb300 = 1;

        success = DeviceIoControl(hHubDevice,
            IOCTL_USB_GET_NODE_CONNECTION_INFORMATION_EX_V2,
            connectionInfoExV2,
            sizeof(USB_NODE_CONNECTION_INFORMATION_EX_V2),
            connectionInfoExV2,
            sizeof(USB_NODE_CONNECTION_INFORMATION_EX_V2),
            &nBytes,
            NULL);

        if (!success || nBytes < sizeof(USB_NODE_CONNECTION_INFORMATION_EX_V2)) {
            FREE(connectionInfoExV2);
            connectionInfoExV2 = NULL;
        }

        if (connectionInfoExV2) {
            supportedUsbProtocols = connectionInfoExV2->SupportedUsbProtocols;
        }

        connectionInfoEx->ConnectionIndex = index;

        success = DeviceIoControl(hHubDevice,
            IOCTL_USB_GET_NODE_CONNECTION_INFORMATION_EX,
            connectionInfoEx,
            nBytesEx,
            connectionInfoEx,
            nBytesEx,
            &nBytesEx,
            NULL);

        if (success) {
            //
            // Since the USB_NODE_CONNECTION_INFORMATION_EX is used to display
            // the device speed, but the hub driver doesn't support indication
            // of superspeed, we overwrite the value if the super speed
            // data structures are available and indicate the device is operating
            // at SuperSpeed.
            // 

            if (connectionInfoEx->Speed == UsbHighSpeed
                && connectionInfoExV2 != NULL
                && (connectionInfoExV2->Flags.DeviceIsOperatingAtSuperSpeedOrHigher)) {
                connectionInfoEx->Speed = UsbSuperSpeed;
            }
        } else {
            PUSB_NODE_CONNECTION_INFORMATION    connectionInfo = NULL;

            // Try using IOCTL_USB_GET_NODE_CONNECTION_INFORMATION
            // instead of IOCTL_USB_GET_NODE_CONNECTION_INFORMATION_EX
            //

            nBytes = sizeof(USB_NODE_CONNECTION_INFORMATION) +
                sizeof(USB_PIPE_INFO) * 30;

            connectionInfo = (PUSB_NODE_CONNECTION_INFORMATION)ALLOC(nBytes);

            if (connectionInfo == NULL) {
                OOPS();

                FREE(connectionInfoEx);
                connectionInfoEx = NULL;

                if (pPortConnectorProps != NULL) {
                    FREE(pPortConnectorProps);
                    pPortConnectorProps = NULL;
                }

                if (connectionInfoExV2 != NULL) {
                    FREE(connectionInfoExV2);
                    connectionInfoExV2 = NULL;
                }
                continue;
            }

            connectionInfo->ConnectionIndex = index;

            success = DeviceIoControl(hHubDevice,
                IOCTL_USB_GET_NODE_CONNECTION_INFORMATION,
                connectionInfo,
                nBytes,
                connectionInfo,
                nBytes,
                &nBytes,
                NULL);

            if (!success) {
                OOPS();

                FREE(connectionInfo);
                connectionInfo = NULL;

                FREE(connectionInfoEx);
                connectionInfoEx = NULL;

                if (pPortConnectorProps != NULL) {
                    FREE(pPortConnectorProps);
                    pPortConnectorProps = NULL;
                }

                if (connectionInfoExV2 != NULL) {
                    FREE(connectionInfoExV2);
                    connectionInfoExV2 = NULL;
                }
                continue;
            }

            // Copy IOCTL_USB_GET_NODE_CONNECTION_INFORMATION into
            // IOCTL_USB_GET_NODE_CONNECTION_INFORMATION_EX structure.
            //
            connectionInfoEx->ConnectionIndex = connectionInfo->ConnectionIndex;
            connectionInfoEx->DeviceDescriptor = connectionInfo->DeviceDescriptor;
            connectionInfoEx->CurrentConfigurationValue = connectionInfo->CurrentConfigurationValue;
            connectionInfoEx->Speed = connectionInfo->LowSpeed ? UsbLowSpeed : UsbFullSpeed;
            connectionInfoEx->DeviceIsHub = connectionInfo->DeviceIsHub;
            connectionInfoEx->DeviceAddress = connectionInfo->DeviceAddress;
            connectionInfoEx->NumberOfOpenPipes = connectionInfo->NumberOfOpenPipes;
            connectionInfoEx->ConnectionStatus = connectionInfo->ConnectionStatus;

            memcpy(&connectionInfoEx->PipeList[0],
                &connectionInfo->PipeList[0],
                sizeof(USB_PIPE_INFO) * 30);

            FREE(connectionInfo);
            connectionInfo = NULL;
        }

        if (connectionInfoEx->DeviceDescriptor.iManufacturer ||
            connectionInfoEx->DeviceDescriptor.iProduct ||
            connectionInfoEx->DeviceDescriptor.iSerialNumber) {
            stringDescs = GetAllStringDescriptors(
                hHubDevice,
                index,
                &connectionInfoEx->DeviceDescriptor);
        } else {
            stringDescs = NULL;
        }

        // If there is a device connected, get the Device Description
        //
        if (connectionInfoEx->ConnectionStatus != NoDeviceConnected) {
            PWCHAR driverKeyName = GetDriverKeyName(hHubDevice, index);
            if (driverKeyName) {
                size_t cbDriverName = 0;

                hr = StringCbLengthW(driverKeyName, MAX_DRIVER_KEY_NAME * sizeof(WCHAR), &cbDriverName);
                if (SUCCEEDED(hr)) {
                    HDEVINFO deviceInfoSet = INVALID_HANDLE_VALUE;
                    PSP_DEVINFO_DATA deviceInfoData = NULL;
                    BOOL ret = FALSE;
                    DWORD requiredSize = 0;
                    DWORD errCode = 0;
                    PBYTE lpData = NULL;

                    do {
                        deviceInfoData = (PSP_DEVINFO_DATA)ALLOC(sizeof(SP_DEVINFO_DATA));
                        if (deviceInfoData == NULL) {
                            break;
                        }

                        ret = DriverNameToDeviceInst(driverKeyName, cbDriverName, &deviceInfoSet, deviceInfoData);
                        if (ret == FALSE) {
                            break;
                        }

                        if (deviceInfoSet == INVALID_HANDLE_VALUE || !deviceInfoData) {
                            break;
                        }

                        PDEVICE_INFO deviceInfo = ALLOC(sizeof(DEVICE_INFO));
                        if (!deviceInfo) {
                            break;
                        }

                        InitializeListHead(&deviceInfo->listEntryDeviceDriver);
                        deviceInfo->deviceType = -1;
                        deviceInfo->connectionIndex = index;
                        deviceInfo->supportedUsbProtocols = supportedUsbProtocols;

                        deviceInfo->portChain = ALLOC(cbPortChain);
                        if (NULL != deviceInfo->portChain) {
                            StringCbPrintfW(deviceInfo->portChain, cbPortChain, L"%s-%d", portChain, index);
                        }

                        if (companionPortNumber != 0) {
                            if (companionPortNumber <= NumPorts) {
                                /*同一个hub上的伙伴端口*/
                                deviceInfo->companionPortChain = ALLOC(cbPortChain);
                                if (NULL != deviceInfo->companionPortChain) {
                                    StringCbPrintfW(deviceInfo->companionPortChain, cbPortChain, L"%s-%d", portChain, companionPortNumber);
                                }
                            } else {
                                /*遍历寻找伙伴端口*/
                                if (!IsListEmpty(listHead)) {
                                    PLIST_ENTRY pEntry = listHead->Flink;

                                    while (pEntry != listHead) {
                                        PDEVICE_INFO lpFindDevDescInfo = CONTAINING_RECORD(pEntry,
                                            DEVICE_INFO,
                                            listEntry);

                                        pEntry = pEntry->Flink;

                                        if (lpFindDevDescInfo) {
                                            if (companionPortNumber == lpFindDevDescInfo->connectionIndex &&
                                                supportedUsbProtocols.ul != lpFindDevDescInfo->supportedUsbProtocols.ul) {
                                                deviceInfo->companionPortChain = ALLOC(cbPortChain);
                                                if (NULL != deviceInfo->companionPortChain) {
                                                    StringCbPrintfW(deviceInfo->companionPortChain, cbPortChain, L"%s", lpFindDevDescInfo->portChain);
                                                }

                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        PSTRING_DESCRIPTOR_NODE stringDescsBack = stringDescs;
                        if (connectionInfoEx->DeviceDescriptor.iManufacturer) {
                            while (stringDescs) {
                                if (stringDescs->DescriptorIndex == connectionInfoEx->DeviceDescriptor.iManufacturer) {
                                    if (stringDescs->StringDescriptor->bLength > sizeof(USHORT)) {
                                        CopyString(&deviceInfo->manufacturer, &stringDescs->StringDescriptor->bString[0], 0);
                                        break;
                                    }

                                }
                                stringDescs = stringDescs->Next;
                            }
                        }

                        if (connectionInfoEx->DeviceDescriptor.iSerialNumber) {
                            while (stringDescs) {
                                if (stringDescs->DescriptorIndex == connectionInfoEx->DeviceDescriptor.iSerialNumber) {
                                    if (stringDescs->StringDescriptor->bLength > sizeof(USHORT)) {
                                        CopyString(&deviceInfo->deviceId, &stringDescs->StringDescriptor->bString[0], 0);
                                        break;
                                    }

                                }
                                stringDescs = stringDescs->Next;
                            }
                        }

                        RecursiveGetDeviceInfo(&deviceInfo->listEntryDeviceDriver, deviceInfoData->DevInst);

                        /*ret = SetupDiBuildDriverInfoList(deviceInfoSet, lpDeviceInfoData, SPDIT_CLASSDRIVER);
                        if (ret) {
                            DWORD driverMemberIndex = 0;
                            PSP_DRVINFO_DATA_W driverInfoData = (PSP_DRVINFO_DATA_W)ALLOC(sizeof(SP_DRVINFO_DATA_W));
                            if (driverInfoData) {
                                driverInfoData->cbSize = sizeof(SP_DRVINFO_DATA);
                                while (TRUE) {
                                    ret = SetupDiEnumDriverInfoW(deviceInfoSet, lpDeviceInfoData, SPDIT_CLASSDRIVER, driverMemberIndex, driverInfoData);
                                    if (!ret) {
                                        errCode = GetLastError();
                                        break;
                                    }

                                    requiredSize = 0;
                                    ret = SetupDiGetDriverInfoDetailW(deviceInfoSet, lpDeviceInfoData, driverInfoData, NULL, 0, &requiredSize);
                                    errCode = GetLastError();
                                    if (errCode == ERROR_INSUFFICIENT_BUFFER) {
                                        PSP_DRVINFO_DETAIL_DATA_W driverInfoDetailData = (PSP_DRVINFO_DETAIL_DATA_W)ALLOC(requiredSize);
                                        if (driverInfoDetailData) {
                                            driverInfoDetailData->cbSize = sizeof(SP_DRVINFO_DETAIL_DATA_W);

                                            ret = SetupDiGetDriverInfoDetailW(deviceInfoSet, lpDeviceInfoData, driverInfoData, driverInfoDetailData, requiredSize, NULL);

                                            FREE(driverInfoDetailData);
                                            driverInfoDetailData = NULL;
                                        }
                                    }

                                    ++driverMemberIndex;
                                }

                                FREE(driverInfoData);
                                driverInfoData = NULL;
                            }

                            SetupDiDestroyDriverInfoList(deviceInfoSet, lpDeviceInfoData, SPDIT_CLASSDRIVER);
                        }*/

                        if (deviceInfo) {
                            if (!IsListEmpty(&deviceInfo->listEntryDeviceDriver)) {
                                PLIST_ENTRY pEntry = deviceInfo->listEntryDeviceDriver.Flink;

                                while (pEntry != &deviceInfo->listEntryDeviceDriver) {
                                    PDEVICE_DRIVER_INFO deviceDriverInfo = CONTAINING_RECORD(pEntry,
                                        DEVICE_DRIVER_INFO,
                                        listEntry);

                                    pEntry = pEntry->Flink;

                                    if (!deviceDriverInfo) {
                                        continue;
                                    }

                                    if ((deviceDriverInfo->className && !_wcsicmp(deviceDriverInfo->className, L"AndroidUsbDeviceClass")) ||
                                        (deviceDriverInfo->classGUID && !_wcsicmp(deviceDriverInfo->classGUID, GUID_ANDROID_CLASS_STRING))) {
                                        deviceInfo->deviceType = 2;
                                        break;
                                    }

                                    if (deviceDriverInfo->desc && (StrStrIW(deviceDriverInfo->desc, L"Apple Mobile Device USB Composite Device"))) {
                                        deviceInfo->deviceType = 3;
                                        break;
                                    }

                                    if ((deviceDriverInfo->className && !_wcsicmp(deviceDriverInfo->className, L"Keyboard")) ||
                                        ((deviceDriverInfo->classGUID && !_wcsicmp(deviceDriverInfo->classGUID, GUID_KEYBOARD_CLASS_STRING)))) {
                                        deviceInfo->deviceType = 0;
                                        break;
                                    }

                                    if ((deviceDriverInfo->className && !_wcsicmp(deviceDriverInfo->className, L"Mouse")) ||
                                        ((deviceDriverInfo->classGUID && !_wcsicmp(deviceDriverInfo->classGUID, GUID_MOUSE_CLASS_STRING)))) {
                                        deviceInfo->deviceType = 1;
                                        break;
                                    }
                                }
                            }

                            InsertTailList(listHead, &deviceInfo->listEntry);
                        } else {
                            FREE(deviceInfo);
                        }

                    } while (0);

                    if (NULL != deviceInfoData) {
                        FREE(deviceInfoData);
                    }

                    if (deviceInfoSet != INVALID_HANDLE_VALUE) {
                        SetupDiDestroyDeviceInfoList(deviceInfoSet);
                    }
                }

                FREE(driverKeyName);
            }
        }

        // If the device connected to the port is an external hub, get the
        // name of the external hub and recursively enumerate it.
        //
        if (connectionInfoEx->DeviceIsHub) {
            PWCHAR extHubName;
            size_t cbHubName = 0;

            extHubName = GetExternalHubName(hHubDevice, index);
            if (extHubName != NULL) {
                hr = StringCbLengthW(extHubName, MAX_DRIVER_KEY_NAME * sizeof(WCHAR), &cbHubName);
                if (SUCCEEDED(hr)) {
                    WCHAR portChain[512] = { 0 };
                    StringCbPrintfW(portChain, sizeof(portChain), L"%s-%d", portChain, index);
                    EnumerateHub(extHubName,
                        cbHubName,
                        connectionInfoEx,
                        connectionInfoExV2,
                        pPortConnectorProps,
                        stringDescs,
                        listHead,
                        portChain,
                        sizeof(portChain));
                }
            }
        }

        if (DevProps != NULL) {
            FreeDeviceProperties(&DevProps);
        }

        if (connectionInfoEx != NULL) {
            FREE(connectionInfoEx);
        }

        if (pPortConnectorProps != NULL) {
            FREE(pPortConnectorProps);
        }

        if (connectionInfoExV2 != NULL) {
            FREE(connectionInfoExV2);
        }

        if (stringDescs != NULL) {
            PSTRING_DESCRIPTOR_NODE Next;

            do {

                Next = stringDescs->Next;
                FREE(stringDescs);
                stringDescs = Next;

            } while (stringDescs != NULL);
        }
    }
}


//*****************************************************************************
//
// WideStrToMultiStr()
//
//*****************************************************************************

PCHAR WideStrToMultiStr(
    _In_reads_bytes_(cbWideStr) PWCHAR WideStr,
    _In_ size_t                   cbWideStr
) {
    ULONG  nBytes = 0;
    PCHAR  MultiStr = NULL;
    PWCHAR pWideStr = NULL;

    // Use local string to guarantee zero termination
    pWideStr = (PWCHAR)ALLOC((DWORD)cbWideStr + sizeof(WCHAR));
    if (NULL == pWideStr) {
        return NULL;
    }
    memcpy(pWideStr, WideStr, cbWideStr);

    // Get the length of the converted string
    //
    nBytes = WideCharToMultiByte(
        CP_ACP,
        WC_NO_BEST_FIT_CHARS,
        pWideStr,
        -1,
        NULL,
        0,
        NULL,
        NULL);

    if (nBytes == 0) {
        FREE(pWideStr);
        return NULL;
    }

    // Allocate space to hold the converted string
    //
    MultiStr = ALLOC(nBytes);
    if (MultiStr == NULL) {
        FREE(pWideStr);
        return NULL;
    }

    // Convert the string
    //
    nBytes = WideCharToMultiByte(
        CP_ACP,
        WC_NO_BEST_FIT_CHARS,
        pWideStr,
        -1,
        MultiStr,
        nBytes,
        NULL,
        NULL);

    if (nBytes == 0) {
        FREE(MultiStr);
        FREE(pWideStr);
        return NULL;
    }

    FREE(pWideStr);
    return MultiStr;
}

PWCHAR MultiStrToWideStr(
    _In_reads_bytes_(cbMultiStr) PCHAR MultiStr,
    _In_ size_t                   cbMultiStr
) {
    ULONG  nBytes = 0;
    PWCHAR WideStr = NULL;
    PCHAR  pMultiStr = NULL;

    // Use local string to guarantee zero termination
    pMultiStr = (PCHAR)ALLOC((DWORD)cbMultiStr + sizeof(CHAR));
    if (NULL == pMultiStr) {
        return NULL;
    }
    memcpy(pMultiStr, MultiStr, cbMultiStr);

    // Get the length of the converted string
    //
    nBytes = MultiByteToWideChar(
        CP_ACP,
        0,
        pMultiStr,
        -1,
        NULL,
        0);

    if (nBytes == 0) {
        FREE(pMultiStr);
        return NULL;
    }

    // Allocate space to hold the converted string
    //
    WideStr = (PWCHAR)ALLOC(sizeof(WCHAR) * nBytes);
    if (WideStr == NULL) {
        FREE(pMultiStr);
        return NULL;
    }

    // Convert the string
    //
    nBytes = MultiByteToWideChar(
        CP_ACP,
        0,
        pMultiStr,
        -1,
        WideStr,
        nBytes);

    if (nBytes == 0) {
        FREE(WideStr);
        FREE(pMultiStr);
        return NULL;
    }

    FREE(pMultiStr);
    return WideStr;
}

//*****************************************************************************
//
// GetRootHubName()
//
//*****************************************************************************

PWCHAR GetRootHubName(
    HANDLE HostController
) {
    BOOL                success = 0;
    ULONG               nBytes = 0;
    USB_ROOT_HUB_NAME   rootHubName;
    PUSB_ROOT_HUB_NAME  rootHubNameW = NULL;
    PWCHAR               rootHubNameString = NULL;

    // Get the length of the name of the Root Hub attached to the
    // Host Controller
    //
    success = DeviceIoControl(HostController,
        IOCTL_USB_GET_ROOT_HUB_NAME,
        0,
        0,
        &rootHubName,
        sizeof(rootHubName),
        &nBytes,
        NULL);

    if (!success) {
        OOPS();
        goto GetRootHubNameError;
    }

    // Allocate space to hold the Root Hub name
    //
    nBytes = rootHubName.ActualLength;

    rootHubNameW = ALLOC(nBytes);
    if (rootHubNameW == NULL) {
        OOPS();
        goto GetRootHubNameError;
    }

    // Get the name of the Root Hub attached to the Host Controller
    //
    success = DeviceIoControl(HostController,
        IOCTL_USB_GET_ROOT_HUB_NAME,
        NULL,
        0,
        rootHubNameW,
        nBytes,
        &nBytes,
        NULL);
    if (!success) {
        OOPS();
        goto GetRootHubNameError;
    }

    // Convert the Root Hub name
    //
    size_t stringByteSize = (wcslen(rootHubNameW->RootHubName) + 1) * sizeof(WCHAR);
    rootHubNameString = ALLOC(stringByteSize);
    if (rootHubNameString) {
        StringCbCopyW(rootHubNameString, stringByteSize, rootHubNameW->RootHubName);
    }

    // All done, free the uncoverted Root Hub name and return the
    // converted Root Hub name
    //
    FREE(rootHubNameW);

    return rootHubNameString;

GetRootHubNameError:
    // There was an error, free anything that was allocated
    //
    if (rootHubNameW != NULL) {
        FREE(rootHubNameW);
        rootHubNameW = NULL;
    }
    return NULL;
}


//*****************************************************************************
//
// GetExternalHubName()
//
//*****************************************************************************

PWCHAR GetExternalHubName(
    HANDLE  Hub,
    ULONG   ConnectionIndex
) {
    BOOL                        success = 0;
    ULONG                       nBytes = 0;
    USB_NODE_CONNECTION_NAME    extHubName;
    PUSB_NODE_CONNECTION_NAME   extHubNameW = NULL;
    PWCHAR                       extHubNameString = NULL;

    // Get the length of the name of the external hub attached to the
    // specified port.
    //
    extHubName.ConnectionIndex = ConnectionIndex;

    success = DeviceIoControl(Hub,
        IOCTL_USB_GET_NODE_CONNECTION_NAME,
        &extHubName,
        sizeof(extHubName),
        &extHubName,
        sizeof(extHubName),
        &nBytes,
        NULL);

    if (!success) {
        OOPS();
        goto GetExternalHubNameError;
    }

    // Allocate space to hold the external hub name
    //
    nBytes = extHubName.ActualLength;

    if (nBytes <= sizeof(extHubName)) {
        OOPS();
        goto GetExternalHubNameError;
    }

    extHubNameW = ALLOC(nBytes);

    if (extHubNameW == NULL) {
        OOPS();
        goto GetExternalHubNameError;
    }

    // Get the name of the external hub attached to the specified port
    //
    extHubNameW->ConnectionIndex = ConnectionIndex;

    success = DeviceIoControl(Hub,
        IOCTL_USB_GET_NODE_CONNECTION_NAME,
        extHubNameW,
        nBytes,
        extHubNameW,
        nBytes,
        &nBytes,
        NULL);

    if (!success) {
        OOPS();
        goto GetExternalHubNameError;
    }

    // Convert the External Hub name
    //
    size_t stringByteSize = (wcslen(extHubNameW->NodeName) + 1) * sizeof(WCHAR);
    extHubNameString = ALLOC(stringByteSize);
    if (extHubNameString) {
        StringCbCopyW(extHubNameString, stringByteSize, extHubNameW->NodeName);
    }

    // All done, free the uncoverted external hub name and return the
    // converted external hub name
    //
    FREE(extHubNameW);

    return extHubNameString;


GetExternalHubNameError:
    // There was an error, free anything that was allocated
    //
    if (extHubNameW != NULL) {
        FREE(extHubNameW);
        extHubNameW = NULL;
    }

    return NULL;
}


//*****************************************************************************
//
// GetDriverKeyName()
//
//*****************************************************************************

PWCHAR GetDriverKeyName(
    HANDLE  Hub,
    ULONG   ConnectionIndex
) {
    BOOL                                success = 0;
    ULONG                               nBytes = 0;
    USB_NODE_CONNECTION_DRIVERKEY_NAME  driverKeyName;
    PUSB_NODE_CONNECTION_DRIVERKEY_NAME pDriverKeyName = NULL;
    PWCHAR                               driverKeyNameString = NULL;

    // Get the length of the name of the driver key of the device attached to
    // the specified port.
    //
    ZeroMemory(&driverKeyName, sizeof(USB_NODE_CONNECTION_DRIVERKEY_NAME));
    driverKeyName.ConnectionIndex = ConnectionIndex;

    success = DeviceIoControl(Hub,
        IOCTL_USB_GET_NODE_CONNECTION_DRIVERKEY_NAME,
        &driverKeyName,
        sizeof(driverKeyName),
        &driverKeyName,
        sizeof(driverKeyName),
        &nBytes,
        NULL);

    if (!success) {
        OOPS();
        goto GetDriverKeyNameError;
    }

    // Allocate space to hold the driver key name
    //
    nBytes = driverKeyName.ActualLength;

    if (nBytes <= sizeof(driverKeyName)) {
        OOPS();
        goto GetDriverKeyNameError;
    }

    pDriverKeyName = ALLOC(nBytes);
    if (pDriverKeyName == NULL) {
        OOPS();
        goto GetDriverKeyNameError;
    }

    // Get the name of the driver key of the device attached to
    // the specified port.
    //
    pDriverKeyName->ConnectionIndex = ConnectionIndex;

    success = DeviceIoControl(Hub,
        IOCTL_USB_GET_NODE_CONNECTION_DRIVERKEY_NAME,
        pDriverKeyName,
        nBytes,
        pDriverKeyName,
        nBytes,
        &nBytes,
        NULL);

    if (!success) {
        OOPS();
        goto GetDriverKeyNameError;
    }

    // Convert the driver key name
    //
    size_t stringByteSize = (wcslen(pDriverKeyName->DriverKeyName) + 1) * sizeof(WCHAR);
    driverKeyNameString = ALLOC(stringByteSize);
    if (driverKeyNameString) {
        StringCbCopyW(driverKeyNameString, stringByteSize, pDriverKeyName->DriverKeyName);;
    }

    // All done, free the uncoverted driver key name and return the
    // converted driver key name
    //
    FREE(pDriverKeyName);

    return driverKeyNameString;


GetDriverKeyNameError:
    // There was an error, free anything that was allocated
    //
    if (pDriverKeyName != NULL) {
        FREE(pDriverKeyName);
        pDriverKeyName = NULL;
    }

    return NULL;
}


//*****************************************************************************
//
// GetHCDDriverKeyName()
//
//*****************************************************************************

PWCHAR GetHCDDriverKeyName(
    HANDLE  HCD
) {
    BOOL                    success = 0;
    ULONG                   nBytes = 0;
    USB_HCD_DRIVERKEY_NAME  driverKeyName = { 0 };
    PUSB_HCD_DRIVERKEY_NAME driverKeyNameW = NULL;
    PWCHAR                   driverKeyNameString = NULL;

    ZeroMemory(&driverKeyName, sizeof(driverKeyName));

    // Get the length of the name of the driver key of the HCD
    //
    success = DeviceIoControl(HCD,
        IOCTL_GET_HCD_DRIVERKEY_NAME,
        &driverKeyName,
        sizeof(driverKeyName),
        &driverKeyName,
        sizeof(driverKeyName),
        &nBytes,
        NULL);

    if (!success) {
        OOPS();
        goto GetHCDDriverKeyNameError;
    }

    // Allocate space to hold the driver key name
    //
    nBytes = driverKeyName.ActualLength;
    if (nBytes <= sizeof(driverKeyName)) {
        OOPS();
        goto GetHCDDriverKeyNameError;
    }

    driverKeyNameW = ALLOC(nBytes);
    if (driverKeyNameW == NULL) {
        OOPS();
        goto GetHCDDriverKeyNameError;
    }

    // Get the name of the driver key of the device attached to
    // the specified port.
    //

    success = DeviceIoControl(HCD,
        IOCTL_GET_HCD_DRIVERKEY_NAME,
        driverKeyNameW,
        nBytes,
        driverKeyNameW,
        nBytes,
        &nBytes,
        NULL);
    if (!success) {
        OOPS();
        goto GetHCDDriverKeyNameError;
    }

    //
    // Convert the driver key name
    // Pass the length of the DriverKeyName string
    // 
    size_t stringByteSize = (wcslen(driverKeyNameW->DriverKeyName) + 1) * sizeof(WCHAR);
    driverKeyNameString = ALLOC(stringByteSize);
    if (driverKeyNameString) {
        StringCbCopyW(driverKeyNameString, stringByteSize, driverKeyNameW->DriverKeyName);;
    }

    // All done, free the uncoverted driver key name and return the
    // converted driver key name
    //
    FREE(driverKeyNameW);

    return driverKeyNameString;

GetHCDDriverKeyNameError:
    // There was an error, free anything that was allocated
    //
    if (driverKeyNameW != NULL) {
        FREE(driverKeyNameW);
        driverKeyNameW = NULL;
    }

    return NULL;
}

//*****************************************************************************
//
// GetHostControllerPowerMap()
//
// HANDLE hHCDev
//      - handle to USB Host Controller
//
// PUSBHOSTCONTROLLERINFO hcInfo
//      - data structure to receive the Power Map Info
//
// return DWORD dwError
//      - return ERROR_SUCCESS or last error
//
//*****************************************************************************

DWORD
GetHostControllerPowerMap(
    HANDLE hHCDev,
    PUSBHOSTCONTROLLERINFO hcInfo) {
    USBUSER_POWER_INFO_REQUEST UsbPowerInfoRequest;
    PUSB_POWER_INFO            pUPI = &UsbPowerInfoRequest.PowerInformation;
    DWORD                      dwError = 0;
    DWORD                      dwBytes = 0;
    BOOL                       bSuccess = FALSE;
    int                        nIndex = 0;
    int                        nPowerState = WdmUsbPowerSystemWorking;

    for (; nPowerState <= WdmUsbPowerSystemShutdown; nIndex++, nPowerState++) {
        // zero initialize our request
        ZeroMemory(&UsbPowerInfoRequest, sizeof(UsbPowerInfoRequest));

        // set the header and request sizes
        UsbPowerInfoRequest.Header.UsbUserRequest = USBUSER_GET_POWER_STATE_MAP;
        UsbPowerInfoRequest.Header.RequestBufferLength = sizeof(UsbPowerInfoRequest);
        UsbPowerInfoRequest.PowerInformation.SystemState = nPowerState;

        //
        // Now query USBHUB for the USB_POWER_INFO structure for this hub.
        // For Selective Suspend support
        //
        bSuccess = DeviceIoControl(hHCDev,
            IOCTL_USB_USER_REQUEST,
            &UsbPowerInfoRequest,
            sizeof(UsbPowerInfoRequest),
            &UsbPowerInfoRequest,
            sizeof(UsbPowerInfoRequest),
            &dwBytes,
            NULL);

        if (!bSuccess) {
            dwError = GetLastError();
            OOPS();
        } else {
            // copy the data into our USB Host Controller's info structure
            memcpy(&(hcInfo->USBPowerInfo[nIndex]), pUPI, sizeof(USB_POWER_INFO));
        }
    }

    return dwError;
}


//*****************************************************************************
//
// GetHostControllerInfo()
//
// HANDLE hHCDev
//      - handle to USB Host Controller
//
// PUSBHOSTCONTROLLERINFO hcInfo
//      - data structure to receive the Power Map Info
//
// return DWORD dwError
//      - return ERROR_SUCCESS or last error
//
//*****************************************************************************

DWORD
GetHostControllerInfo(
    HANDLE hHCDev,
    PUSBHOSTCONTROLLERINFO hcInfo) {
    USBUSER_CONTROLLER_INFO_0 UsbControllerInfo;
    DWORD                      dwError = 0;
    DWORD                      dwBytes = 0;
    BOOL                       bSuccess = FALSE;

    ZeroMemory(&UsbControllerInfo, sizeof(UsbControllerInfo));

    // set the header and request sizes
    UsbControllerInfo.Header.UsbUserRequest = USBUSER_GET_CONTROLLER_INFO_0;
    UsbControllerInfo.Header.RequestBufferLength = sizeof(UsbControllerInfo);

    //
    // Query for the USB_CONTROLLER_INFO_0 structure
    //
    bSuccess = DeviceIoControl(hHCDev,
        IOCTL_USB_USER_REQUEST,
        &UsbControllerInfo,
        sizeof(UsbControllerInfo),
        &UsbControllerInfo,
        sizeof(UsbControllerInfo),
        &dwBytes,
        NULL);

    if (!bSuccess) {
        dwError = GetLastError();
        OOPS();
    } else {
        hcInfo->ControllerInfo = (PUSB_CONTROLLER_INFO_0)ALLOC(sizeof(USB_CONTROLLER_INFO_0));
        if (NULL == hcInfo->ControllerInfo) {
            dwError = GetLastError();
            OOPS();
        } else {
            // copy the data into our USB Host Controller's info structure
            memcpy(hcInfo->ControllerInfo, &UsbControllerInfo.Info0, sizeof(USB_CONTROLLER_INFO_0));
        }
    }
    return dwError;
}

_Success_(return == TRUE)
BOOL
GetDeviceProperty(
    _In_    HDEVINFO         DeviceInfoSet,
    _In_    PSP_DEVINFO_DATA DeviceInfoData,
    _In_    DWORD            Property,
    _Outptr_  LPWSTR        *ppBuffer
) {
    BOOL bResult;
    DWORD requiredLength = 0;
    DWORD lastError;

    if (ppBuffer == NULL) {
        return FALSE;
    }

    *ppBuffer = NULL;

    bResult = SetupDiGetDeviceRegistryPropertyW(DeviceInfoSet,
        DeviceInfoData,
        Property,
        NULL,
        NULL,
        0,
        &requiredLength);
    lastError = GetLastError();

    if ((requiredLength == 0) || (bResult != FALSE && lastError != ERROR_INSUFFICIENT_BUFFER)) {
        return FALSE;
    }

    *ppBuffer = ALLOC(requiredLength);

    if (*ppBuffer == NULL) {
        return FALSE;
    }

    bResult = SetupDiGetDeviceRegistryPropertyW(DeviceInfoSet,
        DeviceInfoData,
        Property,
        NULL,
        (PBYTE)*ppBuffer,
        requiredLength,
        &requiredLength);
    if (bResult == FALSE) {
        FREE(*ppBuffer);
        *ppBuffer = NULL;
        return FALSE;
    }

    return TRUE;
}

DEVICE_POWER_STATE
AcquireDevicePowerState(
    _Inout_ PDEVICE_INFO_NODE pNode
) {
    CM_POWER_DATA cmPowerData = { 0 };
    BOOL bResult;

    bResult = SetupDiGetDeviceRegistryPropertyW(pNode->DeviceInfo,
        &pNode->DeviceInfoData,
        SPDRP_DEVICE_POWER_DATA,
        NULL,
        (PBYTE)&cmPowerData,
        sizeof(cmPowerData),
        NULL);

    pNode->LatestDevicePowerState = bResult ? cmPowerData.PD_MostRecentPowerState : PowerDeviceUnspecified;

    return pNode->LatestDevicePowerState;
}

//*****************************************************************************
//
// GetAllStringDescriptors()
//
// hHubDevice - Handle of the hub device containing the port from which the
// String Descriptors will be requested.
//
// ConnectionIndex - Identifies the port on the hub to which a device is
// attached from which the String Descriptors will be requested.
//
// DeviceDesc - Device Descriptor for which String Descriptors should be
// requested.
//
// ConfigDesc - Configuration Descriptor (also containing Interface Descriptor)
// for which String Descriptors should be requested.
//
//*****************************************************************************

PSTRING_DESCRIPTOR_NODE
GetAllStringDescriptors(
    HANDLE                          hHubDevice,
    ULONG                           ConnectionIndex,
    PUSB_DEVICE_DESCRIPTOR          DeviceDesc
) {
    PSTRING_DESCRIPTOR_NODE supportedLanguagesString = NULL;
    ULONG                   numLanguageIDs = 0;
    USHORT                  *languageIDs = NULL;

    PUCHAR                  descEnd = NULL;
    PUSB_COMMON_DESCRIPTOR  commonDesc = NULL;
    UCHAR                   uIndex = 1;
    UCHAR                   bInterfaceClass = 0;
    BOOL                    getMoreStrings = FALSE;
    HRESULT                 hr = S_OK;

    //
    // Get the array of supported Language IDs, which is returned
    // in String Descriptor 0
    //
    supportedLanguagesString = GetStringDescriptor(hHubDevice,
        ConnectionIndex,
        0,
        0);

    if (supportedLanguagesString == NULL) {
        return NULL;
    }

    numLanguageIDs = (supportedLanguagesString->StringDescriptor->bLength - 2) / 2;

    languageIDs = &supportedLanguagesString->StringDescriptor->bString[0];

    //
    // Get the Device Descriptor strings
    //

    if (DeviceDesc->iManufacturer) {
        GetStringDescriptors(hHubDevice,
            ConnectionIndex,
            DeviceDesc->iManufacturer,
            numLanguageIDs,
            languageIDs,
            supportedLanguagesString);
    }

    if (DeviceDesc->iProduct) {
        GetStringDescriptors(hHubDevice,
            ConnectionIndex,
            DeviceDesc->iProduct,
            numLanguageIDs,
            languageIDs,
            supportedLanguagesString);
    }

    if (DeviceDesc->iSerialNumber) {
        GetStringDescriptors(hHubDevice,
            ConnectionIndex,
            DeviceDesc->iSerialNumber,
            numLanguageIDs,
            languageIDs,
            supportedLanguagesString);
    }

    return supportedLanguagesString;
}

//*****************************************************************************
//
// GetStringDescriptors()
//
// hHubDevice - Handle of the hub device containing the port from which the
// String Descriptor will be requested.
//
// ConnectionIndex - Identifies the port on the hub to which a device is
// attached from which the String Descriptor will be requested.
//
// DescriptorIndex - String Descriptor index.
//
// NumLanguageIDs -  Number of languages in which the string should be
// requested.
//
// LanguageIDs - Languages in which the string should be requested.
//
// StringDescNodeHead - First node in linked list of device's string descriptors
//
// Return Value: HRESULT indicating whether the string is on the list
//
//*****************************************************************************

HRESULT
GetStringDescriptors(
    _In_ HANDLE                         hHubDevice,
    _In_ ULONG                          ConnectionIndex,
    _In_ UCHAR                          DescriptorIndex,
    _In_ ULONG                          NumLanguageIDs,
    _In_reads_(NumLanguageIDs) USHORT  *LanguageIDs,
    _In_ PSTRING_DESCRIPTOR_NODE        StringDescNodeHead
) {
    PSTRING_DESCRIPTOR_NODE tail = NULL;
    PSTRING_DESCRIPTOR_NODE trailing = NULL;
    ULONG i = 0;

    //
    // Go to the end of the linked list, searching for the requested index to
    // see if we've already retrieved it
    //
    for (tail = StringDescNodeHead; tail != NULL; tail = tail->Next) {
        if (tail->DescriptorIndex == DescriptorIndex) {
            return S_OK;
        }

        trailing = tail;
    }

    tail = trailing;

    //
    // Get the next String Descriptor. If this is NULL, then we're done (return)
    // Otherwise, loop through all Language IDs
    //
    for (i = 0; (tail != NULL) && (i < NumLanguageIDs); i++) {
        tail->Next = GetStringDescriptor(hHubDevice,
            ConnectionIndex,
            DescriptorIndex,
            LanguageIDs[i]);

        tail = tail->Next;
    }

    if (tail == NULL) {
        return E_FAIL;
    } else {
        return S_OK;
    }
}

//*****************************************************************************
//
// GetStringDescriptor()
//
// hHubDevice - Handle of the hub device containing the port from which the
// String Descriptor will be requested.
//
// ConnectionIndex - Identifies the port on the hub to which a device is
// attached from which the String Descriptor will be requested.
//
// DescriptorIndex - String Descriptor index.
//
// LanguageID - Language in which the string should be requested.
//
//*****************************************************************************

PSTRING_DESCRIPTOR_NODE
GetStringDescriptor(
    HANDLE  hHubDevice,
    ULONG   ConnectionIndex,
    UCHAR   DescriptorIndex,
    USHORT  LanguageID
) {
    BOOL    success = 0;
    ULONG   nBytes = 0;
    ULONG   nBytesReturned = 0;

    UCHAR   stringDescReqBuf[sizeof(USB_DESCRIPTOR_REQUEST) +
        MAXIMUM_USB_STRING_LENGTH];

    PUSB_DESCRIPTOR_REQUEST stringDescReq = NULL;
    PUSB_STRING_DESCRIPTOR  stringDesc = NULL;
    PSTRING_DESCRIPTOR_NODE stringDescNode = NULL;

    nBytes = sizeof(stringDescReqBuf);

    stringDescReq = (PUSB_DESCRIPTOR_REQUEST)stringDescReqBuf;
    stringDesc = (PUSB_STRING_DESCRIPTOR)(stringDescReq + 1);

    // Zero fill the entire request structure
    //
    ZeroMemory(stringDescReq, nBytes);

    // Indicate the port from which the descriptor will be requested
    //
    stringDescReq->ConnectionIndex = ConnectionIndex;

    //
    // USBHUB uses URB_FUNCTION_GET_DESCRIPTOR_FROM_DEVICE to process this
    // IOCTL_USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION request.
    //
    // USBD will automatically initialize these fields:
    //     bmRequest = 0x80
    //     bRequest  = 0x06
    //
    // We must inititialize these fields:
    //     wValue    = Descriptor Type (high) and Descriptor Index (low byte)
    //     wIndex    = Zero (or Language ID for String Descriptors)
    //     wLength   = Length of descriptor buffer
    //
    stringDescReq->SetupPacket.wValue = (USB_STRING_DESCRIPTOR_TYPE << 8)
        | DescriptorIndex;

    stringDescReq->SetupPacket.wIndex = LanguageID;

    stringDescReq->SetupPacket.wLength = (USHORT)(nBytes - sizeof(USB_DESCRIPTOR_REQUEST));

    // Now issue the get descriptor request.
    //
    success = DeviceIoControl(hHubDevice,
        IOCTL_USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION,
        stringDescReq,
        nBytes,
        stringDescReq,
        nBytes,
        &nBytesReturned,
        NULL);

    //
    // Do some sanity checks on the return from the get descriptor request.
    //

    if (!success) {
        OOPS();
        return NULL;
    }

    if (nBytesReturned < 2) {
        OOPS();
        return NULL;
    }

    if (stringDesc->bDescriptorType != USB_STRING_DESCRIPTOR_TYPE) {
        OOPS();
        return NULL;
    }

    if (stringDesc->bLength != nBytesReturned - sizeof(USB_DESCRIPTOR_REQUEST)) {
        OOPS();
        return NULL;
    }

    if (stringDesc->bLength % 2 != 0) {
        OOPS();
        return NULL;
    }

    //
    // Looks good, allocate some (zero filled) space for the string descriptor
    // node and copy the string descriptor to it.
    //

    stringDescNode = (PSTRING_DESCRIPTOR_NODE)ALLOC(sizeof(STRING_DESCRIPTOR_NODE) +
        stringDesc->bLength);

    if (stringDescNode == NULL) {
        OOPS();
        return NULL;
    }

    stringDescNode->DescriptorIndex = DescriptorIndex;
    stringDescNode->LanguageID = LanguageID;

    memcpy(stringDescNode->StringDescriptor,
        stringDesc,
        stringDesc->bLength);

    return stringDescNode;
}
