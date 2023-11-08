#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#include <conio.h>
#include <dos.h>

#define HORNET_INDEX_REG 0x0022
#define HORNET_DATA_REG 0x0023
#define IRFMAT_INDEX -0x10
#define IRCNT_INDEX -0x11

static inline uint8_t Hornet_read_reg(uint8_t index) {
    outp(HORNET_INDEX_REG, index);
    return inp(HORNET_DATA_REG);
}

static inline uint8_t Hornet_write_reg(uint8_t index, uint8_t value) {
    outp(HORNET_INDEX_REG, index);
    return outp(HORNET_DATA_REG, value);
}

typedef struct {
    bool RED : 1;
    bool MDLTE : 1;
    bool IRURT : 1;
    bool MDSEL : 1;
    bool PMOD : 1;
    bool LBF : 1;
    bool ELBE : 1;
    bool invert : 1;
} IRFMAT;

static inline IRFMAT IRFMAT_read(void) {
    union {
        uint8_t raw;
        IRFMAT reg;
    } value;
    value.raw = Hornet_read_reg(IRFMAT_INDEX);
    return value.reg;
}

static inline void IRFMAT_write(IRFMAT value) {
    union {
        uint8_t raw;
        IRFMAT reg;
    } val;
    val.reg = value;
    Hornet_write_reg(IRFMAT_INDEX, val.raw);
}

// int main() {
//     printf("Hello DOS\n");

//     IRFMAT irfmat = IRFMAT_read();
//     printf("IRFMAT:\n");
//     printf("  RED=%d\n", irfmat.RED);
//     printf("  MDLTE=%d\n", irfmat.MDLTE);
//     printf("  IRURT=%d\n", irfmat.IRURT);
//     printf("  MDSEL=%d\n", irfmat.MDSEL);
//     printf("  PMOD=%d\n", irfmat.PMOD);
//     printf("  LBF=%d\n", irfmat.LBF);
//     printf("  ELBE=%d\n", irfmat.ELBE);
//     printf("  invert=%d\n", irfmat.invert);
//     printf("\n");

//     return 0;
// }
