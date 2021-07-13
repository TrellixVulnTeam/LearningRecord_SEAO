Base64Utils
===========

Openssl base64 functions C++ wrapper.

Simple examples
---------------

#### Encode
```c++
std::string str = "hello world";

std::string strEncodeStr = Base64Utils::Base64EncodeString(str);

int outSize = 0;
unsigned char *data = Base64Utils::Base64EncodeData((const unsigned char*)str.c_str(), str.size(), outSize);
if (data) {
    Base64Utils::FreeData(data);
}
```

#### Decode
```c++
std::string strEncodeStr = "aGVsbG8gd29ybGQ=";

std::string strDecodeStr = Base64Utils::Base64DecodeString(strEncodeStr);

int outSize = 0;
unsigned char *data = Base64Utils::Base64DecodeData((const unsigned char*)strEncodeStr.c_str(), strEncodeStr.size(), outSize);
if (data) {
    Base64Utils::FreeData(data);
}
```