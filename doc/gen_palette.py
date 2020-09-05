#!/usr/bin/env, python3

# This script generates a Verilog snippet generating a 16 × 9 bit RGB palette
# and stores it in registers.

# DawnBringer 16 color palette v1.0
# https://pixeljoint.com/forum/forum_posts.asp?TID=12795
dawnbringer = [
    (20, 12, 28),
    (68, 36, 52),
    (48, 52, 109),
    (78, 74, 78),
    (133, 76, 48),
    (52, 101, 36),
    (208, 70, 72),
    (117, 113, 97),
    (89, 125, 206),
    (210, 125, 44),
    (133, 149, 161),
    (109, 170, 44),
    (210, 170, 153),
    (109, 194, 202),
    (218, 212, 94),
    (222, 238, 214)
]

# Convert the DawnBringer’s palette to 9 bits RGB and generate Verilog code.
index = 0
for (red, green, blue) in dawnbringer:
    print("palette[{}] <= 9'b{}_{}_{};".format(
        index,
        bin(red >> 5)[2:].rjust(3, "0"),
        bin(green >> 5)[2:].rjust(3, "0"),
        bin(blue >> 5)[2:].rjust(3, "0")
    ))
    index += 1
