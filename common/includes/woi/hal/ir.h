#ifndef WOI_COMMON_HAL_IR_H
#define WOI_COMMON_HAL_IR_H

#include <stdint.h>

typedef void (*IR_callback_fn)(void);

void IR_set_receive_callback(IR_callback_fn callback);

#endif
