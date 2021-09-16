#ifndef CHARACTER_CELL_H
#define CHARACTER_CELL_H

#include <stdbool.h>

typedef struct {
    unsigned short ordinal;
    unsigned int character_size;
    unsigned int character_part;
    unsigned int blink;
    bool invert;
    bool underline;
    unsigned char function;
    unsigned char pattern;
    unsigned char foreground;
    unsigned char background;
} character_cell;

character_cell *new_character_cell();
unsigned long pack(character_cell cell);
character_cell *unpack(character_cell *cell, unsigned long value);

#endif