localparam

	CTRL_CODE_00           = 'h00, // ^@

	CTRL_CLEAR             = 'h01, // ^A
		CLEAR_SCREEN       = "!",
		CLEAR_BOL          = ")",
		CLEAR_EOL          = "(",
		CLEAR_BOD          = "+",
		CLEAR_EOD          = "*",
		CLEAR_LINE         = "-",
		CLEAR_CHARS        = "0",

	CTRL_COLOR             = 'h02, // ^B
		COLOR_FOREGROUND   = "@",
		COLOR_BACKGROUND   = "P",

	CTRL_PATTERN           = 'h03, // ^C
		FUNCTION_AND       = 'h40,
		FUNCTION_OR        = 'h41,
		FUNCTION_XOR       = 'h42,
		FUNCTION_BORDER    = 'h43,
		PATTERN_BASE       = 'h04,

	CTRL_CURSOR            = 'h04, // ^D
		CURSOR_RELATIVE    = "#",

	CTRL_ATTRIBUTE         = 'h05, // ^E
		ATTRIBUTE_RESET    = "*",
		SET_UNDERLINE_ON   = "U",
		SET_UNDERLINE_OFF  = "u",
		SET_BLINK_ON       = "B",
		SET_BLINK_OFF      = "b",
		SET_HIGHLIGHT_ON   = "H",
		SET_HIGHLIGHT_OFF  = "h",
		SET_REVERSE_ON     = "R",
		SET_REVERSE_OFF    = "r",
		SET_SIZE_NORMAL    = "0",
		SET_SIZE_DBLWIDTH  = "1",
		SET_SIZE_DBLHEIGHT = "2",
		SET_SIZE_DOUBLE    = "3",

	CTRL_PARAMETER         = 'h06, // ^F
		CURSOR_VISIBLE     = "C",
		CURSOR_EMPHASIZE   = "V",
		CURSOR_HIDDEN      = "c",

	BELL                   = 'h07, // ^G
	CTRL_CODE_08           = 'h08, // ^H
	TAB                    = 'h09, // ^I
	LF                     = 'h0a, // ^J
	CTRL_SCROLL_UP         = 'h0b, // ^K
	CTRL_SCROLL_DOWN       = 'h0c, // ^L
	CR                     = 'h0d, // ^M
	CTRL_CURSOR_UP         = 'h0e, // ^N
	CTRL_CURSOR_DOWN       = 'h0f, // ^O
	CTRL_CURSOR_LEFT       = 'h10, // ^P
	CTRL_CURSOR_RIGHT      = 'h11, // ^Q
	CTRL_REPEAT            = 'h12, // ^R
	CTRL_CHARPAGE_0        = 'h13, // ^S
	CTRL_CHARPAGE_1        = 'h14, // ^T
	CTRL_CHARPAGE_2        = 'h15, // ^U
	CTRL_CHARPAGE_3        = 'h16, // ^V
	CTRL_CHARPAGE_4        = 'h17, // ^W
	CTRL_CODE_18           = 'h18, // ^X
	CTRL_CODE_19           = 'h19, // ^Y
	CTRL_CODE_1A           = 'h1a, // ^Z
	CTRL_CODE_1B           = 'h1b, // ^[
	CTRL_CODE_1C           = 'h1c, // ^\
	CTRL_CODE_1D           = 'h1d, // ^]
	CTRL_CODE_1E           = 'h1e, // ^^
	CTRL_CODE_1F           = 'h1f; // ^_
