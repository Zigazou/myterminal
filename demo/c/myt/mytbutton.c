#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "mytbutton.h"
#include "mytcodes.h"

MytButton *new_button(MytWidget *parent, char *label, unsigned char x,
                      unsigned char y, unsigned char width) {
  MytButton *button = (MytButton *)malloc(sizeof(MytButton));

  init_widget((MytWidget *)button);
  add_child(parent, (MytWidget *)button);
  button->common.parent = parent;
  button->common.draw = (DrawCallback)&draw_button;

  button->common.x = x;
  button->common.y = y;

  if (parent != NULL) {
    button->common.x += parent->x;
    button->common.y += parent->y;
    button->common.foreground = parent->foreground;
    button->common.background = parent->background;
  }

  button->common.width = width;
  button->common.height = 2;

  button->label = label;
  button->length = mytstrlen((unsigned char *)label, 1);
  button->state = BUTTON_IDLE;

  return button;
}

void draw_button(int fd, MytButton *button) {
  int left = (button->common.width - 3 - button->length) / 2;
  int right = button->common.width - 3 - left - button->length;

  dprintf(fd,
          LOCATE_BASE "%c%c" CP0 COLOR_BASE "%c" COLOR_BASE "%c" REVERSE_ON
                      CP4 "\x3a" CP0 "%*s%s%*s" CP4 "\x35" CP0 REVERSE_OFF,
          LOCATE_OFFSET + button->common.y, LOCATE_OFFSET + button->common.x,
          F_OFFSET + button->common.foreground,
          B_OFFSET + button->common.background, left, "", button->label, right,
          "");

}
