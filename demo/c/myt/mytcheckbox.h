#ifndef _MYTCHECKBOX_H
#define _MYTCHECKBOX_H

#include "mytwidget.h"

#define CHECKBOX_UNCHECKED (0xbe)
#define CHECKBOX_PLUS (0xbb)
#define CHECKBOX_MINUS (0xbc)
#define CHECKBOX_CHECKED (0xbd)
#define CHECKBOX_CROSS (0xbf)

#define RADIO_UNCHECKED (0xa2)
#define RADIO_PLUS (0xa1)
#define RADIO_CHECKED (0xa3)

typedef struct {
  MytWidget common;
  char *label;
  unsigned char state;
} MytCheckbox;

MytCheckbox *new_checkbox(MytWidget *parent, char *label, unsigned char x,
                      unsigned char y);
void draw_checkbox(int fd, MytCheckbox *checkbox);
void update_checkbox(int fd, MytCheckbox *checkbox);

#endif