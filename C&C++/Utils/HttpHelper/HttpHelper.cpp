// HttpHelper.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "HttpHelper.h"

size_t ProcessDataToString(void *buffer, size_t size, size_t nmemb, void *user_p);

size_t ProcessDataToFile(void *buffer, size_t size, size_t nmemb, void *user_p);

bool HttpGetHelp(const std::string &strUrl, const std::string &strHeader, const std::wstring &wstrSaveFile,
	std::string &strSaveData, const std::string &strCookie = "");

bool HttpPostHelp(const std::string &strUrl, const std::string &strHeader, const std::string &strPostData,
	const std::wstring &wstrSaveFile, std::string &strSaveData, const std::string &strCookie="");

void SplitLines(const std::string &str, const std::string &split, std::list<std::string> &lines);

std::string HttpGet(const std::string &strUrl, const std::string &strHeader, const std::string &strCookie)
{
    std::string strSaveData;

    HttpGetHelp(strUrl, strHeader, L"", strSaveData, strCookie);

    return strSaveData;
}

bool HttpGetToFile(const std::string &strUrl, const std::string &strHeader, const std::wstring &wstrSaveFile, const std::string &strCookie)
{
    std::string strSaveData;

    return HttpGetHelp(strUrl, strHeader, wstrSaveFile, strSaveData, strCookie);
}

std::string HttpPost(const std::string &strUrl, const std::string &strHeader, const std::string &strPostData, const std::string &strCookie)
{
    std::string strSaveData;

    HttpPostHelp(strUrl, strHeader, strPostData, L"", strSaveData, strCookie);

    return strSaveData;
}

bool HttpPostToFile(const std::string &strUrl, const std::string &strHeader, const std::string &strPostData, const std::wstring &wstrSaveFile, const std::string &strCookie)
{
    std::string strSaveData;

    return HttpPostHelp(strUrl, strHeader, strPostData, wstrSaveFile, strSaveData, strCookie);
}

// 检测internet 连接
bool CheckNetFree()
{
	static std::atomic<bool> bFree;
	bFree.store(false);

	auto fn = [](std::atomic<bool> *pParam)->void {
		pParam->store(false);
		WSADATA wd = { 0 };

		if (0 != WSAStartup(MAKEWORD(2, 2), &wd))
		{
			return;
		}
		if (LOBYTE(wd.wHighVersion) != 2 || HIBYTE(wd.wHighVersion) != 2)
		{
			WSACleanup();
			return;
		}

		const char *hostUrl = "www.baidu.com";
		hostent *ht = gethostbyname(hostUrl);
		if (ht)
		{
			pParam->store(true);
		}
		WSACleanup();
		return;
	};
	std::thread netCheckThread(fn,&bFree);

	::WaitForSingleObject((HANDLE)netCheckThread.native_handle(), 2000);

	return bFree.load();
}

size_t ProcessDataToString(void *buffer, size_t size, size_t nmemb, void *user_p)
{
    std::string *lpStr = (std::string *)user_p;
    if (NULL != lpStr && NULL != buffer)
    {
        std::string str((char*)buffer, size * nmemb);
        lpStr->append(str);
    }

    return size * nmemb;
}

size_t ProcessDataToFile(void *buffer, size_t size, size_t nmemb, void *user_p)
{
    size_t return_size = size * nmemb;
    FILE *fp = (FILE *)user_p;
    if (NULL != fp && NULL != buffer)
    {
        return_size = fwrite(buffer, size, nmemb, fp);
    }

    return return_size;
}

bool HttpGetHelp(const std::string &strUrl, const std::string &strHeader, const std::wstring &wstrSaveFile, std::string &strSaveData, const std::string &strCookie)
{
    CURL *easy_handle = NULL;
    CURLcode return_code;
    FILE *fp = NULL;
    bool bRet = false;
	std::string caFile;
	char szExeDir[MAX_PATH] = { 0 };
	GetModuleFileNameA(NULL, szExeDir, sizeof(szExeDir) / sizeof(szExeDir[0]));
	char *p = strrchr(szExeDir, '\\');
	if (NULL != p)
	{
		*p = 0;
	}

	caFile = std::string(szExeDir) + "\\ssl\\cacert.pem";
    do
    {
        // 获取easy handle
        easy_handle = curl_easy_init();
        if (NULL == easy_handle)
        {
            break;
        }

        if (!wstrSaveFile.empty())
        {
            _wfopen_s(&fp, wstrSaveFile.c_str(), L"wb");
            if (NULL == fp)
            {
                break;
            }

            curl_easy_setopt(easy_handle, CURLOPT_WRITEFUNCTION, &ProcessDataToFile);
            curl_easy_setopt(easy_handle, CURLOPT_WRITEDATA, fp);
        }
        else
        {
            curl_easy_setopt(easy_handle, CURLOPT_WRITEFUNCTION, &ProcessDataToString);
            curl_easy_setopt(easy_handle, CURLOPT_WRITEDATA, &strSaveData);
        }

		// 设置easy handle属性
		curl_slist *http_headers = NULL;
        std::list<std::string> heads;
        SplitLines(strHeader, "\r\n", heads);

        for (const auto &head : heads)
        {
            http_headers = curl_slist_append(http_headers, head.c_str());
        }

		if (NULL == http_headers)
		{
			break;
		}

		curl_easy_setopt(easy_handle, CURLOPT_HTTPHEADER, http_headers);

		curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYPEER, 1L);
		curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYHOST, 1L);
		curl_easy_setopt(easy_handle, CURLOPT_CAINFO, caFile.c_str()); 
		if (!strCookie.empty())
		{
			curl_easy_setopt(easy_handle, CURLOPT_COOKIE, strCookie.c_str());
		}

		// add Dengxg 递归重定向 -- 暂时不用
		//curl_easy_setopt(easy_handle, CURLOPT_FOLLOWLOCATION, 1);
			
        curl_easy_setopt(easy_handle, CURLOPT_URL, strUrl.c_str());

        // 执行数据请求
        return_code = curl_easy_perform(easy_handle);

        curl_slist_free_all(http_headers);

        bRet = CURLE_OK == return_code;

    } while (false);

    // 释放资源
    if (NULL != fp)
    {
        int iFileID = _fileno(fp);
        _commit(iFileID);
        fclose(fp);
    }

    if (NULL != easy_handle)
    {
        curl_easy_cleanup(easy_handle);
    }

    return bRet;
}

bool HttpPostHelp(const std::string &strUrl, const std::string &strHeader, const std::string &strPostData, const std::wstring &wstrSaveFile, std::string &strSaveData, const std::string &strCookie)
{
    CURL *easy_handle = NULL;
    CURLcode return_code;
    FILE *fp = NULL;
    bool bRet = false;

	std::string caFile;
	char szExeDir[MAX_PATH] = { 0 };
	GetModuleFileNameA(NULL, szExeDir, sizeof(szExeDir) / sizeof(szExeDir[0]));
	char *p = strrchr(szExeDir, '\\');
	if (NULL != p)
	{
		*p = 0;
	}

	caFile = std::string(szExeDir) + "\\ssl\\cacert.pem";

    do
    {
        // 获取easy handle
        easy_handle = curl_easy_init();
        if (NULL == easy_handle)
        {
            break;
        }

        if (!wstrSaveFile.empty())
        {
            _wfopen_s(&fp, wstrSaveFile.c_str(), L"wb");
            if (NULL == fp)
            {
                break;
            }

            curl_easy_setopt(easy_handle, CURLOPT_WRITEFUNCTION, &ProcessDataToFile);
            curl_easy_setopt(easy_handle, CURLOPT_WRITEDATA, fp);
        }
        else
        {
            curl_easy_setopt(easy_handle, CURLOPT_WRITEFUNCTION, &ProcessDataToString);
            curl_easy_setopt(easy_handle, CURLOPT_WRITEDATA, &strSaveData);
        }

        // 设置easy handle属性
        curl_slist *http_headers = NULL;
        std::list<std::string> heads;
        SplitLines(strHeader, "\r\n", heads);

        for (const auto &head : heads)
        {
            http_headers = curl_slist_append(http_headers, head.c_str());
        }

        if (NULL == http_headers)
        {
            break;
        }

        curl_easy_setopt(easy_handle, CURLOPT_HTTPHEADER, http_headers);

		curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYPEER, 1L);
		curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYHOST, 1L);
		curl_easy_setopt(easy_handle, CURLOPT_CAINFO, caFile.c_str());
		if (!strCookie.empty())
		{
			curl_easy_setopt(easy_handle, CURLOPT_COOKIE, strCookie.c_str());
		}

        curl_easy_setopt(easy_handle, CURLOPT_URL, strUrl.c_str());
        curl_easy_setopt(easy_handle, CURLOPT_POSTFIELDS, strPostData.c_str());

        // 执行数据请求
        return_code = curl_easy_perform(easy_handle);

        curl_slist_free_all(http_headers);

        bRet = CURLE_OK == return_code;

    } while (false);

    // 释放资源
    if (NULL != fp)
    {
        int iFileID = _fileno(fp);
        _commit(iFileID);
        fclose(fp);
    }

    if (NULL != easy_handle)
    {
        curl_easy_cleanup(easy_handle);
    }

    return bRet;
}

void SplitLines(const std::string &str, const std::string &split, std::list<std::string> &lines)
{
    std::string line;

    lines.clear();

    size_t splitSize = split.size();
    size_t beginPos = 0;
    size_t endPos = str.find(split);
	if (std::string::npos == endPos)
	{
		lines.push_back(str);
		return;
	}

    while (std::string::npos != endPos)
    {
        line = str.substr(beginPos, endPos - beginPos);
        if (!line.empty())
        {
            lines.push_back(line);
        }

        beginPos = endPos + splitSize;
        endPos = str.find(split, beginPos);
    }

    return;
}

