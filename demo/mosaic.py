#!/usr/bin/env python3
import random
import sys

myt_print = sys.stdout.buffer.write

MYT = 'ISO-8859-15'
CHARPAGES = [ b'\x13', b'\x14', b'\x15', b'\x16', b'\x17' ]
LEFT_ROUND = b'\x174\x13'
RIGHT_ROUND = b'\x171\x13'

mosaic = [
    b'\xA0', b'\xA1', b'\xA2', b'\xA3', b'\xA4', b'\xA5', b'\xA6', b'\xA7', 
    b'\xA8', b'\xA9', b'\xAA', b'\xAB', b'\xAC', b'\xAD', b'\xAE', b'\xAF', 
    b'\xB0', b'\xB1', b'\xB2', b'\xB3', b'\xB4', b'\xB5', b'\xB6', b'\xB7', 
    b'\xB8', b'\xB9', b'\xBA', b'\xBB', b'\xBC', b'\xBD', b'\xBE', b'\xBF', 
    b'\xC0', b'\xC1', b'\xC2', b'\xC3', b'\xC4', b'\xC5', b'\xC6', b'\xC7', 
    b'\xC8', b'\xC9', b'\xCA', b'\xCB', b'\xCC', b'\xCD', b'\xCE', b'\xCF', 
    b'\xD0', b'\xD1', b'\xD2', b'\xD3', b'\xD4', b'\xD5', b'\xD6', b'\xD7', 
    b'\xD8', b'\xD9', b'\xDA', b'\xDB', b'\xDC', b'\xDD', b'\xDE', b'\xDF'
]

colors = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
]

screen = CHARPAGES[4]
for _ in range(80*50 - 1):
    screen += bytes([2, 64 + random.choice(colors)])
    screen += bytes([2, 80 + random.choice(colors)])
    screen += random.choice(mosaic)
screen += CHARPAGES[0]

myt_print(b'\x0400\x02@\x02_')
myt_print(LEFT_ROUND + ("Démo: mosaïque | MyTerminal").ljust(78).encode(MYT) + RIGHT_ROUND)
myt_print(b'\x02O\x02P' + screen)