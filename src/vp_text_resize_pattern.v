module vp_text_resize_pattern (
	// Base signals
	input wire clk,
	input wire reset,

	// Inputs
	input wire [3:0] foreground,
	input wire [3:0] background,
	input wire [15:0] char_row_bitmap,
	input wire horz_size,
	input wire horz_part,
	input wire [15:0] pattern,
	input wire [15:0] border,
	input wire [1:0] func,
	input wire blink,
	input wire invert,
	input wire underline,
	input wire enabled,

	// Outputs
	output reg [3:0] txt_foreground,
	output reg [3:0] txt_background,
	output reg [15:0] txt_bitmap,
	output reg enable
);

`include "constant.v"
`include "video_controller/horizontal_resize.v"
`include "video_controller/apply_pattern.v"

always @(posedge clk)
	if (reset) begin
		enable <= FALSE;
		txt_foreground <= 'd0;
		txt_background <= 'd0;
		txt_bitmap <= 'd0;
	end else if (enabled) begin
		enable <= TRUE;

		if (underline) begin
			txt_bitmap <= apply_pattern(
				func,
				16'b1111111111111111,
				pattern
			);
		end else begin
			txt_bitmap <= border | apply_pattern(
				func,
				horizontal_resize(horz_size, horz_part, char_row_bitmap),
				pattern
			);
		end

		if (invert) begin
			txt_foreground <= blink ? foreground : background;
			txt_background <= foreground;
		end else begin
			txt_foreground <= blink ? background : foreground;
			txt_background <= background;
		end
	end else begin
		enable <= FALSE;
	end
endmodule