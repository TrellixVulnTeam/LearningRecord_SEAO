ProcessUtils
===========

Windows process functions C++ wrapper.

Functions
---------------

#### GetProcessPid
```c++
Get process ID by process name and process cmdline.
```

#### KillProcess
```c++
Kill process by process name and process cmdline.
```

#### GetProcessCmdLine
```c++
Use ZwQueryInformationProcess API to get process cmdline.
```

#### GetProcessCmdLineByCmd
```c++
Use wmic to get process cmdline.
```

#### CheckProcessModuleExist
```c++
Check process module is exist.
```