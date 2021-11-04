#ifndef _MYTCODES_H
#define _MYTCODES_H

#define CLR "\001\041"
#define CLR_EOL "\001\050"
#define CLR_BOL "\001\051"
#define CLR_EOS "\001\052"
#define CLR_BOS "\001\053"
#define CLR_LIN "\001\055"

#define COLOR_BASE "\002"
#define F_OFFSET (0x40)
#define B_OFFSET (0x50)

#define FL_BLK "\002\100"
#define FL_RED "\002\101"
#define FL_GRN "\002\102"
#define FL_YEL "\002\103"
#define FL_BLU "\002\104"
#define FL_MAG "\002\105"
#define FL_CYA "\002\106"
#define FL_WHI "\002\107"

#define FH_BLK "\002\110"
#define FH_RED "\002\111"
#define FH_GRN "\002\112"
#define FH_YEL "\002\113"
#define FH_BLU "\002\114"
#define FH_MAG "\002\115"
#define FH_CYA "\002\116"
#define FH_WHI "\002\117"

#define BL_BLK "\002\120"
#define BL_RED "\002\121"
#define BL_GRN "\002\122"
#define BL_YEL "\002\123"
#define BL_BLU "\002\124"
#define BL_MAG "\002\125"
#define BL_CYA "\002\126"
#define BL_WHI "\002\127"

#define BH_BLK "\002\130"
#define BH_RED "\002\131"
#define BH_GRN "\002\132"
#define BH_YEL "\002\133"
#define BH_BLU "\002\134"
#define BH_MAG "\002\135"
#define BH_CYA "\002\136"
#define BH_WHI "\002\137"

#define BLACK (0)
#define RED (1)
#define GREEN (2)
#define YELLOW (3)
#define BLUE (4)
#define MAGENTA (5)
#define CYAN (6)
#define WHITE (7)

#define LIGHT_BLACK (8)
#define LIGHT_RED (9)
#define LIGHT_GREEN (10)
#define LIGHT_YELLOW (11)
#define LIGHT_BLUE (12)
#define LIGHT_MAGENTA (13)
#define LIGHT_CYAN (14)
#define LIGHT_WHITE (15)

#define PATTERN0_AND "\003\100"
#define PATTERN1_AND "\003\104"
#define PATTERN2_AND "\003\110"
#define PATTERN3_AND "\003\114"
#define PATTERN4_AND "\003\120"
#define PATTERN5_AND "\003\124"
#define PATTERN6_AND "\003\130"
#define PATTERN7_AND "\003\134"
#define PATTERN8_AND "\003\140"
#define PATTERN9_AND "\003\144"
#define PATTERN10_AND "\003\150"
#define PATTERN11_AND "\003\154"
#define PATTERN12_AND "\003\160"
#define PATTERN13_AND "\003\164"
#define PATTERN14_AND "\003\170"
#define PATTERN15_AND "\003\174"

#define PATTERN0_OR "\003\101"
#define PATTERN1_OR "\003\105"
#define PATTERN2_OR "\003\111"
#define PATTERN3_OR "\003\115"
#define PATTERN4_OR "\003\121"
#define PATTERN5_OR "\003\125"
#define PATTERN6_OR "\003\131"
#define PATTERN7_OR "\003\135"
#define PATTERN8_OR "\003\141"
#define PATTERN9_OR "\003\145"
#define PATTERN10_OR "\003\151"
#define PATTERN11_OR "\003\155"
#define PATTERN12_OR "\003\161"
#define PATTERN13_OR "\003\165"
#define PATTERN14_OR "\003\171"
#define PATTERN15_OR "\003\175"

#define PATTERN0_XOR "\003\102"
#define PATTERN1_XOR "\003\106"
#define PATTERN2_XOR "\003\112"
#define PATTERN3_XOR "\003\116"
#define PATTERN4_XOR "\003\122"
#define PATTERN5_XOR "\003\126"
#define PATTERN6_XOR "\003\132"
#define PATTERN7_XOR "\003\136"
#define PATTERN8_XOR "\003\142"
#define PATTERN9_XOR "\003\146"
#define PATTERN10_XOR "\003\152"
#define PATTERN11_XOR "\003\156"
#define PATTERN12_XOR "\003\162"
#define PATTERN13_XOR "\003\166"
#define PATTERN14_XOR "\003\172"
#define PATTERN15_XOR "\003\176"

#define LOCATE_BASE "\004"
#define LOCATE_OFFSET (0x30)
#define LOCATE(X,Y) "\004%c%c", 0x30 + (Y), 0x30 + (X)

#define ATTR_BASE "\005"
#define ATTR_RST "\005*"
#define SIZE_NORMAL "\0050"
#define SIZE_DWIDTH "\0051"
#define SIZE_DHEIGHT "\0052"
#define SIZE_DOUBLE "\0053"
#define BLINK_ON "\005B"
#define BLINK_OFF "\005b"
#define HIGHLIGHT_ON "\005H"
#define HIGHLIGHT_OFF "\005h"
#define REVERSE_ON "\005R"
#define REVERSE_OFF "\005r"
#define UNDERLINE_ON "\005U"
#define UNDERLINE_OFF "\005u"

#define CURSOR_ON "\006C"
#define CURSOR_OFF "\006c"

#define SCROLL_UP "\013"
#define SCROLL_DOWN "\014"

#define GO_UP "\016"
#define GO_DOWN "\017"
#define GO_LEFT "\020"
#define GO_RIGHT "\021"

#define CP_BASE (19)
#define CP0 "\023"
#define CP1 "\024"
#define CP2 "\025"
#define CP3 "\026"
#define CP4 "\027"
#define HIRES "\030"

#define MOUSE_BASE "\031"
#define MOUSE_CURSOR_BASE (48)
#define MOUSE_DEFAULT "\0310"
#define MOUSE_POINTER "\0311"
#define MOUSE_NOT_ALLOWED "\0312"
#define MOUSE_WAIT "\0313"
#define MOUSE_MOVE "\0314"
#define MOUSE_GRAB "\0315"
#define MOUSE_CROSSHAIR "\0316"
#define MOUSE_CELL "\0317"

#define MOUSE_HIDE "\031@"
#define MOUSE_SHOW "\031A"

#define KEY_INSERT (0xe0)
#define KEY_HOME (0xe1)
#define KEY_PAGE_UP (0xe2)
#define KEY_DELETE (0xe3)
#define KEY_END (0xe4)
#define KEY_PAGE_DOWN (0xe5)
#define KEY_UP (0xe6)
#define KEY_LEFT (0xe7)
#define KEY_DOWN (0xe8)
#define KEY_RIGHT (0xe9)
#define KEY_CONTEXTUAL (0xea)
#define KEY_PAUSE (0xeb)
#define KEY_SCROLL (0xf0)
#define KEY_F1 (0xf1)
#define KEY_F2 (0xf2)
#define KEY_F3 (0xf3)
#define KEY_F4 (0xf4)
#define KEY_F5 (0xf5)
#define KEY_F6 (0xf6)
#define KEY_F7 (0xf7)
#define KEY_F8 (0xf8)
#define KEY_F9 (0xf9)
#define KEY_F10 (0xfa)
#define KEY_F11 (0xfb)
#define KEY_F12 (0xfc)
#define KEY_PRNT_SCR (0xff)

#endif