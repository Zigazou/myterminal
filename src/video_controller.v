module video_controller #(
	// Video parameters (1280×1024@60Hz, dot clock = 108 MHz)
	parameter HORZ_BACK_PORCH   = 248,
	parameter HORZ_VISIBLE      = 1280,
	parameter HORZ_FRONT_PORCH  = 48,
	parameter HORZ_SYNC         = 112,

	parameter VERT_BACK_PORCH   = 38,
	parameter VERT_VISIBLE      = 1024,
	parameter VERT_FRONT_PORCH  = 1,
	parameter VERT_SYNC         = 3,

	// Character dimensions
	parameter CHAR_WIDTH        = 'd16,
	parameter CHAR_HEIGHT       = 'd20
) (
	// Base signals
	input wire clk,
	input wire reset,

	// VGA output
	output wire hsync,
	output wire vsync,
	output reg [2:0] pixel_red,
	output reg [2:0] pixel_green,
	output reg [2:0] pixel_blue,

	// SDRAM interface
	output reg rd_request,
	output reg [22:0] rd_address,
	input wire rd_available,
	input wire [31:0] rd_data,
	output reg [8:0] rd_burst_length,

	// Font interface
    output reg [14:0] font_address,
    input wire [CHAR_WIDTH - 1:0] char_row_bitmap
);

`include "constant.v"

`include "video_controller/generate_pattern.v"
`include "video_controller/apply_pattern.v"
`include "video_controller/horizontal_resize.v"
`include "video_controller/vertical_resize.v"

integer i;

// =============================================================================
// Video timings (1280×1024@60Hz)
// =============================================================================
localparam
	HORZ_TOTAL = HORZ_BACK_PORCH + HORZ_VISIBLE + HORZ_FRONT_PORCH + HORZ_SYNC,
	VERT_TOTAL = VERT_BACK_PORCH + VERT_VISIBLE + VERT_FRONT_PORCH + VERT_SYNC,

	HORZ_VISIBLE_START = HORZ_BACK_PORCH,
	HORZ_VISIBLE_END   = HORZ_BACK_PORCH + HORZ_VISIBLE,
	HORZ_SYNC_START    = HORZ_BACK_PORCH + HORZ_VISIBLE + HORZ_FRONT_PORCH,

	VERT_VISIBLE_START = VERT_BACK_PORCH,
	VERT_VISIBLE_END   = VERT_BACK_PORCH + VERT_VISIBLE - 4,
	VERT_SYNC_START    = VERT_BACK_PORCH + VERT_VISIBLE + VERT_FRONT_PORCH,
	
	COLUMNS            = HORZ_VISIBLE / CHAR_WIDTH;

// =============================================================================
// Color palette (16 × 9 bit colors)
// =============================================================================
localparam
	PALETTE_SIZE = 'd16,
	COLOR_DEPTH = 'd9;

reg [COLOR_DEPTH - 1:0] palette [PALETTE_SIZE - 1:0];

always @(posedge clk)
	if (reset) begin
		// Defaults to DawnBringer’s palette v1.0 converted to 9 bits RGB
		palette[0] <= 9'b000_000_000;
		palette[1] <= 9'b010_001_001;
		palette[2] <= 9'b001_001_011;
		palette[3] <= 9'b010_010_010;
		palette[4] <= 9'b100_010_001;
		palette[5] <= 9'b001_011_001;
		palette[6] <= 9'b110_010_010;
		palette[7] <= 9'b011_011_011;
		palette[8] <= 9'b010_011_110;
		palette[9] <= 9'b110_011_001;
		palette[10] <= 9'b100_100_101;
		palette[11] <= 9'b011_101_001;
		palette[12] <= 9'b110_101_100;
		palette[13] <= 9'b011_110_110;
		palette[14] <= 9'b110_110_010;
		palette[15] <= 9'b110_111_110;
	end

// =============================================================================
// Horizontal pixel counter
// =============================================================================
reg [$clog2(HORZ_TOTAL):0] xpos = 0;
always @(posedge clk)
	if (reset)
		xpos <= 'd0;
	else
		if (xpos == HORZ_TOTAL - 1) xpos <= 'd0;
		else                        xpos <= xpos + 'd1;

// =============================================================================
// Vertical line counter
// =============================================================================
reg [$clog2(VERT_TOTAL):0] ypos = 0;
always @(posedge clk)
	if (reset)
		ypos <= 'd0;
	else
		if (xpos == HORZ_TOTAL - 1) begin
			if (ypos == VERT_TOTAL - 1) ypos <= 'd0;
			else                        ypos <= ypos + 'd1;
		end else
			ypos <= ypos;

// =============================================================================
// Frame count
// =============================================================================
reg [9:0] frame_count;
always @(posedge clk)
	if (reset)
		frame_count <= 'd0;
	else if (xpos =='d0 && ypos == 'd0)
		frame_count <= frame_count + 'd1;

// =============================================================================
// Synchronization signals
// =============================================================================
assign hsync = xpos < HORZ_SYNC_START;
assign vsync = ypos < VERT_SYNC_START;

reg pg;
reg [4:0] char_row;
always @(posedge clk)
	if (reset || ypos < VERT_VISIBLE_START - 1 || ypos > VERT_VISIBLE_END - 1) begin
		char_row <= 'd0;
	end else if (xpos == HORZ_TOTAL - 1) begin
		if (ypos == VERT_VISIBLE_START - 1) begin
			char_row <= 'd0;
			pg <= 'd0;
		end else if (char_row == CHAR_HEIGHT - 1) begin
			char_row <= 'd0;
			pg <= ~pg;
		end else
			char_row <= char_row + 'd1;
	end

wire x_visible = xpos >= HORZ_VISIBLE_START && xpos < HORZ_VISIBLE_END;
wire y_visible = ypos >= VERT_VISIBLE_START && ypos < VERT_VISIBLE_END;

wire preload =
	ypos == VERT_VISIBLE_START - 1 + 0 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 1 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 2 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 3 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 4 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 5 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 6 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 7 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 8 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 9 * 20 ||

	ypos == VERT_VISIBLE_START - 1 + 10 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 11 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 12 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 13 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 14 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 15 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 16 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 17 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 18 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 19 * 20 ||

	ypos == VERT_VISIBLE_START - 1 + 20 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 21 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 22 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 23 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 24 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 25 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 26 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 27 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 28 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 29 * 20 ||

	ypos == VERT_VISIBLE_START - 1 + 30 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 31 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 32 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 33 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 34 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 35 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 36 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 37 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 38 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 39 * 20 ||

	ypos == VERT_VISIBLE_START - 1 + 40 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 41 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 42 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 43 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 44 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 45 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 46 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 47 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 48 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 49 * 20 ||

	ypos == VERT_VISIBLE_START - 1 + 50 * 20 ||
	ypos == VERT_VISIBLE_START - 1 + 51 * 20;

// =============================================================================
// Preload characters and attributes for one row
// =============================================================================
reg [6:0] wr_index;
reg [6:0] rd_index;
reg wr_enable;

wire cea0 = wr_enable && ~pg;
wire [31:0] dob0;
charattr_row row0 ( 
	.clka (clk),
	.addra (wr_index),
	.cea (cea0),
	.dia (rd_data),

	.clkb (clk),
	.addrb (rd_index),
	.dob (dob0)
);

wire cea1 = wr_enable && pg;
wire [31:0] dob1;
charattr_row row1 ( 
	.clka (clk),
	.addra (wr_index),
	.cea (cea1),
	.dia (rd_data),

	.clkb (clk),
	.addrb (rd_index),
	.dob (dob1)
);

wire [31:0] charattr = pg ? dob0 : dob1;
always @(posedge clk)
	if (reset || (xpos == 'd0 && ypos == 'd0)) begin
		rd_request <= FALSE;
		rd_address <= 'd0 - ('d128 * 'd4);
		rd_burst_length <= 'd80;
		wr_index <= 'd0;
		wr_enable <= FALSE;
	end else if (preload) begin
		rd_request <= xpos == 'd0;

		if (xpos == 'd0) begin
			wr_index <= 'h7F; //'d0;
			rd_address <= rd_address + 'd128 * 'd4;
		end else if (wr_index < COLUMNS - 1 || wr_index == 'h7F) begin
			if (rd_available) begin
				wr_enable <= TRUE;
				wr_index <= wr_index + 'd1;
			end else
				wr_enable <= FALSE;
		end
	end else begin
		rd_request <= FALSE;
		wr_index <= 'd0;
	end

// =============================================================================
// Pixel generation
// =============================================================================
localparam
	STEP_CHARATTR_READ = 'd0,
	STEP_HORZ_RESIZE = 'd3,
	STEP_APPLY_PATTERN = 'd4,
	STEP_DRAW_BITMAP = 'd5,
	STEP_NEXT = 'd6;

reg [2:0] step;

// Helpers pointing to character attributes
reg [3:0] fg;
reg [3:0] bg;
reg [15:0] pattern;
reg [1:0] func;
reg horz_size;
reg horz_part;

// Memory where pixels will be written
reg wr_pixel_enable;
reg [63:0] wr_pixel_data;
reg [6:0] wr_pixel_addr;
wire [3:0] current_pixel_index;
wire [10:0] addrb = xpos - HORZ_VISIBLE_START + 11'd2;
pixels pixels (
	.clka (clk),
	.addra (wr_pixel_addr),
	.cea (wr_pixel_enable),
	.dia (wr_pixel_data),

	.clkb (clk),
	.addrb (addrb),
	.dob (current_pixel_index)
);

wire blink =
	charattr[15:14] != 2'b00 ? (charattr[15:14] == frame_count[6:5]) : FALSE;

reg [15:0] bitmap;
always @(posedge clk)
	if (reset || xpos == HORZ_TOTAL - 1 || ypos < VERT_VISIBLE_START || ypos >= VERT_VISIBLE_END) begin
		step <= STEP_CHARATTR_READ;
		rd_index <= 'd0;
		wr_pixel_addr <= 'd0;
	end	else if (xpos > 'd3 && ~(rd_index == COLUMNS && step == STEP_NEXT)) begin
		case (step)
			STEP_CHARATTR_READ: begin
				rd_index <= rd_index + 'd1;

				// Apply blink and invert attribute
				if (charattr[16]) begin
					fg <= blink ? charattr[27:24] : charattr[31:28];
					bg <= charattr[27:24];
				end else begin
					fg <= blink ? charattr[31:28] : charattr[27:24];
					bg <= charattr[31:28];
				end

				font_address <=
					{ 5'b0, charattr[9:0] } * 15'd20 +
					{ 10'b0, vertical_resize(charattr[11], charattr[13], char_row) };
				
				pattern <= generate_pattern(charattr[23:20], ypos[3:0]);
				func <= charattr[19:18];

				horz_size <= charattr[10];
				horz_part <= charattr[12];
			end

			STEP_HORZ_RESIZE:
				bitmap <= horizontal_resize(horz_size, horz_part, char_row_bitmap);

			STEP_APPLY_PATTERN:
				bitmap <= apply_pattern(func, bitmap, pattern);

			STEP_DRAW_BITMAP: begin
				wr_pixel_enable <= TRUE;
				wr_pixel_data[3:0] <= bitmap[15] ? fg : bg;
				wr_pixel_data[7:4] <= bitmap[14] ? fg : bg;
				wr_pixel_data[11:8] <= bitmap[13] ? fg : bg;
				wr_pixel_data[15:12] <= bitmap[12] ? fg : bg;
				wr_pixel_data[19:16] <= bitmap[11] ? fg : bg;
				wr_pixel_data[23:20] <= bitmap[10] ? fg : bg;
				wr_pixel_data[27:24] <= bitmap[9] ? fg : bg;
				wr_pixel_data[31:28] <= bitmap[8] ? fg : bg;
				wr_pixel_data[35:32] <= bitmap[7] ? fg : bg;
				wr_pixel_data[39:36] <= bitmap[6] ? fg : bg;
				wr_pixel_data[43:40] <= bitmap[5] ? fg : bg;
				wr_pixel_data[47:44] <= bitmap[4] ? fg : bg;
				wr_pixel_data[51:48] <= bitmap[3] ? fg : bg;
				wr_pixel_data[55:52] <= bitmap[2] ? fg : bg;
				wr_pixel_data[59:56] <= bitmap[1] ? fg : bg;
				wr_pixel_data[63:60] <= bitmap[0] ? fg : bg;
			end

			STEP_NEXT: begin
				wr_pixel_enable <= FALSE;
				wr_pixel_addr <= wr_pixel_addr + 'd1;
			end
		endcase

		if (step == STEP_NEXT) step <= STEP_CHARATTR_READ;
		else                   step <= step + 'd1;
	end

// =============================================================================
// Display pixels
// =============================================================================
reg [8:0] current_pixel;
always @(posedge clk) current_pixel <= palette[current_pixel_index];

always @(posedge clk)
	if (y_visible && x_visible && ~reset) begin
		pixel_red <= current_pixel[8:6];
		pixel_green <= current_pixel[5:3];
		pixel_blue <= current_pixel[2:0];
	end else begin
		pixel_red <= 'd0;
		pixel_green <= 'd0;
		pixel_blue <= 'd0;
	end

endmodule