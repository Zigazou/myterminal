module vp_merge_bitmaps (
	// Base signals
	input wire clk,
	input wire reset,

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

always @(posedge clk)
	if (reset) begin
		enable <= FALSE;
		foreground <= 'd0;
		background <= 'd0;
		bitmap <= 'd0;
	end else begin
		case ({ txt_enabled, gfx_enabled })
			2'b00: enable <= FALSE;
			2'b01: begin
				foreground <= gfx_foreground;
				background <= gfx_background;
				bitmap <= gfx_bitmap;
				enable <= TRUE;
			end
			2'b10, 2'b11: begin
				foreground <= txt_foreground;
				background <= txt_background;
				bitmap <= txt_bitmap;
				enable <= TRUE;
			end
		endcase
	end
endmodule