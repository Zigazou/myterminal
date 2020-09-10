localparam
	SPACE_CHARACTER    = 10'h020,

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
reg [6:0] text_x;
reg [5:0] text_y;

reg [3:0] foreground;
reg [3:0] background;
reg bold;

reg [1:0] blink;
reg invert;
reg underline;

reg [1:0] size;
reg [1:0] func;
reg [3:0] pattern;

task reset_position;
	begin
		text_x <= 'd0;
		text_y <= 'd0;
	end
endtask

task reset_attributes;
	begin
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
		background, foreground, pattern, func, underline,
		invert, blink, part, size, ord[9:0]
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
		.foreground (foreground | { bold, 3'b000 }),
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
