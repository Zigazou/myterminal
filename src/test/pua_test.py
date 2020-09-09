#!/usr/bin/env python3

print (chr(0x01) + chr(0x1b) + chr(0x4f), end='')
for codepoint in range(0xE000, 0xE400):
    print(chr(codepoint), end='')

    """if (codepoint - 0xE000) % 40 == 39:
        print()"""