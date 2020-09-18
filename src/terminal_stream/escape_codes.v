localparam
	CR                     = 'h0d, // ^M
	LF                     = 'h0a, // ^J

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
	CTRL_CHARPAGE          = 'h03, // ^C
		CHARPAGE_RESET     = "_",
	CTRL_CURSOR            = 'h04, // ^D
		CURSOR_RELATIVE    = "#",
	CTRL_ATTRIBUTE         = 'h05, // ^E
		ATTRIBUTE_RESET    = "*",
		SET_UNDERLINE_ON   = "U",
		SET_UNDERLINE_OFF  = "u",
		SET_BLINK_ON       = "B",
		SET_BLINK_OFF      = "b",
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

	CTRL_CURSOR_UP         = 'h0e, // ^N
	CTRL_CURSOR_DOWN       = 'h0f, // ^O
	CTRL_CURSOR_LEFT       = 'h10, // ^P
	CTRL_CURSOR_RIGHT      = 'h11, // ^Q

	CTRL_REPEAT            = 'h12; // ^R

