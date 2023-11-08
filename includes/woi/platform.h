#ifndef WOI_PLATFORM_H
#define WOI_PLATFORM_H

#include <stdbool.h>

#include "result.h"

WOI_Result Platform_init(void);
WOI_Result Platform_exit(void);
bool Platform_should_exit(void);
void Platform_yield(void);

#endif
