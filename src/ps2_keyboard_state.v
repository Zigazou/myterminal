module ps2_keyboard_state (
	input wire clk,
	input wire reset, 

	input wire scan_code_ready,
	input wire [7:0] scan_code_in,

	output reg keyboard_state_ready = 0,
	output reg [7:0] scan_code_out,
	output reg scan_code_extended = 0,
	output wire keyboard_shift,
	output reg keyboard_alt = 0,
	output reg keyboard_altgr = 0,
	output wire keyboard_ctrl,
	output wire keyboard_meta
);

`include "ps2_scan_code_set2_fr.v"

// Definitions to make code easier to read and understand.
localparam
	HIGH  = 1'b1,
	LOW   = 1'b0,

	TRUE  = HIGH,
	FALSE = LOW;

reg keyboard_shift_left = FALSE;
reg keyboard_shift_right = FALSE;
assign keyboard_shift = keyboard_shift_left | keyboard_shift_right;

reg keyboard_ctrl_left = FALSE;
reg keyboard_ctrl_right = FALSE;
assign keyboard_ctrl = keyboard_ctrl_left | keyboard_ctrl_right;

reg keyboard_meta_left = FALSE;
reg keyboard_meta_right = FALSE;
assign keyboard_meta = keyboard_meta_left | keyboard_meta_right;

localparam
	STATE_IDLE       = 'd0,
	STATE_E0         = 'd1,
	STATE_E1_1       = 'd2,
	STATE_E1_2       = 'd3,
	STATE_BREAK      = 'd4,
	STATE_E0_BREAK   = 'd5,
	STATE_E1_1_BREAK = 'd6,
	STATE_E1_2_BREAK = 'd7;

reg [2:0] state;

task state_idle;
	begin
		state <= STATE_IDLE;
		case (scan_code_in)
			SCAN_SHIFT_LEFT: keyboard_shift_left <= TRUE;
			SCAN_SHIFT_RIGHT: keyboard_shift_right <= TRUE;
			SCAN_CTRL_LEFT: keyboard_ctrl_left <= TRUE;
			SCAN_ALT: keyboard_alt <= TRUE;
			SCAN_E0: state <= STATE_E0;
			SCAN_E1: state <= STATE_E1_1;
			SCAN_BREAK: state <= STATE_BREAK;
			default: begin
				keyboard_state_ready <= TRUE;
				scan_code_extended <= FALSE;
				scan_code_out <= scan_code_in;
			end
		endcase
	end
endtask

task state_e0;
	begin
		state <= STATE_IDLE;
		case (scan_code_in)
			SCAN_E0_IGNORE: state <= STATE_IDLE;
			SCAN_E0_CTRL_RIGHT: keyboard_ctrl_right <= TRUE;
			SCAN_E0_META_LEFT: keyboard_meta_left <= TRUE;
			SCAN_E0_META_RIGHT: keyboard_meta_right <= TRUE;
			SCAN_E0_ALTGR: keyboard_altgr <= TRUE;
			SCAN_BREAK: state <= STATE_E0_BREAK;
			default: begin
				keyboard_state_ready <= TRUE;
				scan_code_extended <= TRUE;
				scan_code_out <= scan_code_in;
			end
		endcase
	end
endtask

task state_e1_1;
	case (scan_code_in)
		SCAN_BREAK: state <= STATE_E1_1_BREAK;
		SCAN_E1_PAUSE_1: state <= STATE_E1_2;
		default: state <= STATE_IDLE;
	endcase
endtask

task state_e1_2;
	begin
		state <= STATE_IDLE;
		case (scan_code_in)
			SCAN_BREAK: state <= STATE_E1_2_BREAK;
			SCAN_E1_PAUSE_2: begin
				keyboard_state_ready <= TRUE;
				scan_code_extended <= TRUE;
				scan_code_out <= SCAN_E0_PAUSE;
			end
			default: state <= STATE_IDLE;
		endcase
	end
endtask

task state_break;
	begin
		state <= STATE_IDLE;
		case (scan_code_in)
			SCAN_SHIFT_LEFT: keyboard_shift_left <= FALSE;
			SCAN_SHIFT_RIGHT: keyboard_shift_right <= FALSE;
			SCAN_CTRL_LEFT: keyboard_ctrl_left <= FALSE;
		endcase
	end
endtask

task state_e0_break;
	begin
		state <= STATE_IDLE;
		case (scan_code_in)
			SCAN_E0_CTRL_RIGHT: keyboard_ctrl_right <= FALSE;
			SCAN_E0_META_LEFT: keyboard_meta_left <= FALSE;
			SCAN_E0_META_RIGHT: keyboard_meta_right <= FALSE;
			SCAN_E0_ALTGR: keyboard_altgr <= FALSE;
		endcase
	end
endtask

task state_e1_1_break;
	state <= STATE_E1_2;
endtask

task state_e1_2_break;
	state <= STATE_IDLE;
endtask

always @(posedge clk)
	if (reset) begin
		state <= STATE_IDLE;
		keyboard_state_ready <= FALSE;
		scan_code_out <= 'd0;
		scan_code_extended <= FALSE;
		keyboard_shift_right <= FALSE;
		keyboard_shift_left <= FALSE;
		keyboard_alt <= FALSE;
		keyboard_altgr <= FALSE;
		keyboard_ctrl_left <= FALSE;
		keyboard_ctrl_right <= FALSE;
		keyboard_meta_left <= FALSE;
		keyboard_meta_right <= FALSE;
	end else begin
		keyboard_state_ready <= FALSE;
		if (scan_code_ready) begin
			case (state)
				STATE_IDLE: state_idle();
				STATE_E0: state_e0();
				STATE_E1_1: state_e1_1();
				STATE_E1_2: state_e1_2();
				STATE_BREAK: state_break();
				STATE_E0_BREAK: state_e0_break();
				STATE_E1_1_BREAK: state_e1_1_break();
				STATE_E1_2_BREAK: state_e1_2_break();
			endcase
		end
	end

endmodule
