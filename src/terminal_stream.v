module terminal_stream (
	input wire clk,
	input wire reset,
	output reg ready_n,

	// Stream input
	input wire [7:0] unicode_w,
	input wire unicode_available_w,

	// SDRAM input
	output reg rd_request,
	output reg [22:0] rd_address,
	input wire [31:0] rd_data,
	input wire rd_available,
	output reg [8:0] rd_burst_length,

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

// Needed for timing constraints
reg [15:0] unicode_s;
reg [1:0] unicode_available_s;
wire [7:0] unicode = unicode_s[7:0];
wire unicode_available = unicode_available_s[0];
always @(posedge clk) if (ready_n == TRUE_n) begin
	unicode_s <= { unicode_w, unicode_s[15:8] };
	unicode_available_s <= { unicode_available_w, unicode_available_s[1] };
end

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
	STAGE_CURSOR_COMMAND2    = 'd19,
	STAGE_SELECT_ATTRIBUTES  = 'd20,
	STAGE_APPLY_ATTRIBUTES   = 'd21,
	STAGE_READ_CELL          = 'd22,
	STAGE_WRITE_CELL         = 'd23;

task goto;
	input [4:0] next_stage;
	stage <= next_stage;
endtask

// =============================================================================
// Cursor position
// =============================================================================
reg [7:0] last_unicode = 'd0;
reg [7:0] repeat_count = 'd0;
reg [7:0] apply_count = 'd0;

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
		wr_address_end <= real_row_address(first_row) + (ROW_SIZE - 'd4);
	end
endtask

task scroll_down;
	begin
		if (first_row == LAST_ROW) begin
			first_row <= FIRST_ROW;
			set(VIDEO_SET_FIRST_ROW, real_row_address(FIRST_ROW));
			wr_address <= real_row_address(FIRST_ROW);
			wr_address_end <= real_row_address(FIRST_ROW) + (ROW_SIZE - 'd4);
		end else begin
			first_row <= first_row + 'd1;
			set(VIDEO_SET_FIRST_ROW, real_row_address(first_row + 'd1));
			wr_address <= real_row_address(first_row);
			wr_address_end <= real_row_address(first_row) + (ROW_SIZE - 'd4);
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
			wr_address_end <= real_row_address(LAST_ROW) + (ROW_SIZE - 'd4);
		end else begin
			first_row <= first_row - 6'd1;
			set(VIDEO_SET_FIRST_ROW, real_row_address(first_row - 6'd1));
			wr_address <= real_row_address(first_row - 6'd1);
			wr_address_end <= real_row_address(first_row - 6'd1) + (ROW_SIZE - 'd4);
		end

		goto(STAGE_CLEAR_WRITE);
	end
endtask

reg ignore_size = FALSE;
ts_cursor #(
	.COLUMNS (COLUMNS),
	.ROWS (ROWS)
) ts_cursor (
	.clk (clk),
	.reset (reset),
	.command (ts_command),
	.horz_size (size[0]),
	.vert_size (size[1]),
	.ignore_size (ignore_size),
	.orientation (orientation),
	.in_x (in_x),
	.in_y (in_y),
	.x (text_x),
	.y (text_y),
	.scroll (scroll)
);

task line_feed;
	begin
		ignore_size <= FALSE;
		ts_command <= TS_CURSOR_LINE_FEED;
		ready_n <= FALSE_n;
		goto(STAGE_CURSOR_COMMAND1);
	end
endtask

task next_char;
	begin
		ignore_size <= FALSE;
		repeat_count <= repeat_count - { 7'b0, repeat_count != 'd0 };
		ts_command <= TS_CURSOR_NEXT_CHAR;
		ready_n <= FALSE_n;
		goto(STAGE_CURSOR_COMMAND1);
	end
endtask

task next_cell;
	begin
		ignore_size <= TRUE;
		apply_count <= apply_count - { 7'b0, apply_count != 'd0 };
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
			ready_n <= (repeat_count != 'd0 || apply_count != 'd0);
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
wire [22:0] current_address = address_from_position(text_x, text_y);
wire no_repeat = repeat_count == 'd0 && apply_count == 'd0;
task stage_idle;
	begin
		if (apply_count != 'd0) begin
			ready_n <= FALSE_n;
			rd_request <= TRUE;
			rd_address <= current_address;
			rd_burst_length <= 'd1;
			goto(STAGE_READ_CELL);
		end

		if (repeat_count != 'd0) begin
			ready_n <= FALSE_n;
			wr_request <= TRUE;
			wr_address <= current_address;
			wr_data <= generate_cell_part(last_unicode, PART_TOP_LEFT);
			current_pixels_offset <= 2'd0;
			goto(STAGE_WRITE_TOP_LEFT);
		end

		if (no_repeat && unicode_available) begin
			case (unicode)
				CTRL_CODE_00: goto(STAGE_IDLE);
				CTRL_CLEAR: goto(STAGE_CLEAR);
				CTRL_COLOR: goto(STAGE_COLOR);
				CTRL_PATTERN: goto(STAGE_PATTERN);
				CTRL_CURSOR: goto(STAGE_CURSOR1);
				CTRL_ATTRIBUTE: goto(STAGE_ATTRIBUTE);
				CTRL_PARAMETER: goto(STAGE_PARAMETER);
				BELL: goto(STAGE_IDLE);
				CTRL_SELECT_ATTRIBUTES: goto(STAGE_SELECT_ATTRIBUTES);
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

				CTRL_CHARPAGE_0: charpage_base <= CHARPAGE_0;
				CTRL_CHARPAGE_1: charpage_base <= CHARPAGE_1;
				CTRL_CHARPAGE_2: charpage_base <= CHARPAGE_2;
				CTRL_CHARPAGE_3: charpage_base <= CHARPAGE_3;
				CTRL_CHARPAGE_4: charpage_base <= CHARPAGE_4;

				CTRL_CHARPAGE_GFX: begin
					current_pixels_offset <= 2'd0;
					charpage_base <= CHARPAGE_GFX;
				end

				CTRL_MOUSE_CONTROL: goto(STAGE_MOUSE_CONTROL);

				CTRL_APPLY_ATTRIBUTES: goto(STAGE_APPLY_ATTRIBUTES);

				CTRL_CODE_1B, CTRL_CODE_1C, CTRL_CODE_1D, CTRL_CODE_1E,
				CTRL_CODE_1F: goto(STAGE_IDLE);

				default: begin
					if (charpage_base == CHARPAGE_GFX) begin
						case (current_pixels_offset)
							2'd0: begin
								ready_n <= TRUE_n;
								current_pixels[13:7] <= unicode[6:0];
								current_pixels_offset <= 2'd1;
								goto(STAGE_IDLE);
							end
							
							2'd1: begin
								ready_n <= TRUE_n;
								current_pixels[6:0] <= unicode[6:0];
								current_pixels_offset <= 2'd2;
								goto(STAGE_IDLE);
							end
							
							default: begin
								ready_n <= FALSE_n;
								size <= SIZE_NORMAL;
								wr_request <= TRUE;
								wr_address <= current_address;
								wr_data <= generate_cell_gfx({ current_pixels, unicode[5:0] }, unicode[6]);
								current_pixels_offset <= 2'd0;
								goto(STAGE_WRITE_TOP_LEFT);
							end
						endcase
					end else begin
						ready_n <= FALSE_n;
						wr_request <= TRUE;
						wr_address <= current_address;
						wr_data <= generate_cell_part(unicode, PART_TOP_LEFT);
						last_unicode <= unicode;
						current_pixels_offset <= 2'd0;
						goto(STAGE_WRITE_TOP_LEFT);
					end
				end
			endcase
		end
		
		if (no_repeat && ~unicode_available) begin
			ready_n <= TRUE_n;
			goto(STAGE_IDLE);
			set(
				VIDEO_CURSOR_POSITION,
				{7'b0, size, cursor_visible, text_y, text_x}
			);
		end
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
	else
		wr_request <= FALSE;
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
	else
		wr_request <= FALSE;
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
	else
		wr_request <= FALSE;
endtask

task stage_write_bottom_right;
	begin
		wr_request <= FALSE;
		if (wr_done) next_char();
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
			case (wr_address)
				wr_address_end: goto(STAGE_IDLE);

				{ 8'b0, 6'd51, 7'd80, 2'b00 }:  begin
					wr_address <= 'd0;
					goto(STAGE_CLEAR_WRITE);
				end

				default: begin
					wr_address <= wr_address + 'd4;
					goto(STAGE_CLEAR_WRITE);
				end
			endcase
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
// Apply attributes to existing cells
// =============================================================================
reg apply_background = FALSE;
reg apply_foreground = FALSE;
reg apply_function = FALSE;
reg apply_underline = FALSE;
reg apply_invert = FALSE;
reg apply_pattern = FALSE;
reg apply_blink = FALSE;
wire [31:0] apply_mask = {
	apply_background, apply_background, apply_background, apply_background,
	apply_foreground, apply_foreground, apply_foreground, apply_foreground,
	apply_pattern, apply_pattern, apply_pattern, apply_pattern,
	apply_function, apply_function,
	apply_underline,
	apply_invert,
	apply_blink, apply_blink,
	14'b0
};

task stage_apply_attributes;
	if (unicode_available) begin
		apply_count <= unicode - 'h20;
		ready_n <= FALSE_n;
		goto(STAGE_IDLE);
	end
endtask

task stage_read_cell();
	begin
		ready_n <= FALSE_n;
		rd_request <= FALSE;

		if (rd_available) begin
			wr_request <= TRUE;
			wr_address <= current_address;
			wr_data <=
				(rd_data & ~apply_mask)
				| (generate_cell_part('d0, PART_TOP_LEFT) & apply_mask);
			goto(STAGE_WRITE_CELL);
		end
	end
endtask

task stage_write_cell();
	begin
		ready_n <= FALSE_n;
		wr_request <= FALSE;
		if (wr_done) next_cell();
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
	end
endtask

task stage_color;
	if (unicode_available) begin
		if (unicode[4])
			background <= unicode[3:0];
		else
			foreground <= unicode[3:0];
		goto(STAGE_IDLE);
	end
endtask

task stage_cursor1;
	if (unicode_available) begin
		if (unicode[6:0] >= "0" && unicode[6:0] < ROWS + "0")
			in_y <= unicode[6:0] - "0";
		else
			in_y <= text_y;

		goto(STAGE_CURSOR2);
	end
endtask

task stage_cursor2;
	if (unicode_available) begin
		ts_command <= TS_CURSOR_SET;
		if (unicode[6:0] >= "0")
			in_x <= unicode[6:0] - "0";
		else
			in_x <= text_x;

		goto(STAGE_IDLE);
	end
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
	end
endtask

task stage_select_attributes;
	if (unicode_available) begin
		{
			apply_background,
			apply_foreground,
			apply_pattern,
			apply_function,
			apply_underline,
			apply_invert,
			apply_blink
		} <= unicode[6:0];
		goto(STAGE_IDLE);
	end
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
	end
endtask

task stage_pattern;
	if (unicode_available) begin
		if (unicode[6]) begin
			func <= unicode[1:0];
			pattern <= unicode[5:2];
		end

		goto(STAGE_IDLE);
	end
endtask

task stage_mouse_control;
	if (unicode_available) begin
		case (unicode[7:4])
			4'd3: set(VIDEO_MOUSE_CURSOR, { 21'b0, unicode[3:0] });
			4'd4: mouse_control <= unicode[1:0];
		endcase
		goto(STAGE_IDLE);
	end
endtask

task stage_repeat;
	if (unicode_available) begin
		repeat_count <= unicode - 'h20;
		ready_n <= FALSE_n;
		goto(STAGE_IDLE);
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
		rd_address <= 'd0;
		rd_request <= FALSE;
		rd_burst_length <= 'd1;
		apply_count <= 'd0;
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

			STAGE_SELECT_ATTRIBUTES: stage_select_attributes();
			STAGE_APPLY_ATTRIBUTES: stage_apply_attributes();
			STAGE_READ_CELL: stage_read_cell();
			STAGE_WRITE_CELL: stage_write_cell();
			default: stage_idle();
		endcase
	end
endmodule
