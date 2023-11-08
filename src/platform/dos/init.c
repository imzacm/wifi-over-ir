#include <i86.h>

#include "../init.h"

WOI_Result Platform_init(void) {
    return WOI_OK;
}

WOI_Result Platform_exit(void) {
    return WOI_OK;
}

// TODO
bool Platform_should_exit(void) {
    return false;
}

void Platform_yield(void) {
    // delay suspends execution for n milliseconds.
    delay(10);
}
