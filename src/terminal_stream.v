module terminal_stream #(
	parameter COLUMNS = 80,
	parameter ROWS = 51
) (
	input wire clk,
	input wire reset,
	output reg ready_n,

	// Stream input
	input wire [20:0] unicode,
	input wire unicode_available,

	// SDRAM output
	output reg [22:0] wr_address,
	output reg wr_request,
	output reg [31:0] wr_data,
	output reg [3:0] wr_mask,
	output reg [8:0] wr_burst_length,
	input wire wr_done
);

`include "constant.v"
`include "terminal_stream/escape_codes.v"
`include "terminal_stream/attributes.v"

localparam
	REAL_WIDTH = 'd128;

// =============================================================================
// Stage management
// =============================================================================
reg [3:0] stage;
localparam
	STAGE_IDLE               = 'd0,
	STAGE_CLEAR_WRITE        = 'd1,
	STAGE_CLEAR_NEXT         = 'd2,
	STAGE_WRITE_TOP_LEFT     = 'd3,
	STAGE_WRITE_TOP_RIGHT    = 'd4,
	STAGE_WRITE_BOTTOM_LEFT  = 'd5,
	STAGE_WRITE_BOTTOM_RIGHT = 'd6,
	STAGE_ESC                = 'd7,
	STAGE_CSI                = 'd8;

task goto;
	input [3:0] next_stage;
	stage <= next_stage;
endtask


// =============================================================================
// Cursor position
// =============================================================================
task line_feed;
	begin
		text_x <= 'd0;

		if (size[1])
			text_y <= text_y >= ROWS - 2 ? 'd0 : text_y + 'd2;
		else
			text_y <= text_y >= ROWS - 1 ? 'd0 : text_y + 'd1;
	end
endtask

task next_char;
	if (size[0]) begin
		if (text_x >= COLUMNS - 2)
			line_feed();
		else
			text_x <= text_x + 'd2;
	end else begin
		if (text_x >= COLUMNS - 1)
			line_feed();
		else
			text_x <= text_x + 'd1;
	end
endtask

function [22:0] address_from_position;
	input [6:0] x;
	input [5:0] y;
	address_from_position = { 8'b0, y, x, 2'b00 };
endfunction

// =============================================================================
// Idle stage
// =============================================================================
task stage_idle;
	if (unicode_available) begin
		if (unicode == CLS) clear_screen();
		else if (unicode == CR) text_x <= 'd0;
		else if (unicode == LF) line_feed();
		else if (unicode == ESC) goto(STAGE_ESC);
		else begin
			wr_request <= TRUE;
			wr_address <= address_from_position(text_x, text_y);
			wr_data <= generate_cell_part(unicode, PART_TOP_LEFT);
			next_char();
			goto(STAGE_WRITE_TOP_LEFT);
		end
	end
endtask

task stage_write_top_left;
	if (wr_done)
		case (size)
			SIZE_DOUBLE_WIDTH, SIZE_DOUBLE: begin
				wr_request <= TRUE;
				wr_address <= wr_address + 'd4;
				wr_data <= generate_cell_part(unicode, PART_TOP_RIGHT);
				goto(STAGE_WRITE_TOP_RIGHT);
			end

			SIZE_DOUBLE_HEIGHT: begin
				wr_request <= TRUE;
				wr_address <= wr_address + REAL_WIDTH * 'd4;
				wr_data <= generate_cell_part(unicode, PART_BOTTOM_LEFT);
				goto(STAGE_WRITE_BOTTOM_LEFT);
			end

			default: begin
				wr_request <= FALSE;
				goto(STAGE_IDLE);
			end
		endcase
	else begin
		wr_request <= FALSE;
		goto(STAGE_WRITE_TOP_LEFT);
	end
endtask

task stage_write_top_right;
	if (wr_done)
		case (size)
			SIZE_DOUBLE: begin
				wr_request <= TRUE;
				wr_address <= wr_address + (REAL_WIDTH - 'd1) * 'd4;
				wr_data <= generate_cell_part(unicode, PART_BOTTOM_LEFT);
				goto(STAGE_WRITE_BOTTOM_LEFT);
			end

			default: begin
				wr_request <= FALSE;
				goto(STAGE_IDLE);
			end
		endcase
	else begin
		wr_request <= FALSE;
		goto(STAGE_WRITE_TOP_RIGHT);
	end
endtask

task stage_write_bottom_left;
	if (wr_done)
		case (size)
			SIZE_DOUBLE: begin
				wr_request <= TRUE;
				wr_address <= wr_address + 'd4;
				wr_data <= generate_cell_part(unicode, PART_BOTTOM_RIGHT);
				goto(STAGE_WRITE_BOTTOM_RIGHT);
			end

			default: begin
				wr_request <= FALSE;
				goto(STAGE_IDLE);
			end
		endcase
	else begin
		wr_request <= FALSE;
		goto(STAGE_WRITE_BOTTOM_LEFT);
	end
endtask

task stage_write_bottom_right;
	begin
		wr_request <= FALSE;
		if (wr_done)
			goto(STAGE_IDLE);
		else
			goto(STAGE_WRITE_BOTTOM_RIGHT);
	end
endtask


// =============================================================================
// Clear screen
// =============================================================================
reg [22:0] wr_address_end;
task clear;
	input [6:0] from_x;
	input [5:0] from_y;
	input [6:0] to_x;
	input [5:0] to_y;
	begin
		wr_address <= address_from_position(from_x, from_y);
		wr_address_end <= address_from_position(to_x, to_y) - 'd4;
		ready_n <= FALSE_n;
		goto(STAGE_CLEAR_WRITE);
	end
endtask

task clear_screen;
	begin
		reset_position();
		reset_attributes();
		clear(0, 0, COLUMNS, ROWS);
	end
endtask

task clear_write;
	begin
		wr_request <= TRUE;
		wr_data <= clear_cell(SPACE_CHARACTER);
		goto(STAGE_CLEAR_NEXT);
	end
endtask

task clear_next;
	begin
		wr_request <= FALSE;
		if (wr_done) begin
			if (wr_address == wr_address_end) begin
				ready_n <= TRUE_n;
				goto(STAGE_IDLE);
			end else begin
				wr_address <= wr_address + 'd4;
				goto(STAGE_CLEAR_WRITE);
			end
		end
	end
endtask

// =============================================================================
// Control sequences
// =============================================================================
task apply_sgr;
	input [9:0] argument;

	case (argument)
		SGR_RESET: reset_attributes();

		SGR_BOLD: bold <= TRUE;
		SGR_NORMAL: bold <= FALSE;

		SGR_INVERT_ON: invert <= TRUE;
		SGR_INVERT_OFF: invert <= FALSE;

		SGR_BLINK_SLOW: blink <= 'd1;
		SGR_BLINK_FAST: blink <= 'd3;
		SGR_BLINK_OFF: blink <= 'd0;

		SGR_FOREGROUND_0, SGR_FOREGROUND_1, SGR_FOREGROUND_2, SGR_FOREGROUND_3,
		SGR_FOREGROUND_4, SGR_FOREGROUND_5, SGR_FOREGROUND_6, SGR_FOREGROUND_7:
			foreground <= argument - SGR_FOREGROUND_0;

		SGR_FOREGROUND_8, SGR_FOREGROUND_9, SGR_FOREGROUND_10, SGR_FOREGROUND_11,
		SGR_FOREGROUND_12, SGR_FOREGROUND_13, SGR_FOREGROUND_14, SGR_FOREGROUND_15:
			foreground <= argument - SGR_FOREGROUND_8 + 'd8;

		SGR_BACKGROUND_0, SGR_BACKGROUND_1, SGR_BACKGROUND_2, SGR_BACKGROUND_3,
		SGR_BACKGROUND_4, SGR_BACKGROUND_5, SGR_BACKGROUND_6, SGR_BACKGROUND_7:
			background <= argument - SGR_BACKGROUND_0;

		SGR_BACKGROUND_8, SGR_BACKGROUND_9, SGR_BACKGROUND_10, SGR_BACKGROUND_11,
		SGR_BACKGROUND_12, SGR_BACKGROUND_13, SGR_BACKGROUND_14, SGR_BACKGROUND_15:
			background <= argument - SGR_BACKGROUND_8 + 'd8;
	endcase
endtask

reg [2:0] argument_count;
reg [9:0] arguments [1:0];
task stage_esc;
	if (unicode_available) begin
		if (unicode == ESC_SIZE_DOUBLE_WIDTH) begin
			size <= SIZE_DOUBLE_WIDTH;
			goto(STAGE_IDLE);
		end	else if (unicode == ESC_SIZE_DOUBLE_HEIGHT) begin
			size <= SIZE_DOUBLE_HEIGHT;
			goto(STAGE_IDLE);
		end else if (unicode == ESC_SIZE_DOUBLE) begin
			size <= SIZE_DOUBLE;
			goto(STAGE_IDLE);
		end else if (unicode == ESC_SIZE_NORMAL) begin
			size <= SIZE_NORMAL;
			goto(STAGE_IDLE);
		end	else if (unicode == CSI) begin
			argument_count <= 'd0;
			arguments[0] <= 'd0;
			arguments[1] <= 'd0;
			goto(STAGE_CSI);
		end else
			goto(STAGE_IDLE);
	end
endtask

task stage_csi;
	begin
		if (unicode_available) begin
			if (unicode >= 'h30 && unicode < 'h3A) begin // Parameter bytes
				if (argument_count == 'd0) begin
					argument_count <= 'd1;
					arguments[0] <= unicode[3:0];
				end else begin
					arguments[argument_count - 'd1] <=
						arguments[argument_count - 'd1] * 'd10 +
						unicode[3:0];
				end
				goto(STAGE_CSI);
			end else if (unicode == CSI_SEPARATOR) begin
				argument_count <= argument_count + 'd1;
				goto(STAGE_CSI);
			end else if (unicode == CSI_CURSOR_POSITION) begin
				text_y <= arguments[0] == 'd0 ? 'd0 : arguments[0] - 'd1; 
				text_x <= arguments[1] == 'd0 ? 'd0 : arguments[1] - 'd1;
				goto(STAGE_IDLE);
			end else if (unicode == CSI_ERASE_IN_DISPLAY) begin
				case (arguments[0])
					'd1: clear('d0, 'd0, text_x + 'd1, text_y);
					'd2: clear_screen();
					'd3: clear_screen();
					default: clear(text_x, text_y, COLUMNS, ROWS);
				endcase
			end else if (unicode == CSI_ERASE_IN_LINE) begin
				case (arguments[0])
					'd1: clear('d0, text_y, text_x + 'd1, text_y);
					'd2: clear('d0, text_y, COLUMNS, text_y);
					default: clear(text_x, text_y, COLUMNS, text_y);
				endcase
			end else if (unicode == CSI_SGR) begin
				apply_sgr(arguments[0]);
				if (argument_count == 2) apply_sgr(arguments[1]);
				goto(STAGE_IDLE);
			end else
				goto(STAGE_IDLE);
		end else
			goto(STAGE_CSI);
	end
endtask

// =============================================================================
// Automaton
// =============================================================================
always @(posedge clk)
	if (reset) begin
		wr_address <= 'd0;
		wr_address_end <= 'd0;
		wr_request <= FALSE;
		wr_mask <= 4'b1111;
		ready_n <= FALSE_n;
		wr_burst_length <= 'd1;
		reset_position();
		reset_attributes();
		clear_screen();
	end else begin
		case (stage)
			STAGE_IDLE: stage_idle();

			STAGE_CLEAR_WRITE: clear_write();
			STAGE_CLEAR_NEXT: clear_next();

			STAGE_WRITE_TOP_LEFT: stage_write_top_left();
			STAGE_WRITE_TOP_RIGHT: stage_write_top_right();
			STAGE_WRITE_BOTTOM_LEFT: stage_write_bottom_left();
			STAGE_WRITE_BOTTOM_RIGHT: stage_write_bottom_right();

			STAGE_ESC: stage_esc();
			STAGE_CSI: stage_csi();
		endcase
	end
endmodule
