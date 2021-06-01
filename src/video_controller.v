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
    input wire [CHAR_WIDTH - 1:0] char_row_bitmap,

	// Cursor interface
	output reg [8:0] cursor_address,
	input wire [15:0] cursor_row_bitmap,

	// Registers
	input wire [3:0] register_index,
	input wire [22:0] register_value
);

`include "constant.v"

`include "video_controller/registers.v"
`include "video_controller/generate_pattern.v"
`include "video_controller/apply_pattern.v"
`include "video_controller/horizontal_resize.v"
`include "video_controller/vertical_resize.v"
`include "video_controller/cursor_ids.v"
`include "video_controller/cursor_offset.v"

// =============================================================================
// Registers
// =============================================================================
reg [22:0] base_address;
reg [22:0] first_row;
reg [5:0] cursor_row;
reg [6:0] cursor_col;
reg cursor_visible;
reg [10:0] mouse_x;
reg [9:0] mouse_y;
reg [2:0] mouse_cursor;
always @(posedge clk)
	if (reset) begin
		base_address <= 'd0;
		first_row <= 'd0;
		cursor_row <= 'd0;
		cursor_col <= 'd0;
		cursor_visible <= TRUE;
		mouse_cursor <= 'd0;
		mouse_x <= 'd0;
		mouse_y <= 'd0;
	end else
		case (register_index)
			VIDEO_SET_BASE_ADDRESS: base_address <= register_value;

			VIDEO_SET_FIRST_ROW: first_row <= register_value;

			VIDEO_CURSOR_POSITION: begin
				cursor_visible <= register_value[13];
				cursor_row <= register_value[12:7];
				cursor_col <= register_value[6:0];
			end

			VIDEO_MOUSE_CURSOR: mouse_cursor <= register_value[2:0];

			VIDEO_MOUSE_POSITION: begin
				mouse_x <= register_value[10:0];
				mouse_y <= register_value[20:11];
			end
		endcase

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
	VERT_SYNC_START    = VERT_BACK_PORCH + VERT_VISIBLE + VERT_FRONT_PORCH;

// =============================================================================
// Color palette (16 × 9 bit colors)
// =============================================================================
localparam
	PALETTE_SIZE = 'd16,
	COLOR_DEPTH = 'd9;

reg [COLOR_DEPTH - 1:0] palette [PALETTE_SIZE - 1:0];

always @(posedge clk)
	if (reset) begin
		`include "video_controller/ansi_palette.v"
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
reg [9:0] frame_count = 10'd0;
always @(posedge clk)
	if (reset) begin
		frame_count <= 10'd0;
	end else if (xpos == 'd0 && ypos == 'd0) begin
		frame_count <= frame_count + 10'd1;
	end

// =============================================================================
// Synchronization signals
// =============================================================================
assign hsync = xpos < HORZ_SYNC_START;
assign vsync = ypos < VERT_SYNC_START;

reg pg;
reg [4:0] char_row;
reg [5:0] current_row;
always @(posedge clk)
	if (reset || ypos < VERT_VISIBLE_START - 1 || ypos > VERT_VISIBLE_END - 1) begin
		char_row <= 'd0;
		current_row <= 0;
	end else if (xpos == HORZ_TOTAL - 1) begin
		if (ypos == VERT_VISIBLE_START - 1) begin
			char_row <= 'd0;
			current_row <= 0;
			pg <= 0;
		end else if (char_row == CHAR_HEIGHT - 1) begin
			char_row <= 'd0;
			current_row <= current_row + 'd1;
			pg <= ~pg;
		end else
			char_row <= char_row + 'd1;
	end

wire x_visible = xpos >= HORZ_VISIBLE_START && xpos < HORZ_VISIBLE_END;
wire y_visible = ypos >= VERT_VISIBLE_START && ypos < VERT_VISIBLE_END;

wire [$clog2(HORZ_TOTAL):0] current_x = x_visible ? xpos - HORZ_VISIBLE_START : 'd0;
wire [$clog2(HORZ_VISIBLE / 16):0] current_col = current_x[4 + $clog2(HORZ_VISIBLE / 16):4];

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

wire [31:0] charattr_source = pg ? dob0 : dob1;
reg [31:0] charattr;
always @(posedge clk)
	if (reset || (xpos == 'd0 && ypos == 'd0)) begin
		rd_request <= FALSE;
		rd_address <= first_row;
		rd_burst_length <= 'd80;
		wr_index <= 'd0;
		wr_enable <= FALSE;
	end else begin
		if (preload) begin
			rd_request <= xpos == 'd0;

			if (xpos == HORZ_TOTAL - 1) begin
				if (rd_address + ROW_SIZE >= base_address + PAGE_SIZE)
					rd_address <= base_address;
				else
					rd_address <= rd_address + ROW_SIZE;
			end
		end else
			rd_request <= FALSE;

		wr_enable <= rd_available;
		if (xpos == 'd0)
			wr_index <= 'h7f;
		else if (rd_available) begin
			wr_index <= wr_index + 'd1;
		end
	end

// =============================================================================
// Pixel generation
// =============================================================================
localparam
/*
	STEP_START = 'd0,
	STEP_LOAD_CHARATTR = 'd1,
	STEP_CHARATTR_READ = 'd2,
	STEP_GFXMODE_COMPUTE = 'd4,
	STEP_HORZ_RESIZE = 'd5,
	STEP_APPLY_PATTERN = 'd6,
	STEP_DRAW_BITMAP = 'd7,
	STEP_WRITE_PIXEL = 'd8,
	STEP_NEXT = 'd9;
*/
	STEP_START = 'd0,
	STEP_LOAD_CHARATTR = 'd0,
	STEP_CHARATTR_READ = 'd1,
	STEP_GFXMODE_COMPUTE = 'd2,
	STEP_HORZ_RESIZE = 'd3,
	STEP_APPLY_PATTERN = 'd4,
	STEP_DRAW_BITMAP = 'd5,
	STEP_WRITE_PIXEL = 'd6,
	STEP_NEXT = 'd7;

reg [3:0] step;

// Helpers pointing to character attributes
reg [3:0] fg;
reg [3:0] bg;
reg [15:0] pattern;
reg [1:0] func;
reg horz_size;
reg horz_part;
reg gfxmode;
reg blink;
reg underline;

wire cursor_blink = frame_count[4];

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

always @(posedge clk)
	if (gfxmode)
		blink <= FALSE;
	else
	    case (charattr[15:14])
	        2'b00: blink <= FALSE; // off
	        2'b01: blink <= frame_count[5]; // slow
	        2'b10: blink <= frame_count[4]; // norm
	        2'b11: blink <= frame_count[3]; // fast
	    endcase

reg [15:0] bitmap;
reg [15:0] gfx_row_bitmap;

always @(posedge clk)
	if (reset) begin
		gfx_row_bitmap <= 'd0;
	end	else begin
		if (step == STEP_GFXMODE_COMPUTE) begin
			if (charattr[13]) begin
				case (char_row)
					'd01, 'd02: gfx_row_bitmap <= {
						1'b0, charattr[23], charattr[23], 1'b0,
						1'b0, charattr[22], charattr[22], 1'b0,
						1'b0, charattr[21], charattr[21], 1'b0,
						1'b0, charattr[20], charattr[20], 1'b0
					};

					'd05, 'd06: gfx_row_bitmap <= {
						1'b0, charattr[19], charattr[19], 1'b0,
						1'b0, charattr[18], charattr[18], 1'b0,
						1'b0, charattr[17], charattr[17], 1'b0,
						1'b0, charattr[16], charattr[16], 1'b0
					};

					'd09, 'd10: gfx_row_bitmap <= {
						1'b0, charattr[15], charattr[15], 1'b0,
						1'b0, charattr[14], charattr[14], 1'b0,
						1'b0, charattr[9], charattr[9], 1'b0,
						1'b0, charattr[8], charattr[8], 1'b0
					};

					'd13, 'd14: gfx_row_bitmap <= {
						1'b0, charattr[7], charattr[7], 1'b0,
						1'b0, charattr[6], charattr[6], 1'b0,
						1'b0, charattr[5], charattr[5], 1'b0,
						1'b0, charattr[4], charattr[4], 1'b0
					};

					'd00, 'd04, 'd08, 'd12, 'd16, 'd03, 'd07, 'd11, 'd15, 'd19:
						gfx_row_bitmap <= 16'b0;

					default: gfx_row_bitmap <= {
						1'b0, charattr[3], charattr[3], 1'b0,
						1'b0, charattr[2], charattr[2], 1'b0,
						1'b0, charattr[1], charattr[1], 1'b0,
						1'b0, charattr[0], charattr[0], 1'b0
					};
				endcase
			end else begin
				case (char_row)
					'd00, 'd01, 'd02, 'd03: gfx_row_bitmap <= {
						charattr[23], charattr[23], charattr[23], charattr[23],
						charattr[22], charattr[22], charattr[22], charattr[22],
						charattr[21], charattr[21], charattr[21], charattr[21],
						charattr[20], charattr[20], charattr[20], charattr[20]
					};

					'd04, 'd05, 'd06, 'd07: gfx_row_bitmap <= {
						charattr[19], charattr[19], charattr[19], charattr[19],
						charattr[18], charattr[18], charattr[18], charattr[18],
						charattr[17], charattr[17], charattr[17], charattr[17],
						charattr[16], charattr[16], charattr[16], charattr[16]
					};

					'd08, 'd09, 'd10, 'd11: gfx_row_bitmap <= {
						charattr[15], charattr[15], charattr[15], charattr[15],
						charattr[14], charattr[14], charattr[14], charattr[14],
						charattr[9], charattr[9], charattr[9], charattr[9],
						charattr[8], charattr[8], charattr[8], charattr[8]
					};

					'd12, 'd13, 'd14, 'd15: gfx_row_bitmap <= {
						charattr[7], charattr[7], charattr[7], charattr[7],
						charattr[6], charattr[6], charattr[6], charattr[6],
						charattr[5], charattr[5], charattr[5], charattr[5],
						charattr[4], charattr[4], charattr[4], charattr[4]
					};

					default: gfx_row_bitmap <= {
						charattr[3], charattr[3], charattr[3], charattr[3],
						charattr[2], charattr[2], charattr[2], charattr[2],
						charattr[1], charattr[1], charattr[1], charattr[1],
						charattr[0], charattr[0], charattr[0], charattr[0]
					};
				endcase
			end
		end
	end

wire pixel_generate = xpos > 'd3 && ~(rd_index == COLUMNS && step == STEP_NEXT);
wire pixel_reset = reset
				|| xpos == HORZ_TOTAL - 1
				|| ypos < VERT_VISIBLE_START
				|| ypos >= VERT_VISIBLE_END;


always @(posedge clk)
	if (pixel_reset) begin
		step <= STEP_START;
	end else if (pixel_generate) begin
		if (step == STEP_NEXT) step <= STEP_START;
		else                   step <= step + 'd1;
	end

wire enable_gfxmode = charattr[13:10] == 4'b0100 || charattr[13:10] == 4'b1000;
always @(posedge clk)
	if (pixel_reset) begin
		gfxmode <= FALSE;
	end	else if (pixel_generate && step == STEP_CHARATTR_READ) begin
		gfxmode <= enable_gfxmode;
	end else begin
		gfxmode <= gfxmode;
	end

always @(posedge clk)
	if (pixel_reset) begin
		rd_index <= 'd0;
		wr_pixel_addr <= 'd0;
	end	else if (pixel_generate) begin
		case (step)
			STEP_START: charattr <= charattr_source;

			//STEP_LOAD_CHARATTR: rd_index <= rd_index + 'd1;

			STEP_CHARATTR_READ: begin
				//rd_index <= rd_index + 'd1;

				if (enable_gfxmode) begin
					bg <= charattr[31:28];
					fg <= charattr[27:24];
					underline <= FALSE;
					pattern <= generate_pattern(4'b0, 4'b0);
					func <= 2'b0;
				end else begin
					// Apply blink and invert attribute
					if (charattr[16]) begin
						fg <= blink ? charattr[27:24] : charattr[31:28];
						bg <= charattr[27:24];
					end else begin
						fg <= blink ? charattr[31:28] : charattr[27:24];
						bg <= charattr[31:28];
					end

					// Underline
					underline <=
						charattr[17] &&
						char_row == 'd17 &&
						charattr[13] == charattr[11];

					pattern <= generate_pattern(charattr[23:20], ypos[3:0]);
					func <= charattr[19:18];
				end

				font_address <=
					/*{ 5'b0, charattr[9:0] } * 15'd20 // This uses one DSP! */
					{ 1'b0, charattr[9:0], 4'b0 } +
					{ 3'b0, charattr[9:0], 2'b0 } +
					{
						10'b0,
						vertical_resize(charattr[11], charattr[13], char_row)
					};

				horz_size <= charattr[10];
				horz_part <= charattr[12];
			end

			STEP_HORZ_RESIZE:
				if (gfxmode)
					bitmap <= gfx_row_bitmap;
				else
					bitmap <= horizontal_resize(
						horz_size, horz_part, char_row_bitmap
					);

			STEP_APPLY_PATTERN:
				bitmap <= apply_pattern(func, bitmap, pattern);

			STEP_DRAW_BITMAP: begin
				if (underline & !gfxmode) begin
					wr_pixel_data <= {
						fg, fg, fg, fg, fg, fg, fg, fg,
						fg, fg, fg, fg, fg, fg, fg, fg
					};
				end else begin
					wr_pixel_data[ 3: 0] <= bitmap[15] ? fg : bg;
					wr_pixel_data[ 7: 4] <= bitmap[14] ? fg : bg;
					wr_pixel_data[11: 8] <= bitmap[13] ? fg : bg;
					wr_pixel_data[15:12] <= bitmap[12] ? fg : bg;
					wr_pixel_data[19:16] <= bitmap[11] ? fg : bg;
					wr_pixel_data[23:20] <= bitmap[10] ? fg : bg;
					wr_pixel_data[27:24] <= bitmap[ 9] ? fg : bg;
					wr_pixel_data[31:28] <= bitmap[ 8] ? fg : bg;
					wr_pixel_data[35:32] <= bitmap[ 7] ? fg : bg;
					wr_pixel_data[39:36] <= bitmap[ 6] ? fg : bg;
					wr_pixel_data[43:40] <= bitmap[ 5] ? fg : bg;
					wr_pixel_data[47:44] <= bitmap[ 4] ? fg : bg;
					wr_pixel_data[51:48] <= bitmap[ 3] ? fg : bg;
					wr_pixel_data[55:52] <= bitmap[ 2] ? fg : bg;
					wr_pixel_data[59:56] <= bitmap[ 1] ? fg : bg;
					wr_pixel_data[63:60] <= bitmap[ 0] ? fg : bg;
				end

				rd_index <= rd_index + 'd1;
			end

			STEP_WRITE_PIXEL: wr_pixel_enable <= TRUE;

			STEP_NEXT: begin
				wr_pixel_enable <= FALSE;
				wr_pixel_addr <= wr_pixel_addr + 'd1;
			end
		endcase
	end else begin
		wr_pixel_enable <= FALSE;
		wr_pixel_addr <= 'd0;
	end

// =============================================================================
// Mouse cursor drawing
// =============================================================================
reg [31:0] cursor_pixels = 'd0;

wire [8:0] cursor_address_start =
	{ 1'b0, mouse_cursor, 5'b0 } + { 2'b0, mouse_cursor, 4'b0 };

wire [$clog2(VERT_TOTAL):0] cursor_start_y =
	VERT_VISIBLE_START + mouse_y - cursor_offset_y(mouse_cursor);

wire [$clog2(VERT_TOTAL):0] cursor_end_y =
	VERT_VISIBLE_START + mouse_y - cursor_offset_y(mouse_cursor) + 'd24;

wire mouse_cursor_visible_y = ypos >= cursor_start_y && ypos < cursor_end_y;

wire [4:0] cursor_current_row = ypos - cursor_start_y;

wire [$clog2(HORZ_TOTAL):0] cursor_start_x =
	HORZ_VISIBLE_START + mouse_x - cursor_offset_x(mouse_cursor);

wire [$clog2(HORZ_TOTAL):0] cursor_end_x =
	HORZ_VISIBLE_START + mouse_x - cursor_offset_x(mouse_cursor) + 'd16;

wire mouse_cursor_visible_x = xpos >= cursor_start_x && xpos < cursor_end_x;

always @(posedge clk)
	if (reset) begin
		cursor_pixels <= 'd0;
	end else if (mouse_cursor_visible_y) begin
		case (xpos)
			// Read first 8 pixels
			'd0: cursor_address <=
				cursor_address_start + { 3'b0, cursor_current_row, 1'b0 };
			'd3: cursor_pixels[31:16] <= cursor_row_bitmap;

			// Read last 8 pixels
			'd4: cursor_address <=
				cursor_address_start + { 3'b0, cursor_current_row, 1'b1 };
			'd7: cursor_pixels[15:0] <= cursor_row_bitmap;
		endcase
	end

function [1:0] get_cursor_pixel;
	input [3:0] offset;
	case (offset)
		'd0: get_cursor_pixel = cursor_pixels[31:30];
		'd1: get_cursor_pixel = cursor_pixels[29:28];
		'd2: get_cursor_pixel = cursor_pixels[27:26];
		'd3: get_cursor_pixel = cursor_pixels[25:24];
		'd4: get_cursor_pixel = cursor_pixels[23:22];
		'd5: get_cursor_pixel = cursor_pixels[21:20];
		'd6: get_cursor_pixel = cursor_pixels[19:18];
		'd7: get_cursor_pixel = cursor_pixels[17:16];
		'd8: get_cursor_pixel = cursor_pixels[15:14];
		'd9: get_cursor_pixel = cursor_pixels[13:12];
		'd10: get_cursor_pixel = cursor_pixels[11:10];
		'd11: get_cursor_pixel = cursor_pixels[9:8];
		'd12: get_cursor_pixel = cursor_pixels[7:6];
		'd13: get_cursor_pixel = cursor_pixels[5:4];
		'd14: get_cursor_pixel = cursor_pixels[3:2];
		'd15: get_cursor_pixel = cursor_pixels[1:0];
	endcase
endfunction

// =============================================================================
// Display pixels
// =============================================================================
reg [8:0] current_pixel;
always @(posedge clk) current_pixel <= palette[current_pixel_index];

wire [3:0] cursor_pixel_offset = xpos - cursor_start_x;
reg [8:0] current_cursor_pixel;
reg show_mouse_cursor;
always @(posedge clk)
	if (reset) begin
		current_cursor_pixel <= 'd0;
		show_mouse_cursor <= FALSE;
	end else if (mouse_cursor_visible_x && mouse_cursor_visible_y)
		case (get_cursor_pixel(cursor_pixel_offset))
			'd0: begin
				current_cursor_pixel <= 9'b000_000_000;
				show_mouse_cursor <= FALSE;
			end

			'd1: begin
				current_cursor_pixel <= 9'b000_000_000;
				show_mouse_cursor <= TRUE;
			end

			'd2: begin
				current_cursor_pixel <= 9'b100_100_100;
				show_mouse_cursor <= TRUE;
			end

			'd3: begin
				current_cursor_pixel <= 9'b111_111_111;
				show_mouse_cursor <= TRUE;
			end
		endcase
	else begin
		current_cursor_pixel <= 'd0;
		show_mouse_cursor <= FALSE;
	end

wire show_cursor =
	cursor_visible &&
	cursor_blink &&
	current_col == cursor_col
	&& current_row == cursor_row;

wire emit_pixel = y_visible && x_visible && ~reset;

always @(posedge clk)
	if (emit_pixel) begin
		if (show_mouse_cursor) begin
			pixel_red <= current_cursor_pixel[8:6];
			pixel_green <= current_cursor_pixel[5:3];
			pixel_blue <= current_cursor_pixel[2:0];
		end else if (show_cursor) begin
			pixel_red <= ~current_pixel[8:6];
			pixel_green <= ~current_pixel[5:3];
			pixel_blue <= ~current_pixel[2:0];
		end else begin
			pixel_red <= current_pixel[8:6];
			pixel_green <= current_pixel[5:3];
			pixel_blue <= current_pixel[2:0];
		end
	end else begin
		pixel_red <= 'd0;
		pixel_green <= 'd0;
		pixel_blue <= 'd0;
	end

endmodule