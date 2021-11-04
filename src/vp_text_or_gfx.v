module vp_text_or_gfx #(
	// Character dimensions
	parameter CHAR_WIDTH        = 'd16,
	parameter CHAR_HEIGHT       = 'd20
) (
	// Base signals
	input wire clk,
	input wire reset,

	// Inputs
	input wire [31:0] charattr,
	input wire [4:0]  char_row_in,
	input wire [3:0]  ypos,
	input wire [6:0]  frame_count,
	input wire        enabled,

	// Common output
	output reg [4:0]  char_row_out,
	output reg [3:0]  foreground,
	output reg [3:0]  background,

	// Text output
	output reg [14:0] txt_font_address,
	output reg        txt_horz_size,
	output reg        txt_horz_part,
	output reg [15:0] txt_pattern,
	output reg [15:0] txt_border,
	output reg [1:0]  txt_func,
	output reg        txt_blink,
	output reg        txt_invert,
	output reg        txt_underline,
	output reg        txt_enable,

	// Graphic output
	output reg [19:0] gfx_bits,
	output reg        gfx_mosaic,
	output reg        gfx_enable
);

`include "constant.v"
`include "video_controller/horizontal_resize.v"
`include "video_controller/vertical_resize.v"
`include "video_controller/generate_pattern.v"

wire [3:0]  charattr_background    = charattr[31:28];
wire [3:0]  charattr_foreground    = charattr[27:24];
wire [3:0]  charattr_pattern       = charattr[23:20];
wire        charattr_border_left   = charattr[23];
wire        charattr_border_bottom = charattr[22];
wire        charattr_border_right  = charattr[21];
wire        charattr_border_top    = charattr[20];
wire [1:0]  charattr_function      = charattr[19:18];
wire        charattr_underline     = charattr[17];
wire        charattr_invert        = charattr[16];
wire [1:0]  charattr_blink         = charattr[15:14];
wire [3:0]  charattr_gfxmode       = charattr[13:10];
wire        charattr_part_vert     = charattr[13];
wire        charattr_part_horz     = charattr[12];
wire        charattr_size_vert     = charattr[11];
wire        charattr_size_horz     = charattr[10];
wire [9:0]  charattr_charcode      = charattr[9:0];
always @(posedge clk)
	if (reset) begin
		txt_enable <= FALSE;
		gfx_enable <= FALSE;
		char_row_out <= 'd0;
		foreground <= 'd0;
		background <= 'd0;
		txt_font_address <= 'd0;
		txt_horz_size <= 'd0;
		txt_horz_part <= 'd0;
		txt_pattern <= 'd0;
		txt_border <= 'd0;
		txt_func <= 'd0;
		txt_blink <= FALSE;
		txt_invert <= FALSE;
		txt_underline <= FALSE;
		gfx_bits <= 'd0;
		gfx_mosaic <= FALSE;
	end else if (enabled) begin
		background <= charattr_background;
		foreground <= charattr_foreground;
		char_row_out <= char_row_in;

		if (charattr_gfxmode == 4'b0100 || charattr_gfxmode == 4'b1000) begin
			txt_enable <= FALSE;
			gfx_enable <= TRUE;

			gfx_bits <= {
				charattr[23], charattr[22], charattr[21], charattr[20],
				charattr[19], charattr[18], charattr[17], charattr[16],
				charattr[15], charattr[14], charattr[ 9], charattr[ 8],
				charattr[ 7], charattr[ 6], charattr[ 5], charattr[ 4],
				charattr[ 3], charattr[ 2], charattr[ 1], charattr[ 0]
			};
			gfx_mosaic <= charattr[13];
		end else begin
			txt_enable <= TRUE;
			gfx_enable <= FALSE;

			txt_font_address <=
				{ 1'b0, charattr_charcode, 4'b0 } +
				{ 3'b0, charattr_charcode, 2'b0 } +
				{
					10'b0,
					vertical_resize(
						charattr_size_vert, charattr_part_vert, char_row_in
					)
				};

			txt_underline <=
				charattr_underline &&
				char_row_in == 'd17 &&
				charattr_part_vert == charattr_size_vert;

			case (charattr_blink)
				2'b00: txt_blink <= FALSE;
				2'b01: txt_blink <= frame_count[6];
				2'b10: txt_blink <= frame_count[5];
				2'b11: txt_blink <= frame_count[4];
			endcase
			txt_invert <= charattr_invert;

			txt_horz_size <= charattr_size_horz;
			txt_horz_part <= charattr_part_horz;
			txt_pattern <= generate_pattern(charattr_pattern, ypos[3:0]);
			txt_func <= charattr_function;

			// Draw border
			if (charattr_function == 2'b11) begin
				if (char_row_in == 'd0 && charattr_part_vert == FALSE && charattr_border_top == TRUE) begin
					// Top border
					txt_border <= 16'b1111_1111_1111_1111;
				end else if (char_row_in == 'd19 && charattr_part_vert == charattr_size_vert && charattr_border_bottom == TRUE) begin
					// Bottom border
					txt_border <= 16'b1111_1111_1111_1111;
				end else begin
					// Left and right border
					case ({ charattr_border_left, charattr_border_right, charattr_part_horz, charattr_size_horz })
						4'b0000: txt_border <= 16'b0000_0000_0000_0000;
						4'b0001: txt_border <= 16'b0000_0000_0000_0000;
						4'b0010: txt_border <= 16'b0000_0000_0000_0000;
						4'b0011: txt_border <= 16'b0000_0000_0000_0000;

						4'b0100: txt_border <= 16'b0000_0000_0000_0001;
						4'b0101: txt_border <= 16'b0000_0000_0000_0000;
						4'b0110: txt_border <= 16'b0000_0000_0000_0001;
						4'b0111: txt_border <= 16'b0000_0000_0000_0001;

						4'b1000: txt_border <= 16'b1000_0000_0000_0000;
						4'b1001: txt_border <= 16'b1000_0000_0000_0000;
						4'b1010: txt_border <= 16'b1000_0000_0000_0000;
						4'b1011: txt_border <= 16'b0000_0000_0000_0000;

						4'b1100: txt_border <= 16'b1000_0000_0000_0001;
						4'b1101: txt_border <= 16'b1000_0000_0000_0000;
						4'b1110: txt_border <= 16'b1000_0000_0000_0001;
						4'b1111: txt_border <= 16'b0000_0000_0000_0001;
					endcase
				end
			end else begin
				txt_border <= 16'b0000_0000_0000_0000;
			end
		end
	end else begin
		txt_enable <= FALSE;
		gfx_enable <= FALSE;

		txt_horz_size <= 'd0;
		txt_horz_part <= 'd0;
		txt_pattern <= 'd0;
		txt_border <= 'd0;
		txt_func <= 'd0;
		txt_blink <= FALSE;
		txt_invert <= FALSE;
		txt_underline <= FALSE;
		gfx_bits <= 'd0;
		gfx_mosaic <= FALSE;
	end
endmodule