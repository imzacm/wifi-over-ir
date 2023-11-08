#include <stdio.h>

#include <woi/result.h>

const char *WOI_Result_message(WOI_Result result) {
    switch (result) {
        case WOI_OK:
            return "Ok";
        case WOI_ERR_NULL_PTR_ARG:
            return "Error - unexpected null pointer argument";
        case WOI_ERR_ALLOC:
            return "Error - allocation failed, probably out of memory";
        case WOI_ERR_FILE_NOT_FOUND:
            return "Error - file not found";
        default:
            printf("Unhandled result: %d\n", result);
            return "Error - unknown/invalid result";
    }
}
