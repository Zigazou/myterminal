module ps2_keyboard_ascii (
	input wire clk,
	input wire reset, 

	input wire keyboard_state_ready,
	input wire [7:0] scan_code_in,
	input wire scan_code_extended,
	input wire keyboard_shift,
	input wire keyboard_alt,
	input wire keyboard_altgr,
	input wire keyboard_ctrl,
	input wire keyboard_meta,
	
	output reg keyboard_ascii_ready = 0,
	output reg [7:0] keyboard_ascii
);

`include "ps2_scan_code_set2_fr.v"
`include "ps2_ascii_codes.v"

// Definitions to make code easier to read and understand.
localparam
	HIGH  = 1'b1,
	LOW   = 1'b0,

	TRUE  = HIGH,
	FALSE = LOW;

wire [7:0] extended_modifier = {
	3'b010,
	keyboard_meta,
	keyboard_altgr,
	keyboard_alt,
	keyboard_ctrl,
	keyboard_shift
};

localparam
	SHIFT       = 5'b00001,
	CTRL        = 5'b00010,
	ALT         = 5'b00100,
	ALTGR       = 5'b01000,
	META        = 5'b10000,
	SHIFT_ALTGR = 5'b01001
	;

wire [4:0] modifier = {
	keyboard_meta,
	keyboard_altgr,
	keyboard_alt,
	keyboard_ctrl,
	keyboard_shift
};

reg [23:0] code_sequence = 24'h00_00_00;

function [23:0] make_n;
	input wire [7:0] ascii;
	make_n = { 16'h0000, ascii };
endfunction

function [23:0] make_e;
	input wire [7:0] ascii;
	make_e = { ascii, extended_modifier, 8'h1f };
endfunction

function [23:0] normal;
	input wire [7:0] scan_code;

	case (scan_code)
		// Escape and function keys
		SCAN_ESC: normal = make_n(ASCII_ESC);
		SCAN_F1: normal = make_e(ASCII_F1);
		SCAN_F2: normal = make_e(ASCII_F2);
		SCAN_F3: normal = make_e(ASCII_F3);
		SCAN_F4: normal = make_e(ASCII_F4);
		SCAN_F5: normal = make_e(ASCII_F5);
		SCAN_F6: normal = make_e(ASCII_F6);
		SCAN_F7: normal = make_e(ASCII_F7);
		SCAN_F8: normal = make_e(ASCII_F8);
		SCAN_F9: normal = make_e(ASCII_F9);
		SCAN_F10: normal = make_e(ASCII_F10);
		SCAN_F11: normal = make_e(ASCII_F11);
		SCAN_F12: normal = make_e(ASCII_F12);
		SCAN_SCROLL: normal = make_e(ASCII_SCROLL);
		SCAN_PRNT_SCR: normal = make_e(ASCII_PRNT_SCR);

		SCAN_SQUARE: case (modifier)
			SHIFT: normal = make_n(ASCII_S_SQUARE);
			ALTGR: normal = make_n(ASCII_G_SQUARE);
			default: normal = make_n(ASCII_SQUARE);
		endcase

		SCAN_1: case (modifier)
			SHIFT: normal = make_n(ASCII_S_1);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_1);
			default: normal = make_n(ASCII_1);
		endcase

		SCAN_2: case (modifier)
			SHIFT: normal = make_n(ASCII_S_2);
			ALTGR: normal = make_n(ASCII_G_2);
			default: normal = make_n(ASCII_2);
		endcase

		SCAN_3: case (modifier)
			SHIFT: normal = make_n(ASCII_S_3);
			ALTGR: normal = make_n(ASCII_G_3);
			default: normal = make_n(ASCII_3);
		endcase

		SCAN_4: case (modifier)
			SHIFT: normal = make_n(ASCII_S_4);
			ALTGR: normal = make_n(ASCII_G_4);
			default: normal = make_n(ASCII_4);
		endcase

		SCAN_5: case (modifier)
			SHIFT: normal = make_n(ASCII_S_5);
			ALTGR: normal = make_n(ASCII_G_5);
			default: normal = make_n(ASCII_5);
		endcase

		SCAN_6: case (modifier)
			SHIFT: normal = make_n(ASCII_S_6);
			ALTGR: normal = make_n(ASCII_G_6);
			default: normal = make_n(ASCII_6);
		endcase

		SCAN_7: case (modifier)
			SHIFT: normal = make_n(ASCII_S_7);
			ALTGR: normal = make_n(ASCII_G_7);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_7);
			default: normal = make_n(ASCII_7);
		endcase

		SCAN_8: case (modifier)
			SHIFT: normal = make_n(ASCII_S_8);
			ALTGR: normal = make_n(ASCII_G_8);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_8);
			CTRL: normal = make_n(ASCII_C_8);
			default: normal = make_n(ASCII_8);
		endcase

		SCAN_9: case (modifier)
			SHIFT: normal = make_n(ASCII_S_9);
			ALTGR: normal = make_n(ASCII_G_9);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_9);
			default: normal = make_n(ASCII_9);
		endcase

		SCAN_0: case (modifier)
			SHIFT: normal = make_n(ASCII_S_0);
			ALTGR: normal = make_n(ASCII_G_0);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_0);
			default: normal = make_n(ASCII_0);
		endcase

		SCAN_RIGHT_PAREN: case (modifier)
			SHIFT: normal = make_n(ASCII_S_RIGHT_PAREN);
			ALTGR: normal = make_n(ASCII_G_RIGHT_PAREN);
			default: normal = make_n(ASCII_RIGHT_PAREN);
		endcase

		SCAN_EQUAL: case (modifier)
			SHIFT: normal = make_n(ASCII_S_EQUAL);
			ALTGR: normal = make_n(ASCII_G_EQUAL);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_EQUAL);
			default: normal = make_n(ASCII_EQUAL);
		endcase

		SCAN_BACKSPACE: normal = make_n(ASCII_BACKSPACE);

		SCAN_TAB: normal = make_n(ASCII_TAB);

		SCAN_A: case (modifier)
			SHIFT: normal = make_n(ASCII_S_A);
			ALTGR: normal = make_n(ASCII_G_A);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_A);
			CTRL: normal = make_n(ASCII_C_A);
			default: normal = make_n(ASCII_A);
		endcase

		SCAN_Z: case (modifier)
			SHIFT: normal = make_n(ASCII_S_Z);
			ALTGR: normal = make_n(ASCII_G_Z);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_Z);
			CTRL: normal = make_n(ASCII_C_Z);
			default: normal = make_n(ASCII_Z);
		endcase

		SCAN_E: case (modifier)
			SHIFT: normal = make_n(ASCII_S_E);
			ALTGR: normal = make_n(ASCII_G_E);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_E);
			CTRL: normal = make_n(ASCII_C_E);
			default: normal = make_n(ASCII_E);
		endcase

		SCAN_R: case (modifier)
			SHIFT: normal = make_n(ASCII_S_R);
			ALTGR: normal = make_n(ASCII_G_R);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_R);
			CTRL: normal = make_n(ASCII_C_R);
			default: normal = make_n(ASCII_R);
		endcase

		SCAN_T: case (modifier)
			SHIFT: normal = make_n(ASCII_S_T);
			CTRL: normal = make_n(ASCII_C_T);
			default: normal = make_n(ASCII_T);
		endcase

		SCAN_Y: case (modifier)
			SHIFT: normal = make_n(ASCII_S_Y);
			ALTGR: normal = make_n(ASCII_G_Y);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_Y);
			CTRL: normal = make_n(ASCII_C_Y);
			default: normal = make_n(ASCII_Y);
		endcase

		SCAN_U: case (modifier)
			SHIFT: normal = make_n(ASCII_S_U);
			ALTGR: normal = make_n(ASCII_G_U);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_U);
			CTRL: normal = make_n(ASCII_C_U);
			default: normal = make_n(ASCII_U);
		endcase

		SCAN_I: case (modifier)
			SHIFT: normal = make_n(ASCII_S_I);
			ALTGR: normal = make_n(ASCII_G_I);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_I);
			CTRL: normal = make_n(ASCII_C_I);
			default: normal = make_n(ASCII_I);
		endcase

		SCAN_O: case (modifier)
			SHIFT: normal = make_n(ASCII_S_O);
			ALTGR: normal = make_n(ASCII_G_O);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_O);
			CTRL: normal = make_n(ASCII_C_O);
			default: normal = make_n(ASCII_O);
		endcase

		SCAN_P: case (modifier)
			SHIFT: normal = make_n(ASCII_S_P);
			ALTGR: normal = make_n(ASCII_G_P);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_P);
			CTRL: normal = make_n(ASCII_C_P);
			default: normal = make_n(ASCII_P);
		endcase

		SCAN_CIRC: case (modifier)
			SHIFT: normal = make_n(ASCII_S_CIRC);
			ALTGR: normal = make_n(ASCII_G_CIRC);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_CIRC);
			CTRL: normal = make_n(ASCII_C_CIRC);
			default: normal = make_n(ASCII_CIRC);
		endcase

		SCAN_DOLLAR: case (modifier)
			SHIFT: normal = make_n(ASCII_S_DOLLAR);
			ALTGR: normal = make_n(ASCII_G_DOLLAR);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_DOLLAR);
			default: normal = make_n(ASCII_DOLLAR);
		endcase

		SCAN_RETURN: normal = make_n(ASCII_RETURN);

		SCAN_Q: case (modifier)
			SHIFT: normal = make_n(ASCII_S_Q);
			ALTGR: normal = make_n(ASCII_G_Q);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_Q);
			CTRL: normal = make_n(ASCII_C_Q);
			default: normal = make_n(ASCII_Q);
		endcase

		SCAN_S: case (modifier)
			SHIFT: normal = make_n(ASCII_S_S);
			ALTGR: normal = make_n(ASCII_G_S);
			CTRL: normal = make_n(ASCII_C_S);
			default: normal = make_n(ASCII_S);
		endcase

		SCAN_D: case (modifier)
			SHIFT: normal = make_n(ASCII_S_D);
			ALTGR: normal = make_n(ASCII_G_D);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_D);
			CTRL: normal = make_n(ASCII_C_D);
			default: normal = make_n(ASCII_D);
		endcase

		SCAN_F: case (modifier)
			SHIFT: normal = make_n(ASCII_S_F);
			CTRL: normal = make_n(ASCII_C_F);
			default: normal = make_n(ASCII_F);
		endcase

		SCAN_G: case (modifier)
			SHIFT: normal = make_n(ASCII_S_G);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_G);
			CTRL: normal = make_n(ASCII_C_G);
			default: normal = make_n(ASCII_G);
		endcase

		SCAN_H: case (modifier)
			SHIFT: normal = make_n(ASCII_S_H);
			ALTGR: normal = make_n(ASCII_G_H);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_H);
			CTRL: normal = make_n(ASCII_C_H);
			default: normal = make_n(ASCII_H);
		endcase

		SCAN_J: case (modifier)
			SHIFT: normal = make_n(ASCII_S_J);
			ALTGR: normal = make_n(ASCII_G_J);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_J);
			CTRL: normal = make_n(ASCII_C_J);
			default: normal = make_n(ASCII_J);
		endcase

		SCAN_K: case (modifier)
			SHIFT: normal = make_n(ASCII_S_K);
			ALTGR: normal = make_n(ASCII_G_K);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_K);
			CTRL: normal = make_n(ASCII_C_K);
			default: normal = make_n(ASCII_K);
		endcase

		SCAN_L: case (modifier)
			SHIFT: normal = make_n(ASCII_S_L);
			CTRL: normal = make_n(ASCII_C_L);
			default: normal = make_n(ASCII_L);
		endcase

		SCAN_M: case (modifier)
			SHIFT: normal = make_n(ASCII_S_M);
			ALTGR: normal = make_n(ASCII_G_M);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_M);
			CTRL: normal = make_n(ASCII_C_M);
			default: normal = make_n(ASCII_M);
		endcase

		SCAN_PERCENT: case (modifier)
			SHIFT: normal = make_n(ASCII_S_PERCENT);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_PERCENT);
			default: normal = make_n(ASCII_PERCENT);
		endcase

		SCAN_STAR: case (modifier)
			SHIFT: normal = make_n(ASCII_S_STAR);
			ALTGR: normal = make_n(ASCII_G_STAR);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_STAR);
			default: normal = make_n(ASCII_STAR);
		endcase

		SCAN_LESS_THAN: case (modifier)
			SHIFT: normal = make_n(ASCII_S_LESS_THAN);
			ALTGR: normal = make_n(ASCII_G_LESS_THAN);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_LESS_THAN);
			default: normal = make_n(ASCII_LESS_THAN);
		endcase

		SCAN_W: case (modifier)
			SHIFT: normal = make_n(ASCII_S_W);
			ALTGR: normal = make_n(ASCII_G_W);
			CTRL: normal = make_n(ASCII_C_W);
			default: normal = make_n(ASCII_W);
		endcase

		SCAN_X: case (modifier)
			SHIFT: normal = make_n(ASCII_S_X);
			ALTGR: normal = make_n(ASCII_G_X);
			CTRL: normal = make_n(ASCII_C_X);
			default: normal = make_n(ASCII_X);
		endcase

		SCAN_C: case (modifier)
			SHIFT: normal = make_n(ASCII_S_C);
			ALTGR: normal = make_n(ASCII_G_C);
			SHIFT_ALTGR: normal = make_n(ASCII_S_G_C);
			CTRL: normal = make_n(ASCII_C_C);
			default: normal = make_n(ASCII_C);
		endcase

		SCAN_V: case (modifier)
			SHIFT: normal = make_n(ASCII_S_V);
			CTRL: normal = make_n(ASCII_C_V);
			default: normal = make_n(ASCII_V);
		endcase

		SCAN_B: case (modifier)
			SHIFT: normal = make_n(ASCII_S_B);
			CTRL: normal = make_n(ASCII_C_B);
			default: normal = make_n(ASCII_B);
		endcase

		SCAN_N: case(modifier)
			SHIFT: normal = make_n(ASCII_S_N);
			ALTGR: normal = make_n(ASCII_G_N);
			CTRL: normal = make_n(ASCII_C_N);
			default: normal = make_n(ASCII_N);
		endcase

		SCAN_COMMA: case (modifier)
			SHIFT: normal = make_n(ASCII_S_COMMA);
			ALTGR: normal = make_n(ASCII_G_COMMA);
			default: normal = make_n(ASCII_COMMA);
		endcase

		SCAN_SEMICOLON: case (modifier)
			SHIFT: normal = make_n(ASCII_S_SEMICOLON);
			default: normal = make_n(ASCII_SEMICOLON);
		endcase

		SCAN_COLON: case (modifier)
			SHIFT: normal = make_n(ASCII_S_COLON);
			ALTGR: normal = make_n(ASCII_G_COLON);
			default: normal = make_n(ASCII_COLON);
		endcase

		SCAN_EXCLAMATION: case (modifier)
			SHIFT: normal = make_n(ASCII_S_EXCLAMATION);
			ALTGR: normal = make_n(ASCII_G_EXCLAMATION);
			default: normal = make_n(ASCII_EXCLAMATION);
		endcase

		SCAN_SPACE: normal = make_n(ASCII_SPACE);

		SCAN_KP_MUL: normal = make_n(ASCII_KP_MUL);
		SCAN_KP_SUB: normal = make_n(ASCII_KP_SUB);
		SCAN_KP_7: normal = make_n(ASCII_KP_7);
		SCAN_KP_8: normal = make_n(ASCII_KP_8);
		SCAN_KP_9: normal = make_n(ASCII_KP_9);
		SCAN_KP_ADD: normal = make_n(ASCII_KP_ADD);
		SCAN_KP_4: normal = make_n(ASCII_KP_4);
		SCAN_KP_5: normal = make_n(ASCII_KP_5);
		SCAN_KP_6: normal = make_n(ASCII_KP_6);
		SCAN_KP_1: normal = make_n(ASCII_KP_1);
		SCAN_KP_2: normal = make_n(ASCII_KP_2);
		SCAN_KP_3: normal = make_n(ASCII_KP_3);
		SCAN_KP_0: normal = make_n(ASCII_KP_0);
		SCAN_KP_PERIOD: normal = make_n(ASCII_KP_PERIOD);

		default: normal = make_n(8'h00);
	endcase
endfunction

function [23:0] extended;
	input wire [7:0] scan_code;

	case (scan_code)
		SCAN_E0_PRNT_SCR: extended = make_e(ASCII_E0_PRNT_SCR);
		SCAN_E0_PAUSE: extended = make_e(ASCII_E0_PAUSE);
		SCAN_E0_CONTEXTUAL: extended = make_e(ASCII_E0_CONTEXTUAL);

		SCAN_E0_INSERT: extended = make_e(ASCII_E0_INSERT);
		SCAN_E0_HOME: extended = make_e(ASCII_E0_HOME);
		SCAN_E0_PAGE_UP: extended = make_e(ASCII_E0_PAGE_UP);
		SCAN_E0_DELETE: extended = make_e(ASCII_E0_DELETE);
		SCAN_E0_END: extended = make_e(ASCII_E0_END);
		SCAN_E0_PAGE_DOWN: extended = make_e(ASCII_E0_PAGE_DOWN);
		SCAN_E0_UP: extended = make_e(ASCII_E0_UP);
		SCAN_E0_LEFT: extended = make_e(ASCII_E0_LEFT);
		SCAN_E0_DOWN: extended = make_e(ASCII_E0_DOWN);
		SCAN_E0_RIGHT: extended = make_e(ASCII_E0_RIGHT);

		SCAN_E0_KP_DIV: extended = make_n(ASCII_E0_KP_DIV);
		SCAN_E0_KP_ENTER: extended = make_n(ASCII_E0_KP_ENTER);

		default: extended = make_n(8'h00);
	endcase
endfunction

always @(posedge clk)
	if (reset) begin
		keyboard_ascii_ready <= FALSE;
		keyboard_ascii <= 'd0;
		code_sequence <= 'd0;
	end else if (keyboard_state_ready) begin
		keyboard_ascii_ready <= FALSE;
		if (scan_code_extended)
			code_sequence <= extended(scan_code_in);
		else
			code_sequence <= normal(scan_code_in);
	end else if (code_sequence[7:0] != 8'h00) begin
		keyboard_ascii_ready <= TRUE;
		keyboard_ascii <= code_sequence[7:0];
		code_sequence <= { 8'h00, code_sequence[23:8] };
	end else
		keyboard_ascii_ready <= FALSE;
endmodule
