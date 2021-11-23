module vp_text_resize (
	// Base signals
	input wire clk,

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
	output reg [15:0] txt_char_row_bitmap,
	output reg [15:0] txt_pattern,
	output reg [15:0] txt_border,
	output reg [1:0] txt_func,
	output reg txt_blink,
	output reg txt_invert,
	output reg enable
);

`include "constant.v"
`include "video_controller/horizontal_resize.v"

always @(posedge clk) begin
	enable <= enabled;

	if (enabled) begin
		if (underline) begin
			txt_char_row_bitmap <= 16'b1111111111111111;
		end else begin
			txt_char_row_bitmap <= horizontal_resize(
				horz_size, horz_part, char_row_bitmap
			);
		end

		txt_foreground <= foreground;
		txt_background <= background;
		txt_pattern <= pattern;
		txt_border <= border;
		txt_func <= func;
		txt_blink <= blink;
		txt_invert <= invert;
	end
end
endmodule