localparam
	// Escape and function keys
	ASCII_ESC           = 'h1b,

	ASCII_F1            = 'hf1,
	ASCII_F2            = 'hf2,
	ASCII_F3            = 'hf3,
	ASCII_F4            = 'hf4,
	ASCII_F5            = 'hf5,
	ASCII_F6            = 'hf6,
	ASCII_F7            = 'hf7,
	ASCII_F8            = 'hf8,
	ASCII_F9            = 'hf9,
	ASCII_F10           = 'hfa,
	ASCII_F11           = 'hfb,
	ASCII_F12           = 'hfc,

	ASCII_SCROLL        = 'hf0,
	ASCII_PRNT_SCR      = 'hff,

	// Row 1
	ASCII_SQUARE        = 'hb2,	// ²
	ASCII_S_SQUARE      = 'hb3, // ³
	ASCII_G_SQUARE      = 'hb9, // ¹

	ASCII_1             = 'h26,	// &
	ASCII_S_1           = 'h31,	// 1
	ASCII_S_G_1         = 'hc9,	// É

	ASCII_2             = 'he9,	// é
	ASCII_S_2           = 'h32,	// 2
	ASCII_G_2           = 'h7e,	// ~

	ASCII_3             = 'h22,	// "
	ASCII_S_3           = 'h33,	// 3
	ASCII_G_3           = 'h23,	// #

	ASCII_4             = 'h27,	// '
	ASCII_S_4           = 'h34,	// 4
	ASCII_G_4           = 'h7b,	// {

	ASCII_5             = 'h28,	// (
	ASCII_S_5           = 'h35,	// 5
	ASCII_G_5           = 'h5b,	// [

	ASCII_6             = 'h2d,	// -
	ASCII_S_6           = 'h36,	// 6
	ASCII_G_6           = 'h7c,	// |

	ASCII_7             = 'he8,	// è
	ASCII_S_7           = 'h37,	// 7
	ASCII_G_7           = 'h60,	// `
	ASCII_S_G_7         = 'hc8,	// È

	ASCII_8             = 'h5f,	// _
	ASCII_S_8           = 'h38,	// 8
	ASCII_G_8           = 'h5c,	// \
	ASCII_S_G_8         = 'h7f,	// ™
	ASCII_C_8           = 'h1f, // Control+_

	ASCII_9             = 'he7,	// ç
	ASCII_S_9           = 'h39,	// 9
	ASCII_G_9           = 'h5e,	// ^
	ASCII_S_G_9         = 'hc7,	// Ç

	ASCII_0             = 'he0,	// à
	ASCII_S_0           = 'h30,	// 0
	ASCII_G_0           = 'h40,	// @
	ASCII_S_G_0         = 'hc0,	// À

	ASCII_RIGHT_PAREN   = 'h29,	// )
	ASCII_S_RIGHT_PAREN = 'hb0,	// °
	ASCII_G_RIGHT_PAREN = 'h5d,	// ]
	//ASCII_S_G_RIGHT_PAREN = 'h,	// 

	ASCII_EQUAL         = 'h3d,	// =
	ASCII_S_EQUAL       = 'h2b,	// +
	ASCII_G_EQUAL       = 'h7d,	// }
	ASCII_S_G_EQUAL     = 'hb1,	// ±

	ASCII_BACKSPACE     = 'h08,

	// Row 2
	ASCII_TAB           = 'h09,	// 

	ASCII_A             = 'h61,	// a
	ASCII_S_A           = 'h41,	// A
	ASCII_G_A           = 'h41,	// æ
	ASCII_S_G_A         = 'h41,	// Æ
	ASCII_C_A           = 'h01, // Control+A

	ASCII_Z             = 'h7a,	// z
	ASCII_S_Z           = 'h5a,	// Z
	ASCII_G_Z           = 'he2,	// â
	ASCII_S_G_Z         = 'hc2,	// Â
	ASCII_C_Z           = 'h1a, // Control+Z

	ASCII_E             = 'h65,	// e
	ASCII_S_E           = 'h45,	// E
	ASCII_G_E           = 'ha4,	// €
	ASCII_S_G_E         = 'ha2,	// ¢
	ASCII_C_E           = 'h05, // Control+E

	ASCII_R             = 'h72,	// r
	ASCII_S_R           = 'h52,	// R
	ASCII_G_R           = 'hea,	// ê
	ASCII_S_G_R         = 'hca,	// Ê
	ASCII_C_R           = 'h12, // Control+R

	ASCII_T             = 'h74,	// t
	ASCII_S_T           = 'h54,	// T
	//ASCII_G_T           = 'h,	// 
	//ASCII_S_G_T         = 'h,	// 
	ASCII_C_T           = 'h14, // Control+T

	ASCII_Y             = 'h79,	// y
	ASCII_S_Y           = 'h59,	// Y
	ASCII_G_Y           = 'hff,	// ÿ
	ASCII_S_G_Y         = 'hbe,	// Ÿ
	ASCII_C_Y           = 'h19, // Control+Y

	ASCII_U             = 'h75,	// u
	ASCII_S_U           = 'h55,	// U
	ASCII_G_U           = 'hfb,	// û
	ASCII_S_G_U         = 'hdb,	// Û
	ASCII_C_U           = 'h15, // Control+U

	ASCII_I             = 'h69,	// i
	ASCII_S_I           = 'h49,	// I
	ASCII_G_I           = 'hee,	// î
	ASCII_S_G_I         = 'hce,	// Î
	ASCII_C_I           = 'h09, // Control+I

	ASCII_O             = 'h6f,	// o
	ASCII_S_O           = 'h4f,	// O
	ASCII_G_O           = 'hbd,	// œ
	ASCII_S_G_O         = 'hbc,	// Œ
	ASCII_C_O           = 'h0f, // Control+O

	ASCII_P             = 'h70,	// p
	ASCII_S_P           = 'h50,	// P
	ASCII_G_P           = 'hf4,	// ô
	ASCII_S_G_P         = 'hd4,	// Ô
	ASCII_C_P           = 'h10, // Control+P

	ASCII_CIRC          = 'h5e,	// ^
	ASCII_S_CIRC        = 'h22,	// "
	ASCII_G_CIRC        = 'h7e,	// ~
	ASCII_S_G_CIRC      = 'hb0,	// °
	ASCII_C_CIRC        = 'h1e, // Control+^

	ASCII_DOLLAR        = 'h24,	// $
	ASCII_S_DOLLAR      = 'ha3,	// £
	ASCII_G_DOLLAR      = 'hf8,	// ø
	ASCII_S_G_DOLLAR    = 'hd8,	// Ø

	ASCII_RETURN        = 'h0a,	// 

	// Row 3
	//ASCII_CAPS_LOCK     = 'h,

	ASCII_Q             = 'h71,	// q
	ASCII_S_Q           = 'h51,	// Q
	ASCII_G_Q           = 'he4,	// ä
	ASCII_S_G_Q         = 'hc4,	// Ä
	ASCII_C_Q           = 'h11, // Control+Q

	ASCII_S             = 'h73,	// s
	ASCII_S_S           = 'h53,	// S
	ASCII_G_S           = 'hdf,	// ß
	//ASCII_S_G_S         = 'h,	// 
	ASCII_C_S           = 'h13, // Control+S

	ASCII_D             = 'h64,	// d
	ASCII_S_D           = 'h44,	// D
	ASCII_G_D           = 'heb,	// ë
	ASCII_S_G_D         = 'hcb,	// Ë
	ASCII_C_D           = 'h04, // Control+D

	ASCII_F             = 'h66,	// f
	ASCII_S_F           = 'h46,	// F
	// ASCII_G_F           = 'h,	// 
	// ASCII_S_G_F         = 'h,	// 
	ASCII_C_F           = 'h06, // Control+F

	ASCII_G             = 'h67,	// g
	ASCII_S_G           = 'h47,	// G
	//ASCII_G_G           = 'heb,	// 
	ASCII_S_G_G         = 'ha5,	// ¥
	ASCII_C_G           = 'h07, // Control+G

	ASCII_H             = 'h68,	// h
	ASCII_S_H           = 'h48,	// H
	ASCII_G_H           = 'hf0,	// ð
	ASCII_S_G_H         = 'hd0,	// Ð
	ASCII_C_H           = 'h08, // Control+H

	ASCII_J             = 'h6a,	// j
	ASCII_S_J           = 'h4a,	// J
	ASCII_G_J           = 'hfc,	// ü
	ASCII_S_G_J         = 'hdc,	// Ü
	ASCII_C_J           = 'h0a, // Control+J

	ASCII_K             = 'h6b,	// k
	ASCII_S_K           = 'h4b,	// K
	ASCII_G_K           = 'hef,	// ï
	ASCII_S_G_K         = 'hcf,	// Ï
	ASCII_C_K           = 'h0b, // Control+K

	ASCII_L             = 'h6c,	// l
	ASCII_S_L           = 'h4c,	// L
	//ASCII_G_L           = 'h,	// 
	//ASCII_S_G_L         = 'h,	// 
	ASCII_C_L           = 'h0c, // Control+L

	ASCII_M             = 'h6d,	// m
	ASCII_S_M           = 'h4d,	// M
	ASCII_G_M           = 'hf6,	// ö
	ASCII_S_G_M         = 'hc6,	// Ö
	ASCII_C_M           = 'h0d, // Control+M

	ASCII_PERCENT       = 'hf9,	// ù
	ASCII_S_PERCENT     = 'h25,	// %
	//ASCII_G_PERCENT     = 'h,	// 
	ASCII_S_G_PERCENT   = 'hd9,	// Ù

	ASCII_STAR          = 'h2a,	// *
	ASCII_S_STAR        = 'hb5,	// µ
	ASCII_G_STAR        = 'hb7,	// ⋅
	ASCII_S_G_STAR      = 'hd7,	// ×

	// Row 4
	//ASCII_SHIFT_LEFT    = 'h12,

	ASCII_LESS_THAN     = 'h3c,	// <
	ASCII_S_LESS_THAN   = 'h3e,	// >
	ASCII_G_LESS_THAN   = 'h9c,	// ≤
	ASCII_S_G_LESS_THAN = 'h9e,	// ≥

	ASCII_W             = 'h77,	// w
	ASCII_S_W           = 'h57,	// W
	ASCII_G_W           = 'hab,	// «
	//ASCII_S_G_W         = 'hc6,	// 
	ASCII_C_W           = 'h17, // Control+W

	ASCII_X             = 'h78,	// x
	ASCII_S_X           = 'h58,	// X
	ASCII_G_X           = 'hbb,	// »
	//ASCII_S_G_X         = 'h,	// 
	ASCII_C_X           = 'h18, // Control+X

	ASCII_C             = 'h63,	// c
	ASCII_S_C           = 'h43,	// C
	ASCII_G_C           = 'ha9,	// ©
	ASCII_S_G_C         = 'hae,	// ®
	ASCII_C_C           = 'h03, // Control+C

	ASCII_V             = 'h76,	// v
	ASCII_S_V           = 'h56,	// V
	//ASCII_G_V           = 'h,	// 
	//ASCII_S_G_V         = 'h,	// 
	ASCII_C_V           = 'h16, // Control+V

	ASCII_B             = 'h62,	// b
	ASCII_S_B           = 'h42,	// B
	//ASCII_G_B           = 'h,	// 
	//ASCII_S_G_B         = 'h,	// 
	ASCII_C_B           = 'h02, // Control+B

	ASCII_N             = 'h6e,	// n
	ASCII_S_N           = 'h4e,	// N
	ASCII_G_N           = 'hac,	// ¬
	//ASCII_S_G_N         = 'h,	// 
	ASCII_C_N           = 'h0e, // Control+N

	ASCII_COMMA         = 'h2c,	// ,
	ASCII_S_COMMA       = 'h3f,	// ?
	ASCII_G_COMMA       = 'hbf,	// ¿
	//ASCII_S_G_COMMA     = 'h,	// 

	ASCII_SEMICOLON     = 'h3b,	// ;
	ASCII_S_SEMICOLON   = 'h2e,	// .
	//ASCII_G_SEMICOLON   = 'h,	// 
	//ASCII_S_G_SEMICOLON = 'h,	// 

	ASCII_COLON         = 'h3a,	// :
	ASCII_S_COLON       = 'h2f,	// /
	ASCII_G_COLON       = 'hf7,	// ÷
	//ASCII_S_G_COLON     = 'h,	// 

	ASCII_EXCLAMATION   = 'h21,	// !
	ASCII_S_EXCLAMATION = 'ha7,	// §
	ASCII_G_EXCLAMATION = 'ha1,	// ¡
	//ASCII_S_G_EXCLAMATION = 'h,	// 

	//ASCII_SHIFT_RIGHT   = 'h,

	// Row 5
	//ASCII_CTRL_LEFT     = 'h,
	//ASCII_ALT           = 'h,

	ASCII_SPACE         = 'h20,

	// Keypad
	//ASCII_NUM           = 'h,
	ASCII_KP_MUL        = 'h2a,
	ASCII_KP_SUB        = 'h2d,

	ASCII_KP_7          = 'h37,
	ASCII_KP_8          = 'h38,
	ASCII_KP_9          = 'h39,
	ASCII_KP_ADD        = 'h2b,

	ASCII_KP_4          = 'h34,
	ASCII_KP_5          = 'h35,
	ASCII_KP_6          = 'h36,

	ASCII_KP_1          = 'h31,
	ASCII_KP_2          = 'h32,
	ASCII_KP_3          = 'h33,

	ASCII_KP_0          = 'h30,
	ASCII_KP_PERIOD     = 'h2e
	;

// Extended codes 0
localparam
	// Escape and function keys
	ASCII_E0_PRNT_SCR   = 'hff,
	ASCII_E0_PAUSE      = 'heb,

	// Row 5
	//ASCII_E0_META_LEFT  = 'h,
	//ASCII_E0_ALTGR      = 'h,
	//ASCII_E0_META_RIGHT = 'h,
	ASCII_E0_CONTEXTUAL = 'hea,
	//ASCII_E0_CTRL_RIGHT = 'h,

	// Cursor keys
	ASCII_E0_INSERT     = 'he0,
	ASCII_E0_HOME       = 'he1,
	ASCII_E0_PAGE_UP    = 'he2,
	ASCII_E0_DELETE     = 'he3,
	ASCII_E0_END        = 'he4,
	ASCII_E0_PAGE_DOWN  = 'he5,

	ASCII_E0_UP         = 'he6,
	ASCII_E0_LEFT       = 'he7,
	ASCII_E0_DOWN       = 'he8,
	ASCII_E0_RIGHT      = 'he9,

	// Keypad
	ASCII_E0_KP_DIV     = 'h2f,	// /
	ASCII_E0_KP_ENTER   = 'h0a
	;

	// ACPI keys
	//ASCII_E0_POWER      = 'h,
	//ASCII_E0_SLEEP      = 'h,
	//ASCII_E0_WAKE       = 'h,

	// Multimedia keys
	//ASCII_E0_NEXT_TRACK = 'h,
	//ASCII_E0_PREV_TRACK = 'h,
	//ASCII_E0_STOP       = 'h,
	//ASCII_E0_PLAY_PAUSE = 'h,
	//ASCII_E0_MUTE       = 'h,
	//ASCII_E0_VOLUME_UP  = 'h,
	//ASCII_E0_VOLUME_DN  = 'h,
	//ASCII_E0_MEDA_SEL   = 'h,
	//ASCII_E0_EMAIL      = 'h,
	//ASCII_E0_CALCULATOR = 'h,
	//ASCII_E0_COMPUTER   = 'h,
	//ASCII_E0_WWW_SRCH   = 'h,
	//ASCII_E0_WWW_HOME   = 'h,
	//ASCII_E0_WWW_BACK   = 'h,
	//ASCII_E0_WWW_FWRD   = 'h,
	//ASCII_E0_WWW_STOP   = 'h,
	//ASCII_E0_WWW_RFSH   = 'h,
	//ASCII_E0_WWW_FAVS   = 'h
