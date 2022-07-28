# LearningRecord

## ! Important !
**Before proceeding with the following steps, you must have installed Visual Studio 2019 in your computer!**

## Clone codes
git clone https://github.com/songwenhao/LearningRecord

tools\python38\python.exe init-submodules.py

## Open Visual Studio 2019 Command Prompt
### see. https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=msvc-160
* x86 Native Tools Command Prompt - Sets the environment to use 32-bit, x86-native tools to build 32-bit, x86-native code.
* x64 Native Tools Command Prompt - Sets the environment to use 64-bit, x64-native tools to build 64-bit, x64-native code.
* x86_x64 Cross Tools Command Prompt - Sets the environment to use 32-bit, x86-native tools to build 64-bit, x64-native code.
* x64_x86 Cross Tools Command Prompt - Sets the environment to use 64-bit, x64-native tools to build 32-bit, x86-native code.

### Below is my machine
#### x86
![image](https://user-images.githubusercontent.com/11570113/181400614-734160bb-1b91-4de6-b0cc-6ccaf81640bc.png)

#### x64
![image](https://user-images.githubusercontent.com/11570113/181400726-c88043e3-1845-4b46-95c5-2dec4bba7993.png)

**And change path to current path.**

## Prepare for build
First run **prepare-build.cmd** to get build tools, then run **build-x86.cmd** or **build-x64.cmd**.

## Open vs solution file and build projects
Open **C-C++/LearningRecord_C-C++.sln**.
