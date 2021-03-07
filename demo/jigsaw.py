#!/usr/bin/env python3
import random
import sys

myt_print = sys.stdout.buffer.write

MYT = 'ISO-8859-15'
CHARPAGES = [ b'\x13', b'\x14', b'\x15', b'\x16', b'\x17' ]
LEFT_ROUND = b'\x174\x13'
RIGHT_ROUND = b'\x171\x13'


colors = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
]

jigsaw = [ chr(j).encode(MYT) for j in range(96, 160) ]
screen = CHARPAGES[3]
for _ in range(80*50 - 1):
    screen += bytes([2, 64 + random.choice(colors)])
    #screen += bytes([2, 80 + random.choice(colors)])
    screen += random.choice(jigsaw)
screen += CHARPAGES[0]

myt_print(b'\x0400\x02@\x02_')
myt_print(LEFT_ROUND + ("Démo: jigsaw | MyTerminal").ljust(78).encode(MYT) + RIGHT_ROUND)
myt_print(b'\x02O\x02P' + screen)
