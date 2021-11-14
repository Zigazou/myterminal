module terminal_stream (
	input wire clk,
	input wire reset,
	output reg ready_n,

	// Stream input
	input wire [7:0] unicode,
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
	output reg [22:0] register_value,

	// Mouse control
	output reg [1:0] mouse_control
);

`include "constant.v"
`include "ts_cursor.vh"
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
reg [4:0] stage;
localparam
	STAGE_IDLE               = 'd0,
	STAGE_CLEAR_WRITE        = 'd1,
	STAGE_CLEAR_NEXT         = 'd2,
	STAGE_WRITE_TOP_LEFT     = 'd3,
	STAGE_WRITE_TOP_RIGHT    = 'd4,
	STAGE_WRITE_BOTTOM_LEFT  = 'd5,
	STAGE_WRITE_BOTTOM_RIGHT = 'd6,
	STAGE_CLEAR_SCREEN_WRITE = 'd7,
	STAGE_CLEAR_SCREEN_NEXT  = 'd8,
	STAGE_CLEAR              = 'd9,
	STAGE_COLOR              = 'd10,
	STAGE_CURSOR1            = 'd11,
	STAGE_CURSOR2            = 'd12,
	STAGE_ATTRIBUTE          = 'd13,
	STAGE_PARAMETER          = 'd14,
	STAGE_PATTERN            = 'd15,
	STAGE_MOUSE_CONTROL      = 'd16,
	STAGE_REPEAT             = 'd17,
	STAGE_CURSOR_COMMAND1    = 'd18,
	STAGE_CURSOR_COMMAND2    = 'd19;

task goto;
	input [4:0] next_stage;
	stage <= next_stage;
endtask

// =============================================================================
// Cursor position
// =============================================================================
reg [7:0] last_unicode = 'd0;
reg [7:0] repeat_count = 'd0;

localparam
	LIMIT_Y   = 2 ** 6 - 1,
	FIRST_ROW = 'd0,
	LAST_ROW  = ROWS - 'd1;

reg [22:0] wr_address_end;

function [22:0] real_row_address;
	input [5:0] row;
	real_row_address = { 8'b0, row, 7'b0, 2'b0 };
endfunction

task prepare_first_row;
	input [5:0] new_first_row;
	begin
		if (new_first_row == ROWS) begin
			first_row <= FIRST_ROW;
			set(VIDEO_SET_FIRST_ROW, real_row_address(FIRST_ROW));
		end else begin
			first_row <= new_first_row;
			set(VIDEO_SET_FIRST_ROW, real_row_address(new_first_row));
		end

		wr_address <= real_row_address(first_row);
		wr_address_end <= real_row_address(first_row) + ROW_SIZE - 'd4;
	end
endtask

task scroll_down;
	begin
		if (first_row == LAST_ROW) begin
			first_row <= FIRST_ROW;
			set(VIDEO_SET_FIRST_ROW, real_row_address(FIRST_ROW));
			wr_address <= real_row_address(FIRST_ROW);
			wr_address_end <= real_row_address(FIRST_ROW) + ROW_SIZE - 'd4;
		end else begin
			first_row <= first_row + 'd1;
			set(VIDEO_SET_FIRST_ROW, real_row_address(first_row + 'd1));
			wr_address <= real_row_address(first_row);
			wr_address_end <= real_row_address(first_row) + ROW_SIZE - 'd4;
		end

		goto(STAGE_CLEAR_WRITE);
	end
endtask

task scroll_up;
	begin
		if (first_row == FIRST_ROW) begin
			first_row <= LAST_ROW;
			set(VIDEO_SET_FIRST_ROW, real_row_address(LAST_ROW));
			wr_address <= real_row_address(LAST_ROW);
			wr_address_end <= real_row_address(LAST_ROW) + ROW_SIZE - 'd4;
		end else begin
			first_row <= first_row - 6'd1;
			set(VIDEO_SET_FIRST_ROW, real_row_address(first_row - 6'd1));
			wr_address <= real_row_address(first_row - 6'd1);
			wr_address_end <= real_row_address(first_row - 6'd1) + ROW_SIZE - 'd4;
		end

		goto(STAGE_CLEAR_WRITE);
	end
endtask


ts_cursor #(
	.COLUMNS (COLUMNS),
	.ROWS (ROWS)
) ts_cursor (
	.clk (clk),
	.reset (reset),
	.command (ts_command),
	.horz_size (size[0]),
	.vert_size (size[1]),
	.orientation (orientation),
	.in_x (in_x),
	.in_y (in_y),
	.x (text_x),
	.y (text_y),
	.scroll (scroll)
);

task line_feed;
	begin
		ts_command <= TS_CURSOR_LINE_FEED;
		ready_n <= FALSE_n;
		goto(STAGE_CURSOR_COMMAND1);
	end
endtask

task next_char;
	begin
		if (repeat_count != 'd0) begin
			repeat_count <= repeat_count - 'd1;
		end
		ts_command <= TS_CURSOR_NEXT_CHAR;
		ready_n <= FALSE_n;
		goto(STAGE_CURSOR_COMMAND1);
	end
endtask

task stage_cursor_command1;
	begin
		ts_command <= TS_CURSOR_NOP;
		goto(STAGE_CURSOR_COMMAND2);
	end
endtask

task stage_cursor_command2;
	begin
		if (scroll) begin
			prepare_first_row(first_row + 'd1);
			ready_n <= FALSE_n;
			goto(STAGE_CLEAR_WRITE);
		end else begin
			if (repeat_count != 'd0)
				ready_n <= FALSE_n;
			else
				ready_n <= TRUE_n;
			goto(STAGE_IDLE);
		end
	end
endtask

wire [5:0] first_row_diff = ROWS - first_row;
function [22:0] address_from_position;
	input [6:0] x;
	input [5:0] y;
	if (y >= first_row_diff)
		address_from_position = { 8'b0, y - first_row_diff, x, 2'b00 };
	else
		address_from_position = { 8'b0, y + first_row, x, 2'b00 };
endfunction

// =============================================================================
// Idle stage
// =============================================================================
task stage_idle;
	if (repeat_count != 'd0) begin
		ready_n <= FALSE_n;
		wr_request <= TRUE;
		wr_address <= address_from_position(text_x, text_y);
		wr_data <= generate_cell_part(last_unicode, PART_TOP_LEFT);
		current_pixels_offset <= 2'd0;
		goto(STAGE_WRITE_TOP_LEFT);
	end else if (unicode_available) begin
		if (unicode[7:5] == 3'b0)
			case (unicode)
				CTRL_CODE_00: goto(STAGE_IDLE);
				CTRL_CLEAR: goto(STAGE_CLEAR);
				CTRL_COLOR: goto(STAGE_COLOR);
				CTRL_PATTERN: goto(STAGE_PATTERN);
				CTRL_CURSOR: goto(STAGE_CURSOR1);
				CTRL_ATTRIBUTE: goto(STAGE_ATTRIBUTE);
				CTRL_PARAMETER: goto(STAGE_PARAMETER);
				BELL: goto(STAGE_IDLE);
				CTRL_CODE_08: goto(STAGE_IDLE);
				TAB: goto(STAGE_IDLE);

				LF: begin
					ready_n <= FALSE_n;
					line_feed();
				end

				CTRL_SCROLL_UP: begin
					ready_n <= FALSE_n;
					scroll_up();
				end

				CTRL_SCROLL_DOWN: begin
					ready_n <= FALSE_n;
					scroll_down();
				end

				CR: begin
					ts_command <= TS_CURSOR_SET;
					in_x <= 'd0;
					in_y <= text_y;
					goto(STAGE_CURSOR_COMMAND1);
				end

				CTRL_CURSOR_UP: begin
					ts_command <= TS_CURSOR_UP;
					goto(STAGE_CURSOR_COMMAND1);
				end
				CTRL_CURSOR_DOWN: begin
					ts_command <= TS_CURSOR_DOWN;
					goto(STAGE_CURSOR_COMMAND1);
				end
				CTRL_CURSOR_LEFT: begin
					ts_command <= TS_CURSOR_LEFT;
					goto(STAGE_CURSOR_COMMAND1);
				end
				CTRL_CURSOR_RIGHT: begin
					ts_command <= TS_CURSOR_RIGHT;
					goto(STAGE_CURSOR_COMMAND1);
				end

				CTRL_REPEAT: goto(STAGE_REPEAT);

				CTRL_CHARPAGE_0: begin
					charpage_base <= CHARPAGE_0;
					goto(STAGE_IDLE);
				end
				CTRL_CHARPAGE_1: begin
					charpage_base <= CHARPAGE_1;
					goto(STAGE_IDLE);
				end
				CTRL_CHARPAGE_2: begin
					charpage_base <= CHARPAGE_2;
					goto(STAGE_IDLE);
				end
				CTRL_CHARPAGE_3: begin
					charpage_base <= CHARPAGE_3;
					goto(STAGE_IDLE);
				end
				CTRL_CHARPAGE_4: begin
					charpage_base <= CHARPAGE_4;
					goto(STAGE_IDLE);
				end

				CTRL_CHARPAGE_GFX: begin
					current_pixels_offset <= 2'd0;
					charpage_base <= CHARPAGE_GFX;
					goto(STAGE_IDLE);
				end

				CTRL_MOUSE_CONTROL: goto(STAGE_MOUSE_CONTROL);

				CTRL_CODE_1B: goto(STAGE_IDLE);
				CTRL_CODE_1C: goto(STAGE_IDLE);
				CTRL_CODE_1D: goto(STAGE_IDLE);
				CTRL_CODE_1E: goto(STAGE_IDLE);
				CTRL_CODE_1F: goto(STAGE_IDLE);
			endcase
		else begin
			if (charpage_base == CHARPAGE_GFX) begin
				if (current_pixels_offset == 2'd0) begin
					ready_n <= TRUE_n;
					current_pixels[13:7] <= unicode[6:0];
					current_pixels_offset <= 2'd1;
					goto(STAGE_IDLE);
				end else if (current_pixels_offset == 2'd1) begin
					ready_n <= TRUE_n;
					current_pixels[6:0] <= unicode[6:0];
					current_pixels_offset <= 2'd2;
					goto(STAGE_IDLE);
				end else begin
					ready_n <= FALSE_n;
					size <= SIZE_NORMAL;
					wr_request <= TRUE;
					wr_address <= address_from_position(text_x, text_y);
					wr_data <= generate_cell_gfx({ current_pixels, unicode[5:0] }, unicode[6]);
					current_pixels_offset <= 2'd0;
					goto(STAGE_WRITE_TOP_LEFT);
				end
			end else begin
				ready_n <= FALSE_n;
				wr_request <= TRUE;
				wr_address <= address_from_position(text_x, text_y);
				wr_data <= generate_cell_part(unicode, PART_TOP_LEFT);
				last_unicode <= unicode;
				current_pixels_offset <= 2'd0;
				goto(STAGE_WRITE_TOP_LEFT);
			end
		end
	end else begin
		ready_n <= TRUE_n;
		goto(STAGE_IDLE);
		set(VIDEO_CURSOR_POSITION, {9'b0, cursor_visible, text_y, text_x});
	end
endtask

task stage_write_top_left;
	if (wr_done)
		case (size)
			SIZE_DOUBLE_WIDTH, SIZE_DOUBLE: begin
				wr_request <= TRUE;
				wr_address <= wr_address + CHARATTR_SIZE;
				wr_data <= generate_cell_part(last_unicode, PART_TOP_RIGHT);
				goto(STAGE_WRITE_TOP_RIGHT);
			end

			SIZE_DOUBLE_HEIGHT: begin
				wr_request <= TRUE;
				wr_address <= wr_address + ROW_SIZE;
				wr_data <= generate_cell_part(last_unicode, PART_BOTTOM_LEFT);
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
				wr_address <= wr_address + {ROW_SIZE - CHARATTR_SIZE};
				wr_data <= generate_cell_part(last_unicode, PART_BOTTOM_LEFT);
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
				wr_data <= generate_cell_part(last_unicode, PART_BOTTOM_RIGHT);
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
		wr_burst_length <= 'd1;
		wr_address <= address_from_position(from_x, from_y);
		wr_address_end <= address_from_position(to_x, to_y);
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
			end else if (wr_address == { 8'b0, 6'd51, 7'd80, 2'b00 }) begin
				wr_address <= 'd0;
				goto(STAGE_CLEAR_WRITE);
			end else begin
				wr_address <= wr_address + 'd4;
				goto(STAGE_CLEAR_WRITE);
			end
		end
	end
endtask

localparam
	CLEAR_SCREEN_BURST = 'd32;

task clear_screen;
	begin
		set(VIDEO_SET_FIRST_ROW, 'd0);
		first_row <= FIRST_ROW;
		reset_position();
		wr_address <= 'd0;
		wr_address_end <= PAGE_SIZE - 'd4;
		wr_burst_length <= CLEAR_SCREEN_BURST;
		goto(STAGE_CLEAR_SCREEN_WRITE);
	end
endtask

task clear_screen_write;
	begin
		wr_request <= TRUE;
		wr_data <= clear_cell(SPACE_CHARACTER);
		goto(STAGE_CLEAR_SCREEN_NEXT);
	end
endtask

task clear_screen_next;
	begin
		wr_request <= FALSE;
		if (wr_done) begin
			if (wr_address >= wr_address_end) begin
				wr_burst_length <= 'd1;
				goto(STAGE_IDLE);
			end else begin
				wr_address <= wr_address + CLEAR_SCREEN_BURST * 'd4;
				goto(STAGE_CLEAR_SCREEN_WRITE);
			end
		end
	end
endtask

// =============================================================================
// Control sequences
// =============================================================================
task stage_clear;
	if (unicode_available) begin
		case (unicode[6:0])
			CLEAR_SCREEN: begin
				ready_n <= FALSE_n;
				clear_screen();
			end
			CLEAR_BOL: begin
				ready_n <= FALSE_n;
				clear('d0, text_y, text_x, text_y);
			end
			CLEAR_EOL: begin
				ready_n <= FALSE_n;
				clear(text_x, text_y, COLUMNS - 'd1, text_y);
			end
			CLEAR_BOD: begin
				ready_n <= FALSE_n;
				clear('d0, 'd0, text_x + 'd1, text_y);
			end
			CLEAR_EOD: begin
				ready_n <= FALSE_n;
				clear(text_x, text_y, COLUMNS - 'd1, ROWS - 'd1);
			end
			CLEAR_LINE: begin
				ready_n <= FALSE_n;
				clear('d0, text_y, COLUMNS - 'd1, text_y);
			end

			default: begin
				if (unicode >= CLEAR_CHARS) begin
					ready_n <= FALSE_n;
					clear(text_x, text_y, text_x + unicode[6:0] - CLEAR_CHARS[6:0], text_y);
				end else begin
					ready_n <= TRUE_n;
					goto(STAGE_IDLE);
				end
			end
		endcase
	end else
		goto(STAGE_CLEAR);
endtask

task stage_color;
	if (unicode_available) begin
		if (unicode[4])
			background <= unicode[3:0];
		else
			foreground <= unicode[3:0];
		goto(STAGE_IDLE);
	end else
		goto(STAGE_COLOR);
endtask

task stage_cursor1;
	if (unicode_available) begin
		if (unicode[6:0] >= "0" && unicode[6:0] < ROWS + "0")
			in_y <= unicode[6:0] - "0";
		else
			in_y <= text_y;

		goto(STAGE_CURSOR2);
	end else
		goto(STAGE_CURSOR1);
endtask

task stage_cursor2;
	if (unicode_available) begin
		ts_command <= TS_CURSOR_SET;
		if (unicode[6:0] >= "0")
			in_x <= unicode[6:0] - "0";
		else
			in_x <= text_x;

		goto(STAGE_IDLE);
	end else
		goto(STAGE_CURSOR2);
endtask

task stage_attribute;
	if (unicode_available) begin
		case (unicode[6:0])
			ATTRIBUTE_RESET: reset_attributes();
			SET_UNDERLINE_ON: underline <= TRUE;
			SET_UNDERLINE_OFF: underline <= FALSE;
			SET_BLINK_ON: blink <= BLINK_NORMAL;
			SET_BLINK_OFF: blink <= BLINK_NONE;
			SET_HIGHLIGHT_ON: bold <= TRUE;
			SET_HIGHLIGHT_OFF: bold <= FALSE;
			SET_REVERSE_ON: invert <= TRUE;
			SET_REVERSE_OFF: invert <= FALSE;
			SET_SIZE_NORMAL: size <= SIZE_NORMAL;
			SET_SIZE_DBLWIDTH: size <= SIZE_DOUBLE_WIDTH;
			SET_SIZE_DBLHEIGHT: size <= SIZE_DOUBLE_HEIGHT;
			SET_SIZE_DOUBLE: size <= SIZE_DOUBLE;
		endcase
		goto(STAGE_IDLE);
	end else
		goto(STAGE_ATTRIBUTE);
endtask

task stage_parameter;
	if (unicode_available) begin
		case (unicode[6:0])
			CURSOR_VISIBLE: cursor_visible <= TRUE;
			CURSOR_EMPHASIZE: func <= 'd0;
			CURSOR_HIDDEN: cursor_visible <= FALSE;
			ORIENTATION_RIGHT: orientation <= TS_ORIENTATION_RIGHT;
			ORIENTATION_LEFT: orientation <= TS_ORIENTATION_LEFT;
			ORIENTATION_DOWN: orientation <= TS_ORIENTATION_DOWN;
			ORIENTATION_UP: orientation <= TS_ORIENTATION_UP;
		endcase

		goto(STAGE_IDLE);
	end else
		goto(STAGE_PARAMETER);
endtask


task stage_pattern;
	if (unicode_available) begin
		if (unicode[6]) begin
			func <= unicode[1:0];
			pattern <= unicode[5:2];
		end else begin
			func <= func;
			pattern <= pattern;
		end

		goto(STAGE_IDLE);
	end else
		goto(STAGE_PATTERN);
endtask

task stage_mouse_control;
	if (unicode_available) begin
		case (unicode[7:4])
			4'd3: set(VIDEO_MOUSE_CURSOR, { 21'b0, unicode[3:0] });
			4'd4: mouse_control <= unicode[1:0];
		endcase
		goto(STAGE_IDLE);
	end else
		goto(STAGE_MOUSE_CONTROL);
endtask

task stage_repeat;
	if (unicode_available) begin
		repeat_count <= unicode - 'h20;
		ready_n <= FALSE_n;
		goto(STAGE_IDLE);
	end else
		goto(STAGE_REPEAT);
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
		ts_command <= TS_CURSOR_NOP;

		case (stage)
			STAGE_IDLE: stage_idle();

			STAGE_CLEAR_WRITE: clear_write();
			STAGE_CLEAR_NEXT: clear_next();

			STAGE_CLEAR_SCREEN_WRITE: clear_screen_write();
			STAGE_CLEAR_SCREEN_NEXT: clear_screen_next();

			STAGE_WRITE_TOP_LEFT: stage_write_top_left();
			STAGE_WRITE_TOP_RIGHT: stage_write_top_right();
			STAGE_WRITE_BOTTOM_LEFT: stage_write_bottom_left();
			STAGE_WRITE_BOTTOM_RIGHT: stage_write_bottom_right();

			STAGE_CLEAR: stage_clear();
			STAGE_COLOR: stage_color();
			STAGE_CURSOR1: stage_cursor1();
			STAGE_CURSOR2: stage_cursor2();
			STAGE_ATTRIBUTE: stage_attribute();
			STAGE_PARAMETER: stage_parameter();
			STAGE_PATTERN: stage_pattern();
			STAGE_MOUSE_CONTROL: stage_mouse_control();
			STAGE_REPEAT: stage_repeat();
			STAGE_CURSOR_COMMAND1: stage_cursor_command1();
			STAGE_CURSOR_COMMAND2: stage_cursor_command2();
		endcase
	end
endmodule
