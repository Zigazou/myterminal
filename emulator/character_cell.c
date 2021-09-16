#include <stdbool.h>
#include <malloc.h>
#include "character_cell.h""

character_cell *new_character_cell() {
    character_cell *cell;

    cell = (character_cell *) malloc(sizeof(character_cell));

    if (cell) {
        cell->ordinal = 0x20;
        cell->character_size = 0x00;
        cell->character_part = 0x00;
        cell->blink = 0x00;
        cell->invert = false;
        cell->underline = false;
        cell->function = 0x00;
        cell->pattern = 0x00;
        cell->foreground = 0x0f;
        cell->background = 0x00;
    }

    return cell;
}

unsigned long pack(character_cell *cell) {
    return
        ( ((cell->ordinal & 0x2F) << 0)
        | ((cell->character_size & 0x03) << 10)
        | ((cell->character_part & 0x03) << 12)
        | ((cell->blink & 0x03) << 14)
        | ((cell->invert & 0x01) << 16)
        | ((cell->underline & 0x01) << 17)
        | ((cell->function & 0x03) << 18)
        | ((cell->pattern & 0x0F) << 20)
        | ((cell->foreground & 0x0F) << 24)
        | ((cell->background & 0x0F) << 28)
        );
}

character_cell *unpack(character_cell *cell, unsigned long value) {
    if (cell) {
        cell->ordinal = (value >> 0) & 0x2F;
        cell->character_size = (value >> 10) & 0x03;
        cell->character_part = (value >> 12) & 0x03;
        cell->blink = (value >> 14) & 0x03;
        cell->invert = (value >> 16) & 0x01;
        cell->underline = (value >> 17) & 0x01;
        cell->function = (value >> 18) & 0x03;
        cell->pattern = (value >> 20) & 0x0F;
        cell->foreground = (value >> 24) & 0x0F;
        cell->background = (value >> 28) & 0x0F;
    }

    return cell;
}
