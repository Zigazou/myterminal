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

localparam
	TRUE = 1'b1,
	FALSE = 1'b0,
	TRUE_n = 1'b0,
	FALSE_n = 1'b1,

	REAL_WIDTH = 'd128,

	LAST_ADDRESS = 4 * (REAL_WIDTH * ROWS - 1),

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
	CR = 13,
	LF = 10,

	ESC = 'h1B,
	ESC_SIZE_NORMAL = 'h4C,
	ESC_SIZE_DOUBLE_HEIGHT = 'h4D,
	ESC_SIZE_DOUBLE_WIDTH = 'h4E,
	ESC_SIZE_DOUBLE = 'h4F,

	CSI = 'h5B,
	CSI_CURSOR_POSITION = 'h48,
	CSI_SEPARATOR = 'h3B,

	SGR = 'h6D,
	SGR_RESET = 'd0,
	SGR_UNDERLINE_ON = 'd4,
	SGR_UNDERLINE_OFF = 'd24,
	SGR_BLINK_SLOW = 'd5,
	SGR_BLINK_FAST = 'd6,
	SGR_BLINK_OFF = 'd25,
	SGR_INVERT_ON = 'd7,
	SGR_INVERT_OFF = 'd27;

// Automaton registers
reg [6:0] text_x;
reg [5:0] text_y;

reg [3:0] foreground;
reg [3:0] background;

reg [1:0] blink;
reg invert;
reg underline;

reg [1:0] size;
reg [1:0] func;
reg [3:0] pattern;

// =============================================================================
// Stage management
// =============================================================================
reg [7:0] stage;
localparam
	STAGE_IDLE               = 'd0,
	STAGE_CLEAR_SCREEN_START = 'd1,
	STAGE_CLEAR_SCREEN_WRITE = 'd2,
	STAGE_CLEAR_SCREEN_NEXT  = 'd3,
	STAGE_WRITE_TOP_LEFT     = 'd4,
	STAGE_WRITE_TOP_RIGHT    = 'd5,
	STAGE_WRITE_BOTTOM_LEFT  = 'd6,
	STAGE_WRITE_BOTTOM_RIGHT = 'd7,
	STAGE_ESC                = 'd8,
	STAGE_CSI                = 'd9;

task goto;
	input [7:0] next_stage;
	stage <= next_stage;
endtask

// =============================================================================
// Generate a cell
// =============================================================================
function [31:0] generate_cell;
	input [20:0] ord;
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
		part, size, ord[9:0]
	};
endfunction

function [31:0] generate_cell_part;
	input [20:0] ord;
	input [1:0] part;

	generate_cell_part = generate_cell(
		.ord (ord),
		.size (size),
		.part (part),
		.blink (blink),
		.invert (invert),
		.underline (underline),
		.func (func),
		.pattern (pattern),
		.foreground (foreground),
		.background (background)

	);
endfunction

function clear_cell;
	input [20:0] ord;
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
	address_from_position = { 8'b0, y, x, 2'b00 };
endfunction

// =============================================================================
// Idle stage
// =============================================================================
task stage_idle;
	if (unicode_available) begin
		if (unicode == CLS) goto(STAGE_CLEAR_SCREEN_START);
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
task clear_screen_start;
	begin
		wr_address <= 'd0;
		ready_n <= FALSE_n;
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
				ready_n <= TRUE_n;
				goto(STAGE_IDLE);
			end else begin
				wr_address <= wr_address + 'd4;
				goto(STAGE_CLEAR_SCREEN_WRITE);
			end
		end
	end
endtask

// =============================================================================
// Control sequences
// =============================================================================
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
			end else if (unicode == CSI_CURSOR_POSITION) begin
				text_y <= arguments[0] == 'd0 ? 'd0 : arguments[0] - 'd1; 
				text_x <= arguments[1] == 'd0 ? 'd0 : arguments[1] - 'd1;
				goto(STAGE_IDLE);
			end else
				goto(STAGE_CSI);
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
		foreground <= DEFAULT_FOREGROUND;
		background <= DEFAULT_BACKGROUND;
		blink <= BLINK_NONE;
		size <= SIZE_NORMAL;
		func <= LOGICAL_AND;
		pattern <= PATTERN_NONE;
		invert <= FALSE;
		underline <= FALSE;
		ready_n <= FALSE_n;
		wr_burst_length <= 'd1;
		goto(STAGE_CLEAR_SCREEN_START);
	end else begin
		case (stage)
			STAGE_IDLE: stage_idle();

			STAGE_CLEAR_SCREEN_START: clear_screen_start();
			STAGE_CLEAR_SCREEN_WRITE: clear_screen_write();
			STAGE_CLEAR_SCREEN_NEXT: clear_screen_next();

			STAGE_WRITE_TOP_LEFT: stage_write_top_left();
			STAGE_WRITE_TOP_RIGHT: stage_write_top_right();
			STAGE_WRITE_BOTTOM_LEFT: stage_write_bottom_left();
			STAGE_WRITE_BOTTOM_RIGHT: stage_write_bottom_right();

			STAGE_ESC: stage_esc();
			STAGE_CSI: stage_csi();
		endcase
	end
endmodule
