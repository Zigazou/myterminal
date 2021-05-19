#include <stdbool.h>
#include "myterminal.h"
#include "character_cell.h"
#include "video_memory.h"

typedef struct {
    int top_row;
    bool cursor_visible;
    unsigned long cells[MYT_ROWS][MYT_COLUMNS];
} video_memory;

video_memory *new_video_memory() {
    video_memory *vram;
    int row;
    int column;

    vram = (video_memory *) malloc(sizeof(video_memory));

    if (vram) {
        vram->top_row = 0;
        vram->cursor_visible = true;

        for (row = 0; row < MYT_ROWS; row++) {
            for (column = 0; column < MYT_COLUMNS; column++) {
                vram->cells[row][column] = new_character_cell();
            }
        }
    }

    return vram;
}
