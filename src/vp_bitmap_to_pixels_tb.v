`timescale 1 ns / 100 ps
`include "vp_bitmap_to_pixels.v"
module vp_gfx_bitmap_tb ();
`include "constant.v"

reg clk;
reg reset;


reg [3:0] foreground;
reg [3:0] background;
reg [15:0] bitmap;
reg enabled;

wire [63:0] pixels;
wire enable;

vp_bitmap_to_pixels vp_bitmap_to_pixels (
	// Base signals
	.clk (clk),
	.reset (reset),

	// Inputs
	.foreground (foreground),
	.background (background),
	.bitmap (bitmap),
	.enabled (enabled),

	// Outputs
	.pixels (pixels),
	.enable (enable)
);

always #10 clk <= ~clk;

reg [15:0] ticks = 'd0;
always @(posedge clk) begin
    $display($time, " ticks=%d", ticks);
	ticks <= ticks + 'd1;
end

always @(posedge clk)
	case (ticks)
		'd1: begin
            foreground <= 'd15;
            background <= 'd00;
            bitmap <= 'b1010_0101_0000_1111_1001;
            enabled <= TRUE;
		end

		'd2: $finish;

		default:
			enabled <= FALSE;
	endcase

initial begin
    $monitor(
        $time,
		" enabled=%b, bitmap=%b, foreground=%d, background=%d\n",
		enabled, bitmap, foreground, background,
        "                     enable =%b, pixels=%b\n",
        enable, pixels
    );

    clk <= 1'b0;
    reset <= TRUE;

    #10	reset <= FALSE;
end

endmodule