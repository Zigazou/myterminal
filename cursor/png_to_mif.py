#!/usr/bin/env python3
from PIL import Image

# Generate a MIF file containing the cursors ROM.
# The MIF file can then be used as an initialization file for FPGA project.

# Cursor dimensions
CURSOR_HEIGHT = 24
CURSOR_WIDTH = 16

CURSOR_COUNT = 8

# Bitmap dimension
GRID_WIDTH = 16
GRID_HEIGHT = 384

def getvalue(rgbs, x, y):
    r, _, _, a = rgbs.getpixel((x, y))
    if a == 0:
        return (0, 0)
    elif r == 0:
        return (0, 1)
    elif r == 0x80:
        return (1, 0)
    else:
        return (1, 1)

def getcharwords(rgbs):
    words = []

    for y in range(CURSOR_HEIGHT):
        word = 0
        for i in range(0, CURSOR_WIDTH // 2):
            x = i
            word += getvalue(rgbs, x, y)[0] << (CURSOR_WIDTH - 2 - (i * 2))
            word += getvalue(rgbs, x, y)[1] << (CURSOR_WIDTH - 1 - (i * 2))

        words.append(word)

        word = 0
        for i in range(0, CURSOR_WIDTH // 2):
            x = CURSOR_WIDTH // 2 + i
            word += getvalue(rgbs, x, y)[0] << (CURSOR_WIDTH - 2 - (i * 2))
            word += getvalue(rgbs, x, y)[1] << (CURSOR_WIDTH - 1 - (i * 2))

        words.append(word)

    return words

# Load the image

cursor_files = [
    "cursor-default.png",
    "cursor-pointer.png",
    "cursor-not-allowed.png",
    "cursor-wait.png",
    "cursor-move.png",
    "cursor-grab.png",
    "cursor-crosshair.png",
    "cursor-cell.png",
]

with open('cursors.mif', 'w') as f:
    f.write("DEPTH = {};\n".format(CURSOR_HEIGHT * CURSOR_COUNT * 2))
    f.write("WIDTH = {};\n\n".format(CURSOR_WIDTH))

    f.write("ADDRESS_RADIX = HEX;\n")
    f.write("DATA_RADIX = BIN;\n\n")

    f.write("CONTENT\n")
    f.write("BEGIN\n")

    offset = 0
    for cursor_file in cursor_files:
        cursor = Image.open(cursor_file)

        # Convert the image to RGB
        rgbs = cursor.convert('RGBA')

        allwords = []
        for word in getcharwords(rgbs):
            allwords.append(word)

        f.write("-- Cursor {}\n".format(cursor_file))
        for word in allwords:
            f.write("{}: {};\n".format(
                hex(offset)[2:].rjust(6, "0"),
                bin(word)[2:].rjust(CURSOR_WIDTH, "0")
            ))

            offset += 1

    f.write("END;\n")
