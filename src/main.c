#include <stdio.h>
#include <stdlib.h>

#include <woi/result.h>
#include <woi/platform.h>

static inline void exit_if_error(WOI_Result result) {
    if (result == WOI_OK) {
        return;
    }
    const char *message = WOI_Result_message(result);
    printf("%s\n", message);
    exit(result);
}

int main(int argc, char *argv[]) {
    WOI_Result result;
    result = Platform_init();
    exit_if_error(result);

    while (!Platform_should_exit()) {
        Platform_yield();
        // TODO
        printf("Main loop...\n");
    }

    result = Platform_exit();
    exit_if_error(result);
    return 0;
}
