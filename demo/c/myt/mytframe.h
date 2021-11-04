#ifndef _MYTFRAME_H
#define _MYTFRAME_H

#include "mytwidget.h"

typedef struct {
  MytWidget common;
  char *label;
  unsigned char label_width;
  unsigned char label_foreground;
  unsigned char label_background;
} MytFrame;

MytFrame *new_frame(MytWidget *parent, char *label, unsigned char x,
                    unsigned char y, unsigned char width, unsigned char height);
void draw_frame(int fd, MytFrame *frame);

#endif