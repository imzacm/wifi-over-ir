#include <3ds.h>

#include "../init.h"

WOI_Result Platform_init(void) {
    srvInit();       // services
    aptInit();       // applets
    hidInit();       // input
    gfxInitDefault();// graphics

    consoleInit(GFX_BOTTOM, NULL);

    return WOI_OK;
}

WOI_Result Platform_exit(void) {
    gfxExit();
    hidExit();
    aptExit();
    srvExit();

    return WOI_OK;
}

bool Platform_should_exit(void) {
    return !aptMainLoop();
}

void Platform_yield(void) {
    gspWaitForVBlank();
}

// hidScanInput();

//         u32 kDown = hidKeysDown();
//         if (kDown & KEY_START)
//             break;// break in order to return to hbmenu
