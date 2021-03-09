localparam
	SPACE_CHARACTER    = 10'h020,

	CHARPAGE_0         = 5'h00,
	CHARPAGE_1         = 5'h04,
	CHARPAGE_2         = 5'h0b,
	CHARPAGE_3         = 5'h12,
	CHARPAGE_4         = 5'h19,

	DEFAULT_FOREGROUND = 4'd7,
	DEFAULT_BACKGROUND = 4'd0,

	SIZE_NORMAL        = 2'b00,
	SIZE_DOUBLE_WIDTH  = 2'b01,
	SIZE_DOUBLE_HEIGHT = 2'b10,
	SIZE_DOUBLE        = 2'b11,

	PART_TOP_LEFT      = 2'b00,
	PART_TOP_RIGHT     = 2'b01,
	PART_BOTTOM_LEFT   = 2'b10,
	PART_BOTTOM_RIGHT  = 2'b11,

	BLINK_NONE         = 2'b00,
	BLINK_SLOW         = 2'b01,
	BLINK_NORMAL       = 2'b10,
	BLINK_FAST         = 2'b11,

	LOGICAL_AND        = 2'b00,
	LOGICAL_OR         = 2'b01,
	LOGICAL_XOR        = 2'b10,
	LOGICAL_NONE       = 2'b11,

	PATTERN_NONE       = 4'b0000
;

// Automaton registers
reg [5:0] first_row;
reg [6:0] text_x;
reg [5:0] text_y;
reg cursor_visible;

reg [9:0] charpage_base;

reg [3:0] foreground;
reg [3:0] background;
reg bold;

reg [1:0] blink;
reg invert;
reg underline;

reg [1:0] size;
reg [1:0] func;
reg [3:0] pattern;

task reset_all;
    begin
        first_row <= 'd0;
        cursor_visible <= TRUE;
        reset_position();
        reset_attributes();
    end
endtask

task reset_position;
	begin
		text_x <= 'd0;
		text_y <= 'd0;
	end
endtask

task reset_attributes;
	begin
		charpage_base <= CHARPAGE_0;
		foreground <= DEFAULT_FOREGROUND;
		background <= DEFAULT_BACKGROUND;
		bold <= FALSE;
		blink <= BLINK_NONE;
		size <= SIZE_NORMAL;
		func <= LOGICAL_AND;
		pattern <= PATTERN_NONE;
		invert <= FALSE;
		underline <= FALSE;
	end
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
		background, foreground, pattern, func, underline,
		invert, blink, part, size, ord
	};
endfunction

function [31:0] generate_cell_part;
	input [7:0] ord;
	input [1:0] part;

	generate_cell_part = generate_cell(
		.ord ({ charpage_base, 5'b0 } + { 2'b0, ord }),
		.size (size),
		.part (part),
		.blink (blink),
		.invert (invert),
		.underline (underline),
		.func (func),
		.pattern (pattern),
		.foreground (foreground | { bold, 3'b000 }),
		.background (background)
	);
endfunction

function [31:0] clear_cell;
	input [9:0] ord;
	clear_cell = generate_cell(
		.ord (ord),
		.size (SIZE_NORMAL),
		.part (PART_TOP_LEFT),
		.blink (BLINK_NONE),
		.invert (FALSE),
		.underline (FALSE),
		.func (LOGICAL_AND),
		.pattern (PATTERN_NONE),
		.foreground (foreground | { bold, 3'b000 }),
		.background (background)
	);
endfunction
