#ifndef WOI_RESULT_H
#define WOI_RESULT_H

typedef enum {
    WOI_OK = 0,
    WOI_ERR_NULL_PTR_ARG,
    WOI_ERR_ALLOC,
    WOI_ERR_FILE_NOT_FOUND,
} WOI_Result;

const char *WOI_Result_message(WOI_Result result);

#endif
