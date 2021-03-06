#!/usr/bin/env python3
import random

mosaic = [
    0xE380,
    0xE381,
    0xE382,
    0xE383,
    0xE384,
    0xE385,
    0xE386,
    0xE387,
    0xE388,
    0xE389,
    0xE38A,
    0xE38B,
    0xE38C,
    0xE38D,
    0xE38E,
    0xE38F,
    0xE390,
    0xE391,
    0xE392,
    0xE393,
    0xE394,
    0xE395,
    0xE396,
    0xE397,
    0xE398,
    0xE399,
    0xE39A,
    0xE39B,
    0xE39C,
    0xE39D,
    0xE39E,
    0xE39F,
    0xE3A0,
    0xE3A1,
    0xE3A2,
    0xE3A3,
    0xE3A4,
    0xE3A5,
    0xE3A6,
    0xE3A7,
    0xE3A8,
    0xE3A9,
    0xE3AA,
    0xE3AB,
    0xE3AC,
    0xE3AD,
    0xE3AE,
    0xE3AF,
    0xE3B0,
    0xE3B1,
    0xE3B2,
    0xE3B3,
    0xE3B4,
    0xE3B5,
    0xE3B6,
    0xE3B7,
    0xE3B8,
    0xE3B9,
    0xE3BA,
    0xE3BB,
    0xE3BC,
    0xE3BD,
    0xE3BE,
    0xE3BF,
]

colors = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    #16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
]

screen = ""
for _ in range(80*50 - 1):
    screen += chr(2) + chr(64 + random.choice(colors))
    screen += chr(2) + chr(80 + random.choice(colors))
    screen += chr(random.choice(mosaic) + 64)

print(chr(4) + '00' + chr(2) + '@' + chr(2) + chr(80 + 15), end='')
print(chr(0xE354) + "Mosaic demo".ljust(78) + chr(5) + "0" + chr(0xE351), end='')
print(screen, end='')
