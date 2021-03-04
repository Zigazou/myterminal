#!/usr/bin/env python3
import curses

def main(stdscr):
    # Clear screen
    curses.start_color()
    stdscr.clear()

    for y in range(0, 4):
        for x in range(0, 4):
            color_num = x + y * 4
            if color_num == 0: continue
            curses.init_pair(color_num, color_num, curses.COLOR_BLACK)

    for y in range(0, 4):
        for x in range(0, 4):
            color_num = x + y * 4
            stdscr.addstr(
                y * 3, x * 10,
                '{} {}'.format(chr(0x05) + "3" + chr(0xE3FF) + chr(0xE3FF), color_num),
                curses.color_pair(color_num) | curses.A_HORIZONTAL
            )

    stdscr.refresh()

curses.wrapper(main)
