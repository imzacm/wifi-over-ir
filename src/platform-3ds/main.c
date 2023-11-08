#include <stdlib.h>

#include <3ds.h>

#include "../log.h"

static inline void init_3ds(void) {
    srvInit();
    aptInit();
    hidInit();
    gfxInitDefault();
    consoleInit(GFX_BOTTOM, NULL);
}

static inline void deinit_3ds(void) {
    gfxExit();
    hidExit();
    aptExit();
    srvExit();
}

int main(int argc, char *argv[]) {
    init_3ds();

    uint32_t counter = 0;
    while (aptMainLoop()) {
        gspWaitForVBlank();

        log_info("Main loop: %d\n", counter);
        counter += 1;
    }

    deinit_3ds();
    return 0;
}
