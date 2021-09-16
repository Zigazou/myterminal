#include <stdio.h>
#include <stdlib.h>

const char f[] =
    "1111"
    "1000"
    "1110"
    "1000"
    "1000"
;

const char half1[] =
    "1010"
    "0101"
    "1010"
    "0101"
    "1010"
;

const char half2[] =
    "0101"
    "1010"
    "0101"
    "1010"
    "0101"
;

char gfxchar(int pos, const char bitmap[]) {
    if (pos == 0) {
        return 128
            + (bitmap[0] == '1' ? 64 : 0)
            + (bitmap[1] == '1' ? 32 : 0)
            + (bitmap[2] == '1' ? 16 : 0)
            + (bitmap[3] == '1' ? 8 : 0)
            + (bitmap[4] == '1' ? 4 : 0)
            + (bitmap[5] == '1' ? 2 : 0)
            + (bitmap[6] == '1' ? 1 : 0)
            ;
    } else if (pos == 1) {
        return 128
            + (bitmap[7] == '1' ? 64 : 0)
            + (bitmap[8] == '1' ? 32 : 0)
            + (bitmap[9] == '1' ? 16 : 0)
            + (bitmap[10] == '1' ? 8 : 0)
            + (bitmap[11] == '1' ? 4 : 0)
            + (bitmap[12] == '1' ? 2 : 0)
            + (bitmap[13] == '1' ? 1 : 0)
            ;
    } else {
        return 128
            + (bitmap[14] == '1' ? 32 : 0)
            + (bitmap[15] == '1' ? 16 : 0)
            + (bitmap[16] == '1' ? 8 : 0)
            + (bitmap[17] == '1' ? 4 : 0)
            + (bitmap[18] == '1' ? 2 : 0)
            + (bitmap[19] == '1' ? 1 : 0)
            ;
    }
}

void main() {
    int i, j;

    printf("\001!\030");

    for (j = 0; j < 51; j++) {
        for (i = 0; i < (j == 50 ? 79 : 80); i++) {
            if ((j & 1) == 0) {
                printf(
                    "%c%c%c",
                    gfxchar(0, half1),
                    gfxchar(1, half1),
                    gfxchar(2, half1)
                );
            } else {
                printf(
                    "%c%c%c",
                    gfxchar(0, half2),
                    gfxchar(1, half2),
                    gfxchar(2, half2)
                );
            }
        }
    }
}