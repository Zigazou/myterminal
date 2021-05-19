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

	output reg [31:0] sequence_out = 0,	
	output reg [2:0] sequence_out_count = 0
);

`include "constant.v"
`include "ps2_scan_code_set2_fr.v"
`include "ps2_ascii_codes.v"

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

task send_nothing;
	begin
		sequence_out <= 32'h00000000;
		sequence_out_count <= 'd0;
	end
endtask

task send_normal;
	input wire [7:0] ascii;
	begin
		sequence_out <= { 24'h0000, ascii };
		sequence_out_count <= 'd1;
	end
endtask

task send_extended;
	input wire [7:0] ascii;
	begin
		sequence_out <= { 8'h00, ascii, extended_modifier, 8'h1f };
		sequence_out_count <= 'd3;
	end
endtask

task execute_normal;
	input wire [7:0] scan_code;

	case (scan_code)
		// Escape and function keys
		SCAN_ESC: send_normal(ASCII_ESC);
		SCAN_F1: send_extended(ASCII_F1);
		SCAN_F2: send_extended(ASCII_F2);
		SCAN_F3: send_extended(ASCII_F3);
		SCAN_F4: send_extended(ASCII_F4);
		SCAN_F5: send_extended(ASCII_F5);
		SCAN_F6: send_extended(ASCII_F6);
		SCAN_F7: send_extended(ASCII_F7);
		SCAN_F8: send_extended(ASCII_F8);
		SCAN_F9: send_extended(ASCII_F9);
		SCAN_F10: send_extended(ASCII_F10);
		SCAN_F11: send_extended(ASCII_F11);
		SCAN_F12: send_extended(ASCII_F12);
		SCAN_SCROLL: send_extended(ASCII_SCROLL);
		SCAN_PRNT_SCR: send_extended(ASCII_PRNT_SCR);

		SCAN_SQUARE: case (modifier)
			SHIFT: send_normal(ASCII_S_SQUARE);
			ALTGR: send_normal(ASCII_G_SQUARE);
			default: send_normal(ASCII_SQUARE);
		endcase

		SCAN_1: case (modifier)
			SHIFT: send_normal(ASCII_S_1);
			SHIFT_ALTGR: send_normal(ASCII_S_G_1);
			default: send_normal(ASCII_1);
		endcase

		SCAN_2: case (modifier)
			SHIFT: send_normal(ASCII_S_2);
			ALTGR: send_normal(ASCII_G_2);
			default: send_normal(ASCII_2);
		endcase

		SCAN_3: case (modifier)
			SHIFT: send_normal(ASCII_S_3);
			ALTGR: send_normal(ASCII_G_3);
			default: send_normal(ASCII_3);
		endcase

		SCAN_4: case (modifier)
			SHIFT: send_normal(ASCII_S_4);
			ALTGR: send_normal(ASCII_G_4);
			default: send_normal(ASCII_4);
		endcase

		SCAN_5: case (modifier)
			SHIFT: send_normal(ASCII_S_5);
			ALTGR: send_normal(ASCII_G_5);
			default: send_normal(ASCII_5);
		endcase

		SCAN_6: case (modifier)
			SHIFT: send_normal(ASCII_S_6);
			ALTGR: send_normal(ASCII_G_6);
			default: send_normal(ASCII_6);
		endcase

		SCAN_7: case (modifier)
			SHIFT: send_normal(ASCII_S_7);
			ALTGR: send_normal(ASCII_G_7);
			SHIFT_ALTGR: send_normal(ASCII_S_G_7);
			default: send_normal(ASCII_7);
		endcase

		SCAN_8: case (modifier)
			SHIFT: send_normal(ASCII_S_8);
			ALTGR: send_normal(ASCII_G_8);
			SHIFT_ALTGR: send_normal(ASCII_S_G_8);
			CTRL: send_normal(ASCII_C_8);
			default: send_normal(ASCII_8);
		endcase

		SCAN_9: case (modifier)
			SHIFT: send_normal(ASCII_S_9);
			ALTGR: send_normal(ASCII_G_9);
			SHIFT_ALTGR: send_normal(ASCII_S_G_9);
			default: send_normal(ASCII_9);
		endcase

		SCAN_0: case (modifier)
			SHIFT: send_normal(ASCII_S_0);
			ALTGR: send_normal(ASCII_G_0);
			SHIFT_ALTGR: send_normal(ASCII_S_G_0);
			default: send_normal(ASCII_0);
		endcase

		SCAN_RIGHT_PAREN: case (modifier)
			SHIFT: send_normal(ASCII_S_RIGHT_PAREN);
			ALTGR: send_normal(ASCII_G_RIGHT_PAREN);
			default: send_normal(ASCII_RIGHT_PAREN);
		endcase

		SCAN_EQUAL: case (modifier)
			SHIFT: send_normal(ASCII_S_EQUAL);
			ALTGR: send_normal(ASCII_G_EQUAL);
			SHIFT_ALTGR: send_normal(ASCII_S_G_EQUAL);
			default: send_normal(ASCII_EQUAL);
		endcase

		SCAN_BACKSPACE: send_normal(ASCII_BACKSPACE);

		SCAN_TAB: send_normal(ASCII_TAB);

		SCAN_A: case (modifier)
			SHIFT: send_normal(ASCII_S_A);
			ALTGR: send_normal(ASCII_G_A);
			SHIFT_ALTGR: send_normal(ASCII_S_G_A);
			CTRL: send_normal(ASCII_C_A);
			default: send_normal(ASCII_A);
		endcase

		SCAN_Z: case (modifier)
			SHIFT: send_normal(ASCII_S_Z);
			ALTGR: send_normal(ASCII_G_Z);
			SHIFT_ALTGR: send_normal(ASCII_S_G_Z);
			CTRL: send_normal(ASCII_C_Z);
			default: send_normal(ASCII_Z);
		endcase

		SCAN_E: case (modifier)
			SHIFT: send_normal(ASCII_S_E);
			ALTGR: send_normal(ASCII_G_E);
			SHIFT_ALTGR: send_normal(ASCII_S_G_E);
			CTRL: send_normal(ASCII_C_E);
			default: send_normal(ASCII_E);
		endcase

		SCAN_R: case (modifier)
			SHIFT: send_normal(ASCII_S_R);
			ALTGR: send_normal(ASCII_G_R);
			SHIFT_ALTGR: send_normal(ASCII_S_G_R);
			CTRL: send_normal(ASCII_C_R);
			default: send_normal(ASCII_R);
		endcase

		SCAN_T: case (modifier)
			SHIFT: send_normal(ASCII_S_T);
			CTRL: send_normal(ASCII_C_T);
			default: send_normal(ASCII_T);
		endcase

		SCAN_Y: case (modifier)
			SHIFT: send_normal(ASCII_S_Y);
			ALTGR: send_normal(ASCII_G_Y);
			SHIFT_ALTGR: send_normal(ASCII_S_G_Y);
			CTRL: send_normal(ASCII_C_Y);
			default: send_normal(ASCII_Y);
		endcase

		SCAN_U: case (modifier)
			SHIFT: send_normal(ASCII_S_U);
			ALTGR: send_normal(ASCII_G_U);
			SHIFT_ALTGR: send_normal(ASCII_S_G_U);
			CTRL: send_normal(ASCII_C_U);
			default: send_normal(ASCII_U);
		endcase

		SCAN_I: case (modifier)
			SHIFT: send_normal(ASCII_S_I);
			ALTGR: send_normal(ASCII_G_I);
			SHIFT_ALTGR: send_normal(ASCII_S_G_I);
			CTRL: send_normal(ASCII_C_I);
			default: send_normal(ASCII_I);
		endcase

		SCAN_O: case (modifier)
			SHIFT: send_normal(ASCII_S_O);
			ALTGR: send_normal(ASCII_G_O);
			SHIFT_ALTGR: send_normal(ASCII_S_G_O);
			CTRL: send_normal(ASCII_C_O);
			default: send_normal(ASCII_O);
		endcase

		SCAN_P: case (modifier)
			SHIFT: send_normal(ASCII_S_P);
			ALTGR: send_normal(ASCII_G_P);
			SHIFT_ALTGR: send_normal(ASCII_S_G_P);
			CTRL: send_normal(ASCII_C_P);
			default: send_normal(ASCII_P);
		endcase

		SCAN_CIRC: case (modifier)
			SHIFT: send_normal(ASCII_S_CIRC);
			ALTGR: send_normal(ASCII_G_CIRC);
			SHIFT_ALTGR: send_normal(ASCII_S_G_CIRC);
			CTRL: send_normal(ASCII_C_CIRC);
			default: send_normal(ASCII_CIRC);
		endcase

		SCAN_DOLLAR: case (modifier)
			SHIFT: send_normal(ASCII_S_DOLLAR);
			ALTGR: send_normal(ASCII_G_DOLLAR);
			SHIFT_ALTGR: send_normal(ASCII_S_G_DOLLAR);
			default: send_normal(ASCII_DOLLAR);
		endcase

		SCAN_RETURN: send_normal(ASCII_RETURN);

		SCAN_Q: case (modifier)
			SHIFT: send_normal(ASCII_S_Q);
			ALTGR: send_normal(ASCII_G_Q);
			SHIFT_ALTGR: send_normal(ASCII_S_G_Q);
			CTRL: send_normal(ASCII_C_Q);
			default: send_normal(ASCII_Q);
		endcase

		SCAN_S: case (modifier)
			SHIFT: send_normal(ASCII_S_S);
			ALTGR: send_normal(ASCII_G_S);
			CTRL: send_normal(ASCII_C_S);
			default: send_normal(ASCII_S);
		endcase

		SCAN_D: case (modifier)
			SHIFT: send_normal(ASCII_S_D);
			ALTGR: send_normal(ASCII_G_D);
			SHIFT_ALTGR: send_normal(ASCII_S_G_D);
			CTRL: send_normal(ASCII_C_D);
			default: send_normal(ASCII_D);
		endcase

		SCAN_F: case (modifier)
			SHIFT: send_normal(ASCII_S_F);
			CTRL: send_normal(ASCII_C_F);
			default: send_normal(ASCII_F);
		endcase

		SCAN_G: case (modifier)
			SHIFT: send_normal(ASCII_S_G);
			SHIFT_ALTGR: send_normal(ASCII_S_G_G);
			CTRL: send_normal(ASCII_C_G);
			default: send_normal(ASCII_G);
		endcase

		SCAN_H: case (modifier)
			SHIFT: send_normal(ASCII_S_H);
			ALTGR: send_normal(ASCII_G_H);
			SHIFT_ALTGR: send_normal(ASCII_S_G_H);
			CTRL: send_normal(ASCII_C_H);
			default: send_normal(ASCII_H);
		endcase

		SCAN_J: case (modifier)
			SHIFT: send_normal(ASCII_S_J);
			ALTGR: send_normal(ASCII_G_J);
			SHIFT_ALTGR: send_normal(ASCII_S_G_J);
			CTRL: send_normal(ASCII_C_J);
			default: send_normal(ASCII_J);
		endcase

		SCAN_K: case (modifier)
			SHIFT: send_normal(ASCII_S_K);
			ALTGR: send_normal(ASCII_G_K);
			SHIFT_ALTGR: send_normal(ASCII_S_G_K);
			CTRL: send_normal(ASCII_C_K);
			default: send_normal(ASCII_K);
		endcase

		SCAN_L: case (modifier)
			SHIFT: send_normal(ASCII_S_L);
			CTRL: send_normal(ASCII_C_L);
			default: send_normal(ASCII_L);
		endcase

		SCAN_M: case (modifier)
			SHIFT: send_normal(ASCII_S_M);
			ALTGR: send_normal(ASCII_G_M);
			SHIFT_ALTGR: send_normal(ASCII_S_G_M);
			CTRL: send_normal(ASCII_C_M);
			default: send_normal(ASCII_M);
		endcase

		SCAN_PERCENT: case (modifier)
			SHIFT: send_normal(ASCII_S_PERCENT);
			SHIFT_ALTGR: send_normal(ASCII_S_G_PERCENT);
			default: send_normal(ASCII_PERCENT);
		endcase

		SCAN_STAR: case (modifier)
			SHIFT: send_normal(ASCII_S_STAR);
			ALTGR: send_normal(ASCII_G_STAR);
			SHIFT_ALTGR: send_normal(ASCII_S_G_STAR);
			default: send_normal(ASCII_STAR);
		endcase

		SCAN_LESS_THAN: case (modifier)
			SHIFT: send_normal(ASCII_S_LESS_THAN);
			ALTGR: send_normal(ASCII_G_LESS_THAN);
			SHIFT_ALTGR: send_normal(ASCII_S_G_LESS_THAN);
			default: send_normal(ASCII_LESS_THAN);
		endcase

		SCAN_W: case (modifier)
			SHIFT: send_normal(ASCII_S_W);
			ALTGR: send_normal(ASCII_G_W);
			CTRL: send_normal(ASCII_C_W);
			default: send_normal(ASCII_W);
		endcase

		SCAN_X: case (modifier)
			SHIFT: send_normal(ASCII_S_X);
			ALTGR: send_normal(ASCII_G_X);
			CTRL: send_normal(ASCII_C_X);
			default: send_normal(ASCII_X);
		endcase

		SCAN_C: case (modifier)
			SHIFT: send_normal(ASCII_S_C);
			ALTGR: send_normal(ASCII_G_C);
			SHIFT_ALTGR: send_normal(ASCII_S_G_C);
			CTRL: send_normal(ASCII_C_C);
			default: send_normal(ASCII_C);
		endcase

		SCAN_V: case (modifier)
			SHIFT: send_normal(ASCII_S_V);
			CTRL: send_normal(ASCII_C_V);
			default: send_normal(ASCII_V);
		endcase

		SCAN_B: case (modifier)
			SHIFT: send_normal(ASCII_S_B);
			CTRL: send_normal(ASCII_C_B);
			default: send_normal(ASCII_B);
		endcase

		SCAN_N: case(modifier)
			SHIFT: send_normal(ASCII_S_N);
			ALTGR: send_normal(ASCII_G_N);
			CTRL: send_normal(ASCII_C_N);
			default: send_normal(ASCII_N);
		endcase

		SCAN_COMMA: case (modifier)
			SHIFT: send_normal(ASCII_S_COMMA);
			ALTGR: send_normal(ASCII_G_COMMA);
			default: send_normal(ASCII_COMMA);
		endcase

		SCAN_SEMICOLON: case (modifier)
			SHIFT: send_normal(ASCII_S_SEMICOLON);
			default: send_normal(ASCII_SEMICOLON);
		endcase

		SCAN_COLON: case (modifier)
			SHIFT: send_normal(ASCII_S_COLON);
			ALTGR: send_normal(ASCII_G_COLON);
			default: send_normal(ASCII_COLON);
		endcase

		SCAN_EXCLAMATION: case (modifier)
			SHIFT: send_normal(ASCII_S_EXCLAMATION);
			ALTGR: send_normal(ASCII_G_EXCLAMATION);
			default: send_normal(ASCII_EXCLAMATION);
		endcase

		SCAN_SPACE: send_normal(ASCII_SPACE);

		SCAN_KP_MUL: send_normal(ASCII_KP_MUL);
		SCAN_KP_SUB: send_normal(ASCII_KP_SUB);
		SCAN_KP_7: send_normal(ASCII_KP_7);
		SCAN_KP_8: send_normal(ASCII_KP_8);
		SCAN_KP_9: send_normal(ASCII_KP_9);
		SCAN_KP_ADD: send_normal(ASCII_KP_ADD);
		SCAN_KP_4: send_normal(ASCII_KP_4);
		SCAN_KP_5: send_normal(ASCII_KP_5);
		SCAN_KP_6: send_normal(ASCII_KP_6);
		SCAN_KP_1: send_normal(ASCII_KP_1);
		SCAN_KP_2: send_normal(ASCII_KP_2);
		SCAN_KP_3: send_normal(ASCII_KP_3);
		SCAN_KP_0: send_normal(ASCII_KP_0);
		SCAN_KP_PERIOD: send_normal(ASCII_KP_PERIOD);

		default: send_nothing();
	endcase
endtask

task execute_extended;
	input wire [7:0] scan_code;

	case (scan_code)
		SCAN_E0_PRNT_SCR: send_extended(ASCII_E0_PRNT_SCR);
		SCAN_E0_PAUSE: send_extended(ASCII_E0_PAUSE);
		SCAN_E0_CONTEXTUAL: send_extended(ASCII_E0_CONTEXTUAL);

		SCAN_E0_INSERT: send_extended(ASCII_E0_INSERT);
		SCAN_E0_HOME: send_extended(ASCII_E0_HOME);
		SCAN_E0_PAGE_UP: send_extended(ASCII_E0_PAGE_UP);
		SCAN_E0_DELETE: send_extended(ASCII_E0_DELETE);
		SCAN_E0_END: send_extended(ASCII_E0_END);
		SCAN_E0_PAGE_DOWN: send_extended(ASCII_E0_PAGE_DOWN);
		SCAN_E0_UP: send_extended(ASCII_E0_UP);
		SCAN_E0_LEFT: send_extended(ASCII_E0_LEFT);
		SCAN_E0_DOWN: send_extended(ASCII_E0_DOWN);
		SCAN_E0_RIGHT: send_extended(ASCII_E0_RIGHT);

		SCAN_E0_KP_DIV: send_normal(ASCII_E0_KP_DIV);
		SCAN_E0_KP_ENTER: send_normal(ASCII_E0_KP_ENTER);

		default: send_nothing();
	endcase
endtask

always @(posedge clk)
	if (reset) begin
		send_nothing();
	end else begin
		send_nothing();
		if (keyboard_state_ready) begin
			if (scan_code_extended)
				execute_extended(scan_code_in);
			else
				execute_normal(scan_code_in);
		end
	end
endmodule
