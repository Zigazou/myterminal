module terminal_stream (
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
	input wire wr_done,

	// Video registers
	output reg [3:0] register_index,
	output reg [22:0] register_value
);

`include "constant.v"
`include "terminal_stream/escape_codes.v"
`include "terminal_stream/attributes.v"
`include "video_controller/registers.v"

task set;
	input [3:0] register;
	input [22:0] value;
	begin
		register_index <= register;
		register_value <= value;
	end
endtask

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
reg [22:0] wr_address_end;

task prepare_first_row;
	input [5:0] new_first_row;
	begin
		if (new_first_row == ROWS) begin
			first_row <= 'd0;
			set(VIDEO_SET_FIRST_ROW, 'd0);
		end else begin
			first_row <= new_first_row;
			set(VIDEO_SET_FIRST_ROW, { new_first_row, 9'b000_0000 });
		end

		wr_address <= { first_row, 9'b000_0000 };
		wr_address_end <= { first_row, 9'b000_0000 } + ROW_SIZE - 'd4;
	end
endtask

task gotoxy;
	input [6:0] x;
	input [5:0] y;
	if (x < COLUMNS) begin
		text_x <= x;

		if (y < ROWS) begin
			text_y <= y;
			goto(STAGE_IDLE);
		end else begin
			text_y <= ROWS - 6'd1;
			prepare_first_row(first_row + 'd1);
			ready_n <= FALSE_n;
			goto(STAGE_CLEAR_WRITE);
		end
	end else
		gotoxy('d0, y + { 5'b0, size[1] } + 'd1);
endtask

task line_feed;
	gotoxy('d0, text_y + { 5'b0, size[1] } + 'd1);
endtask

task next_char;
	gotoxy(text_x + { 6'b0, size[0] } + 'd1, text_y);
endtask

function [22:0] address_from_position;
	input [6:0] x;
	input [5:0] y;
	if (y >= ROWS - first_row)
		address_from_position = { 8'b0, y - ROWS + first_row, x, 2'b00 };
	else
		address_from_position = { 8'b0, y + first_row, x, 2'b00 };
endfunction

// =============================================================================
// Idle stage
// =============================================================================
task stage_idle;
	if (unicode_available) begin
		if (unicode == CLS) begin
			ready_n <= FALSE_n;
			clear_screen();
		end else if (unicode == CR) text_x <= 'd0;
		else if (unicode == LF) begin
			ready_n <= FALSE_n;
			line_feed();
		end else if (unicode == ESC) goto(STAGE_ESC);
		else begin
			ready_n <= FALSE_n;
			wr_request <= TRUE;
			wr_address <= address_from_position(text_x, text_y);
			wr_data <= generate_cell_part(unicode, PART_TOP_LEFT);
			goto(STAGE_WRITE_TOP_LEFT);
		end
	end else
		ready_n <= TRUE_n;
endtask

task stage_write_top_left;
	if (wr_done)
		case (size)
			SIZE_DOUBLE_WIDTH, SIZE_DOUBLE: begin
				wr_request <= TRUE;
				wr_address <= wr_address + CHARATTR_SIZE;
				wr_data <= generate_cell_part(unicode, PART_TOP_RIGHT);
				goto(STAGE_WRITE_TOP_RIGHT);
			end

			SIZE_DOUBLE_HEIGHT: begin
				wr_request <= TRUE;
				wr_address <= wr_address + ROW_SIZE;
				wr_data <= generate_cell_part(unicode, PART_BOTTOM_LEFT);
				goto(STAGE_WRITE_BOTTOM_LEFT);
			end

			default: begin
				wr_request <= FALSE;
				next_char();
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
				wr_address <= wr_address + ROW_SIZE - CHARATTR_SIZE;
				wr_data <= generate_cell_part(unicode, PART_BOTTOM_LEFT);
				goto(STAGE_WRITE_BOTTOM_LEFT);
			end

			default: begin
				wr_request <= FALSE;
				next_char();
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
				wr_address <= wr_address + CHARATTR_SIZE;
				wr_data <= generate_cell_part(unicode, PART_BOTTOM_RIGHT);
				goto(STAGE_WRITE_BOTTOM_RIGHT);
			end

			default: begin
				wr_request <= FALSE;
				next_char();
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
			next_char();
		else
			goto(STAGE_WRITE_BOTTOM_RIGHT);
	end
endtask

// =============================================================================
// Clear screen
// =============================================================================
task clear;
	input [6:0] from_x;
	input [5:0] from_y;
	input [6:0] to_x;
	input [5:0] to_y;
	begin
		wr_address <= address_from_position(from_x, from_y);
		wr_address_end <= address_from_position(to_x, to_y) - 'd4;
		goto(STAGE_CLEAR_WRITE);
	end
endtask

task clear_screen;
	begin
		set(VIDEO_SET_FIRST_ROW, 'd0);
		reset_all();
		wr_address <= 'd0;
		wr_address_end <= PAGE_SIZE - 'd4;
		goto(STAGE_CLEAR_WRITE);
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
reg [9:0] arguments [3:0];
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
			arguments[2] <= 'd0;
			arguments[3] <= 'd0;
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
				ready_n <= FALSE_n;
				case (arguments[0])
					'd1: clear('d0, 'd0, text_x + 'd1, text_y);
					'd2: clear_screen();
					'd3: clear_screen();
					default: clear(text_x, text_y, COLUMNS, ROWS);
				endcase
			end else if (unicode == CSI_ERASE_IN_LINE) begin
				ready_n <= FALSE_n;
				case (arguments[0])
					'd1: clear('d0, text_y, text_x + 'd1, text_y);
					'd2: clear('d0, text_y, COLUMNS, text_y);
					default: clear(text_x, text_y, COLUMNS, text_y);
				endcase
			end else if (unicode == CSI_SGR) begin
				apply_sgr(arguments[0]);
				if (argument_count == 2) apply_sgr(arguments[1]);
				if (argument_count == 3) apply_sgr(arguments[2]);
				if (argument_count == 4) apply_sgr(arguments[3]);
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
		set(VIDEO_NOP, 'd0);
		reset_all();
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
