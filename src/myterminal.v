module myterminal (
	// Clock and reset
	input wire refclk,
	input wire reset_n,

	// Serial port
	input wire rx,
	output wire tx,
	output wire cts,

	// PS/2 port 0,
	input wire ps2_0_data,
	input wire ps2_0_clock,

	// PS/2 port 1,
	input wire ps2_1_data,
	input wire ps2_1_clock,

	// VGA output
	output wire [2:0] vga_red,
	output wire [2:0] vga_green,
	output wire [2:0] vga_blue,
	output wire vga_hsync,
	output wire vga_vsync
);

`include "constant.v"

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
	//.SERIAL_BPS (9_600)
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

wire ps2_byte_available;
wire [7:0] ps2_byte;
ps2_receiver ps2_0_receiver (
	.clk (clk),
	.reset (~reset_n),
	
	.ps2_data (ps2_0_data),
	.ps2_clock (ps2_0_clock),

	.rx_done_tick (ps2_byte_available),
	.rx_data (ps2_byte)
);

wire [7:0] scan_code;
wire scan_code_extended;
wire keyboard_shift;
wire keyboard_alt;
wire keyboard_altgr;
wire keyboard_ctrl;
wire keyboard_meta;
wire keyboard_state_ready;
ps2_keyboard_state ps2_keyboard_state (
	.clk (clk),
	.reset (~reset_n),

	.scan_code_ready (ps2_byte_available),
	.scan_code_in (ps2_byte),

	.keyboard_state_ready (keyboard_state_ready),
	.scan_code_out (scan_code),
	.scan_code_extended (scan_code_extended),
	.keyboard_shift (keyboard_shift),
	.keyboard_alt (keyboard_alt),
	.keyboard_altgr (keyboard_altgr),
	.keyboard_ctrl (keyboard_ctrl),
	.keyboard_meta (keyboard_meta)
);

wire keyboard_ascii_ready;
wire [7:0] keyboard_ascii;
ps2_keyboard_ascii ps2_keyboard_ascii (
	.clk (clk),
	.reset (~reset_n),

	.keyboard_state_ready (keyboard_state_ready),
	.scan_code_in (scan_code),
	.scan_code_extended (scan_code_extended),
	.keyboard_shift (keyboard_shift),
	.keyboard_alt (keyboard_alt),
	.keyboard_altgr (keyboard_altgr),
	.keyboard_ctrl (keyboard_ctrl),
	.keyboard_meta (keyboard_meta),
	
	.keyboard_ascii_ready (keyboard_ascii_ready),
	.keyboard_ascii (keyboard_ascii)
);

wire serial_out_sending;
wire serial_out_available;
wire [7:0] serial_out_data;
simple_fifo #(
	.DATA_WIDTH (8)
) fifo_out (
	.clk (clk),
	.reset (~reset_n),

	.in_data (keyboard_ascii),
	.in_data_available (keyboard_ascii_ready),

	.receiver_ready (~serial_out_sending),
	.out_data_available (serial_out_available),
	.out_data (serial_out_data)
);

serial_out #(
	.CLK_FREQUENCY_HZ (108_000_000),
	.SERIAL_BPS (3_000_000)
) serial_out (
	.clk (clk),
	.reset (~reset_n),

	.ie (serial_out_available),
	.data (serial_out_data),

	.tx (tx),
	.sending (serial_out_sending)
);

endmodule
