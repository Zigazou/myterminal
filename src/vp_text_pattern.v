module vp_text_pattern (
	// Base signals
	input wire clk,

	// Inputs
	input wire [3:0] foreground,
	input wire [3:0] background,
	input wire [15:0] char_row_bitmap,
	input wire [15:0] pattern,
	input wire [15:0] border,
	input wire [1:0] func,
	input wire blink,
	input wire invert,
	input wire enabled,

	// Outputs
	output reg [3:0] txt_foreground,
	output reg [3:0] txt_background,
	output reg [15:0] txt_bitmap,
	output reg enable
);

`include "constant.v"
`include "video_controller/apply_pattern.v"

always @(posedge clk) begin
	enable <= enabled;
	txt_bitmap <= border | apply_pattern(func, char_row_bitmap, pattern);

	if (invert) begin
		txt_foreground <= blink ? foreground : background;
		txt_background <= foreground;
	end else begin
		txt_foreground <= blink ? background : foreground;
		txt_background <= background;
	end
end
endmodule