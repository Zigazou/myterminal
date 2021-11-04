module ps2_mouse_state2 (
	input wire clk,
	input wire reset, 

	input wire left_button,
	input wire right_button,
	input wire middle_button,
	input wire [8:0] x_increment,
	input wire [8:0] y_increment,
	input wire data_ready,
	output reg read,

	output reg mouse_state_ready = 0,
	output reg button_left = 0,
	output reg button_middle = 0,
	output reg button_right = 0,
	output reg [6:0] x_text = 0,
	output reg [5:0] y_text = 0,
	output reg [10:0] x_screen = 'd0,
	output reg [9:0] y_screen = 'd0,

	output reg [3:0] register_index,
	output reg [22:0] register_value
);

`include "constant.v"
`include "video_controller/registers.v"

localparam
	MAX_X             = 11'd1279,
	MAX_Y             = 10'd1023;

localparam
	STATE_IDLE       = 'd0,
	STATE_SEND       = 'd1,
	STATE_SENT       = 'd2;

reg [1:0] state = STATE_IDLE;

reg [10:0] new_x_screen;
reg [9:0] new_y_screen;

task state_idle;
	begin
		read <= FALSE;
		mouse_state_ready <= FALSE;
		register_index <= VIDEO_NOP;
		register_value <= 'd0;

		if (data_ready)
			state <= STATE_SEND;
		else
			state <= STATE_IDLE;
	end
endtask

wire x_increment_is_negative = x_increment[8];
wire y_increment_is_negative = y_increment[8];
task state_send;
	begin
		read <= TRUE;
		mouse_state_ready <= FALSE;

		button_left <= left_button;
		button_right <= right_button;
		button_middle <= middle_button;

		if (x_increment_is_negative)
			// new_x_screen <= x_screen + { 2'b11, x_increment }; // speed x 1
			new_x_screen <= x_screen + { 1'b1, x_increment, 1'b0 }; // speed x 2
		else
			// new_x_screen <= x_screen + { 2'b00, x_increment }; // speed x 1
			new_x_screen <= x_screen + { 1'b0, x_increment, 1'b0 }; // speed x 2

		if (y_increment_is_negative)
			// new_y_screen <= y_screen - { 1'b1, y_increment }; // speed x 1
			new_y_screen <= y_screen - { y_increment, 1'b0 }; // speed x 2
		else
			// new_y_screen <= y_screen - { 1'b0, y_increment }; // speed x 1
			new_y_screen <= y_screen - { y_increment, 1'b0 }; // speed x 2

		state <= STATE_SENT;
	end
endtask

wire x_too_low = x_increment_is_negative && (new_x_screen > x_screen);
wire x_too_high =
	!x_increment_is_negative
	&& (new_x_screen < x_screen || new_x_screen > 'd1279);

wire y_too_low = !y_increment_is_negative && (new_y_screen > y_screen);
wire y_too_high =
	y_increment_is_negative
	&& (new_y_screen < y_screen || new_y_screen > 'd1019);

task state_sent;
	begin
		read <= FALSE;
		mouse_state_ready <= TRUE;

		if (x_too_low) begin
			x_screen <= 'd0;
			x_text <= 'd0;
		end else if (x_too_high) begin
			x_screen <= 'd1279;
			x_text <= 'd79;
		end else begin
			x_screen <= new_x_screen;
			x_text <= new_x_screen[10:4];
		end

		if (y_too_low) begin
			y_screen <= 'd0;
			y_text <= 'd0;
		end else if (y_too_high) begin
			y_screen <= 'd1019;
			y_text <= 'd50;
		end else begin
			y_screen <= new_y_screen;
			y_text <= new_y_screen / 'd20;
		end

		register_index <= VIDEO_MOUSE_POSITION;
		register_value <= {
			2'b0,
			y_too_low ? 10'd0 : y_too_high ? 10'd1019 : new_y_screen,
			x_too_low ? 11'd0 : x_too_high ? 11'd1279 : new_x_screen
		};

		state <= STATE_IDLE;
	end
endtask

always @(posedge clk)
	if (reset) begin
		state <= STATE_IDLE;
		read <= FALSE;
		mouse_state_ready <= FALSE;
		button_left <= FALSE;
		button_middle <= FALSE;
		button_right <= FALSE;
		x_text <= 'd0;
		y_text <= 'd0;
		x_screen <= 'd0;
		y_screen <= 'd0;
		register_index <= VIDEO_NOP;
		register_value <= 'd0;
	end else begin
		case (state)
			STATE_IDLE: state_idle();
			STATE_SEND: state_send();
			STATE_SENT: state_sent();
			default: state_idle();
		endcase
	end
endmodule
