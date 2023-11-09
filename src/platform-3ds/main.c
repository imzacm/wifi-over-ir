#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>

#include <3ds.h>

#include "../log.h"

typedef uint8_t AppMode;

#define APP_MODE_RECV 0
#define APP_MODE_SEND 1

typedef uint8_t PulseRate;

// These are the 3DS values.
#define IR_PULSE_115200 3
#define IR_PULSE_96000 4
#define IR_PULSE_72000 5
#define IR_PULSE_48000 6
#define IR_PULSE_36000 7
#define IR_PULSE_24000 8
#define IR_PULSE_18000 9
#define IR_PULSE_12000 10
#define IR_PULSE_9600 11
#define IR_PULSE_6000 12
#define IR_PULSE_3000 13
#define IR_PULSE_57600 14
#define IR_PULSE_38400 15
#define IR_PULSE_19200 16
#define IR_PULSE_7200 17
#define IR_PULSE_4800 18
//
#define IR_PULSE_MIN 3
#define IR_PULSE_MAX 18

#define IR_MEM_SIZE 0x1000
#define IR_MEM_ALIGN 0x1000

u32 *ir_mem_ptr;

static inline Result init_3ds(void) {
    Result srv_result = srvInit();
    Result apt_result = aptInit();
    Result hid_result = hidInit();

    gfxInitDefault();
    consoleInit(GFX_BOTTOM, NULL);
    consoleDebugInit(debugDevice_CONSOLE);

    if (srv_result) {
        log_error("[init] srv: %d\n", srv_result);
        return srv_result;
    }
    if (apt_result) {
        log_error("[init] apt: %d\n", apt_result);
        return apt_result;
    }
    if (hid_result) {
        log_error("[init] hid: %d\n", hid_result);
        return hid_result;
    }

    ir_mem_ptr = (u32 *) memalign(IR_MEM_ALIGN, IR_MEM_SIZE);
    if (ir_mem_ptr == NULL) {
        log_error("[init] ir_mem - out of memory?\n");
        // return result;
    }
    Result ir_result = iruInit(ir_mem_ptr, IR_MEM_SIZE);
    if (ir_result) {
        log_error("[init] iru: %d\n", ir_result);
        return ir_result;
    }

    return 0;
}

static inline void deinit_3ds(void) {
    iruExit();
    ir_mem_ptr = NULL;
    gfxExit();
    hidExit();
    aptExit();
    srvExit();
}

PulseRate cycle_pulse_rate(PulseRate old_pulse, bool next) {
    PulseRate new_pulse;
    if (next) {
        new_pulse = old_pulse + 1;
        if (new_pulse > IR_PULSE_MAX) {
            new_pulse = IR_PULSE_MIN;
        }
    } else {
        new_pulse = old_pulse - 1;
        if (new_pulse < IR_PULSE_MIN) {
            new_pulse = IR_PULSE_MAX;
        }
    }
    return new_pulse;
}

const char *app_mode_str(AppMode mode) {
    switch (mode) {
        case APP_MODE_RECV:
            return "RECV";
        case APP_MODE_SEND:
            return "SEND";
        default:
            return "";
    }
}

const char *enabled_str(bool enabled) {
    return enabled ? "ON" : "OFF";
}

const char *pulse_rate_str(PulseRate pulse_rate) {
    switch (pulse_rate) {
        case IR_PULSE_115200:
            return "115200";
        case IR_PULSE_96000:
            return "96000";
        case IR_PULSE_72000:
            return "72000";
        case IR_PULSE_48000:
            return "48000";
        case IR_PULSE_36000:
            return "36000";
        case IR_PULSE_24000:
            return "24000";
        case IR_PULSE_18000:
            return "18000";
        case IR_PULSE_12000:
            return "12000";
        case IR_PULSE_9600:
            return "9600";
        case IR_PULSE_6000:
            return "6000";
        case IR_PULSE_3000:
            return "3000";
        case IR_PULSE_57600:
            return "57600";
        case IR_PULSE_38400:
            return "38400";
        case IR_PULSE_19200:
            return "19200";
        case IR_PULSE_7200:
            return "7200";
        case IR_PULSE_4800:
            return "4800";
        default:
            return "";
    }
}

int main(int argc, char *argv[]) {
    Result result;
    AppMode app_mode = APP_MODE_RECV;
    PulseRate pulse_rate = IR_PULSE_115200;
    bool enabled = false;
    bool state_changed = true;


    result = init_3ds();
    if (result) {
        while (aptMainLoop()) {
            gspWaitForVBlank();
        }
        deinit_3ds();
        return 1;
    }

    while (aptMainLoop()) {
        hidScanInput();

        u32 keys = hidKeysDown();
        if ((keys & KEY_UP) && app_mode != APP_MODE_RECV) {
            app_mode = APP_MODE_RECV;
            state_changed = true;
        } else if ((keys & KEY_DDOWN) && app_mode != APP_MODE_SEND) {
            app_mode = APP_MODE_SEND;
            state_changed = true;
        }
        if (keys & KEY_START) {
            enabled = !enabled;
            state_changed = true;
        }

        bool pulse_changed = false;
        if (keys & KEY_LEFT) {
            pulse_rate = cycle_pulse_rate(pulse_rate, true);
            state_changed = true;
            pulse_changed = true;
        } else if (keys & KEY_RIGHT) {
            pulse_rate = cycle_pulse_rate(pulse_rate, false);
            state_changed = true;
            pulse_changed = true;
        }

        if (pulse_changed) {
            result = IRU_SetBitRate(pulse_rate);
            if (result) {
                log_error("[set bit rate] %d\n", result);
            }
        }
        if (state_changed) {
            consoleClear();

            printf("Buttons:\nUP - RECV\nDOWN - SEND\nLEFT - Cycle previous pulse rate\nRIGHT - Cycle next pulse rate\nSTART=START/STOP\n");
            printf("MODE=%s(%s) PULSE=%s\n", app_mode_str(app_mode), enabled_str(enabled), pulse_rate_str(pulse_rate));
            state_changed = false;
        }

        if (enabled && app_mode == APP_MODE_RECV) {
            uint8_t buffer[4] = {0};
            uint32_t count;
            result = iruRecvData(&buffer[0], 4, 0, &count, true);
            if (result) {
                log_error("[recv data] %d\n", result);
            } else if (count != 0) {
                printf("Received (%d): %s\n", count, &buffer);
            }
        } else if (enabled && app_mode == APP_MODE_SEND) {
            uint8_t buffer[4] = {0};
            size_t len = 0;

            if (keys & KEY_A) {
                buffer[len] = 'A';
                len += 1;
            }
            if (keys & KEY_B) {
                buffer[len] = 'B';
                len += 1;
            }
            if (keys & KEY_X) {
                buffer[len] = 'X';
                len += 1;
            }
            if (keys & KEY_Y) {
                buffer[len] = 'Y';
                len += 1;
            }

            if (len != 0) {
                result = IRU_StartSendTransfer(&buffer[0], len);
                if (result) {
                    log_error("[start send transfer] %d\n", result);
                }
                result = IRU_WaitSendTransfer();
                if (result) {
                    log_error("[wait send transfer] %d\n", result);
                }
            }
        }

        gspWaitForVBlank();
    }

    deinit_3ds();
    return 0;
}
