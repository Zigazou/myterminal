module vp_gfx_delay (
	// Base signals
	input wire clk,

	// Inputs
	input wire [3:0] foreground,
	input wire [3:0] background,
	input wire [15:0] bitmap,
	input wire enabled,

	// Outputs
	output reg [3:0] gfx_foreground,
	output reg [3:0] gfx_background,
	output reg [15:0] gfx_bitmap,
	output reg enable
);

`include "constant.v"

reg [49:0] fifo = 50'b0;
always @(posedge clk) begin
	fifo <= { background, foreground, bitmap, enabled, fifo[49:25] };
	{ gfx_background, gfx_foreground, gfx_bitmap, enable } <= fifo;
end
endmodule