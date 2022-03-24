#pragma once

#ifdef QUOTEDPRINTABLEUTILS_EXPORTS
    #define QUOTEDPRINTABLEUTILS_API __declspec(dllexport)
#else
    #define QUOTEDPRINTABLEUTILS_API __declspec(dllimport)
#endif

#include <string>

namespace QuotedPrintableUtils {

    QUOTEDPRINTABLEUTILS_API std::string QuotedPrintableEncode(
        const std::string &strSrc
    );

    QUOTEDPRINTABLEUTILS_API std::string QuotedPrintableDecode(
        const std::string &strSrc
    );
   
};