#!/usr/bin/env python3
import random

random.choice(['a', 'b', 'c'])

diagonals = [
    0xE211,
    0xE212,
    0xE213,
    0xE214,
    0xE215,
    0xE216,
    0xE217,
    0xE218,
    0xE219,
    0xE21A,
    0xE21B,
    0xE21C,
    0xE21F,
    0xE221,
    0xE222,
    0xE223,
    0xE224,
    0xE225,
    0xE226,
    0xE227,
    0xE228,
    0xE229,
    0xE22A,
    0xE22B,
    0xE22C,
    0xE22D,
    0xE22E,
    0xE22F
]

screen = ""
for _ in range(80*50 - 1):
    screen += chr(random.choice(diagonals))

print(chr(4) + '00' + chr(2) + '@' + chr(2) + chr(80 + 15), end='')
print(chr(0xE354) + ("Diagonal demo" + chr(0xE287) + " MyTerminal " + chr(0xE363) + chr(0xE370)).ljust(78) + chr(5) + "0" + chr(0xE351), end='')
print(chr(2) + chr(64 + 15) + chr(2) + chr(80 + 0) + screen, end='')
