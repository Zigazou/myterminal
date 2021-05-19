#!/usr/bin/env python3
from PIL import Image

# Generate a Verilog file that can be used as a font RAM simulator.

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
charset = Image.open("../font/extended_videotex.png")

# Convert the image to RGB
rgbs = charset.convert('RGB')

with open('myterminal_font.h', 'w') as f:
	f.write("#ifndef MYTERMINAL_FONT_H\n")
	f.write("#define MYTERMINAL_FONT_H\n")
	f.write("unsigned short myterminal_font[{}][{}];\n".format(
		CHAR_COUNT,
		CHAR_HEIGHT
	))
	f.write("#endif\n")

with open('myterminal_font.c', 'w') as f:
	f.write("#include \"myterminal_font.h\"\n")
	f.write("\n")

	f.write("unsigned short myterminal_font[{}][{}] = {}\n".format(
		CHAR_COUNT,
		CHAR_HEIGHT,
		"{"
	))

	for i in range(0, GRID_WIDTH // CHAR_WIDTH):
		for j in range(0, CHAR_WIDTH):
			f.write("    {\n")
			for word in getcharwords(rgbs, i, j):
				f.write("        {},\n".format(word))
			f.write("    },\n")

	f.write("};\n")
