module vp_bitmap_to_pixels (
	// Base signals
	input wire clk,
	input wire reset,

	// Inputs
	input wire [3:0] foreground,
	input wire [3:0] background,
	input wire [15:0] bitmap,
	input wire enabled,

	// Outputs
	output reg [63:0] pixels,
	output reg enable
);

`include "constant.v"

always @(posedge clk)
	if (reset) begin
		enable <= FALSE;
        pixels <= 'd0;
	end else if (enabled) begin
		enable <= TRUE;
        pixels <= {
            bitmap[ 0] ? foreground : background,
            bitmap[ 1] ? foreground : background,
            bitmap[ 2] ? foreground : background,
            bitmap[ 3] ? foreground : background,
            bitmap[ 4] ? foreground : background,
            bitmap[ 5] ? foreground : background,
            bitmap[ 6] ? foreground : background,
            bitmap[ 7] ? foreground : background,
            bitmap[ 8] ? foreground : background,
            bitmap[ 9] ? foreground : background,
            bitmap[10] ? foreground : background,
            bitmap[11] ? foreground : background,
            bitmap[12] ? foreground : background,
            bitmap[13] ? foreground : background,
            bitmap[14] ? foreground : background,
            bitmap[15] ? foreground : background
        };
	end else begin
		enable <= FALSE;
	end
endmodule