#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "error_message.h"
#include "serial.h"

#include "myt/mytwidget.h"
#include "myt/mytbutton.h"
#include "myt/mytcheckbox.h"
#include "myt/mytcodes.h"
#include "myt/mytframe.h"
#include "myt/mytprogress.h"

#define EVENT_NULL (0)
#define EVENT_CHARACTER (1)
#define EVENT_EXTENDED_KEY (2)
#define EVENT_MOUSE (3)

struct {
  unsigned char event_type;

  struct {
    unsigned meta : 1;
    unsigned alt : 1;
    unsigned altgr : 1;
    unsigned ctrl : 1;
    unsigned shift : 1;
    unsigned middle : 1;
    unsigned right : 1;
    unsigned left : 1;
  } modifier;

  union {
    unsigned char key;
    struct {
      unsigned char x;
      unsigned char y;
    } mouse;
  } data;
} myt_event;

#define STATE_INIT (0)
#define STATE_EXTENDED_KEY_1 (1)
#define STATE_EXTENDED_KEY_2 (2)
#define STATE_MOUSE_X (3)
#define STATE_MOUSE_Y (4)
#define STATE_MOUSE_MODIFIERS (5)
#define START_EXTENDED_KEY (0x1f)
#define START_MOUSE (0x1e)
void get_sequence(int myt) {
  unsigned char bytes_read;
  unsigned char byte;
  unsigned char state = STATE_INIT;

  myt_event.event_type = EVENT_NULL;

  while (1) {
    if ((bytes_read = read(myt, &byte, 1)) != 1) {
      continue;
    }

    switch (state) {
    case STATE_INIT:
      if (byte == START_MOUSE) {
        state = STATE_MOUSE_X;
        myt_event.event_type = EVENT_MOUSE;
      } else if (byte == START_EXTENDED_KEY) {
        state = STATE_EXTENDED_KEY_1;
        myt_event.event_type = EVENT_EXTENDED_KEY;
      } else {
        myt_event.data.key = byte;
        myt_event.event_type = EVENT_CHARACTER;
        return;
      }
      break;

    case STATE_EXTENDED_KEY_1:
      myt_event.modifier.meta = byte & 0b00010000;
      myt_event.modifier.alt = byte & 0b00001000;
      myt_event.modifier.altgr = byte & 0b00000100;
      myt_event.modifier.ctrl = byte & 0b00000010;
      myt_event.modifier.shift = byte & 0b00000001;
      myt_event.modifier.middle = 0;
      myt_event.modifier.right = 0;
      myt_event.modifier.left = 0;
      state = STATE_EXTENDED_KEY_2;
      break;

    case STATE_EXTENDED_KEY_2:
      myt_event.data.key = byte;
      state = STATE_INIT;
      return;

    case STATE_MOUSE_X:
      myt_event.data.mouse.x = byte & 0x7f;
      state = STATE_MOUSE_Y;
      break;

    case STATE_MOUSE_Y:
      myt_event.data.mouse.y = byte & 0x7f;
      state = STATE_MOUSE_MODIFIERS;
      break;

    case STATE_MOUSE_MODIFIERS:
      myt_event.modifier.meta = byte & 0b01000000;
      myt_event.modifier.alt = byte & 0b00100000;
      myt_event.modifier.altgr = 0;
      myt_event.modifier.ctrl = byte & 0b00010000;
      myt_event.modifier.shift = byte & 0b00001000;
      myt_event.modifier.middle = byte & 0b00000100;
      myt_event.modifier.right = byte & 0b00000010;
      myt_event.modifier.left = byte & 0b00000001;
      state = STATE_INIT;
      return;
    }
  }
}

int main(int argc, char **argv) {
  int myt = -1;
  MytWidget *widget;

  if (argc < 2) {
    error_message("Need the serial port path to open as first arg");
    return 1;
  }

  myt = open_serial_port(argv[1]);

  dprintf(myt, ATTR_RST BL_BLK FH_WHI CLR CURSOR_OFF MOUSE_SHOW);

  MytFrame *window = new_frame(NULL, "MyTerminal TUI demo", 10, 20, 60, 8);

  MytButton *button_ok =
      new_button((MytWidget *)window, "O" CP1 "\xcb" CP0, 51, 1, 9);
  MytButton *button_cancel = new_button(
      (MytWidget *)window, "C" CP1 "\xc1\xce\xc3\xc5\xcc" CP0, 51, 3, 9);
  MytButton *button_help =
      new_button((MytWidget *)window, "H" CP1 "\xc5\xcc\xd0" CP0, 51, 5, 9);
  MytCheckbox *checkbox_cool =
      new_checkbox((MytWidget *)window, "MyTerminal is cool!", 1, 1);
  MytCheckbox *checkbox_fun =
      new_checkbox((MytWidget *)window, "MyTerminal is fun!", 1, 2);
  MytProgress *progress = new_progress((MytWidget *)window, 1, 4, 20);

  checkbox_cool->state = CHECKBOX_CHECKED;
  checkbox_fun->state = CHECKBOX_UNCHECKED;

  /*
  locate_widget(myt, &root, 1, 1);
  dprintf(myt, SIZE_DOUBLE "Hello, World!" SIZE_NORMAL "\n");
  locate_widget(myt, &root, 10, 5);
  dprintf(myt, SIZE_NORMAL BLINK_ON UNDERLINE_ON
          "Good bye, " BLINK_OFF UNDERLINE_OFF "World!");
  dprintf(myt, ATTR_RST);
  */

  draw_widget(myt, (MytWidget *)window);

  while (1) {
    get_sequence(myt);

    if (myt_event.event_type == EVENT_CHARACTER) {
      if (myt_event.data.key == '+') {
        progress->value++;
        draw_progress(myt, progress);
      } else if (myt_event.data.key == '-') {
        progress->value--;
        draw_progress(myt, progress);
      }
    } else if (myt_event.event_type == EVENT_EXTENDED_KEY) {
      if (myt_event.data.key == KEY_F12) {
        break;
      }
    } else if (myt_event.event_type == EVENT_MOUSE) {
      if (myt_event.modifier.left != 0) {
        widget = which_widget((MytWidget *)window, myt_event.data.mouse.x,
                              myt_event.data.mouse.y);

        if (widget == (MytWidget *)checkbox_cool) {
          if (checkbox_cool->state == CHECKBOX_UNCHECKED) {
            checkbox_cool->state = CHECKBOX_CHECKED;
          } else {
            checkbox_cool->state = CHECKBOX_UNCHECKED;
          }
          update_checkbox(myt, checkbox_cool);
        } else if (widget == (MytWidget *)checkbox_fun) {
          if (checkbox_fun->state == CHECKBOX_UNCHECKED) {
            checkbox_fun->state = CHECKBOX_CHECKED;
          } else {
            checkbox_fun->state = CHECKBOX_UNCHECKED;
          }
          update_checkbox(myt, checkbox_fun);
        } else if (widget == (MytWidget *)button_ok) {
          break;
        } else if (widget == (MytWidget *)button_cancel) {
          break;
        }
      }
    }
  }

  free_widget((MytWidget *)window);
}
