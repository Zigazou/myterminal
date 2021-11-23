module video_controller #(
	// Video parameters (1280×1024@60Hz, dot clock = 108 MHz)
	parameter HORZ_BACK_PORCH   = 248,
	parameter HORZ_VISIBLE      = 1280,
	parameter HORZ_FRONT_PORCH  = 48,
	parameter HORZ_SYNC         = 112,
    parameter HORZ_DEPTH        = 11,
    parameter HORZ_COL_DEPTH    = 7,

	parameter VERT_BACK_PORCH   = 38,
	parameter VERT_VISIBLE      = 1024,
	parameter VERT_FRONT_PORCH  = 1,
	parameter VERT_SYNC         = 3,
    parameter VERT_DEPTH        = 11,

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
    output wire [14:0] font_address,
    input wire [CHAR_WIDTH - 1:0] char_row_bitmap,

	// Cursor interface
	output reg [8:0] cursor_address,
	input wire [15:0] cursor_row_bitmap,

	// Mouse control
	input wire [1:0] mouse_control,

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
		mouse_cursor <= CURSOR_DEFAULT;
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
reg [HORZ_DEPTH - 1:0] xpos = 0;
always @(posedge clk)
	if (reset || xpos == HORZ_TOTAL - 1) begin
		xpos <= 'd0;
	end else begin
		xpos <= xpos + 'd1;
	end

// =============================================================================
// Vertical line counter
// =============================================================================
reg [VERT_DEPTH - 1:0] ypos = 0;
always @(posedge clk)
	if (reset || (xpos == HORZ_TOTAL - 1 && ypos == VERT_TOTAL - 1))
		ypos <= 'd0;
	else begin
		ypos <= ypos + { 20'd0, xpos == HORZ_TOTAL - 1 };
	end

// =============================================================================
// Frame count
// =============================================================================
reg [6:0] frame_count = 'd0;
always @(posedge clk)
	if (reset) begin
		frame_count <= 'd0;
	end else begin
		frame_count <= frame_count + { 6'd0, xpos == 'd0 && ypos == 'd0 };
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
	end else if (xpos == HORZ_TOTAL - 2) begin
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

wire [HORZ_DEPTH - 1:0] current_x = x_visible ? xpos - HORZ_VISIBLE_START : 'd0;
wire [HORZ_COL_DEPTH - 1:0] current_col = current_x[4 + HORZ_COL_DEPTH - 1:4];

wire preload = ypos == VERT_VISIBLE_START - 1 || (y_visible && char_row == 'd0);

// =============================================================================
// Preload characters and attributes for one row
// =============================================================================
reg [6:0] wr_index;
reg [31:0] wr_data;

reg [6:0] rd_index;
reg wr_enable = FALSE;

wire cea0 = wr_enable && ~pg;
wire [31:0] dob0;
charattr_row row0 ( 
	.clka (clk),
	.addra (wr_index),
	.cea (cea0),
	.dia (wr_data),

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
	.dia (wr_data),

	.clkb (clk),
	.addrb (rd_index),
	.dob (dob1)
);

// Burst read of one row
always @(posedge clk) begin
	rd_request <= preload && xpos == 'd0;

	if (reset || (xpos == 'd0 && ypos == 'd0)) begin
		rd_address <= first_row;
		rd_burst_length <= 'd88;
	end else if (preload) begin
		if (xpos == HORZ_TOTAL - 1) begin
			if (rd_address + ROW_SIZE >= base_address + PAGE_SIZE)
				rd_address <= base_address;
			else
				rd_address <= rd_address + ROW_SIZE;
		end
	end
end

// Write each row cell in the preloaded row
always @(posedge clk) begin
	wr_enable <= rd_available;
	wr_data <= rd_data;
	if (xpos == 'd0) begin
		wr_index <= 'h7f;
	end else begin
		wr_index <= wr_index + { 6'd0, rd_available };
	end
end

// =============================================================================
// Pixel generation
// =============================================================================
wire cursor_blink = frame_count[4];

// Memory where pixels will be written
wire wr_pixel_enable;
wire [63:0] wr_pixel_data;
reg [6:0] wr_pixel_addr;
wire [3:0] current_pixel_index;

reg [10:0] addrb;
always @(posedge clk) addrb <= xpos[10:0] - (HORZ_VISIBLE_START[10:0] - 11'd3);

pixels pixels (
	.clka (clk),
	.addra (wr_pixel_addr),
	.cea (wr_pixel_enable),
	.dia (wr_pixel_data),

	.clkb (clk),
	.addrb (addrb),
	.dob (current_pixel_index)
);

wire pixel_reset = reset
				|| xpos == HORZ_TOTAL - 1
				|| ypos < VERT_VISIBLE_START
				|| ypos >= VERT_VISIBLE_END;

reg [31:0] charattr;
reg vp_enable;
vp_pipeline vp_pipeline (
	// Base signals
	.clk (clk),

	// Inputs
	.charattr (charattr),
	.char_row_in (char_row),
	.ypos (ypos[3:0]),
	.frame_count (frame_count),
	.enabled (vp_enable),

	// Intermediate inputs/outputs
	.txt_font_address (font_address),
	.txt_char_row_bitmap (char_row_bitmap),

	// Outputs
	.pixels (wr_pixel_data),
	.enable (wr_pixel_enable)
);

always @(posedge clk)
	if (pixel_reset) begin
		wr_pixel_addr <= 'd0;
	end	else begin
		wr_pixel_addr <= wr_pixel_addr + { 6'b0, wr_pixel_enable };
	end

always @(posedge clk) begin
	rd_index <= xpos[6:0];
	charattr <= pg ? dob0 : dob1;
end

always @(posedge clk)
	if (pixel_reset) begin
		vp_enable <= FALSE;
	end	else case (xpos)
		'd3: vp_enable <= TRUE;
		(COLUMNS + 'd4): vp_enable <= FALSE;
	endcase

// =============================================================================
// Mouse cursor drawing
// =============================================================================
reg [31:0] cursor_pixels = 'd0;
reg [8:0] cursor_address_start;
always @(posedge clk)
	cursor_address_start <=
		{ 1'b0, mouse_cursor, 5'b0 } + { 2'b0, mouse_cursor, 4'b0 };

reg [VERT_DEPTH - 1:0] cursor_start_y = 'd0;
reg [VERT_DEPTH - 1:0] cursor_end_y = 'd0;
always @(posedge clk)
	if (xpos =='d0) begin
		cursor_start_y <=
			VERT_VISIBLE_START +
			mouse_y -
			cursor_offset_y(mouse_cursor);

		cursor_end_y <=
			VERT_VISIBLE_START + 'd24 +
			mouse_y -
			cursor_offset_y(mouse_cursor);
	end

reg mouse_cursor_visible_y = FALSE;
always @(posedge clk)
	mouse_cursor_visible_y <= ypos >= cursor_start_y && ypos < cursor_end_y;

wire [4:0] cursor_current_row = ypos - cursor_start_y;

wire [HORZ_DEPTH - 1:0] cursor_start_x =
	HORZ_VISIBLE_START[HORZ_DEPTH - 1:0] +
    mouse_x[HORZ_DEPTH - 1:0] -
    { 7'b0, cursor_offset_x(mouse_cursor) };

wire [HORZ_DEPTH - 1:0] cursor_end_x =
	HORZ_VISIBLE_START[HORZ_DEPTH - 1:0] +
    mouse_x[HORZ_DEPTH - 1:0] -
    { 7'b0, cursor_offset_x(mouse_cursor) } +
    11'd16;

reg mouse_cursor_visible_x;
always @(posedge clk)
	mouse_cursor_visible_x <= xpos >= cursor_start_x && xpos < cursor_end_x;

always @(posedge clk)
	if (reset) begin
		cursor_pixels <= 'd0;
	end else if (mouse_cursor_visible_y) begin
		case (xpos)
			// Read first 8 pixels
			'd1: cursor_address <=
				cursor_address_start + { 3'b0, cursor_current_row, 1'b0 };
			'd4: cursor_pixels[31:16] <= cursor_row_bitmap;

			// Read last 8 pixels
			'd5: cursor_address <=
				cursor_address_start + { 3'b0, cursor_current_row, 1'b1 };
			'd8: cursor_pixels[15:0] <= cursor_row_bitmap;
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

reg [3:0] cursor_pixel_offset;
always @(posedge clk) cursor_pixel_offset <= xpos - cursor_start_x;

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
		if (show_mouse_cursor && mouse_control != 'd0) begin
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