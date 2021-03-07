#!/usr/bin/env python3

# Palette from https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
ubuntu_palette = [
    (1, 1, 1),
    (222, 56, 43),
    (57, 181, 74),
    (255, 199, 6),
    (0, 111, 184),
    (118, 38, 113),
    (44, 181, 233),
    (204, 204, 204),
    (128, 128, 128),
    (255, 0, 0),
    (0, 255, 0),
    (255, 255, 0),
    (0, 0, 255),
    (255, 0, 255),
    (0, 255, 255),
    (255, 255, 255)
]

index = 0
for (red8, green8, blue8) in ubuntu_palette:
    (red3, green3, blue3) = (red8 >> 5, green8 >> 5, blue8 >> 5)
    print("\t\tpalette[{}] <= 9'b{:03b}_{:03b}_{:03b};".format(
        index,
        red3, green3, blue3
    ))

    index += 1
