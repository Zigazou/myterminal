#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "mytcheckbox.h"
#include "mytcodes.h"

MytCheckbox *new_checkbox(MytWidget *parent, char *label, unsigned char x,
                          unsigned char y) {
  MytCheckbox *checkbox = (MytCheckbox *)malloc(sizeof(MytCheckbox));

  init_widget((MytWidget *)checkbox);
  add_child(parent, (MytWidget *)checkbox);
  checkbox->common.parent = parent;
  checkbox->common.draw = (DrawCallback)&draw_checkbox;

  checkbox->common.x = x;
  checkbox->common.y = y;

  if (parent != NULL) {
    checkbox->common.x += parent->x;
    checkbox->common.y += parent->y;
    checkbox->common.foreground = parent->foreground;
    checkbox->common.background = parent->background;
  }

  checkbox->common.width = mytstrlen((unsigned char *)label, 1) + 2;
  checkbox->common.height = 1;

  checkbox->label = label;
  checkbox->state = CHECKBOX_UNCHECKED;

  return checkbox;
}

void draw_checkbox(int fd, MytCheckbox *checkbox) {
  dprintf(
      fd,
      LOCATE_BASE "%c%c" COLOR_BASE "%c" COLOR_BASE "%c" CP1 "%c" CP0 " %s",
      LOCATE_OFFSET + checkbox->common.y, LOCATE_OFFSET + checkbox->common.x,
      F_OFFSET + checkbox->common.foreground,
      B_OFFSET + checkbox->common.background, 
      checkbox->state, checkbox->label);
}

void update_checkbox(int fd, MytCheckbox *checkbox) {
  dprintf(
      fd,
      LOCATE_BASE "%c%c" COLOR_BASE "%c" COLOR_BASE "%c" CP1 "%c" CP0,
      LOCATE_OFFSET + checkbox->common.y, LOCATE_OFFSET + checkbox->common.x,
      F_OFFSET + checkbox->common.foreground,
      B_OFFSET + checkbox->common.background, 
      checkbox->state);
}