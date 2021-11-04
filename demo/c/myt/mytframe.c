#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "mytcodes.h"
#include "mytframe.h"

MytFrame *new_frame(MytWidget *parent, char *label, unsigned char x,
                    unsigned char y, unsigned char width,
                    unsigned char height) {
  MytFrame *frame = (MytFrame *)malloc(sizeof(MytFrame));

  init_widget((MytWidget *)frame);
  add_child(parent, (MytWidget *)frame);
  frame->common.parent = parent;
  frame->common.draw = (DrawCallback)&draw_frame;

  frame->common.x = x;
  frame->common.y = y;

  if (parent != NULL) {
    frame->common.x += parent->x;
    frame->common.y += parent->y;
    frame->common.foreground = parent->foreground;
    frame->common.background = parent->background;
  } else {
    frame->common.foreground = LIGHT_WHITE;
    frame->common.background = LIGHT_BLUE;
  }

  frame->common.width = width;
  frame->common.height = height;

  frame->label = label;
  frame->label_width = mytstrlen((unsigned char *)label, 1);
  frame->label_foreground = BLACK;
  frame->label_background = LIGHT_YELLOW;

  return frame;
}

void draw_frame(int fd, MytFrame *frame) {
  fill_widget(fd, (MytWidget *)frame);

  dprintf(fd,
          LOCATE_BASE "%c%c" COLOR_BASE "%c" COLOR_BASE "%c" CP4 "\x34" CP0
                      "%s%*s" CP4 "\x31" CP0,
          LOCATE_OFFSET + frame->common.y - 1, LOCATE_OFFSET + frame->common.x,
          F_OFFSET + frame->label_foreground,
          B_OFFSET + frame->label_background, frame->label,
          frame->common.width - frame->label_width - 2, " ");
}
