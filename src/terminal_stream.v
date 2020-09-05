module terminal_stream #(
	parameter COLUMNS = 80,
	parameter ROWS = 51
) (
	input wire clk,
	input wire reset,

	// Stream input
	input wire [20:0] unicode,
	input wire unicode_available,

	// SDRAM output
	output reg [22:0] wr_address,
	output reg wr_request,
	output reg [31:0] wr_data,
	output reg [3:0] wr_mask,
	input wire wr_done
);

localparam
	TRUE = 1'b1,
	FALSE = 1'b0,

	LAST_ADDRESS = 4 * (COLUMNS * ROWS - 1),

	SPACE_CHARACTER = 10'h020,

	DEFAULT_FOREGROUND = 4'd15,
	DEFAULT_BACKGROUND = 4'd0,

	SIZE_NORMAL = 2'b00,
	SIZE_DOUBLE_WIDTH = 2'b01,
	SIZE_DOUBLE_HEIGHT = 2'b10,
	SIZE_DOUBLE = 2'b11,

	PART_TOP_LEFT = 2'b00,
	PART_TOP_RIGHT = 2'b01,
	PART_BOTTOM_LEFT = 2'b10,
	PART_BOTTOM_RIGHT = 2'b11,

	BLINK_NONE = 2'b00,
	BLINK_SLOW = 2'b01,
	BLINK_NORMAL = 2'b10,
	BLINK_FAST = 2'b11,

	LOGICAL_AND = 2'b00,
	LOGICAL_OR = 2'b01,
	LOGICAL_XOR = 2'b10,
	LOGICAL_NONE = 2'b11,
	
	PATTERN_NONE = 4'b0000,

	CLS = 1,
	DBLWIDTH = 2,
	CR = 13,
	LF = 10;

// Automaton registers
reg [6:0] text_x;
reg [5:0] text_y;

reg [3:0] foreground;
reg [3:0] background;

reg [1:0] blink;

reg [1:0] size;
reg [1:0] func;

// =============================================================================
// Stage management
// =============================================================================
reg [7:0] stage;
localparam
	STAGE_IDLE = 'd0,
	STAGE_CLEAR_SCREEN_START = 'd1,
	STAGE_CLEAR_SCREEN_WRITE = 'd2,
	STAGE_CLEAR_SCREEN_NEXT = 'd3,
	STAGE_WRITE = 'd4;

task goto;
	input [7:0] next_stage;
	stage <= next_stage;
endtask

// =============================================================================
// Generate a cell
// =============================================================================
function [31:0] generate_cell;
	input [9:0] ord;
	input [1:0] size;
	input [1:0] part;
	input [1:0] blink;
	input invert;
	input underline;
	input [1:0] func;
	input [3:0] pattern;
	input [3:0] foreground;
	input [3:0] background;

	generate_cell = {
		background, foreground, pattern, func, underline, invert, blink,
		part, size, ord
	};
endfunction

function clear_cell;
	input [9:0] ord;
	clear_cell = generate_cell(
		.ord (ord),
		.size (SIZE_NORMAL),
		.part (PART_TOP_LEFT),
		.blink (BLINK_NONE),
		.invert (FALSE),
		.underline (FALSE),
		.func (LOGICAL_OR),
		.pattern (PATTERN_NONE),
		.foreground (DEFAULT_FOREGROUND),
		.background (DEFAULT_BACKGROUND)
	);
endfunction

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
	address_from_position = { 13'b0, x, 2'b00 } + { 14'b0, y, 2'b00 } * COLUMNS;
endfunction

// =============================================================================
// Idle stage
// =============================================================================
task stage_idle;
	if (unicode_available) begin
		if (unicode == CLS) goto(STAGE_CLEAR_SCREEN_START);
		else if (unicode == CR) text_x <= 'd0;
		else if (unicode == LF) line_feed();
		else if (unicode == DBLWIDTH) size <= SIZE_DOUBLE_WIDTH;
		else begin
			wr_request <= TRUE;
			wr_address <= address_from_position(text_x, text_y);
			wr_data <= generate_cell(
				.ord (unicode[9:0]),
				.size (size),
				.part (PART_TOP_LEFT),
				.blink (blink),
				.invert (FALSE),
				.underline (FALSE),
				.func (func),
				.pattern (PATTERN_NONE),
				.foreground (foreground),
				.background (background)
			);

			next_char();
			goto(STAGE_WRITE);
		end
	end
endtask

task stage_write;
	begin
		wr_request <= FALSE;
		if (wr_done)
			goto(STAGE_IDLE);
		else
			goto(STAGE_WRITE);
	end
endtask

// =============================================================================
// Clear screen
// =============================================================================
task clear_screen_start;
	begin
		wr_address <= 'd0;
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
			if (wr_address == LAST_ADDRESS) begin
				text_x <= 'd0;
				text_y <= 'd0;
				size <= SIZE_NORMAL;
				goto(STAGE_IDLE);
			end else begin
				wr_address <= wr_address + 'd4;
				goto(STAGE_CLEAR_SCREEN_WRITE);
			end
		end
	end
endtask

// =============================================================================
// Automaton
// =============================================================================
always @(posedge clk)
	if (reset) begin
		wr_address <= 'd0;
		wr_request <= FALSE;
		wr_mask <= 4'b1111;
		stage <= STAGE_CLEAR_SCREEN_START;
		foreground <= DEFAULT_FOREGROUND;
		background <= DEFAULT_BACKGROUND;
		blink <= BLINK_NONE;
		size <= SIZE_NORMAL;
		func <= LOGICAL_AND;
	end else
		case (stage)
			STAGE_IDLE: stage_idle();

			STAGE_CLEAR_SCREEN_START: clear_screen_start();
			STAGE_CLEAR_SCREEN_WRITE: clear_screen_write();
			STAGE_CLEAR_SCREEN_NEXT: clear_screen_next();

			STAGE_WRITE: stage_write();
		endcase
endmodule
