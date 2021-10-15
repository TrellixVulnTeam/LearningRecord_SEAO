#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include <gmime/config.h>

#include <glib.h>
#include <gmime/gmime.h>
#include <gmessages.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#ifdef __cplusplus
}
#endif

typedef struct EmlInfoEx {
    char *subject;
    char *from;
    char *to;
    char *body;
    char *richbody;
    long long date;
    char *msgId;
} EmlInfoEx;

EmlInfoEx ParseEmlFileEx(
    const wchar_t *decodeFilePath
);

void FreeGPointer(
    EmlInfoEx emlInfo
);