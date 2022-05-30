# -*- coding: UTF-8 -*-

import os
import sys

if __name__ == '__main__':
    if len(sys.argv) < 2:
        exit

    submodule = sys.argv[1]
    os.system("git submodule deinit -f " + submodule)
    os.system("git rm --cached " + submodule)

    convertedSubmodule = submodule.replace('/', '\\')
    os.system("rmdir /s /q " + convertedSubmodule)
    os.system("rmdir /s /q .git\\modules\\" + convertedSubmodule)