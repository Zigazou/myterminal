#ifndef _MYTWIDGET_H
#define _MYTWIDGET_H

typedef struct MytWidget MytWidget;
typedef void (*DrawCallback)(int, MytWidget *);

struct MytWidget {
  void *parent;
  void **children;
  DrawCallback draw;
  unsigned char children_count;
  unsigned char x;
  unsigned char y;
  unsigned char width;
  unsigned char height;
  unsigned char foreground;
  unsigned char background;
};

MytWidget *which_widget(MytWidget *widget, unsigned char x, unsigned char y);
void fill_widget(int myt, MytWidget *widget);
void locate_widget(int myt, MytWidget *widget, unsigned char x,
                   unsigned char y);
int mytstrlen(const unsigned char *string, unsigned char char_width);
void init_widget(MytWidget *widget);
void add_child(MytWidget *parent, MytWidget *child);
void free_widget(MytWidget *widget);
void draw_widget(int myt, MytWidget *widget);

#endif