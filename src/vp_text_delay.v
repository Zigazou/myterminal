module vp_text_delay (
	// Base signals
	input wire clk,

	// Inputs
	input wire [3:0] foreground,
	input wire [3:0] background,
	input wire horz_size,
	input wire horz_part,
	input wire [15:0] pattern,
	input wire [15:0] border,
	input wire [1:0] func,
	input wire blink,
	input wire invert,
	input wire underline,
	input wire enabled,

	// Text output
	output reg [3:0] txt_foreground,
	output reg [3:0] txt_background,    
	output reg txt_horz_size,
	output reg txt_horz_part,
	output reg [15:0] txt_pattern,
	output reg [15:0] txt_border,
	output reg [1:0] txt_func,
	output reg txt_blink,
	output reg txt_invert,
	output reg txt_underline,
	output reg txt_enable
);

`include "constant.v"

reg [47:0] fifo;
always @(posedge clk) begin
	fifo <= {
		background,
		foreground,
		horz_size,
		horz_part,
		pattern,
		border,
		func,
		blink,
		invert,
		underline,
		enabled
	};

	{ txt_background,
	txt_foreground, 
	txt_horz_size,
	txt_horz_part,
	txt_pattern,
	txt_border,
	txt_func,
	txt_blink,
	txt_invert,
	txt_underline,
	txt_enable } <= fifo;
end
endmodule