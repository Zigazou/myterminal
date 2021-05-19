#include <stdlib.h>
#include <stdio.h>
#include "myterminal.h"
#include "video_memory.h"
#include "bitmap.h"

unsigned char palette[16][3] = {
    { 0, 0, 0 },
    { 128, 0, 0 },
    { 0, 128, 0 },
    { 128, 128, 0 },
    { 0, 0, 128 },
    { 128, 0, 128 },
    { 0, 128, 128 },
    { 192, 192, 192 },
    { 128, 128, 128 },
    { 255, 0, 0 },
    { 0, 255, 0 },
    { 255, 255, 0 },
    { 0, 0, 255 },
    { 255, 0, 255 },
    { 0, 255, 255 },
    { 255, 255, 255 }
};

void write_ppm(FILE *ppm, bitmap *image) {
    int x, y;
    static unsigned char color[3];

    if (ppm && image) {
        fprintf(ppm, "P6\n%d %d\n255\n", MYT_TOTAL_WIDTH, MYT_TOTAL_HEIGHT);

        for (y = 0; y < MYT_TOTAL_HEIGHT; y++) {
            for (x = 0; x < MYT_TOTAL_WIDTH; x++) {
                fwrite(palette[(*image)[y][x]], 1, 3, ppm);
            }
        }
    }
}

int main(int argc, char *argv[]) {
    video_memory *vram;
    bitmap *image;
    FILE *ppm;

    vram = new_video_memory();
    image = new_bitmap();

    ppm = freopen(NULL, "wb", stdout);
    write_ppm(ppm, image);
    fclose(ppm);

    return EXIT_SUCCESS;
}