#!/usr/bin/env python3
import random
import sys

myt_print = sys.stdout.buffer.write

MYT = 'ISO-8859-15'
CHARPAGES = [ b'\x13', b'\x14', b'\x15', b'\x16', b'\x17' ]
LEFT_ROUND = b'\x174\x13'
RIGHT_ROUND = b'\x171\x13'

diagonals = [
    b'\xD1', b'\xD2', b'\xD3', b'\xD4', b'\xD5', b'\xD6', b'\xD7',
    b'\xD8', b'\xD9', b'\xDA', b'\xDC', b'\xDF',

    b'\xE1', b'\xE2', b'\xE3', b'\xE4', b'\xE5', b'\xE6', b'\xE7',
    b'\xE8', b'\xE9', b'\xEA', b'\xEB', b'\xEC', b'\xED', b'\xEE', b'\xEF'
]

screen = CHARPAGES[2]
for _ in range(80*50 - 1):
    screen += random.choice(diagonals)
screen += CHARPAGES[0]

myt_print(b'\x0400\x02@\x02_')
myt_print(LEFT_ROUND + ("Démo: diagonal | MyTerminal").ljust(78).encode(MYT) + RIGHT_ROUND)
myt_print(b'\x02O\x02P' + screen)
