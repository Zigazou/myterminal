#include "mytwidget.h"
#include "mytcodes.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

MytWidget *which_widget(MytWidget *widget, unsigned char x, unsigned char y) {
  MytWidget *child;

  if (widget == NULL) {
    return NULL;
  }

  if (x < widget->x || x >= (widget->x + widget->width) || y < widget->y ||
      y >= (widget->y + widget->height)) {
    return NULL;
  }

  for (int i = 0; i < widget->children_count; i++) {
    child = which_widget(widget->children[i], x, y);
    if (child != NULL) {
      return child;
    }
  }

  return widget;
}

void fill_widget(int myt, MytWidget *widget) {
  int y;
  int i;

  if (widget == NULL) {
    return;
  }

  dprintf(myt, COLOR_BASE "%c" COLOR_BASE "%c", F_OFFSET + widget->foreground,
          B_OFFSET + widget->background);
  for (y = widget->y; y < widget->y + widget->height; y++) {
    dprintf(myt, LOCATE(widget->x, y));
    for (i = 0; i < widget->width; i++) {
      write(myt, " ", 1);
    }
  }
}

void locate_widget(int myt, MytWidget *widget, unsigned char x,
                   unsigned char y) {
  dprintf(myt, LOCATE_BASE "%c%c", LOCATE_OFFSET + widget->y + y,
          LOCATE_OFFSET + widget->x + x);
}

int mytstrlen(const unsigned char *string, unsigned char char_width) {
  int count = 0;
  int offset = 0;

  if (string == NULL) {
    return 0;
  }

  while (string[offset] != '\0') {
    if (string[offset] >= ' ') {
      count += char_width;
      offset++;
    } else {
      switch (string[offset]) {
      case 0x01:
      case 0x02:
      case 0x03:
      case 0x06:
      case 0x19:
        if (string[offset + 1] == 0x00) {
          return count;
        }
        offset += 2;
        break;

      case 0x04:
        if (string[offset + 1] == 0x00 || string[offset + 2] == 0x00) {
          return count;
        }
        offset += 3;
        break;

      case 0x05:
        switch (string[offset + 1]) {
        case 0x00:
          return count;
        case 0x30:
        case 0x32:
          char_width = 1;
          break;
        case 0x31:
        case 0x33:
          char_width = 2;
          break;
        }
        offset += 2;
        break;

      default:
        offset++;
      }
    }
  }

  return count;
}

void init_widget(MytWidget *widget) {
  if (widget == NULL) {
    return;
  }

  widget->parent = NULL;
  widget->children = NULL;
  widget->children_count = 0;
  widget->x = 0;
  widget->y = 0;
  widget->width = 80;
  widget->height = 51;
  widget->foreground = LIGHT_WHITE;
  widget->background = BLACK;
}

void add_child(MytWidget *parent, MytWidget *child) {
  if (parent == NULL || child == NULL) {
    return;
  }

  if (parent->children == NULL) {
    parent->children = malloc(sizeof(MytWidget *));
  } else {
    parent->children = realloc(parent->children, (parent->children_count + 1) *
                                                     sizeof(MytWidget *));
  }

  parent->children[parent->children_count] = child;
  parent->children_count++;
}

void free_widget(MytWidget *widget) {
  if (widget == NULL) {
    return;
  }

  for (int i = 0; i < widget->children_count; i++) {
    free_widget(widget->children[i]);
  }

  free(widget);
}

void draw_widget(int myt, MytWidget *widget) {
  if (widget == NULL) {
    return;
  }

  (*(widget->draw))(myt, widget);
  for (int i = 0; i < widget->children_count; i++) {
    draw_widget(myt, widget->children[i]);
  }
}