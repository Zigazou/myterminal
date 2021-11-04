#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "mytcodes.h"
#include "mytprogress.h"

MytProgress *new_progress(MytWidget *parent, unsigned char x, unsigned char y,
                          unsigned char width) {
  MytProgress *progress = (MytProgress *)malloc(sizeof(MytProgress));

  init_widget((MytWidget *)progress);
  add_child(parent, (MytWidget *)progress);
  progress->common.parent = parent;
  progress->common.draw = (DrawCallback)&draw_progress;

  progress->common.x = x;
  progress->common.y = y;

  if (parent != NULL) {
    progress->common.x += parent->x;
    progress->common.y += parent->y;
    progress->common.foreground = parent->foreground;
    progress->common.background = parent->background;
  }

  progress->common.width = width;
  progress->common.height = 1;

  progress->value = 0;

  return progress;
}

void draw_progress(int fd, MytProgress *progress) {
  unsigned char buf;
  unsigned int steps = progress->value;
  unsigned int start_steps = steps < PROGRESS_START ? steps : 6;

  dprintf(fd, LOCATE_BASE "%c%c" COLOR_BASE "%c" COLOR_BASE "%c" CP4 "%c",
          LOCATE_OFFSET + progress->common.y,
          LOCATE_OFFSET + progress->common.x,
          F_OFFSET + progress->common.foreground,
          B_OFFSET + progress->common.background, 0x40 + start_steps);

  unsigned int remaining_steps = steps - start_steps;

  for (int i = 0; i < progress->common.width - 2; i++) {
    if (remaining_steps >= PROGRESS_MIDDLE) {
      buf = 0x4f;
    } else {
      buf = 0x47 + remaining_steps;
    }

    write(fd, &buf, 1);

    remaining_steps = remaining_steps < PROGRESS_MIDDLE
                          ? 0
                          : remaining_steps - PROGRESS_MIDDLE;
  }

  dprintf(fd, "%c" CP0, 0x50 + remaining_steps);
}
