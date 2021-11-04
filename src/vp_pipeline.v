`include "vp_text_or_gfx.v"
`include "vp_text_delay.v"
`include "vp_text_resize_pattern.v"
`include "vp_gfx_bitmap.v"
`include "vp_gfx_delay.v"
`include "vp_merge_bitmaps.v"
`include "vp_bitmap_to_pixels.v"

module vp_pipeline #(
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
	input wire        enabled,

	// Intermediate inputs/outputs
	output wire [14:0] txt_font_address,
	input wire [15:0] txt_char_row_bitmap,

	// Outputs
	output wire [63:0] pixels,
	output wire        enable
);

wire [14:0] vptog_txt_font_address;
assign txt_font_address = vptog_txt_font_address;

wire [4:0]  vptog_char_row_out;
wire [3:0]  vptog_foreground;
wire [3:0]  vptog_background;
wire        vptog_txt_horz_size;
wire        vptog_txt_horz_part;
wire [15:0] vptog_txt_pattern;
wire [15:0] vptog_txt_border;
wire [1:0]  vptog_txt_func;
wire        vptog_txt_blink;
wire        vptog_txt_invert;
wire        vptog_txt_underline;
wire        vptog_txt_enable;
wire [19:0] vptog_gfx_bits;
wire        vptog_gfx_mosaic;
wire        vptog_gfx_enable;
vp_text_or_gfx vp_text_or_gfx (
	.clk (clk),
	.reset (reset),

	// Inputs
	.charattr (charattr),
	.char_row_in (char_row_in),
	.ypos (ypos),
	.enabled (enabled),

	// Common output
	.char_row_out (vptog_char_row_out),
	.foreground (vptog_foreground),
	.background (vptog_background),

	// Text output
	.txt_font_address (vptog_txt_font_address),
	.txt_horz_size (vptog_txt_horz_size),
	.txt_horz_part (vptog_txt_horz_part),
	.txt_pattern (vptog_txt_pattern),
	.txt_border (vptog_txt_border),
	.txt_func (vptog_txt_func),
	.txt_blink (vptog_txt_blink),
	.txt_invert (vptog_txt_invert),
	.txt_underline (vptog_txt_underline),
	.txt_enable (vptog_txt_enable),

	// Graphic output
	.gfx_bits (vptog_gfx_bits),
	.gfx_mosaic (vptog_gfx_mosaic),
	.gfx_enable (vptog_gfx_enable)
);

// -----------------------------------------------------------------------------
// Graphic
// -----------------------------------------------------------------------------
wire [19:0] vpgb_gfx_bits;
wire [4:0]  vpgb_char_row;
wire        vpgb_mosaic;
wire        vpgb_enabled;
wire [3:0]  vpgb_gfx_foreground;
wire [3:0]  vpgb_gfx_background;
wire [15:0] vpgb_gfx_bitmap;
wire        vpgb_enable;
vp_gfx_bitmap vp_gfx_bitmap (
	.clk (clk),
	.reset (reset),

	// Inputs
	.foreground (vptog_foreground),
	.background (vptog_background),
	.gfx_bits (vptog_gfx_bits),
	.char_row (vptog_char_row_out),
	.mosaic (vptog_gfx_mosaic),
	.enabled (vptog_gfx_enable),

	// Outputs
	.gfx_foreground (vpgb_gfx_foreground),
	.gfx_background (vpgb_gfx_background),
	.gfx_bitmap (vpgb_gfx_bitmap),
	.enable (vpgb_enable)
);

wire [3:0]  vpgd_gfx_foreground;
wire [3:0]  vpgd_gfx_background;
wire [15:0] vpgd_gfx_bitmap;
wire        vpgd_enable;
vp_gfx_delay vp_gfx_delay (
	.clk (clk),
	.reset (reset),

	// Inputs
	.foreground (vpgb_gfx_foreground),
	.background (vpgb_gfx_background),
	.bitmap (vpgb_gfx_bitmap),
	.enabled (vpgb_enable),

	// Outputs
	.gfx_foreground (vpgd_gfx_foreground),
	.gfx_background (vpgd_gfx_background),
	.gfx_bitmap (vpgd_gfx_bitmap),
	.enable (vpgd_enable)
);

// -----------------------------------------------------------------------------
// Text
// -----------------------------------------------------------------------------
wire [3:0]  vptd_foreground;
wire [3:0]  vptd_background;
wire        vptd_horz_size;
wire        vptd_horz_part;
wire [15:0] vptd_pattern;
wire [15:0] vptd_border;
wire [1:0]  vptd_func;
wire        vptd_blink;
wire        vptd_invert;
wire        vptd_underline;
wire        vptd_enable;
vp_text_delay vp_text_delay (
	.clk (clk),
	.reset (reset),

	// Inputs
	.foreground (vptog_foreground),
	.background (vptog_background),
	.horz_size (vptog_txt_horz_size),
	.horz_part (vptog_txt_horz_part),
	.pattern (vptog_txt_pattern),
	.border (vptog_txt_border),
	.func (vptog_txt_func),
	.blink (vptog_txt_blink),
	.invert (vptog_txt_invert),
	.underline (vptog_txt_underline),
	.enabled (vptog_txt_enable),

	// Text output
	.txt_foreground (vptd_foreground),
	.txt_background (vptd_background),
	.txt_horz_size (vptd_horz_size),
	.txt_horz_part (vptd_horz_part),
	.txt_pattern (vptd_pattern),
	.txt_border (vptd_border),
	.txt_func (vptd_func),
	.txt_blink (vptd_blink),
	.txt_invert (vptd_invert),
	.txt_underline (vptd_underline),
	.txt_enable (vptd_enable)
);

wire [3:0]  vptrp_txt_foreground;
wire [3:0]  vptrp_txt_background;
wire [15:0] vptrp_txt_bitmap;
wire        vptrp_enable;
vp_text_resize_pattern vp_text_resize_pattern (
	.clk (clk),
	.reset (reset),

	// Inputs
	.foreground (vptd_foreground),
	.background (vptd_background),
	.char_row_bitmap (txt_char_row_bitmap),
	.horz_size (vptd_horz_size),
	.horz_part (vptd_horz_part),
	.pattern (vptd_pattern),
	.border (vptd_border),
	.func (vptd_func),
	.blink (vptd_blink),
	.invert (vptd_invert),
	.underline (vptd_underline),
	.enabled (vptd_enable),

	// Outputs
	.txt_foreground (vptrp_txt_foreground),
	.txt_background (vptrp_txt_background),
	.txt_bitmap (vptrp_txt_bitmap),
	.enable (vptrp_enable)
);

// -----------------------------------------------------------------------------
// Merging and pixel generation
// -----------------------------------------------------------------------------
wire [3:0]  vpmb_foreground;
wire [3:0]  vpmb_background;
wire [15:0] vpmb_bitmap;
wire        vpmb_enable;
vp_merge_bitmaps vp_merge_bitmaps (
	.clk (clk),
	.reset (reset),

	// Text inputs
	.txt_foreground (vptrp_txt_foreground),
	.txt_background (vptrp_txt_background),
	.txt_bitmap (vptrp_txt_bitmap),
	.txt_enabled (vptrp_enable),

	// Graphic inputs
	.gfx_foreground (vpgd_gfx_foreground),
	.gfx_background (vpgd_gfx_background),
	.gfx_bitmap (vpgd_gfx_bitmap),
	.gfx_enabled (vpgd_enable),

	// Outputs
	.foreground (vpmb_foreground),
	.background (vpmb_background),
	.bitmap (vpmb_bitmap),
	.enable (vpmb_enable)
);

vp_bitmap_to_pixels vp_bitmap_to_pixels (
	.clk (clk),
	.reset (reset),

	// Inputs
	.foreground (vpmb_foreground),
	.background (vpmb_background),
	.bitmap (vpmb_bitmap),
	.enabled (vpmb_enable),

	// Outputs
	.pixels (pixels),
	.enable (enable)
);

endmodule