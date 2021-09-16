#include "image_generator.h"
#include "video_memory.h"
#include "bitmap.h"
#include "character_cell.h"
#include "myterminal_font.h"

void generate_image(video_memory *vram, bitmap *image) {
    video_memory *vram;
    character_cell *cell;
    int row, real_row;
    int column;
    int char_row;
    int char_col;
    int x;
    int y;
    bool pixel_mask;
    unsigned short char_bitmap;

    if (!(vram && image)) return;

    for (row = 0; row < MYT_ROWS; row++) {
        real_row = (vram->top_row + row) % MYT_ROWS;

        for (column = 0; column < MYT_COLUMNS; column++) {
            cell = vram->cells[real_row][column];

            for (char_row = 0; char_row < MYT_CHARACTER_HEIGHT; char_row++) {
                char_bitmap = myterminal_font[cell->ordinal][char_row];
                for (char_col = 0; char_col < MYT_CHARACTER_WIDTH; char_col++) {
                    x = column * MYT_CHARACTER_WIDTH + char_col;
                    y = row * MYT_CHARACTER_HEIGHT + char_row;
                    pixel_mask = 1 << (MYT_CHARACTER_WIDTH - 1 - char_col);
                    (*image)[y][x] = (char_bitmap & pixel_mask)
                        ? cell->foreground
                        : cell->background;
                }
            }
        }
    }
}
