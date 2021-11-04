#ifndef _MYTPROGRESS_H
#define _MYTPROGRESS_H

#include "mytwidget.h"

#define PROGRESS_START (7)
#define PROGRESS_MIDDLE (9)
#define PROGRESS_END (6)

typedef struct {
  MytWidget common;
  unsigned int value;
} MytProgress;

MytProgress *new_progress(MytWidget *parent, unsigned char x, unsigned char y,
                          unsigned char width);
void draw_progress(int fd, MytProgress *progress);

#endif