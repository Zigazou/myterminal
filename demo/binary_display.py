#!/usr/bin/env python3
import random
import sys
from time import sleep

def myt_print(string):
    if type(string) is bytes:
        sys.stdout.buffer.write(string)
    elif type(string) is list:
        sys.stdout.buffer.write(bytes(string))
    elif type(string) is str:
        sys.stdout.buffer.write(string.encode(MYT))

MYT = 'ISO-8859-15'
CHARPAGES = [ b'\x13', b'\x14', b'\x15', b'\x16', b'\x17' ]

def cls():
    myt_print([ 0x01, 0x21 ])

def set_foreground(color):
    myt_print([ 0x02, 0x40 + color ])

def set_background(color):
    myt_print([ 0x02, 0x50 + color ])

def locate(x, y):
    myt_print([ 0x04, 0x30 + y, 0x30 + x ])

UNDERLINE_ON   = "U"
UNDERLINE_OFF  = "u"
BLINK_ON       = "B"
BLINK_OFF      = "b"
REVERSE_ON     = "R"
REVERSE_OFF    = "r"
SIZE_NORMAL    = "0"
SIZE_DBLWIDTH  = "1"
SIZE_DBLHEIGHT = "2"
SIZE_DOUBLE    = "3"
def attribute(value):
    myt_print(chr(0x05) + value)

def titlebar(title):
    set_foreground(0)
    set_background(15)

    myt_print(
        b'\x174\x13' +
        (title + " | MyTerminal").ljust(78).encode(MYT) +
        b'\x171\x13'
    )

    set_foreground(15)
    set_background(0)

def binary(number, length):
    images = {
        '00': 0xA4,
        '01': 0xA5,
        '10': 0xA6,
        '11': 0xA7,
        '0': 0xAA,
        '1': 0xAB
    }

    number = number & (2 ** length - 1)
    bits_string = bin(number)[2:].rjust(length, '0')
    myt_print(b'\x14')
    myt_print([ images[bits_string[i:i+2]] for i in range(0, length, 2) ])
    myt_print(b'\x13')

cls()
titlebar("Démo : nombres binaires")
locate(1, 2)

attribute(SIZE_DOUBLE)
myt_print("Liste des nombres sur 8 bits : ")
attribute(SIZE_NORMAL)

for number in range(256):
    locate(1 + 10 * (number // 32), 5 + number % 32)
    set_foreground(14)
    myt_print(str(number).rjust(3) + ":")
    set_foreground(13)
    binary(number, 8)

locate(0, 0)
sys.stdout.flush()
for _ in range(30):
    sleep(1)
    myt_print(b'\x0b')
    sys.stdout.flush()
