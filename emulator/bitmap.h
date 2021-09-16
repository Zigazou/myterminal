#ifndef BITMAP_H
#define BITMAP_H

#include "myterminal.h"

typedef unsigned char bitmap[MYT_TOTAL_HEIGHT][MYT_TOTAL_WIDTH];

bitmap *new_bitmap();
#endif