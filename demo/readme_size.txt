O[93mMyTerminal
[m
MyTerminal is a serial terminal implemented on an FPGA.

N[92mCharacteristics
[m
- VGA output
  - 1280×1024@60Hz,
  - 16 colors from a 512 colors/9 bits palette
  - 16x20 1024 character set
  - semi-graphic characters
- fast serial input (tested at 1Mbps)
  - CTSRTS control signal when doing "intensive" operations
  - 8 characters FIFO 
  - UTF-8 support
- low cost (cheap FPGA, 9 resistor DAC etc.)
- written in Verilog
- inspired by Videotex and text mode video card

N[92mRequirements
[m
- Tang SiPeed Primer (Anlogic Eagle EG4S20BG256)
- Tang Dynasty 4.6
- Icarus Verilog
- Python 3

N[92mNotes
[m
This is work in progress!