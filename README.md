# LearningRecord

## ! Important !
**Before proceeding with the following steps, you must have installed Visual Studio 2019 in your computer!**

## Clone codes
git clone https://github.com/songwenhao/LearningRecord

double click cmd file: **init-submodules.cmd**

## Open Visual Studio 2019 Command Prompt
### see. https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=msvc-160
* x86 Native Tools Command Prompt - Sets the environment to use 32-bit, x86-native tools to build 32-bit, x86-native code.
* x64 Native Tools Command Prompt - Sets the environment to use 64-bit, x64-native tools to build 64-bit, x64-native code.
* x86_x64 Cross Tools Command Prompt - Sets the environment to use 32-bit, x86-native tools to build 64-bit, x64-native code.
* x64_x86 Cross Tools Command Prompt - Sets the environment to use 64-bit, x64-native tools to build 32-bit, x86-native code.

### Below is my machine
#### x86
![image](https://user-images.githubusercontent.com/11570113/181400969-92f338d6-d964-4765-b18a-063a140cb105.png)

#### x64
![image](https://user-images.githubusercontent.com/11570113/181400895-a615032f-ffcb-415a-96f2-a8c311e86856.png)

**And change path to current path.**

## Prepare for build
First run **prepare-build.cmd** to get build tools, then run **build-x86.cmd** or **build-x64.cmd**.

## Open vs solution file and build projects
Open **C-C++/LearningRecord_C-C++.sln**.
