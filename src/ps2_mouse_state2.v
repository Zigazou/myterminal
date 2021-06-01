module ps2_mouse_state2 (
	input wire clk,
	input wire reset, 

	input wire left_button,
	input wire right_button,
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
	output reg [10:0] x_screen = 'd640,
	output reg [9:0] y_screen = 'd512,

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
	STATE_SEND       = 'd1;

reg state = STATE_IDLE;

task state_idle;
	begin
		read <= FALSE;
		mouse_state_ready <= FALSE;

		if (data_ready) begin
			state <= STATE_SEND;

			button_left <= left_button;
			button_right <= right_button;
			button_middle <= FALSE;

			if (x_increment[8]) begin
				if (x_screen < { 3'b0, x_increment[7:0] })
					x_screen <= 'd0;
				else
					x_screen <= x_screen - { 3'b0, x_increment[7:0] };
			end else begin
				if (x_screen > (MAX_X - { 3'b0, x_increment[7:0] }))
					x_screen <= MAX_X;
				else
					x_screen <= x_screen + { 3'b0, x_increment[7:0] };
			end

			if (y_increment[8]) begin
				if (y_screen > (MAX_Y - { 3'b0, y_increment[7:0] }))
					y_screen <= MAX_Y;
				else
					y_screen <= y_screen + { 3'b0, y_increment[7:0] };
			end else begin
				if (y_screen < { 3'b0, y_increment[7:0] })
					y_screen <= 'd0;
				else
					y_screen <= y_screen - { 3'b0, y_increment[7:0] };
			end
		end else
			state <= STATE_IDLE;
	end
endtask

task state_send;
	begin
		read <= TRUE;
		mouse_state_ready <= TRUE;

		x_text <= x_screen[10:4];
		/* TEST */y_text <= y_screen[9:4]; //y_screen / 'd20;
		register_index <= VIDEO_MOUSE_POSITION;
		register_value <= { 2'b0, y_screen, x_screen };
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
		x_screen <= 'd640;
		y_screen <= 'd512;
		register_index <= VIDEO_NOP;
		register_value <= 'd0;
	end else begin
		case (state)
			STATE_IDLE: state_idle();
			STATE_SEND: state_send();
		endcase
	end
endmodule
