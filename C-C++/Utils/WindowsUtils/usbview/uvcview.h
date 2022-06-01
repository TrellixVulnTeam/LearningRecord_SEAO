/*++

Copyright (c) 1997-2008 Microsoft Corporation

Module Name:

    UVCVIEW.H

Abstract:

    This is the header file for UVCVIEW

Environment:

    user mode

Revision History:

    04-25-97 : created
    04/13/2005 : major bug fixing

--*/

/*****************************************************************************
 I N C L U D E S
*****************************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <initguid.h>
#include <devioctl.h>
#include <dbt.h>
#include <stdio.h>
#include <stddef.h>
#include <commctrl.h>
#include <usbioctl.h>
#include <usbiodef.h>
#include <intsafe.h>
#include <strsafe.h>
#include <specstrings.h>
#include <usb.h>
#include <usbuser.h>
#include <basetyps.h>
#include <wtypes.h>
#include <objbase.h>
#include <io.h>
#include <conio.h>
#include <shellapi.h>
#include <cfgmgr32.h>
#include <shlwapi.h>
#include <setupapi.h>
#include <winioctl.h>
#include <devpkey.h>
#include <math.h>
#include <Poclass.h>

// This is mostly a private USB Audio descriptor header
#include "usbdesc.h"

// This is the inbox USBVideo driver descriptor header (copied locally)
#include "uvcdesc.h"

/*****************************************************************************
 P R A G M A S
*****************************************************************************/

#pragma once

/*****************************************************************************
 D E F I N E S
*****************************************************************************/

// define H264_SUPPORT to add H.264 support to uvcview.exe
#define H264_SUPPORT

#define TEXT_ITEM_LENGTH 64

#ifdef  DEBUG
#undef  DBG
#define DBG 1
#endif

#if DBG
#define OOPS() Oops(__FILE__, __LINE__)
#else
#define  OOPS()
#endif

#if DBG

#define ALLOC(dwBytes) MyAlloc(__FILE__, __LINE__, (dwBytes))

#define REALLOC(hMem, dwBytes) MyReAlloc((hMem), (dwBytes))

#define FREE(hMem)  MyFree((hMem))

#define CHECKFORLEAKS() MyCheckForLeaks()

#else

#define ALLOC(dwBytes) GlobalAlloc(GPTR,(dwBytes))

#define REALLOC(hMem, dwBytes) GlobalReAlloc((hMem), (dwBytes), (GMEM_MOVEABLE|GMEM_ZEROINIT))

#define FREE(hMem)  GlobalFree((hMem))

#define CHECKFORLEAKS()

#endif

#define DEVICE_CONFIGURATION_TEXT_LENGTH 10240

#define STR_INVALID_POWER_STATE    "(invalid state) "
#define STR_UNKNOWN_CONTROLLER_FLAVOR "Unknown"

/*
    https://android.googlesource.com/platform/development/+/master/host/windows/usb/android_winusb.inf
    Class = AndroidUsbDeviceClass
    ClassGuid = {3F966BD9-FA04-4EC5-991C-D326973B5128}
*/
DEFINE_GUID(GUID_ANDROID_CLASS, 0x3F966BD9, 0xFA04, 0x4EC5, 0x99, 0x1C, 0xD3, \
    0x26, 0x97, 0x3B, 0x51, 0x28);
#define GUID_ANDROID_CLASS_STRING L"{3f966bd9-fa04-4ec5-991c-d326973b5128}"

/*
https://docs.microsoft.com/en-us/windows-hardware/drivers/install/system-defined-device-setup-classes-available-to-vendors
Class = Keyboard
ClassGuid = {4d36e96b-e325-11ce-bfc1-08002be10318}

Class = Mouse
ClassGuid = {4d36e96f-e325-11ce-bfc1-08002be10318}

Class = Bluetooth
ClassGuid = {e0cbf06c-cd8b-4647-bb8a-263b43f0f974}

*/
#define GUID_KEYBOARD_CLASS_STRING L"{4d36e96b-e325-11ce-bfc1-08002be10318}"
#define GUID_MOUSE_CLASS_STRING L"{4d36e96f-e325-11ce-bfc1-08002be10318}"
#define GUID_BLUETOOTH_CLASS_STRING L"{e0cbf06c-cd8b-4647-bb8a-263b43f0f974}"

/*
    https://android.googlesource.com/platform/development/+/8c78ba643862731c603677284ae88089a959cc52/host/windows/usb/api/adb_api_extra.h
    adb DeviceInterface GUID
*/
#define GUID_ADB_STRING L"{F72FE0D4-CBCB-407D-8814-9ED673D0DD6B}"

/*
    hdb DeviceInterface GUID
*/
#define GUID_HDB_STRING L"{9DB27A70-239F-4598-A0E6-C94D8FC7F1B3}"

/*
    DeviceInterface GUID
*/
#define GUID_DEVICE_APPLICATIONLAUNCH_BUTTON_STRING L"{629758EE-986E-4D9E-8E47-DE27F8AB054D}"
#define GUID_DEVICE_BATTERY_STRING L"{72631E54-78A4-11D0-BCF7-00AA00B7B32A}"
#define GUID_DEVICE_LID_STRING L"{4AFA3D52-74A7-11d0-be5e-00A0C9062857}"
#define GUID_DEVICE_MEMORY_STRING L"{3FD0F03D-92E0-45FB-B75C-5ED8FFB01021}"
#define GUID_DEVICE_MESSAGE_INDICATOR_STRING L"{CD48A365-FA94-4CE2-A232-A1B764E5D8B4}"
#define GUID_DEVICE_PROCESSOR_STRING L"{97FADB10-4E33-40AE-359C-8BEF029DBDD0}"
#define GUID_DEVICE_SYS_BUTTON_STRING L"{4AFA3D53-74A7-11d0-be5e-00A0C9062857}"
#define GUID_DEVICE_THERMAL_ZONE_STRING L"{4AFA3D51-74A7-11d0-be5e-00A0C9062857}"
#define GUID_DEVINTERFACE_BRIGHTNESS_STRING L"{FDE5BBA4-B3F9-46FB-BDAA-0728CE3100B4}"
#define GUID_DEVINTERFACE_CDCHANGER_STRING L"{53F56312-B6BF-11D0-94F2-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_CDROM_STRING L"{53F56308-B6BF-11D0-94F2-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_COMPORT_STRING L"{86E0D1E0-8089-11D0-9CE4-08003E301F73}"
#define GUID_DEVINTERFACE_DISK_STRING L"{53F56307-B6BF-11D0-94F2-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_DISPLAY_ADAPTER_STRING L"{5B45201D-F2F2-4F3B-85BB-30FF1F953599}"
#define GUID_DEVINTERFACE_FLOPPY_ADAPTER_STRING L"{53F56311-B6BF-11D0-94F2-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_HID_STRING L"{4D1E55B2-F16F-11CF-88CB-001111000030}"
#define GUID_DEVINTERFACE_I2C_STRING L"{2564AA4F-DDDB-4495-B497-6AD4A84163D7}"
#define GUID_DEVINTERFACE_IMAGE_STRING L"{6BDD1FC6-810F-11D0-BEC7-08002BE2092F}"
#define GUID_DEVINTERFACE_KEYBOARD_STRING L"{884b96c3-56ef-11d1-bc8c-00a0c91405dd}"
#define GUID_DEVINTERFACE_MEDIUMCHANGER_STRING L"{53F56310-B6BF-11D0-94F2-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_MODEM_STRING L"{2C7089AA-2E0E-11D1-B114-00C04FC2AAE4}"
#define GUID_DEVINTERFACE_MONITOR_STRING L"{E6F07B5F-EE97-4a90-B076-33F57BF4EAA7}"
#define GUID_DEVINTERFACE_MOUSE_STRING L"{378DE44C-56EF-11D1-BC8C-00A0C91405DD}"
#define GUID_DEVINTERFACE_NET_STRING L"{CAC88484-7515-4C03-82E6-71A87ABAC361}"
#define GUID_DEVINTERFACE_OPM_STRING L"{BF4672DE-6B4E-4BE4-A325-68A91EA49C09}"
#define GUID_DEVINTERFACE_PARALLEL_STRING L"{97F76EF0-F883-11D0-AF1F-0000F800845C}"
#define GUID_DEVINTERFACE_PARCLASS_STRING L"{811FC6A5-F728-11D0-A537-0000F8753ED1}"
#define GUID_DEVINTERFACE_PARTITION_STRING L"{53F5630A-B6BF-11D0-94F2-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_SERENUM_BUS_ENUMERATOR_STRING L"{4D36E978-E325-11CE-BFC1-08002BE10318}"
#define GUID_DEVINTERFACE_SIDESHOW_STRING L"{152E5811-FEB9-4B00-90F4-D32947AE1681}"
#define GUID_DEVINTERFACE_STORAGEPORT_STRING L"{2ACCFE60-C130-11D2-B082-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_TAPE_STRING L"{53F5630B-B6BF-11D0-94F2-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_USB_DEVICE_STRING L"{A5DCBF10-6530-11D2-901F-00C04FB951ED}"
#define GUID_DEVINTERFACE_USB_HOST_CONTROLLER_STRING L"{3ABF6F2D-71C4-462A-8A92-1E6861E6AF27}"
#define GUID_DEVINTERFACE_USB_HUB_STRING L"{F18A0E88-C30C-11D0-8815-00A0C906BED8}"
#define GUID_DEVINTERFACE_VIDEO_OUTPUT_ARRIVAL_STRING L"{1AD9E4F0-F88D-4360-BAB9-4C2D55E564CD}"
#define GUID_DEVINTERFACE_VOLUME_STRING L"{53F5630D-B6BF-11D0-94F2-00A0C91EFB8B}"
#define GUID_DEVINTERFACE_WPD_STRING L"{6AC27878-A6FA-4155-BA85-F98F491D4F33}"
#define GUID_DEVINTERFACE_WPD_PRIVATE_STRING L"{BA0C718F-4DED-49B7-BDD3-FABE28661211}"
#define GUID_DEVINTERFACE_WRITEONCEDISK_STRING L"{53F5630C-B6BF-11D0-94F2-00A0C91EFB8B}"

#define GUID_DEVINTERFACE_WINUSB_STRING L"{DEE824EF-729B-4A0E-9C14-B7117D33A817}"



FORCEINLINE
VOID
InitializeListHead(
    _Out_ PLIST_ENTRY ListHead
) {
    ListHead->Flink = ListHead->Blink = ListHead;
}

//
//  BOOLEAN
//  IsListEmpty(
//      PLIST_ENTRY ListHead
//      );
//

#define IsListEmpty(ListHead) \
    ((ListHead)->Flink == (ListHead))

//
//  PLIST_ENTRY
//  RemoveHeadList(
//      PLIST_ENTRY ListHead
//      );
//

#define RemoveHeadList(ListHead) \
    (ListHead)->Flink;\
    {RemoveEntryList((ListHead)->Flink)}

//
//  VOID
//  RemoveEntryList(
//      PLIST_ENTRY Entry
//      );
//

#define RemoveEntryList(Entry) {\
    PLIST_ENTRY _EX_Blink;\
    PLIST_ENTRY _EX_Flink;\
    _EX_Flink = (Entry)->Flink;\
    _EX_Blink = (Entry)->Blink;\
    _EX_Blink->Flink = _EX_Flink;\
    _EX_Flink->Blink = _EX_Blink;\
    }

//
//  VOID
//  InsertTailList(
//      PLIST_ENTRY ListHead,
//      PLIST_ENTRY Entry
//      );
//

#define InsertTailList(ListHead,Entry) {\
    PLIST_ENTRY _EX_Blink;\
    PLIST_ENTRY _EX_ListHead;\
    _EX_ListHead = (ListHead);\
    _EX_Blink = _EX_ListHead->Blink;\
    (Entry)->Flink = _EX_ListHead;\
    (Entry)->Blink = _EX_Blink;\
    _EX_Blink->Flink = (Entry);\
    _EX_ListHead->Blink = (Entry);\
    }

// global version for USB Video Class spec version (pre-release)
#define BCDVDC     0x0083

// A.2  Video Interface Subclass Codes
#define SC_VIDEO_INTERFACE_COLLECTION  0x03

// A.3  Video Interface Protocol Codes
#define PC_PROTOCOL_UNDEFINED     0x00

// USB Video Class spec version
#define NOT_UVC 0x0
#define UVC10   0x100
#define UVC11   0x110

#ifdef H264_SUPPORT
#define UVC15   0x150
#endif

#define OUTPUT_MESSAGE_MAX_LENGTH    1024
#define MAX_DEVICE_PROP 200
#define MAX_DRIVER_KEY_NAME 256

/*****************************************************************************
 T Y P E D E F S
*****************************************************************************/

//
// Structure used to build a linked list of String Descriptors
// retrieved from a device.
//

typedef struct _STRING_DESCRIPTOR_NODE {
    struct _STRING_DESCRIPTOR_NODE *Next;
    UCHAR                           DescriptorIndex;
    USHORT                          LanguageID;
    USB_STRING_DESCRIPTOR           StringDescriptor[1];
} STRING_DESCRIPTOR_NODE, *PSTRING_DESCRIPTOR_NODE;

//
// A collection of device properties. The device can be hub, host controller or usb device
//
typedef struct _USB_DEVICE_PNP_STRINGS {
    PWCHAR DeviceId;
    PWCHAR DeviceDesc;
    PWCHAR HwId;
    PWCHAR Service;
    PWCHAR DeviceClass;
    PWCHAR PowerState;
} USB_DEVICE_PNP_STRINGS, *PUSB_DEVICE_PNP_STRINGS;

typedef struct _DEVICE_INFO_NODE {
    HDEVINFO                         DeviceInfo;
    LIST_ENTRY                       ListEntry;
    SP_DEVINFO_DATA                  DeviceInfoData;
    SP_DEVICE_INTERFACE_DATA         DeviceInterfaceData;
    PSP_DEVICE_INTERFACE_DETAIL_DATA DeviceDetailData;
    PSTR                             DeviceDescName;
    ULONG                            DeviceDescNameLength;
    PSTR                             DeviceDriverName;
    ULONG                            DeviceDriverNameLength;
    DEVICE_POWER_STATE               LatestDevicePowerState;
} DEVICE_INFO_NODE, *PDEVICE_INFO_NODE;

//
// Structures assocated with TreeView items through the lParam.  When an item
// is selected, the lParam is retrieved and the structure it which it points
// is used to display information in the edit control.
//

typedef enum _USBDEVICEINFOTYPE {
    HostControllerInfo,
    RootHubInfo,
    ExternalHubInfo,
    DeviceInfo
} USBDEVICEINFOTYPE, *PUSBDEVICEINFOTYPE;

typedef struct _USBHOSTCONTROLLERINFO {
    USBDEVICEINFOTYPE                   DeviceInfoType;
    LIST_ENTRY                          ListEntry;
    PWCHAR                              DriverKey;
    ULONG                               VendorID;
    ULONG                               DeviceID;
    ULONG                               SubSysID;
    ULONG                               Revision;
    USB_POWER_INFO                      USBPowerInfo[6];
    BOOL                                BusDeviceFunctionValid;
    ULONG                               BusNumber;
    USHORT                              BusDevice;
    USHORT                              BusFunction;
    PUSB_CONTROLLER_INFO_0              ControllerInfo;
    PUSB_DEVICE_PNP_STRINGS             UsbDeviceProperties;
} USBHOSTCONTROLLERINFO, *PUSBHOSTCONTROLLERINFO;

typedef struct _USBROOTHUBINFO {
    USBDEVICEINFOTYPE                   DeviceInfoType;
    PUSB_NODE_INFORMATION               HubInfo;
    PUSB_HUB_INFORMATION_EX             HubInfoEx;
    PWCHAR                              HubName;
    PUSB_PORT_CONNECTOR_PROPERTIES      PortConnectorProps;
    PUSB_DEVICE_PNP_STRINGS             UsbDeviceProperties;
    PDEVICE_INFO_NODE                   DeviceInfoNode;
    PUSB_HUB_CAPABILITIES_EX            HubCapabilityEx;

} USBROOTHUBINFO, *PUSBROOTHUBINFO;

typedef struct _USBEXTERNALHUBINFO {
    USBDEVICEINFOTYPE                      DeviceInfoType;
    PUSB_NODE_INFORMATION                  HubInfo;
    PUSB_HUB_INFORMATION_EX                HubInfoEx;
    PWCHAR                                 HubName;
    PUSB_NODE_CONNECTION_INFORMATION_EX    ConnectionInfo;
    PUSB_PORT_CONNECTOR_PROPERTIES         PortConnectorProps;
    PUSB_DESCRIPTOR_REQUEST                ConfigDesc;
    PUSB_DESCRIPTOR_REQUEST                BosDesc;
    PSTRING_DESCRIPTOR_NODE                StringDescs;
    PUSB_NODE_CONNECTION_INFORMATION_EX_V2 ConnectionInfoV2; // NULL if root HUB
    PUSB_DEVICE_PNP_STRINGS                UsbDeviceProperties;
    PDEVICE_INFO_NODE                      DeviceInfoNode;
    PUSB_HUB_CAPABILITIES_EX               HubCapabilityEx;
} USBEXTERNALHUBINFO, *PUSBEXTERNALHUBINFO;


// HubInfo, HubName may be in USBDEVICEINFOTYPE, so they can be removed
typedef struct {
    USBDEVICEINFOTYPE                      DeviceInfoType;
    PUSB_NODE_INFORMATION                  HubInfo;          // NULL if not a HUB
    PUSB_HUB_INFORMATION_EX                HubInfoEx;        // NULL if not a HUB
    PWCHAR                                 HubName;          // NULL if not a HUB
    PUSB_NODE_CONNECTION_INFORMATION_EX    ConnectionInfo;   // NULL if root HUB
    PUSB_PORT_CONNECTOR_PROPERTIES         PortConnectorProps;
    PUSB_DESCRIPTOR_REQUEST                ConfigDesc;       // NULL if root HUB
    PUSB_DESCRIPTOR_REQUEST                BosDesc;          // NULL if root HUB
    PSTRING_DESCRIPTOR_NODE                StringDescs;
    PUSB_NODE_CONNECTION_INFORMATION_EX_V2 ConnectionInfoV2; // NULL if root HUB
    PUSB_DEVICE_PNP_STRINGS                UsbDeviceProperties;
    PDEVICE_INFO_NODE                      DeviceInfoNode;
    PUSB_HUB_CAPABILITIES_EX               HubCapabilityEx;  // NULL if not a HUB
} USBDEVICEINFO, *PUSBDEVICEINFO;

typedef struct _STRINGLIST {
#ifdef H264_SUPPORT
    ULONGLONG       ulFlag;
#else
    ULONG           ulFlag;
#endif
    PCHAR     pszString;
    PCHAR     pszModifier;

} STRINGLIST, *PSTRINGLIST;

typedef struct _DEVICE_GUID_LIST {
    HDEVINFO   DeviceInfo;
    LIST_ENTRY ListHead;
} DEVICE_GUID_LIST, *PDEVICE_GUID_LIST;

typedef struct _DEVICE_INTERFACE_INFO {
    LIST_ENTRY listEntry;
    PWCHAR interfaceClassGUID;
    PWCHAR devicePath;
} DEVICE_INTERFACE_INFO, *PDEVICE_INTERFACE_INFO;

typedef struct _DEVICE_DRIVER_INFO {
    LIST_ENTRY listEntry;
    LIST_ENTRY listEntryDeviceInterface;
    PWCHAR driverKeyName;
    PWCHAR instanceId;
    PWCHAR desc;
    PWCHAR friendlyName;
    PWCHAR locationInfo;
    PWCHAR className;
    PWCHAR classGUID;
} DEVICE_DRIVER_INFO, *PDEVICE_DRIVER_INFO;

typedef struct _DEVICE_INFO {
    LIST_ENTRY listEntry;
    LIST_ENTRY listEntryDeviceDriver;

    /*
    -1 - other device
    -2 - usb hub
    0 - keyboard
    1 - mouse
    2 - bluetooth
    3 - android device
    4 - apple device
    */
    ULONG deviceType;

    PWCHAR portChain;
    PWCHAR companionPortChain;
    PWCHAR hubSymbolicLinkName;
    USHORT companionPortNumber;
    PWCHAR companionHubSymbolicLinkName;
    PWCHAR manufacturer;
    PWCHAR deviceId;
    USB_PROTOCOLS supportedUsbProtocols;
    ULONG connectionIndex;

    // an opaque handle to the device instance(also known as a handle to the devnode).
    DWORD devInst;
} DEVICE_INFO, *PDEVICE_INFO;


/*****************************************************************************
 F U N C T I O N    P R O T O T Y P E S
*****************************************************************************/

PCHAR WideStrToMultiStr(
    _In_reads_bytes_(cbWideStr) PWCHAR WideStr,
    _In_ size_t                   cbWideStr
);

PWCHAR MultiStrToWideStr(
    _In_reads_bytes_(cbMultiStr) PCHAR MultiStr,
    _In_ size_t                   cbMultiStr
);

//
// ENUM.C
//

VOID
EnumerateHostControllers(PLIST_ENTRY listHead, int getDetailData);

DEVICE_POWER_STATE
AcquireDevicePowerState(
    _Inout_ PDEVICE_INFO_NODE pNode
);

_Success_(return == TRUE)
BOOL
GetDeviceProperty(
    _In_    HDEVINFO         DeviceInfoSet,
    _In_    PSP_DEVINFO_DATA DeviceInfoData,
    _In_    DWORD            Property,
    _Outptr_ LPWSTR         *ppBuffer
);

BOOL
DriverNameToDeviceInst(
    _In_reads_bytes_(cbDriverName) LPWSTR pDriverName,
    _In_ size_t cbDriverName,
    _Out_ HDEVINFO *pDevInfo,
    _Out_writes_bytes_(sizeof(SP_DEVINFO_DATA)) PSP_DEVINFO_DATA pDevInfoData
);

//
// DEBUG.C
//

_Success_(return != NULL)
_Post_writable_byte_size_(dwBytes)
HGLOBAL
MyAlloc(
    _In_    PCHAR   File,
    ULONG   Line,
    DWORD   dwBytes
);

_Success_(return != NULL)
_Post_writable_byte_size_(dwBytes)
HGLOBAL
MyReAlloc(
    HGLOBAL hMem,
    DWORD   dwBytes
);

HGLOBAL
MyFree(
    HGLOBAL hMem
);

VOID
MyCheckForLeaks(
    VOID
);

//
// DEVNODE.C
//


PUSB_DEVICE_PNP_STRINGS
DriverNameToDeviceProperties(
    _In_reads_bytes_(cbDriverName) LPWSTR   pDriverName,
    _In_ size_t                       cbDriverName
);

VOID FreeDeviceProperties(
    _In_ PUSB_DEVICE_PNP_STRINGS *ppDevProps
);
//
// DISPAUD.C
//

BOOL
DisplayAudioDescriptor(
    PUSB_AUDIO_COMMON_DESCRIPTOR CommonDesc,
    UCHAR                        bInterfaceSubClass
);

//
// DISPVID.C
//

BOOL
DisplayVideoDescriptor(
    PVIDEO_SPECIFIC VidCommonDesc,
    UCHAR                        bInterfaceSubClass,
    PSTRING_DESCRIPTOR_NODE      StringDescs,
    DEVICE_POWER_STATE           LatestDevicePowerState
);

//
// DISPLAY.C
//

BOOL
ValidateDescAddress(
    PUSB_COMMON_DESCRIPTOR          commonDesc
);
