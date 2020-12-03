// rapidjson
#include "rapidjson\rapidjson.h"
#include "rapidjson\document.h"
#include "rapidjson\writer.h"
#include "rapidjson\stringbuffer.h"

#include <windows.h>
#include <tchar.h>
#include <strsafe.h>
#include <shlwapi.h>
#include <shlobj.h>
#include <atlbase.h>
#include <string>
#include <list>
#include <map>

#pragma comment(lib, "shlwapi")
#pragma comment(lib, "shell32")

//#pragma comment(lib, "legacy_stdio_definitions")

// libplist
#include "libplist\include\plist\plist.h"
#pragma comment(lib, "libplist")

// openssl
#include <openssl/md5.h>
#pragma comment(lib, "libeay32")

// GDI+
#include <GdiPlus.h>
#pragma comment(lib, "gdiplus")

// StringConvertor
#include "StringConvertor\StringConvertor.h"
#pragma comment(lib, "StringConvertor")

// imageconverter
#include "ImageConverter/ImageConverter.h"
#pragma comment(lib, "ImageConverter")

// pugixml
#include "pugixml\pugixml.hpp"
#pragma comment(lib, "pugixml")

// rapidxml
#include "rapidxml\rapidxml_utils.hpp"

// tinyxml2
#include "tinyxml2\tinyxml2.h"
#pragma comment(lib, "tinyxml2")

// pcre
#include "pcre\pcre.h"
#pragma comment(lib, "pcre")

// pcre2
#define PCRE2_CODE_UNIT_WIDTH 8
#include "pcre2\pcre2.h"
#pragma comment(lib, "pcre2")

#include <google/protobuf/compiler/command_line_interface.h>
#ifdef _DEBUG
#pragma comment(lib, "libprotobufd")
#pragma comment(lib, "libprotocd")
#else
#pragma comment(lib, "libprotobuf")
#pragma comment(lib, "libprotoc")
#endif

int ParseProp(const std::wstring& wstrFile, std::map<std::string, std::string>& values) {
    values.clear();
    google::protobuf::compiler::CommandLineInterface cli;
    cli.AllowPlugins("protoc-");
    return cli.Run(wstrFile, values);
}

int ParseProp(const char* szData, int iSize, std::map<std::string, std::string>& values) {
    values.clear();
    google::protobuf::compiler::CommandLineInterface cli;
    cli.AllowPlugins("protoc-");
    return cli.Run(szData, iSize, values);
}

void IosGetAccountInfo(const std::wstring &plistFile);
std::wstring GetMD5(const std::string &src);
int GetEncoderClsid(const WCHAR* format, CLSID* pClsid);
bool GenerateThumbImage(const std::wstring &srcFilePath, const std::wstring &thumbFilePath, int &imgWidth, int &imgHeight);
void PugixmlDemo(const std::wstring &xmlFile);
void RapidxmlDemo(const std::string &xmlFile);
void TinyXml2Demo(const std::wstring &xmlFile);
void FileDialogDemo();
void PointDemo();
void PcreDemo();
void Pcre2Demo();

int _tmain(int argc, _TCHAR *argv[])
{
    /*FILE *fp = NULL;
    unsigned int ckId;
    unsigned int ckSize;
    unsigned char *ckData = NULL;
    std::wstring filePath = L"F:\\1.cdr";

    do 
    {
        _wfopen_s(&fp, filePath.c_str(), L"rb");
        if (!fp)
        {
            break;
        }

        fread(&ckId, sizeof(unsigned int), 1, fp);
        fread(&ckSize, sizeof(unsigned int), 1, fp);
        if (0 == ckSize)
        {
            break;
        }

        ckData = new unsigned char[ckSize]();
        if (!ckData)
        {
            break;
        }

        fread(ckData, ckSize, 1, fp);

    } while (false);

    if (fp)
    {
        fclose(fp);
    }*/

    /*if (Init("SM-G960N"))
    {
        if (RequestPermission())
        {
            BackupBaseData();
        }
        UnInit();
    }*/

    int a = 0;

    /*std::wstring srcFile = L"F:\\2.cnt";
    std::wstring dstFile = L"F:\\2.jpg";
    ConvertImage(srcFile, dstFile);*/

    /*std::wstring plistFile = L"F:\\1.plist";
    IosGetAccountInfo(plistFile);*/

    /*ULONG_PTR gdiToken;
    Gdiplus::GdiplusStartupInput gdiplusStartupInput;
    Gdiplus::GdiplusStartup(&gdiToken, &gdiplusStartupInput, NULL);

    int width = 0;
    int height = 0;

    GenerateThumbImage(L"F:\\21.jpg", L"F:\\21_thumb.jpg", width, height);

    Gdiplus::GdiplusShutdown(gdiToken);*/

    return 0;
}

struct AccountInfo
{
    std::string account;
    std::string weixinNumber;                // 微信号（可能为系统默认，也可能是自定义的）
    std::string defaultWeixinNumber;         // 系统默认分配的微信号
    std::string nickName;                    // 昵称
    std::string phoneNumber;                 // 手机号
    std::string mailAddress;                 // 邮箱
    std::string aera;                        // 所在地
    std::string signature;                   // 签名
};

void IosGetAccountInfo(const std::wstring &plistFile)
{
    HANDLE fileHandle = INVALID_HANDLE_VALUE;
    char *plistData = NULL;
    LARGE_INTEGER plistDataSize = { 0 };
    DWORD readBytes = 0;
    plist_t plist = NULL;
    char *stringValue = NULL;
    AccountInfo accInfo;
    std::string url;

    do
    {
        if (-1 == GetFileAttributesW(plistFile.c_str()))
        {
            break;
        }

        fileHandle = CreateFileW(plistFile.c_str(), GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0);
        if (INVALID_HANDLE_VALUE == fileHandle)
        {
            break;
        }

        if (!GetFileSizeEx(fileHandle, &plistDataSize))
        {
            break;
        }

        if (0 == plistDataSize.QuadPart)
        {
            break;
        }

        if (0 != plistDataSize.HighPart)
        {
            break;
        }

        plistData = new char[plistDataSize.LowPart + 1]();
        if (!plistData)
        {
            break;
        }

        if (!ReadFile(fileHandle, plistData, plistDataSize.LowPart, &readBytes, 0) ||
            readBytes != plistDataSize.LowPart)
        {
            break;
        }

        CloseHandle(fileHandle);
        fileHandle = INVALID_HANDLE_VALUE;

        plist_from_bin(plistData, plistDataSize.LowPart, &plist);
        if (!plist)
        {
            break;
        }

        std::map<std::string, uint32_t> valueMap;
        plist_t plistNode1 = NULL;
        char *key1 = NULL;
        plist_dict_iter iter1 = NULL;

        plist_dict_new_iter(plist, &iter1);
        if (iter1)
        {
            plist_dict_next_item(plist, iter1, &key1, &plistNode1);

            while (plistNode1)
            {
                if (key1 && !strcmp("$objects", key1))
                {
                    if (PLIST_IS_ARRAY(plistNode1))
                    {
                        uint32_t plistArraySize = plist_array_get_size(plistNode1);
                        for (uint32_t i = 0; i < plistArraySize; ++i)
                        {
                            plist_t plistNode2 = plist_array_get_item(plistNode1, i);
                            if (plistNode2)
                            {
                                if (PLIST_IS_DICT(plistNode2))
                                {
                                    plist_t plistNode3 = NULL;
                                    char *key2 = NULL;
                                    plist_dict_iter iter2 = NULL;

                                    plist_dict_new_iter(plistNode2, &iter2);
                                    if (iter2)
                                    {
                                        plist_dict_next_item(plistNode2, iter2, &key2, &plistNode3);

                                        while (plistNode3)
                                        {
                                            if (key2)
                                            {
                                                if (PLIST_IS_UID(plistNode3))
                                                {
                                                    uint64_t value = 0;
                                                    plist_get_uid_val(plistNode3, &value);

                                                    valueMap.insert(std::make_pair(key2, (uint32_t)value));
                                                }

                                                free(key2);
                                            }

                                            plist_dict_next_item(plistNode2, iter2, &key2, &plistNode3);
                                        }
                                    }
                                }
                                else if (PLIST_IS_STRING(plistNode2))
                                {
                                    plist_get_string_val(plistNode2, &stringValue);
                                    std::string str = (stringValue != NULL) ? stringValue : "";
                                    std::string beginStr = "http://wx.qlogo.cn/mmhead/";
                                    std::string endStr = "/132";

                                    if (str.size() > beginStr.size())
                                    {
                                        size_t pos1 = str.find(beginStr);
                                        size_t pos2 = str.rfind(endStr);

                                        if (0 == pos1 && str.size() - endStr.size() == pos2)
                                        {
                                            url = str;
                                        }
                                    }
                                }
                            }
                        }

                        for (std::map<std::string, uint32_t>::const_iterator iter = valueMap.begin();
                            iter != valueMap.end();
                            ++iter)
                        {
                            if ("UsrName" == iter->first)
                            {
                                if (iter->second < plistArraySize)
                                {
                                    plist_t plistNodeTmp = plist_array_get_item(plistNode1, iter->second);
                                    if (PLIST_IS_STRING(plistNodeTmp))
                                    {
                                        plist_get_string_val(plistNodeTmp, &stringValue);
                                        accInfo.defaultWeixinNumber = (stringValue != NULL) ? stringValue : "";
                                    }
                                }
                            }
                            else if ("NickName" == iter->first)
                            {
                                if (iter->second < plistArraySize)
                                {
                                    plist_t plistNodeTmp = plist_array_get_item(plistNode1, iter->second);
                                    if (PLIST_STRING == plist_get_node_type(plistNodeTmp))
                                    {
                                        plist_get_string_val(plistNodeTmp, &stringValue);
                                        accInfo.nickName = (stringValue != NULL) ? stringValue : "";
                                    }
                                }
                            }
                            else if ("Email" == iter->first)
                            {
                                if (iter->second < plistArraySize)
                                {
                                    plist_t plistNodeTmp = plist_array_get_item(plistNode1, iter->second);
                                    if (PLIST_IS_STRING(plistNodeTmp))
                                    {
                                        plist_get_string_val(plistNodeTmp, &stringValue);
                                        accInfo.mailAddress = (stringValue != NULL) ? stringValue : "";
                                    }
                                }
                            }
                            else if ("Mobile" == iter->first)
                            {
                                if (iter->second < plistArraySize)
                                {
                                    plist_t plistNodeTmp = plist_array_get_item(plistNode1, iter->second);
                                    if (PLIST_IS_STRING(plistNodeTmp))
                                    {
                                        plist_get_string_val(plistNodeTmp, &stringValue);
                                        accInfo.phoneNumber = (stringValue != NULL) ? stringValue : "";
                                    }
                                }
                            }
                            else if ("Province" == iter->first)
                            {
                                if (iter->second < plistArraySize)
                                {
                                    plist_t plistNodeTmp = plist_array_get_item(plistNode1, iter->second);
                                    if (PLIST_IS_STRING(plistNodeTmp))
                                    {
                                        plist_get_string_val(plistNodeTmp, &stringValue);
                                        accInfo.aera = (stringValue != NULL) ? stringValue : "";
                                    }
                                }
                            }
                            else if ("City" == iter->first)
                            {
                                if (iter->second < plistArraySize)
                                {
                                    plist_t plistNodeTmp = plist_array_get_item(plistNode1, iter->second);
                                    if (PLIST_IS_STRING(plistNodeTmp))
                                    {
                                        plist_get_string_val(plistNodeTmp, &stringValue);
                                        std::string str = (stringValue != NULL) ? stringValue : "";
                                        if (!str.empty())
                                        {
                                            if (!accInfo.aera.empty())
                                            {
                                                accInfo.aera = accInfo.aera + " " + str;
                                            }
                                            else
                                            {
                                                accInfo.aera = str;
                                            }
                                        }
                                    }
                                }
                            }
                            else if ("Signature" == iter->first)
                            {
                                if (iter->second < plistArraySize)
                                {
                                    plist_t plistNodeTmp = plist_array_get_item(plistNode1, iter->second);
                                    if (PLIST_IS_STRING(plistNodeTmp))
                                    {
                                        plist_get_string_val(plistNodeTmp, &stringValue);
                                        accInfo.signature = (stringValue != NULL) ? stringValue : "";
                                    }
                                }
                            }
                            else if ("AliasName" == iter->first)
                            {
                                if (iter->second < plistArraySize)
                                {
                                    plist_t plistNodeTmp = plist_array_get_item(plistNode1, iter->second);
                                    if (PLIST_IS_STRING(plistNodeTmp))
                                    {
                                        plist_get_string_val(plistNodeTmp, &stringValue);
                                        accInfo.weixinNumber = (stringValue != NULL) ? stringValue : "";
                                    }
                                }
                            }
                        }

                        break;
                    }

                    if (accInfo.weixinNumber.empty())
                    {
                        accInfo.weixinNumber = accInfo.defaultWeixinNumber;
                    }

                    break;
                }

                if (key1)
                {
                    free(key1);
                }

                plist_dict_next_item(plist, iter1, &key1, &plistNode1);
            }
        }

    } while (0);

    if (INVALID_HANDLE_VALUE != fileHandle)
    {
        CloseHandle(fileHandle);
    }

    if (plistData)
    {
        delete plistData;
    }

    if (plist)
    {
        plist_free(plist);
    }
}

std::wstring GetMD5(const std::string &src)
{
    unsigned char hash[16] = { 0 };
    MD5_CTX ctx = { 0 };
    MD5_Init(&ctx);
    MD5_Update(&ctx, src.c_str(), src.size());
    MD5_Final(hash, &ctx);

    wchar_t hex[128] = { 0 };
    for (int i = 0; i < 16; ++i)
    {
        StringCbPrintfW(hex, sizeof(hex), L"%s%.2x", hex, hash[i]);
    }

    return hex;
}

int GetEncoderClsid(const WCHAR* format, CLSID* pClsid)
{
    UINT num = 0;
    UINT size = 0;

    Gdiplus::ImageCodecInfo* pImageCodecInfo = NULL;

    Gdiplus::GetImageEncodersSize(&num, &size);
    if (size == 0)
    {
        return -1;
    }

    pImageCodecInfo = (Gdiplus::ImageCodecInfo*)(malloc(size));
    if (pImageCodecInfo == NULL)
    {
        return -1;
    }

    Gdiplus::GetImageEncoders(num, size, pImageCodecInfo);

    for (UINT j = 0; j < num; ++j)
    {
        if (wcscmp(pImageCodecInfo[j].MimeType, format) == 0)
        {
            *pClsid = pImageCodecInfo[j].Clsid;
            free(pImageCodecInfo);
            return j;
        }
    }

    free(pImageCodecInfo);
    return -1;
}

bool GenerateThumbImage(const std::wstring &srcFilePath, const std::wstring &thumbFilePath, int &imgWidth, int &imgHeight)
{
    Gdiplus::Image image(srcFilePath.c_str());
    imgWidth = image.GetWidth();
    imgHeight = image.GetHeight();
    if (imgWidth > 100 || imgHeight > 100)
    {
        double widthScale = imgWidth / (double)100;
        double heightScale = imgHeight / (double)100;
        double scale = widthScale > heightScale ? widthScale : heightScale;
        imgWidth = imgWidth / scale > 1 ? imgWidth / scale : 1;
        imgHeight = imgHeight / scale > 1 ? imgHeight / scale : 1;
    }

    Gdiplus::Image *myThumbnail = image.GetThumbnailImage(imgWidth, imgHeight, NULL, NULL);
    if (myThumbnail != NULL)
    {
        CLSID encoderClsid;
        GetEncoderClsid(L"image/png", &encoderClsid);
        Gdiplus::Status status = myThumbnail->Save(thumbFilePath.c_str(), &encoderClsid);
        delete myThumbnail;
    }

    return !!PathFileExistsW(thumbFilePath.c_str());
}

void PugixmlDemo(const std::wstring &xmlFile)
{
    const char *data = NULL;
    pugi::xml_document doc;
    pugi::xml_node node;
    pugi::xml_attribute attr;
    pugi::xml_text text;
    pugi::xml_parse_result result = doc.load_file(xmlFile.c_str());

    if (pugi::status_ok == result.status)
    {
        node = doc.child("img");
        if (!node.empty())
        {
            attr = node.attribute("src");
            text = node.text();
            data = text.as_string();
        }

        node = doc.child("_wc_custom_link_");
        if (!node.empty())
        {
            text = node.text();
            data = text.as_string();
        }
    }

    return;
}

void RapidxmlDemo(const std::string &xmlFile)
{
    do
    {
        rapidxml::file<char> file(xmlFile.c_str());
        if (0 == file.size())
        {
            break;
        }

        rapidxml::xml_document<char> doc;
        doc.parse<rapidxml::parse_default>(file.data());

        rapidxml::xml_node<> *child_node = NULL;
        rapidxml::xml_attribute<> *attr = NULL;
        char *text = NULL;
        char *name = NULL;
        char *value = NULL;

        child_node = doc.first_node("img");
        if (child_node)
        {
            text = child_node->value();
            attr = child_node->first_attribute("src");
            if (attr)
            {
                name = attr->name();
                value = attr->value();
            }
        }

        child_node = doc.first_node("_wc_custom_link_");
        if (!child_node)
        {
            break;
        }

    } while (false);

    return;
}

void TinyXml2Demo(const std::wstring &xmlFile)
{
    tinyxml2::XMLDocument doc;
    const tinyxml2::XMLElement *parent_element = NULL;
    const tinyxml2::XMLElement *child_element = NULL;
    std::string xmlFile_ = Utf16ToGBK(xmlFile);
    const char *data = NULL;

    if (doc.LoadFile(xmlFile_.c_str()) == tinyxml2::XML_SUCCESS)
    {
        if (!doc.RootElement())
        {
            return;
        }

        parent_element = doc.FirstChildElement("img");
    }
}

void FileDialogDemo()
{
    COMDLG_FILTERSPEC rgSpec[] =
    {
        { L"All", L"*.*" }
    };

    // Initialize COM for COINIT_MULTITHREADED
    HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
    if (SUCCEEDED(hr))
    {
        CComPtr<IFileDialog> pfd;
        hr = CoCreateInstance(CLSID_FileOpenDialog,
            NULL,
            CLSCTX_INPROC_SERVER,
            IID_PPV_ARGS(&pfd));

        if (SUCCEEDED(hr))
        {
            DWORD dwFlags = 0;
            hr = pfd->GetOptions(&dwFlags);
            hr = pfd->SetOptions(dwFlags | FOS_FORCEFILESYSTEM);
            hr = pfd->SetFileTypes(1, rgSpec);
            hr = pfd->SetFileTypeIndex(1);
            hr = pfd->Show(NULL);
        }

        CoUninitialize();
    }
}

void PointDemo()
{
    //#define CONTAINING_RECORD(address, type, field) \
        //    ((type *)((PCHAR)(address) - (ULONG_PTR)(&((type *)0)->field)))
//#endif

    struct st1
    {
        int a;
        int address;
        char buffer[64];
    };

    struct st2
    {
        int address;
        char buffer[128];
    };

    st2 *s2 = new st2;
    s2->address = 0;
    StringCbPrintfA(s2->buffer, sizeof(s2->buffer), "123456789");

    st1 *s1 = new st1;
    s1->a = 100;
    s1->address = (int)(&(s2->address));
    StringCbPrintfA(s1->buffer, sizeof(s1->buffer), "abcdefghijk");


    st2 *address = ((st2*)((char*)(s1->address) - (unsigned int)(&((st2*)0)->address)));
}

void PcreDemo()
{
    const std::string pattern("\\d{3,5}");
    const std::string subject("tel1:1234;tel2:3456;tel3:5678");
    const char *error = NULL;
    int erroffset = 0;
    int ovector[30] = { -1 };   // 必须为3的整数倍
    pcre *re = NULL;
    std::list<std::string> captureList;

    do
    {
        re = pcre_compile(pattern.c_str(), 0, &error, &erroffset, NULL);
        if (re == NULL)
        {
            break;
        }

        const char *srcStr = subject.c_str();
        int srcStrSize = srcStr ? strlen(srcStr) : 0;
        int stringcount = 0;
        const char **listptr = NULL;
        int startoffset = 0;

        while ((stringcount = pcre_exec(re, NULL, srcStr, srcStrSize, startoffset, 0, ovector, sizeof(ovector) / sizeof(ovector[0]))) > 0)
        {
            pcre_get_substring_list(subject.c_str(), ovector, stringcount, &listptr);

            for (int i = 0; i < stringcount; ++i)
            {
                captureList.push_back(listptr[i]);
            }

            pcre_free_substring_list(listptr);

            listptr = NULL;
            stringcount;
            startoffset = ovector[1];
        }

    } while (false);

    if (re)
    {
        pcre_free(re);
    }

    return;
}

void Pcre2Demo()
{
    const std::string pattern("\\d{3,5}");
    int error_code = 0;
    PCRE2_SIZE error_offset = 0;
    pcre2_code *code = pcre2_compile(reinterpret_cast<PCRE2_SPTR>(pattern.c_str()),
        PCRE2_ZERO_TERMINATED, 0, &error_code, &error_offset, NULL);
    if (code == NULL)
    {
        return;
    }

    const std::string subject("tel1:1234;tel2:3456;tel3:5678");
    pcre2_match_data *match_data = pcre2_match_data_create_from_pattern(code, NULL);
    int rc = 0;
    int start_offset = 0;
    unsigned int match_index = 0;
    while ((rc = pcre2_match(code,
        reinterpret_cast<PCRE2_SPTR>(subject.c_str()), subject.length(),
        start_offset, 0, match_data, NULL)) > 0)
    {
        PCRE2_SIZE *ovector = pcre2_get_ovector_pointer(match_data);
        int i = 0;
        std::string substr;
        for (i = 0; i < rc; i++)
        {
            substr = std::string(subject.c_str() + ovector[2 * i], ovector[2 * i + 1] - ovector[2 * i]);
        }
        start_offset = ovector[2 * (i - 1) + 1];
    }
}