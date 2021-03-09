#!/usr/bin/env python3

from sys import argv

with open(argv[1], "rb") as f:
    stream = f.read()

offset = 0
while offset < len(stream):
    byte = stream[offset]

    if byte == 0x00:
        description = "NUL"
        length = 1
    elif byte == 0x01:
        next_byte = stream[offset + 1]
        length = 2
        if next_byte == 0x21:
            description = "CLEAR SCREEN"
        elif next_byte == 0x29:
            description = "CLEAR BEGINNING OF LINE"
        elif next_byte == 0x28:
            description = "CLEAR END OF LINE"
        elif next_byte == 0x2b:
            description = "CLEAR BEGINNING OF DISPLAY"
        elif next_byte == 0x2a:
            description = "CLEAR END OF DISPLAY"
        elif next_byte == 0x2d:
            description = "CLEAR LINE"
        elif next_byte >= 0x30:
            description = "CLEAR {} CHARACTERS".format(next_byte - 0x30)
        else:
            description = "INVALID CLEAR"
    elif byte == 0x02:
        next_byte = stream[offset + 1]
        length = 2
        if next_byte >= 0x40 and next_byte <= 0x4f:
            description = "FOREGROUND COLOR {}".format(next_byte - 0x40)
        elif next_byte >= 0x50 and next_byte <= 0x5f:
            description = "BACKGROUND COLOR {}".format(next_byte - 0x50)
        else:
            description = "INVALID COLOR"
    elif byte == 0x04:
        row = stream[offset + 1]
        col = stream[offset + 2]
        length = 3
        description = "LOCATE COL={}, ROW={}".format(col - 0x30, row - 0x30)
    elif byte == 0x05:
        next_byte = stream[offset + 1]
        length = 2
        if next_byte == 0x2a:
            description = "RESET ALL ATTRIBUTES"
        elif next_byte == 0x55:
            description = "UNDERLINE ON"
        elif next_byte == 0x75:
            description = "UNDERLINE OFF"
        elif next_byte == 0x42:
            description = "BLINK ON"
        elif next_byte == 0x62:
            description = "BLINK OFF"
        elif next_byte == 0x48:
            description = "HIGHLIGHT ON"
        elif next_byte == 0x68:
            description = "HIGHTLIGHT OFF"
        elif next_byte == 0x52:
            description = "REVERSE ON"
        elif next_byte == 0x72:
            description = "REVERSE OFF"
        elif next_byte == 0x30:
            description = "SIZE NORMAL"
        elif next_byte == 0x31:
            description = "SIZE DOUBLE WIDTH"
        elif next_byte == 0x32:
            description = "SIZE DOUBLE HEIGHT"
        elif next_byte == 0x33:
            description = "SIZE DOUBLE SIZE"
        else:
            description = "INVALID ATTRIBUTE"
    elif byte == 0x06:
        next_byte = stream[offset + 1]
        length = 2

        if next_byte == 0x43:
            description = "CURSOR VISIBLE"
        elif next_byte == 0x56:
            description = "CURSOR EMPHASIZE"
        elif next_byte == 0x63:
            description = "CURSOR HIDDEN"
        else:
            description = "INVALID CURSOR SETTING"
    elif byte == 0x07:
        length = 1
        description = "BELL"
    elif byte == 0x0a:
        length = 1
        description = "LINE FEED"
    elif byte == 0x0b:
        length = 1
        description = "SCROLL UP"
    elif byte == 0x0c:
        length = 1
        description = "SCROLL DOWN"
    elif byte == 0x0d:
        length = 1
        description = "CARRIAGE RETURN"
    elif byte == 0x0e:
        length = 1
        description = "CURSOR UP"
    elif byte == 0x0f:
        length = 1
        description = "CURSOR DOWN"
    elif byte == 0x10:
        length = 1
        description = "CURSOR LEFT"
    elif byte == 0x11:
        length = 1
        description = "CURSOR RIGHT"
    elif byte == 0x13:
        length = 1
        description = "CHARACTER PAGE 0"
    elif byte == 0x14:
        length = 1
        description = "CHARACTER PAGE 1"
    elif byte == 0x15:
        length = 1
        description = "CHARACTER PAGE 2"
    elif byte == 0x16:
        length = 1
        description = "CHARACTER PAGE 3"
    elif byte == 0x17:
        length = 1
        description = "CHARACTER PAGE 4"
    elif byte < 0x20:
        length = 1
        description = "CONTROL CODE {:02x}".format(byte)
    else:
        next_offset = offset + 1
        while stream[next_offset] >= 0x20 and next_offset < len(stream):
            next_offset += 1

        length = next_offset - offset
        string = stream[offset:next_offset].decode('ISO-8859-15')
        description = "STRING[{}] {}".format(len(string), string)

    print("{:08x}: {}".format(offset, description))

    offset += length