module vp_gfx_delay (
	// Base signals
	input wire clk,
	input wire reset,

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

reg [24:0] fifo = 25'b0;
always @(posedge clk)
	fifo <= { background, foreground, bitmap, enabled };

always @(posedge clk)
	if (reset) begin
		enable <= FALSE;
		gfx_background <= 'd0;
		gfx_foreground <= 'd0;
		gfx_bitmap <= 'd0;
	end else begin
		enable <= fifo[0];
		gfx_background <= fifo[24:21];
		gfx_foreground <= fifo[20:17];
		gfx_bitmap <= fifo[16:1];
	end
endmodule