QuotedPrintableUtils
===========

Use POCO C++ Libraries(https://pocoproject.org/) Quoted-Printable functions.

Simple examples
---------------

```c++
std::string str = u8"中文";
std::string strEncode = QuotedPrintableUtils::QuotedPrintableEncode(str);
std::string strDecode = QuotedPrintableUtils::QuotedPrintableDecode(strEncode);
```