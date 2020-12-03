#include <google/protobuf/compiler/cpp/cpp_generator.h>
#include <google/protobuf/compiler/java/java_generator.h>
#include <google/protobuf/compiler/js/js_generator.h>
#include <google/protobuf/compiler/command_line_interface.h>
#include <google/protobuf/compiler/python/python_generator.h>
#include <google/protobuf/compiler/csharp/csharp_generator.h>
#include <google/protobuf/compiler/objectivec/objectivec_generator.h>
#include <google/protobuf/compiler/php/php_generator.h>
#include <google/protobuf/compiler/ruby/ruby_generator.h>

#include <windows.h>
int main(int argc, char* argv[])
{
	google::protobuf::compiler::CommandLineInterface cli;
	cli.AllowPlugins("protoc-");

    return cli.Run(argc, argv);

    int nArgs = 0;
    wchar_t **lpArglist = CommandLineToArgvW(GetCommandLineW(), &nArgs);

    std::wstring wstrFile;
    if (nArgs >= 2) {
        wstrFile = lpArglist[1];
    }

	std::map<std::string, std::string> values;
	int iRes = cli.Run(wstrFile, values);

	//Ô´ÎÄ¼þ
	HANDLE hFile = INVALID_HANDLE_VALUE;
	char* szContent = nullptr;
	hFile = CreateFileW(
		wstrFile.c_str(),
		GENERIC_READ,
		FILE_SHARE_READ | FILE_SHARE_WRITE,
		NULL,
		OPEN_EXISTING,
		0,
		NULL);
    if (hFile != INVALID_HANDLE_VALUE) {
        DWORD dwSize = GetFileSize(hFile, nullptr);
        szContent = new char[dwSize];
        DWORD dwRead = 0;
        ReadFile(hFile, szContent, dwSize, &dwRead, nullptr);
        CloseHandle(hFile);

        std::map<std::string, std::string> values2;
        iRes = cli.Run(szContent, dwSize, values2);
        delete[] szContent;
    }
		
	return iRes;
}