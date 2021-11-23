module vp_merge_bitmaps (
	// Base signals
	input wire clk,

	// Text inputs
	input wire [3:0] txt_foreground,
	input wire [3:0] txt_background,
	input wire [15:0] txt_bitmap,
	input wire txt_enabled,

	// Graphic inputs
	input wire [3:0] gfx_foreground,
	input wire [3:0] gfx_background,
	input wire [15:0] gfx_bitmap,
	input wire gfx_enabled,

	// Outputs
	output reg [3:0] foreground,
	output reg [3:0] background,
	output reg [15:0] bitmap,
	output reg enable
);

`include "constant.v"

always @(posedge clk) begin
	enable <= txt_enabled | gfx_enabled;

	foreground <= gfx_enabled ? gfx_foreground : txt_foreground;
	background <= gfx_enabled ? gfx_background : txt_background;
	bitmap <= gfx_enabled ? gfx_bitmap : txt_bitmap;
end
endmodule