// From https://www.avrfreaks.net/sites/default/files/PS2%20Keyboard.pdf
// Codes are given for a french keyboard!
// Standard codes
localparam
	SCAN_BREAK         = 'hf0,

	// Escape and function keys
	SCAN_ESC           = 'h76,
	SCAN_F1            = 'h05,
	SCAN_F2            = 'h06,
	SCAN_F3            = 'h04,
	SCAN_F4            = 'h0c,
	SCAN_F5            = 'h03,
	SCAN_F6            = 'h0b,
	SCAN_F7            = 'h83,
	SCAN_F8            = 'h0a,
	SCAN_F9            = 'h01,
	SCAN_F10           = 'h09,
	SCAN_F11           = 'h78,
	SCAN_F12           = 'h07,

	SCAN_SCROLL        = 'h7e,
	SCAN_PRNT_SCR      = 'h84, // When used in combination with Alt or AltGr key

	// Row 1
	SCAN_SQUARE        = 'h0e,
	SCAN_1             = 'h16,
	SCAN_2             = 'h1e,
	SCAN_3             = 'h26,
	SCAN_4             = 'h25,
	SCAN_5             = 'h2e,
	SCAN_6             = 'h36,
	SCAN_7             = 'h3d,
	SCAN_8             = 'h3e,
	SCAN_9             = 'h46,
	SCAN_0             = 'h45,
	SCAN_RIGHT_PAREN   = 'h4e,
	SCAN_EQUAL         = 'h55,
	SCAN_BACKSPACE     = 'h66,

	// Row 2
	SCAN_TAB           = 'h0d,
	SCAN_A             = 'h15,
	SCAN_Z             = 'h1d,
	SCAN_E             = 'h24,
	SCAN_R             = 'h2d,
	SCAN_T             = 'h2c,
	SCAN_Y             = 'h35,
	SCAN_U             = 'h3c,
	SCAN_I             = 'h43,
	SCAN_O             = 'h44,
	SCAN_P             = 'h4d,
	SCAN_CIRC          = 'h54,
	SCAN_DOLLAR        = 'h5b,
	SCAN_RETURN        = 'h5a,

	// Row 3
	SCAN_CAPS_LOCK     = 'h58,
	SCAN_Q             = 'h1c,
	SCAN_S             = 'h1b,
	SCAN_D             = 'h23,
	SCAN_F             = 'h2b,
	SCAN_G             = 'h34,
	SCAN_H             = 'h33,
	SCAN_J             = 'h3b,
	SCAN_K             = 'h42,
	SCAN_L             = 'h4b,
	SCAN_M             = 'h4c,
	SCAN_PERCENT       = 'h52,
	SCAN_STAR          = 'h5d,

	// Row 4
	SCAN_SHIFT_LEFT    = 'h12,
	SCAN_LESS_THAN     = 'h61,
	SCAN_W             = 'h1a,
	SCAN_X             = 'h22,
	SCAN_C             = 'h21,
	SCAN_V             = 'h2a,
	SCAN_B             = 'h32,
	SCAN_N             = 'h31,
	SCAN_COMMA         = 'h3a,
	SCAN_SEMICOLON     = 'h41,
	SCAN_COLON         = 'h49,
	SCAN_EXCLAMATION   = 'h4a,
	SCAN_SHIFT_RIGHT   = 'h59,

	// Row 5
	SCAN_CTRL_LEFT     = 'h14,
	SCAN_ALT           = 'h11,
	SCAN_SPACE         = 'h29,

	// Keypad
	SCAN_NUM           = 'h77,
	SCAN_KP_MUL        = 'h7c,
	SCAN_KP_SUB        = 'h7b,

	SCAN_KP_7          = 'h6c,
	SCAN_KP_8          = 'h75,
	SCAN_KP_9          = 'h7d,
	SCAN_KP_ADD        = 'h79,

	SCAN_KP_4          = 'h6b,
	SCAN_KP_5          = 'h73,
	SCAN_KP_6          = 'h74,

	SCAN_KP_1          = 'h69,
	SCAN_KP_2          = 'h72,
	SCAN_KP_3          = 'h7a,

	SCAN_KP_0          = 'h70,
	SCAN_KP_PERIOD     = 'h71
	;

// Extended codes 0
localparam
	SCAN_E0            = 'he0,
	SCAN_E0_IGNORE     = 'h12,

	// Escape and function keys
	SCAN_E0_PRNT_SCR   = 'h7c,
	SCAN_E0_PAUSE      = 'h7e, // When used in combination with Ctrl key

	// Row 5
	SCAN_E0_META_LEFT  = 'h1f,
	SCAN_E0_ALTGR      = 'h11,
	SCAN_E0_META_RIGHT = 'h27,
	SCAN_E0_CONTEXTUAL = 'h2f,
	SCAN_E0_CTRL_RIGHT = 'h14,

	// Cursor keys
	SCAN_E0_INSERT     = 'h70,
	SCAN_E0_HOME       = 'h6c,
	SCAN_E0_PAGE_UP    = 'h7d,
	SCAN_E0_DELETE     = 'h71,
	SCAN_E0_END        = 'h69,
	SCAN_E0_PAGE_DOWN  = 'h7a,

	SCAN_E0_UP         = 'h75,
	SCAN_E0_LEFT       = 'h6b,
	SCAN_E0_DOWN       = 'h72,
	SCAN_E0_RIGHT      = 'h74,

	// Keypad
	SCAN_E0_KP_DIV     = 'h4a,
	SCAN_E0_KP_ENTER   = 'h5a,

	// ACPI keys
	SCAN_E0_POWER      = 'h37,
	SCAN_E0_SLEEP      = 'h3f,
	SCAN_E0_WAKE       = 'h5e,

	// Multimedia keys
	SCAN_E0_NEXT_TRACK = 'h4d,
	SCAN_E0_PREV_TRACK = 'h15,
	SCAN_E0_STOP       = 'h3b,
	SCAN_E0_PLAY_PAUSE = 'h34,
	SCAN_E0_MUTE       = 'h23,
	SCAN_E0_VOLUME_UP  = 'h32,
	SCAN_E0_VOLUME_DN  = 'h21,
	SCAN_E0_MEDA_SEL   = 'h50,
	SCAN_E0_EMAIL      = 'h48,
	SCAN_E0_CALCULATOR = 'h2b,
	SCAN_E0_COMPUTER   = 'h40,
	SCAN_E0_WWW_SRCH   = 'h10,
	SCAN_E0_WWW_HOME   = 'h3a,
	SCAN_E0_WWW_BACK   = 'h38,
	SCAN_E0_WWW_FWRD   = 'h30,
	SCAN_E0_WWW_STOP   = 'h28,
	SCAN_E0_WWW_RFSH   = 'h20,
	SCAN_E0_WWW_FAVS   = 'h18
	;

// Extended codes 1
localparam
	SCAN_E1            = 'he1,
	SCAN_E1_PAUSE_1    = 'h14,
	SCAN_E1_PAUSE_2    = 'h77
	;