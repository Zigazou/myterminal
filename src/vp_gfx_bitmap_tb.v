`timescale 1 ns / 100 ps
`include "vp_gfx_bitmap.v"
module vp_gfx_bitmap_tb ();
`include "constant.v"

reg clk;
reg reset;

reg [3:0] foreground;
reg [3:0] background;
reg [19:0] gfx_bits;
reg [4:0] char_row;
reg mosaic;
reg enabled;
wire [3:0] gfx_foreground;
wire [3:0] gfx_background;
wire [15:0] gfx_bitmap;
wire enable;

vp_gfx_bitmap vp_gfx_bitmap (
	// Base signals
	.clk (clk),
	.reset (reset),

	// Inputs
	.background (background),
	.gfx_bits (gfx_bits),
	.foreground (foreground),
	.char_row (char_row),
	.mosaic (mosaic),
	.enabled (enabled),

	// Outputs
	.gfx_foreground (gfx_foreground),
	.gfx_background (gfx_background),
	.gfx_bitmap (gfx_bitmap),
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
			foreground <= 'd01;
			background <= 'd02;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd0;
			mosaic <= FALSE;
			enabled <= TRUE;
		end

		'd2: begin
			foreground <= 'd03;
			background <= 'd04;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd4;
			mosaic <= FALSE;
			enabled <= TRUE;
		end

		'd3: begin
			foreground <= 'd05;
			background <= 'd06;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd8;
			mosaic <= FALSE;
			enabled <= TRUE;
		end

		'd4: begin
			foreground <= 'd07;
			background <= 'd08;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd12;
			mosaic <= FALSE;
			enabled <= TRUE;
		end

		'd5: begin
			foreground <= 'd08;
			background <= 'd09;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd16;
			mosaic <= FALSE;
			enabled <= TRUE;
		end

		'd10: begin
			foreground <= 'd01;
			background <= 'd02;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd1;
			mosaic <= TRUE;
			enabled <= TRUE;
		end

		'd11: begin
			foreground <= 'd03;
			background <= 'd04;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd5;
			mosaic <= TRUE;
			enabled <= TRUE;
		end

		'd12: begin
			foreground <= 'd05;
			background <= 'd06;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd9;
			mosaic <= TRUE;
			enabled <= TRUE;
		end

		'd13: begin
			foreground <= 'd07;
			background <= 'd08;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd13;
			mosaic <= TRUE;
			enabled <= TRUE;
		end

		'd14: begin
			foreground <= 'd08;
			background <= 'd09;
			gfx_bits <= 'b1010_0101_0000_1111_1001;
			char_row <= 'd17;
			mosaic <= TRUE;
			enabled <= TRUE;
		end

		'd15: $finish;

		default:
			enabled <= FALSE;
	endcase

initial begin
    $monitor(
        $time,
		" enabled=%b, gfx_bits  =%b, foreground    =%d, background    =%d\n",
		enabled, gfx_bits, foreground, background,
        "                     enable =%b, gfx_bitmap=%b    , gfx_foreground=%d, gfx_background=%d\n",
        enable, gfx_bitmap, gfx_foreground, gfx_background
    );

    clk <= 1'b0;
    reset <= TRUE;

    #10	reset <= FALSE;
end

endmodule