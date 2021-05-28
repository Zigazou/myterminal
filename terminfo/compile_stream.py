#!/usr/bin/env python3

import sys
import fileinput
import shlex
import re

colors_codes = {
    'black': 0,
    'red': 1,
    'green': 2,
    'yellow': 3,
    'blue': 4,
    'magenta': 5,
    'cyan': 6,
    'white': 7,
    'gray': 8,
    'lightred': 9,
    'lightgreen': 10,
    'lightyellow': 11,
    'lightblue': 12,
    'lightmagenta': 13,
    'lightcyan': 14,
    'lightwhite': 15,
}

def replace_hex_escape(matchobj):
    return chr(int(matchobj.group(0)[2:], 16))

def apply_escaped_sequences(string):
    string = string.replace("\\n", "\n")
    string = string.replace("\\r", "\r")
    string = string.replace("\\t", "\t")
    string = re.sub(r'\\x[0-9a-fA-F]{2}', replace_hex_escape, string)
    return string.replace("\\\\", "\\")

def interpret_number(string):
    string = string.strip().lower()
    if string in colors_codes:
        return colors_codes[string]
    elif string[0:2] == '0x':
        return int(string[2:], 16)
    else:
        return int(string)

def interpret_boolean(string):
    return string.strip().lower() in [ 'on', 'yes', 'true', 'visible' ]

def command_nul():
    return bytes([ 0x00 ])

def command_clearscreen():
    return bytes([ 0x01, 0x21 ])

def command_clear_bol():
    return bytes([ 0x01, 0x29 ])

def command_clear_eol():
    return bytes([ 0x01, 0x28 ])

def command_clear_bod():
    return bytes([ 0x01, 0x2b ])

def command_clear_eod():
    return bytes([ 0x01, 0x2a ])

def command_clear_line():
    return bytes([ 0x01, 0x2d ])

def command_clear_chars(count):
    return bytes([ 0x01, 0x30 + interpret_number(count) ])

def command_foreground(color):
    return bytes([ 0x02, 0x40 + interpret_number(color) ])

def command_background(color):
    return bytes([ 0x02, 0x50 + interpret_number(color) ])

def command_locate(x, y):
    return bytes([
        0x04,
        0x30 + interpret_number(y),
        0x30 + interpret_number(x)
    ])

def command_reset():
    return bytes([ 0x05, 0x2a ])

def command_underline(state):
    if interpret_boolean(state):
        return bytes([ 0x05, 0x55 ])
    else:
        return bytes([ 0x05, 0x75 ])

def command_blink(state):
    if interpret_boolean(state):
        return bytes([ 0x05, 0x42 ])
    else:
        return bytes([ 0x05, 0x62 ])

def command_highlight(state):
    if interpret_boolean(state):
        return bytes([ 0x05, 0x48 ])
    else:
        return bytes([ 0x05, 0x68 ])

def command_reverse(state):
    if interpret_boolean(state):
        return bytes([ 0x05, 0x52 ])
    else:
        return bytes([ 0x05, 0x72 ])

def command_size(state):
    state = state.strip().lower()
    if state == 'normal':
        return bytes([ 0x05, 0x30 ])
    elif state == 'doublewidth':
        return bytes([ 0x05, 0x31 ])
    elif state == 'doublewidth':
        return bytes([ 0x05, 0x32 ])
    elif state == 'double':
        return bytes([ 0x05, 0x33 ])
    else:
        raise TypeError("Expected normal, doublewidth, doubleheight or double")

def command_cursor(state):
    if interpret_boolean(state):
        return bytes([ 0x06, 0x43 ])
    else:
        return bytes([ 0x06, 0x63 ])

def command_scroll(direction):
    direction = direction.strip().lower()
    if direction == 'up':
        return bytes([ 0x0b ])
    elif direction == 'down':
        return bytes([ 0x0c ])
    else:
        raise TypeError("Expected up or down")

def command_move(direction):
    direction = direction.strip().lower()
    if direction == 'up':
        return bytes([ 0x0e ])
    elif direction == 'right':
        return bytes([ 0x11 ])
    elif direction == 'down':
        return bytes([ 0x0f ])
    elif direction == 'left':
        return bytes([ 0x10 ])
    else:
        raise TypeError("Expected up, down, left or right")

def command_charpage(page):
    page = interpret_number(page)
    if page >= 0 and page <= 4:
        return bytes([0x13 + page])
    else:
        raise TypeError("Expected 0, 1, 2, 3 or 4")

def command_print(string):
    return apply_escaped_sequences(string).encode('ISO-8859-15')

def command_mouse(control):
    control = control.strip().lower()
    if control == 'enable':
        return bytes([ 0x19, 0x41])
    elif control == 'disable':
        return bytes([ 0x19, 0x40])
    else:
        raise TypeError("Expected enable or disable")

commands = {
    "nul": command_nul,
    "clearscreen": command_clearscreen,
    "clearbol": command_clear_bol,
    "cleareol": command_clear_eol,
    "clearbod": command_clear_bod,
    "cleareod": command_clear_eod,
    "clearline": command_clear_line,
    "clearchars": command_clear_chars,
    "foreground": command_foreground,
    "background": command_background,
    "locate": command_locate,
    "reset": command_reset,
    "underline": command_underline,
    "blink": command_blink,
    "highlight": command_highlight,
    "reverse": command_reverse,
    "size": command_size,
    "cursor": command_cursor,
    "scroll": command_scroll,
    "move": command_move,
    "charpage": command_charpage,
    "print": command_print,
    "mouse": command_mouse,
}

program = []
for line in fileinput.input():
    program.append(line.rstrip())

stream = bytes()
for line, command in enumerate(program):
    arguments = shlex.split(command, comments=True)

    # Ignores empty lines or comments
    if len(arguments) == 0:
        continue

    instruction = arguments[0].strip().lower()
    arguments = arguments[1:]
    
    if instruction not in commands:
        print("Unknown instruction: {}".format(instruction), file=sys.stderr)
        exit(1)

    try:
        stream += commands[instruction](*arguments)
    except TypeError as err:
        print(
            "{} (instruction {}, line {})".format(
                err,
                instruction,
                line
            ),
            file=sys.stderr
        )
        exit(2)

sys.stdout.buffer.write(stream)
