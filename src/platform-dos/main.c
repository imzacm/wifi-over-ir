#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#include <conio.h>
#include <i86.h>

#include "../log.h"

int main(int argc, char *argv[]) {
    uint32_t counter = 0;
    while (true) {
        if (kbhit()) {
            int c = getch();
            if ((c & 0xFF) == 27) {
                // ESC?
                break;
            }
        }

        log_info("Main loop: %d\n", counter);
        counter += 1;

        // delay suspends execution for n milliseconds.
        delay(1);
    }
    return 0;
}
