#ifndef HTTP_HELPER_H
#define HTTP_HELPER_H

#include <string>

std::string HttpGet(const std::string &strUrl, const std::string &strHeader, const std::string &strCookie = "");

bool HttpGetToFile(const std::string &strUrl, const std::string &strHeader, const std::wstring &wstrSaveFile, const std::string &strCookie = "");

std::string HttpPost(const std::string &strUrl, const std::string &strHeader, const std::string &strPostData, const std::string &strCookie = "");

bool HttpPostToFile(const std::string &strUrl, const std::string &strHeader, const std::string &strPostData, const std::wstring &wstrSaveFile, const std::string &strCookie = "");

bool CheckNetFree();

#endif // HTTP_HELPER_H
