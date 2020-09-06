#!/usr/bin/env python3

for codepoint in range(0xE000, 0xE400):
    print(chr(codepoint), end='')

    #if (codepoint - 0xE000) % 40 == 39:
    #    print()