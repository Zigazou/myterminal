MyTerminal
==========

MyTerminal is a serial terminal implemented on an FPGA.

![MyTerminal](doc/myterminal.png)

Characteristics
---------------

- VGA output
  - 1280×1024@60Hz,
  - 16 colors from a 512 colors/9 bits palette
  - 16×20 1024 character set
  - semi-graphic characters
- fast serial input (tested at 3 Mbps)
  - CTSRTS control signal when doing “intensive” operations
  - 8 characters FIFO 
  - ISO-8859-15 support
- low cost (cheap FPGA, 9 resistor DAC…)
- written in Verilog
- inspired by Videotex and text mode video card

Requirements
------------

- Tang SiPeed Primer (Anlogic Eagle EG4S20BG256)
- Tang Dynasty 4.6
- Icarus Verilog
- Python 3
- Google Chrome if you wish to use the JavaScript demo files

Using MyTerminal as a Linux terminal
------------------------------------

If you want to use MyTerminal under Linux, you first need to install the
[MyTerminal terminfo](terminfo/myterminal.ti) file located.

This requires the `tic`, the terminfo entry-description compiler. The following
command will compile the file and install it for the current user:

```bash
tic myterminal.ti
```

Once installed, the following commands must be issued:

```bash
export TERM=myterminal
export LC_CTYPE='fr_FR.ISO-8859-15@euro'
export LANG="$LC_CTYPE"
stty -F /dev/ttyUSB0 3000000 raw
```

Note: `/dev/ttyUSB0` must be replaced with the device file attributed to
MyTerminal by your Linux OS.

Escape codes
------------

| Code (hexa)   | Function                                                    |
| ------------- |-------------------------------------------------------------|
| 01 21         | Clear entire screen, move cursor to top left position       |
| 01 28         | Clear end of current line                                   |
| 01 29         | Clear beginning of current line                             |
| 01 2A         | Clear end of screen                                         |
| 01 2B         | Clear beginning of screen                                   |
| 01 2D         | Clear current line                                          |
| 01 30+n       | Clear the n characters to the right of the current position |
|               |                                                             |
| 02 40+n       | Set foreground color (0≤n<16)                               |
| 02 50+n       | Set background color (0≤n<16)                               |
|               |                                                             |
| 03 44+n       | Use pattern n with an `and` logical function                |
| 03 45+n       | Use pattern n with an `or` logical function                 |
| 03 46+n       | Use pattern n with an `xor` logical function                |
| 03 47+n       | Use border n                                                |
|               |                                                             |
| 04 30+y 30+x  | Move cursor absolute position (x, y) 0≤x<80, 0≤y<51         |
| 04 23 30+x    | Move cursor to column x, 0≤x<80                             |
| 04 30+y 23    | Move cursor to row y, 0≤y<51                                |
|               |                                                             |
| 05 2A         | Reset attributes to default                                 |
| 05 30         | Set normal size                                             |
| 05 31         | Set double width                                            |
| 05 32         | Set double height                                           |
| 05 33         | Set double size                                             |
| 05 42         | Enable blinking                                             |
| 05 48         | Enable highlight                                            |
| 05 52         | Enable reverse video                                        |
| 05 55         | Enable underline                                            |
| 05 62         | Disable blinking                                            |
| 05 68         | Disable highlight                                           |
| 05 72         | Disable reverse video                                       |
| 05 75         | Disable underline                                           |
|               |                                                             |
| 06 43         | Show cursor                                                 |
| 06 63         | Hide cursor                                                 |
|               |                                                             |
| 0B            | Scroll screen up (does not move cursor)                     |
| 0C            | Scroll screen down (does not move cursor)                   |
|               |                                                             |
| 0E            | Move cursor up                                              |
| 0F            | Move cursor down                                            |
| 10            | Move cursor left                                            |
| 11            | Move cursor right                                           |
|               |                                                             |
| 13            | Use character page 0, see [charpage.pdf](font/charpage.pdf) |
| 14            | Use character page 1, see [charpage.pdf](font/charpage.pdf) |
| 15            | Use character page 2, see [charpage.pdf](font/charpage.pdf) |
| 16            | Use character page 3, see [charpage.pdf](font/charpage.pdf) |
| 17            | Use character page 4, see [charpage.pdf](font/charpage.pdf) |
|               |                                                             |
| 18            | Use hi-res graphics                                         |

Notes
-----

This is work in progress!