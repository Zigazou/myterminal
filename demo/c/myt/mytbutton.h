#ifndef _MYTBUTTON_H
#define _MYTBUTTON_H

#define BUTTON_IDLE 0
#define BUTTON_SELECTED 1

#include "mytwidget.h"

typedef struct {
  MytWidget common;
  char *label;
  unsigned char length;
  unsigned char state;
} MytButton;

MytButton *new_button(MytWidget *parent, char *label, unsigned char x,
                      unsigned char y, unsigned char width);
void draw_button(int fd, MytButton *button);

#endif