module vp_text_delay (
	// Base signals
	input wire clk,
	input wire reset,

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

reg [47:0] fifo = 48'b0;
always @(posedge clk)
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

always @(posedge clk)
	if (reset) begin
		txt_enable <= FALSE;
		txt_foreground <= 'd0;
		txt_background <= 'd0;
		txt_horz_size <= 'd0;
		txt_horz_part <= 'd0;
		txt_pattern <= 'd0;
		txt_border <= 'd0;
		txt_func <= 'd0;
		txt_blink <= FALSE;
		txt_invert <= FALSE;
		txt_underline <= FALSE;
	end else begin
		txt_enable <= fifo[0];
		txt_background <= fifo[47:44];
		txt_foreground <= fifo[43:40];
		txt_horz_size <= fifo[39];
		txt_horz_part <= fifo[38];
		txt_pattern <= fifo[37:22];
		txt_border <= fifo[21:6];
		txt_func <= fifo[5:4];
		txt_blink <= fifo[3];
		txt_invert <= fifo[2];
		txt_underline <= fifo[1];
	end
endmodule