#ifndef VIDEO_MEMORY_H
#define VIDEO_MEMORY_H

#include <stdbool.h>
#include "myterminal.h"

typedef struct {
    int top_row;
    bool cursor_visible;
    unsigned long cells[MYT_ROWS][MYT_COLUMNS];
} video_memory;

video_memory *new_video_memory();

#endif