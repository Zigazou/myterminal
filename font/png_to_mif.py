#!/usr/bin/env python3
from PIL import Image

# Generate a MIF file containing the font ROM of our extended videotex character
# set. The MIF file can then be used as an initialization file for FPGA project.

# Character dimension
CHAR_HEIGHT = 20
CHAR_WIDTH = 16

# Bitmap dimension
GRID_WIDTH = 1024
GRID_HEIGHT = 320

CHAR_COUNT = (GRID_WIDTH // CHAR_WIDTH) * (GRID_HEIGHT // CHAR_HEIGHT)

def getbit(rgbs, x, y):
    r, g, b = rgbs.getpixel((x, y))
    if r < 32 and g < 32 and b < 32:
        return 1

    return 0

def getcharwords(rgbs, i, j):
    x = i * CHAR_WIDTH
    words = []

    for y in range(j * CHAR_HEIGHT, (j + 1) * CHAR_HEIGHT):
        word = 0
        for i in range(0, CHAR_WIDTH):
            word += getbit(rgbs, x + i, y) << (CHAR_WIDTH - 1 - i)

        words.append(word)

    return words

# Load the image
charset = Image.open("extended_videotex.png")

# Convert the image to RGB
rgbs = charset.convert('RGB')

allwords = []
for i in range(0, GRID_WIDTH // CHAR_WIDTH):
    for j in range(0, CHAR_WIDTH):
        for word in getcharwords(rgbs, i, j):
            allwords.append(word)

with open('extended_videotex.mif', 'w') as f:
    f.write("DEPTH = {};\n".format(CHAR_HEIGHT * CHAR_COUNT))
    f.write("WIDTH = {};\n\n".format(CHAR_WIDTH))

    f.write("ADDRESS_RADIX = HEX;\n")
    f.write("DATA_RADIX = BIN;\n\n")

    f.write("CONTENT\n")
    f.write("BEGIN\n")

    offset = 0
    for word in allwords:
        if offset % CHAR_HEIGHT == 0:
            f.write("-- Character {}\n".format(offset // CHAR_HEIGHT))

        f.write("{}: {};\n".format(
            hex(offset)[2:].rjust(6, "0"),
            bin(word)[2:].rjust(CHAR_WIDTH, "0")
        ))

        offset += 1

    f.write("END;\n")
