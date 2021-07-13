#include "EmlUtilsInternal.h"

char *FindCharset(
    const char *buffer
);

char *ConvertToUtf8(
    const char *srcBuf,
    const char *charset
);

int IsStandardEmlHeader(
    const char *headerValue
);

EmlInfoEx ParseEmlFileEx(
    const wchar_t *emlFilePath
) {
    FILE *fp = NULL;
    GMimeMessage *message = NULL;
    GMimeParser *parser = NULL;
    GMimeStream *stream = NULL;
    EmlInfoEx emlInfoEx;
    char *fileContent = NULL;
    char charset[16];

    /* init the gmime library */
    g_mime_init();

    do {
        memset(charset, 0, sizeof(charset));
        memset(&emlInfoEx, 0, sizeof(EmlInfoEx));

        _wfopen_s(&fp, emlFilePath, L"rb");
        if (!fp) {
            break;
        }

        size_t fileSize = 0;
        if (fseek(fp, 0, SEEK_END) != 0) {
            break;
        }

        fileSize = ftell(fp);
        if (fseek(fp, 0, SEEK_SET) != 0) {
            break;
        }

        if (fileSize <= 0) {
            break;
        }

        fileContent = (char*)malloc(fileSize);
        if (!fileContent) {
            break;
        }

        fileContent[fileSize - 1] = 0;
        size_t readSize = fread(fileContent, 1, fileSize, fp);
        if (readSize != fileSize) {
            break;
        }

        /* find mail begin */
        const char *begin = fileContent;
        while (*begin) {
            if (*begin != 0x20 && *begin != 0x0D && *begin != 0x0A) {
                break;
            }
            begin++;
        }

        if (fseek(fp, begin - fileContent, SEEK_SET) != 0) {
            break;
        }

        char *p = FindCharset(fileContent);
        if (p) {
            strcpy_s(charset, _countof(charset), p);
            free(p);
        }

        free(fileContent);
        fileContent = NULL;

        /* create a stream to read from the file descriptor */
        stream = g_mime_stream_file_new(fp);

        /* create a new parser object to parse the stream */
        parser = g_mime_parser_new_with_stream(stream);

        /* unref the stream (parser owns a ref, so this object does not actually get free'd until we destroy the parser) */
        g_object_unref(stream);

        /* parse the message from the stream */
        message = g_mime_parser_construct_message(parser, NULL);

        /* free the parser (and the stream) */
        g_object_unref(parser);

        if (message) {
            GMimeObject *object = (GMimeObject *)message;
            int count = g_mime_header_list_get_count(object->headers);
            int index = 0;
            const char *header_content = NULL;
            char *convert_header_content = NULL;

            while (index < count) {
                GMimeHeader *header = g_mime_header_list_get_header_at(object->headers, index);
                if (!header || !header->name || !header->raw_value) {
                    continue;
                }

                if (!g_mime_format_options_is_hidden_header(NULL, header->name)) {
                    if (_stricmp(header->name, "From") == 0
                        || _stricmp(header->name, "Subject") == 0
                        || _stricmp(header->name, "To") == 0) {
                        if (IsStandardEmlHeader(header->raw_value)) {
                            header_content = g_mime_header_get_value(header);
                        } else {
                            convert_header_content = ConvertToUtf8(header->raw_value, charset);
                            header_content = convert_header_content;
                        }

                        if (header_content) {
                            if (_stricmp(header->name, "From") == 0) {
                                emlInfoEx.from = _strdup(header_content);
                            } else if (_stricmp(header->name, "Subject") == 0) {
                                emlInfoEx.subject = _strdup(header_content);
                            } else if (_stricmp(header->name, "To") == 0) {
                                emlInfoEx.to = _strdup(header_content);
                            }

                            header_content = NULL;
                        }

                        if (convert_header_content) {
                            free(convert_header_content);
                            convert_header_content = NULL;
                        }
                    }
                }

                index++;
            }

            if (!emlInfoEx.subject) {
                const char *subject = g_mime_message_get_subject(message);
                if (subject) {
                    emlInfoEx.subject = _strdup(subject);
                }
            }

            char *body = g_mime_object_to_string((GMimeObject *)message, NULL);
            if (body) {
                emlInfoEx.body = _strdup(body);
                g_free(body);
                body = NULL;
            }

            GDateTime *date = g_mime_message_get_date(message);
            if (date) {
                emlInfoEx.date = g_date_time_to_unix(date);
            }

            /* free the mesage */
            g_object_unref(message);
        }

    } while (0);

    g_mime_shutdown();

    if (fileContent) {
        free(fileContent);
    }

    if (fp) {
        fclose(fp);
    }

    return emlInfoEx;
}

void FreeGPointer(
    EmlInfoEx emlInfo
) {
    if (emlInfo.subject) {
        free(emlInfo.subject);
    }

    if (emlInfo.from) {
        free(emlInfo.from);
    }

    if (emlInfo.to) {
        free(emlInfo.to);
    }

    if (emlInfo.body) {
        free(emlInfo.body);
    }
}

static char * FindCharset(
    const char *buffer
) {
    /*find charset */
    char *begin, *end;
    char charset[16];
    memset(charset, 0, sizeof(charset));

    begin = strstr(buffer, "charset=");
    if (begin) {
        begin += strlen("charset=");
        if (*begin == '\"') {
            begin++;
        }

        end = strstr(begin, "\"");
        if (end && (end - begin < 16)) {
            for (int index = 0; begin < end; begin++) {
                if (*begin != '\"') {
                    charset[index++] = *begin;
                }
            }
        } else {
            end = strstr(begin, ";");
            if (end && (end - begin < 16)) {
                for (int index = 0; begin < end; begin++) {
                    if (*begin != '\"') {
                        charset[index++] = *begin;
                    }
                }
            } else {
                end = strstr(begin, "\r\n");
                if (end && (end - begin < 16)) {
                    for (int index = 0; begin < end; begin++) {
                        if (*begin != '\"') {
                            charset[index++] = *begin;
                        }
                    }
                } else {
                    end = strstr(begin, "\n");
                    if (end && (end - begin < 16)) {
                        for (int index = 0; begin < end; begin++) {
                            if (*begin != '\"') {
                                charset[index++] = *begin;
                            }
                        }
                    }
                }
            }
        }
    }

    if (charset[0]) {
        return _strdup(charset);
    }

    return NULL;
}

static char * ConvertToUtf8(
    const char *srcBuf,
    const char *charset
) {
    char *dstBuf = NULL;
    const char *locale, *utf8;
    iconv_t cd;

    do {
        if (!srcBuf || !charset || !charset[0]) {
            break;
        }

        locale = g_mime_charset_iconv_name(charset);
        if (!locale || _stricmp(locale, "UTF-8") == 0) {
            break;
        }

        utf8 = g_mime_charset_iconv_name("UTF-8");

        cd = iconv_open(utf8, locale);
        if (cd != (iconv_t)-1) {
            dstBuf = g_mime_iconv_strdup(cd, srcBuf);
            iconv_close(cd);
        }

    } while (0);
    
    if (dstBuf) {
        char *p = dstBuf;
        dstBuf = _strdup(dstBuf);
        g_free(p);
    } else {
        dstBuf = _strdup(srcBuf);
    }

    return dstBuf;
}

static int IsStandardEmlHeader(
    const char *headerValue
) {
    if (headerValue && strstr(headerValue, "=?") && strstr(headerValue, "?=")) {
        return 1;
    }

    return 0;
}