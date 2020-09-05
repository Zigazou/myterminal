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
charset = Image.open("extended_videotex.png")

# Convert the image to RGB
rgbs = charset.convert('RGB')

allwords = []
for i in range(0, GRID_WIDTH // CHAR_WIDTH):
	for j in range(0, CHAR_WIDTH):
		for word in getcharwords(rgbs, i, j):
			allwords.append(word)

with open('font_sim.v', 'w') as f:
	f.write("module font (\n")
	f.write("	input wire clk,\n")
	f.write("	input wire [14:0] font_address,\n")
	f.write("	output reg [15:0] char_row_bitmap\n")
	f.write(");\n")
	f.write("\n")

	f.write("reg [29:0] fifo = 30'd0;\n")
	f.write("always @(posedge clk) fifo <= { font_address, fifo[29:15] };\n")
	f.write("\n")

	f.write("always @(posedge clk)\n")
	f.write("    case (fifo[14:0])\n")

	offset = 0
	for word in allwords:
		f.write("		15'h{}: char_row_bitmap <= 16'b{};\n".format(
			hex(offset)[2:].rjust(4, "0"),
			bin(word)[2:].rjust(CHAR_WIDTH, "0")
		))

		offset += 1

	f.write("    endcase\n")
	f.write("\n")

	f.write("endmodule\n")
