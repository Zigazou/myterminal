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
	inout wire ps2_1_data,
	inout wire ps2_1_clock,

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
	//.SERIAL_BPS (115_200)
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

wire [8:0] cursor_address;
wire [15:0] cursor_row_bitmap;
cursor_ram cursor_ram (
	.clka (clk),
	.rsta (~reset_n),
	.doa (cursor_row_bitmap),
	.addra (cursor_address)
);

wire [7:0] unicode;
wire unicode_available;
simple_fifo #(
	.DATA_WIDTH (8),
	.FIFO_SIZE (16)
) simple_fifo (
	.clk (clk),
	.reset (~reset_n),

	.in_data (in_byte),
	.in_data_available (in_byte_available),

	.receiver_ready (~cts),
	.out_data_available (unicode_available),
	.out_data (unicode)
);

wire [3:0] register_index_0;
wire [22:0] register_value_0;
wire [3:0] register_index_1;
wire [22:0] register_value_1;
wire [3:0] register_index;
wire [22:0] register_value;
register_muxer register_muxer (
	.clk (clk),
	.reset (~reset_n),
	
	.register_index_0 (register_index_0),
	.register_index_1 (register_index_1),
	.register_value_0 (register_value_0),
	.register_value_1 (register_value_1),

	.register_index (register_index),
	.register_value (register_value)
);

wire [22:0] wr_address;
wire [31:0] wr_data;
wire [3:0] wr_mask;
wire wr_request;
wire wr_done;
wire [8:0] wr_burst_length;
wire [1:0] mouse_control;
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
	.register_index (register_index_0),
	.register_value (register_value_0),
	.mouse_control (mouse_control)
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

	.cursor_address (cursor_address),
	.cursor_row_bitmap (cursor_row_bitmap),

	.mouse_control (mouse_control),

	.register_index (register_index),
	.register_value (register_value)
);

wire ps2_0_byte_available;
wire [7:0] ps2_0_byte;
ps2_receiver ps2_0_receiver (
	.clk (clk),
	.reset (~reset_n),
	
	.ps2_data (ps2_0_data),
	.ps2_clock (ps2_0_clock),

	.rx_done_tick (ps2_0_byte_available),
	.rx_data (ps2_0_byte)
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

	.scan_code_ready (ps2_0_byte_available),
	.scan_code_in (ps2_0_byte),

	.keyboard_state_ready (keyboard_state_ready),
	.scan_code_out (scan_code),
	.scan_code_extended (scan_code_extended),
	.keyboard_shift (keyboard_shift),
	.keyboard_alt (keyboard_alt),
	.keyboard_altgr (keyboard_altgr),
	.keyboard_ctrl (keyboard_ctrl),
	.keyboard_meta (keyboard_meta)
);

wire [31:0] keyboard_sequence_out;
wire [2:0] keyboard_sequence_out_count;
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
	
	.sequence_out (keyboard_sequence_out),
	.sequence_out_count (keyboard_sequence_out_count)
);

wire ps2_1_byte_available;
wire [7:0] ps2_1_byte;
/*
ps2_receiver ps2_1_receiver (
	.clk (clk),
	.reset (~reset_n),
	
	.ps2_data (ps2_1_data),
	.ps2_clock (ps2_1_clock),

	.rx_done_tick (ps2_1_byte_available),
	.rx_data (ps2_1_byte)
);
*/

wire left_button;
wire right_button;
wire middle_button;
wire [8:0] x_increment;
wire [8:0] y_increment;
wire data_ready;
wire read;
wire error_no_ack;
ps2_mouse_interface #(
	.WATCHDOG_TIMER_VALUE_PP (43200),
	.WATCHDOG_TIMER_BITS_PP (16),
	.DEBOUNCE_TIMER_VALUE_PP (700),
	.DEBOUNCE_TIMER_BITS_PP (10)
) ps2_1_receiver (
	.clk (clk),
	.reset (~reset_n),
	
	.ps2_data (ps2_1_data),
	.ps2_clk (ps2_1_clock),

	.left_button (left_button),
	.right_button (right_button),
	.middle_button (middle_button),
	.x_increment (x_increment),
	.y_increment (y_increment),
	.data_ready (data_ready),
	.read (read),
	.error_no_ack(error_no_ack)

	//.rx_done_tick (ps2_1_byte_available),
	//.rx_data (ps2_1_byte)
);

wire mouse_button_left;
wire mouse_button_right;
wire mouse_button_middle;
wire [6:0] mouse_x_text;
wire [5:0] mouse_y_text;
wire [10:0] mouse_x_screen;
wire [9:0] mouse_y_screen;
ps2_mouse_state2 ps2_mouse_state (
	.clk (clk),
	.reset (~reset_n),

	.left_button (left_button),
	.right_button (right_button),
	.middle_button (middle_button),
	.x_increment (x_increment),
	.y_increment (y_increment),
	.data_ready (data_ready),
	.read (read),

	.mouse_state_ready (mouse_state_ready),
	.button_left (mouse_button_left),
	.button_middle (mouse_button_middle),
	.button_right (mouse_button_right),
	.x_text (mouse_x_text),
	.y_text (mouse_y_text),
	.x_screen (mouse_x_screen),
	.y_screen (mouse_y_screen),

	.register_index (register_index_1),
	.register_value (register_value_1)
);

/*
wire mouse_button_left;
wire mouse_button_right;
wire mouse_button_middle;
wire [6:0] mouse_x_text;
wire [5:0] mouse_y_text;
wire [10:0] mouse_x_screen;
wire [9:0] mouse_y_screen;
ps2_mouse_state ps2_mouse_state (
	.clk (clk),
	.reset (~reset_n),

	.scan_code_ready (ps2_1_byte_available),
	.scan_code_in (ps2_1_byte),

	.mouse_state_ready (mouse_state_ready),
	.button_left (mouse_button_left),
	.button_middle (mouse_button_middle),
	.button_right (mouse_button_right),
	.x_text (mouse_x_text),
	.y_text (mouse_y_text),
	.x_screen (mouse_x_screen),
	.y_screen (mouse_y_screen),

	.register_index (register_index_1),
	.register_value (register_value_1)
);
*/

wire [31:0] mouse_sequence_out;
wire [2:0] mouse_sequence_out_count;
ps2_mouse_ascii ps2_mouse_ascii (
	.clk (clk),
	.reset (~reset_n),

	.mouse_control (mouse_control),

	.keyboard_shift (keyboard_shift),
	.keyboard_alt (keyboard_alt),
	.keyboard_ctrl (keyboard_ctrl),
	.keyboard_meta (keyboard_meta),

	.mouse_state_ready (mouse_state_ready),
	.button_left (mouse_button_left),
	.button_middle (mouse_button_middle),
	.button_right (mouse_button_right),
	.x_text (mouse_x_text),
	.y_text (mouse_y_text),
	.x_screen (mouse_x_screen),
	.y_screen (mouse_y_screen),

	.sequence_out (mouse_sequence_out),
	.sequence_out_count (mouse_sequence_out_count)
);

wire [34:0] in_muxer_keyboard_data;
wire in_muxer_keyboard_ready;
wire in_muxer_keyboard_available;
simple_fifo #(.DATA_WIDTH (35)) keyboard_sequence_fifo (
	.clk (clk),
	.reset (~reset_n),

	.in_data ({ keyboard_sequence_out_count, keyboard_sequence_out }),
	.in_data_available (keyboard_sequence_out_count != 3'd0),

	.receiver_ready (in_muxer_keyboard_ready),
	.out_data_available (in_muxer_keyboard_available),
	.out_data (in_muxer_keyboard_data)
);


wire [34:0] in_muxer_mouse_data;
wire in_muxer_mouse_ready;
wire in_muxer_mouse_available;
simple_fifo #(.DATA_WIDTH (35)) mouse_sequence_fifo (
	.clk (clk),
	.reset (~reset_n),

	.in_data ({ mouse_sequence_out_count, mouse_sequence_out }),
	.in_data_available (mouse_sequence_out_count != 3'd0),

	.receiver_ready (in_muxer_mouse_ready),
	.out_data_available (in_muxer_mouse_available),
	.out_data (in_muxer_mouse_data)
);

wire serial_out_sending;
wire muxer_out_available;
wire [34:0] muxer_out_data;
wire sequence_to_bytes_ready;
muxer #(
	.DATA_WIDTH (35)
) muxer (
	.clk (clk),
	.reset (~reset_n),

	.in_data_0 (in_muxer_keyboard_data),
	.in_data_0_available (in_muxer_keyboard_available),
	.in_data_0_ready (in_muxer_keyboard_ready),

	.in_data_1 (in_muxer_mouse_data),
	.in_data_1_available (in_muxer_mouse_available),
	.in_data_1_ready (in_muxer_mouse_ready),

	.receiver_ready (sequence_to_bytes_ready),
	.out_data_available (muxer_out_available),
	.out_data (muxer_out_data)
);

wire [7:0] serial_out_data;
wire serial_out_available;
sequence_to_bytes sequence_to_bytes(
	.clk (clk),
	.reset (~reset_n),

	.in_sequence (muxer_out_data),
	.in_sequence_available (muxer_out_available),
	.in_sequence_ready (sequence_to_bytes_ready),

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
