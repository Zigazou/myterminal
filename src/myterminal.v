module myterminal (
	// Clock and reset
	input wire refclk,
	input wire reset_n,

	// Serial port
	input wire rx,
	output wire tx,
	output wire cts,

	// VGA output
	output wire [2:0] vga_red,
	output wire [2:0] vga_green,
	output wire [2:0] vga_blue,
	output wire vga_hsync,
	output wire vga_vsync
);

`include "constant.v"

assign tx = 'b1;

wire clk;
clock clock (
	.refclk (refclk),
	.reset (~reset_n),
	.clk0_out (clk)
);

wire [7:0] in_byte;
wire in_byte_available;
serial_in #(
	.CLK_FREQUENCY_HZ (108_000_000),
	.SERIAL_BPS (3_000_000)
) serial_in (
	.clk (clk),
	.reset (~reset_n),
	.rx (rx),
	.data (in_byte),
	.oe (in_byte_available)
);

wire [14:0] font_address;
wire [15:0] char_row_bitmap;
font font (
	.clk (clk),
	.font_address (font_address),
	.char_row_bitmap (char_row_bitmap)
);
/*
wire out_data_available;
wire [20:0] out_data;
utf8_decode utf8_decode (
	.clk (clk),
	.reset (~reset_n),
	.ie (in_byte_available),
	.current_byte (in_byte),
	.unicode (out_data),
	.oe (out_data_available)
);
*/
wire [7:0] unicode;
wire unicode_available;
simple_fifo #(
	.DATA_WIDTH (8)
) simple_fifo (
	.clk (clk),
	.reset (~reset_n),

	.in_data (in_byte),
	.in_data_available (in_byte_available),

	.receiver_ready (~cts),
	.out_data_available (unicode_available),
	.out_data (unicode)
);

wire [22:0] wr_address;
wire [31:0] wr_data;
wire [3:0] wr_mask;
wire wr_request;
wire wr_done;
wire [8:0] wr_burst_length;
wire [3:0] register_index;
wire [22:0] register_value;
terminal_stream terminal_stream (
	.clk (clk),
	.reset (~reset_n),
	.ready_n (cts),
	.unicode (unicode),
	.unicode_available (unicode_available),
	.wr_address (wr_address),
	.wr_request (wr_request),
	.wr_data (wr_data),
	.wr_mask (wr_mask),
	.wr_done (wr_done),
	.wr_burst_length (wr_burst_length),
	.register_index (register_index),
	.register_value (register_value)
);

wire rd_request;
wire [22:0] rd_address;
wire [31:0] rd_data;
wire rd_available;
wire [8:0] rd_burst_length;
ram #(
	.CLK_FREQUENCY_HZ (108_000_000)
) ram (
	.clk (clk),
	.rst_n (reset_n),

	// Read signals
	.rd_request (rd_request),
	.rd_address (rd_address),
	.rd_available (rd_available),
	.rd_data (rd_data),
	.rd_burst_length (rd_burst_length),

	// Write signals
	.wr_request (wr_request),
	.wr_mask (wr_mask),
	.wr_done (wr_done),
	.wr_address (wr_address),
	.wr_data (wr_data),
	.wr_burst_length (wr_burst_length)
);

video_controller video_controller (
	.clk (clk),
	.reset (~reset_n),

	.hsync (vga_hsync),
	.vsync (vga_vsync),
	.pixel_red (vga_red),
	.pixel_green (vga_green),
	.pixel_blue (vga_blue),

	.rd_request (rd_request),
	.rd_address (rd_address),
	.rd_available (rd_available),
	.rd_data (rd_data),
	.rd_burst_length (rd_burst_length),

	.font_address (font_address),
	.char_row_bitmap (char_row_bitmap),

	.register_index (register_index),
	.register_value (register_value)
);

endmodule
