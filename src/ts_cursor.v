module ts_cursor #(
	parameter COLUMNS = 7'd80,
	parameter ROWS = 6'd51
) (
	input wire clk,
	input wire reset,

	input wire [2:0] command,
	input wire horz_size,
	input wire vert_size,
	input wire [1:0] orientation,
	input wire [6:0] in_x,
	input wire [5:0] in_y,

	output reg [6:0] x,
	output reg [5:0] y,
	output reg scroll
);

`include "constant.v"
`include "ts_cursor.vh"

localparam
	FIRST_ROW     = 6'd0,
	LAST_ROW      = ROWS - 6'd1,
	FIRST_COLUMN  = 7'd0,
	LAST_COLUMN   = COLUMNS - 7'd1;

// =============================================================================
// Text size
// =============================================================================
localparam
	NORMAL_SIZE   = 2'b00,
	DOUBLE_HEIGHT = 2'b01,
	DOUBLE_WIDTH  = 2'b10,
	DOUBLE_SIZE   = 2'b11;

wire [1:0] text_size = { horz_size, vert_size };

// =============================================================================
// Cursor goes to the right automatically
// =============================================================================
task next_char_right;
	case (text_size)
		NORMAL_SIZE:
			if (y == LAST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				scroll <= TRUE;
			end else if (x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= y + 'd1;
				scroll <= FALSE;
			end else begin
				x <= x + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_HEIGHT:
			if (y == LAST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW - 'd1 && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				scroll <= TRUE;
			end else if (x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= y + 'd2;
				scroll <= FALSE;
			end else begin
				x <= x + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_WIDTH:
			if (y == LAST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				scroll <= TRUE;
			end else if (y == LAST_ROW && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				scroll <= TRUE;
			end else if (x == LAST_COLUMN || x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= y + 'd1;
				scroll <= FALSE;
			end else begin
				x <= x + 'd2;
				scroll <= FALSE;
			end

		DOUBLE_SIZE:
			if (y == LAST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW - 'd1 && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				scroll <= TRUE;
			end else if (y == LAST_ROW - 'd1 && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				scroll <= TRUE;
			end else if (x == LAST_COLUMN || x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= y + 'd2;
				scroll <= FALSE;
			end else begin
				x <= x + 'd2;
				scroll <= FALSE;
			end
	endcase
endtask

// =============================================================================
// Cursor goes to the left automatically
// =============================================================================
task next_char_left;
	case (text_size)
		NORMAL_SIZE:
			if (y == LAST_ROW && x == FIRST_COLUMN) begin
				x <= LAST_COLUMN;
				scroll <= TRUE;
			end else if (x == FIRST_COLUMN) begin
				x <= LAST_COLUMN;
				y <= y + 'd1;
				scroll <= FALSE;
			end else begin
				x <= x - 'd1;
				scroll <= FALSE;
			end

		DOUBLE_HEIGHT:
			if (y == LAST_ROW && x == FIRST_COLUMN) begin
				x <= LAST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW - 'd1 && x == FIRST_COLUMN) begin
				x <= LAST_COLUMN;
				scroll <= TRUE;
			end else if (x == FIRST_COLUMN) begin
				x <= LAST_COLUMN;
				y <= y + 'd2;
				scroll <= FALSE;
			end else begin
				x <= x - 'd1;
				scroll <= FALSE;
			end

		DOUBLE_WIDTH:
			if (y == LAST_ROW && x == FIRST_COLUMN) begin
				x <= LAST_COLUMN - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW && x == FIRST_COLUMN + 'd1) begin
				x <= LAST_COLUMN - 'd1;
				scroll <= TRUE;
			end else if (x == FIRST_COLUMN || x == FIRST_COLUMN + 'd1) begin
				x <= LAST_COLUMN - 'd1;
				y <= y + 'd1;
				scroll <= FALSE;
			end else begin
				x <= x - 'd2;
				scroll <= FALSE;
			end

		DOUBLE_SIZE:
			if (y == LAST_ROW && x == FIRST_COLUMN) begin
				x <= LAST_COLUMN - 'd1;
				y <= LAST_ROW - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW && x == FIRST_COLUMN + 'd1) begin
				x <= LAST_COLUMN - 'd1;
				y <= LAST_ROW - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW - 'd1 && x == FIRST_COLUMN) begin
				x <= LAST_COLUMN - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW - 'd1 && x == FIRST_COLUMN + 'd1) begin
				x <= LAST_COLUMN - 'd1;
				scroll <= TRUE;
			end else if (x == FIRST_COLUMN || x == FIRST_COLUMN + 'd1) begin
				x <= LAST_COLUMN - 'd1;
				y <= y + 'd2;
				scroll <= FALSE;
			end else begin
				x <= x - 'd2;
				scroll <= FALSE;
			end
	endcase
endtask

// =============================================================================
// Cursor goes down automatically
// =============================================================================
task next_char_down;
	case (text_size)
		NORMAL_SIZE:
			if (y == LAST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW) begin
				x <= x + 'd1;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else begin
				y <= y + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_HEIGHT:
			if (y == LAST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW - 'd1 && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW || y == LAST_ROW - 'd1) begin
				x <= x + 'd1;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else begin
				x <= x + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_WIDTH:
			if (y == LAST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW) begin
				x <= x + 'd2;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else begin
				y <= y + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_SIZE:
			if (y == LAST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW - 'd1 && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW - 'd1 && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (y == LAST_ROW || y == LAST_ROW - 'd1) begin
				x <= x + 'd2;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else begin
				y <= y + 'd2;
				scroll <= FALSE;
			end
	endcase
endtask

// =============================================================================
// Cursor goes up automatically
// =============================================================================
task next_char_up;
	case (text_size)
		NORMAL_SIZE:
			if (y == FIRST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW;
				scroll <= FALSE;
			end else if (y == FIRST_ROW) begin
				x <= x + 'd1;
				y <= LAST_ROW;
				scroll <= FALSE;
			end else begin
				y <= y - 'd1;
				scroll <= FALSE;
			end

		DOUBLE_HEIGHT:
			if (y == FIRST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else if (y == FIRST_ROW + 'd1 && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else if (y == FIRST_ROW || y == FIRST_ROW + 'd1) begin
				x <= x + 'd1;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else begin
				y <= y - 'd1;
				scroll <= FALSE;
			end

		DOUBLE_WIDTH:
			if (y == FIRST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW;
				scroll <= FALSE;
			end else if (y == FIRST_ROW && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW;
				scroll <= FALSE;
			end else if (y == FIRST_ROW) begin
				x <= x + 'd2;
				y <= LAST_ROW;
				scroll <= FALSE;
			end else begin
				y <= y - 'd1;
				scroll <= FALSE;
			end

		DOUBLE_SIZE:
			if (y == FIRST_ROW && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else if (y == FIRST_ROW && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else if (y == FIRST_ROW + 'd1 && x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else if (y == FIRST_ROW + 'd1 && x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else if (y == FIRST_ROW || y == FIRST_ROW - 'd1) begin
				x <= x + 'd2;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else begin
				y <= y - 'd2;
				scroll <= FALSE;
			end
	endcase
endtask

// =============================================================================
// Line feed right
// =============================================================================
task line_feed_right;
	case (text_size)
		NORMAL_SIZE, DOUBLE_WIDTH:
			if (y == LAST_ROW) begin
				x <= FIRST_COLUMN;
				scroll <= TRUE;
			end else begin
				x <= FIRST_COLUMN;
				y <= y + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_HEIGHT, DOUBLE_SIZE:
			if (y == LAST_ROW) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW - 'd1) begin
				x <= FIRST_COLUMN;
				scroll <= TRUE;
			end else begin
				x <= FIRST_COLUMN;
				y <= y + 'd2;
				scroll <= FALSE;
			end
	endcase
endtask

// =============================================================================
// Line feed left
// =============================================================================
task line_feed_left;
	case (text_size)
		NORMAL_SIZE, DOUBLE_WIDTH:
			if (y == LAST_ROW) begin
				x <= LAST_COLUMN;
				scroll <= TRUE;
			end else begin
				x <= LAST_COLUMN;
				y <= y + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_HEIGHT, DOUBLE_SIZE:
			if (y == LAST_ROW) begin
				x <= LAST_COLUMN - 'd1;
				y <= LAST_ROW - 'd1;
				scroll <= TRUE;
			end else if (y == LAST_ROW - 'd1) begin
				x <= LAST_COLUMN - 'd1;
				scroll <= TRUE;
			end else begin
				x <= LAST_COLUMN - 'd1;
				y <= y + 'd2;
				scroll <= FALSE;
			end
	endcase
endtask

// =============================================================================
// Line feed down
// =============================================================================
task line_feed_down;
	case (text_size)
		NORMAL_SIZE, DOUBLE_HEIGHT:
			if (x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else begin
				y <= FIRST_ROW;
				x <= x + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_WIDTH, DOUBLE_SIZE:
			if (x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else if (x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= FIRST_ROW;
				scroll <= FALSE;
			end else begin
				y <= FIRST_ROW;
				x <= x + 'd2;
				scroll <= FALSE;
			end
	endcase
endtask

// =============================================================================
// Line feed up
// =============================================================================
task line_feed_up;
	case (text_size)
		NORMAL_SIZE:
			if (x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW;
				scroll <= FALSE;
			end else begin
				y <= LAST_ROW;
				x <= x + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_HEIGHT:
			if (x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else begin
				y <= LAST_ROW - 'd1;
				x <= x + 'd1;
				scroll <= FALSE;
			end

		DOUBLE_WIDTH:
			if (x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW;
				scroll <= FALSE;
			end else if (x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW;
				scroll <= FALSE;
			end else begin
				y <= LAST_ROW;
				x <= x + 'd2;
				scroll <= FALSE;
			end

		DOUBLE_SIZE:
			if (x == LAST_COLUMN) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else if (x == LAST_COLUMN - 'd1) begin
				x <= FIRST_COLUMN;
				y <= LAST_ROW - 'd1;
				scroll <= FALSE;
			end else begin
				y <= LAST_ROW - 'd1;
				x <= x + 'd2;
				scroll <= FALSE;
			end
	endcase
endtask

// =============================================================================
// Cursor automaton
// =============================================================================
always @(posedge clk)
	if (reset) begin
		x <= FIRST_COLUMN;
		y <= FIRST_ROW;
		scroll <= FALSE;
	end else case (command)
		TS_CURSOR_NOP: scroll <= FALSE;

		TS_CURSOR_SET: begin
			scroll <= FALSE;
			x <= in_x;
			y <= in_y;
		end

		TS_CURSOR_UP: if (y != FIRST_ROW) y <= y - 'd1;
		TS_CURSOR_DOWN: if (y != LAST_ROW) y <= y + 'd1;
		TS_CURSOR_LEFT: if (x != FIRST_COLUMN) x <= x - 'd1;
		TS_CURSOR_RIGHT: if (x != LAST_COLUMN) x <= x + 'd1;

		TS_CURSOR_NEXT_CHAR: case (orientation)
			TS_ORIENTATION_RIGHT: next_char_right();
			TS_ORIENTATION_LEFT: next_char_left();
			TS_ORIENTATION_DOWN: next_char_down();
			TS_ORIENTATION_UP: next_char_up();
		endcase

		TS_CURSOR_LINE_FEED: case (orientation)
			TS_ORIENTATION_RIGHT: line_feed_right();
			TS_ORIENTATION_LEFT: line_feed_left();
			TS_ORIENTATION_DOWN: line_feed_down();
			TS_ORIENTATION_UP: line_feed_up();
		endcase

		default: scroll <= FALSE;
	endcase
endmodule