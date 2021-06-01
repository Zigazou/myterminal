module ps2_mouse_state (
	input wire clk,
	input wire reset, 

	input wire scan_code_ready,
	input wire [7:0] scan_code_in,

	output reg mouse_state_ready = 0,
	output reg button_left = 0,
	output reg button_middle = 0,
	output reg button_right = 0,
	output reg [6:0] x_text = 0,
	output reg [5:0] y_text = 0,
	output reg [10:0] x_screen = 0,
	output reg [9:0] y_screen = 0,

	output reg [3:0] register_index,
	output reg [22:0] register_value
);

`include "constant.v"
`include "video_controller/registers.v"

localparam
	BIT_BUTTON_LEFT   = 0,
	BIT_BUTTON_RIGHT  = 1,
	BIT_BUTTON_MIDDLE = 2,
	BIT_ALWAYS_1      = 3,
	BIT_X_SIGN        = 4,
	BIT_Y_SIGN        = 5,
	MAX_X             = 11'd1279,
	MAX_Y             = 10'd1023;

localparam
	STATE_IDLE       = 'd0,
	STATE_BYTE_1     = 'd1,
	STATE_BYTE_2     = 'd2,
	STATE_SEND       = 'd3;


reg [1:0] state = STATE_IDLE;

reg [7:0] incoming_byte_1 = 'd0;
reg [7:0] incoming_byte_2 = 'd0;

task state_idle;
	begin
		mouse_state_ready <= FALSE;
		if (scan_code_ready) begin
			incoming_byte_1 <= scan_code_in;
			state <= STATE_BYTE_1;
		end else begin
			state <= STATE_IDLE;
		end
	end
endtask

task state_byte_1;
	begin
		if (scan_code_ready) begin
			incoming_byte_2 <= scan_code_in;
			state <= STATE_BYTE_2;
		end else begin
			state <= STATE_BYTE_1;
		end
	end
endtask

task state_byte_2;
	begin
		/*if (scan_code_ready) begin*/
			state <= STATE_SEND;
			button_left <= incoming_byte_1[BIT_BUTTON_LEFT];
			button_right <= incoming_byte_1[BIT_BUTTON_RIGHT];
			button_middle <= incoming_byte_1[BIT_BUTTON_MIDDLE];

			if (incoming_byte_1[BIT_X_SIGN]) begin
				if (x_screen < { 3'b0, incoming_byte_1 })
					x_screen <= 'd0;
				else
					x_screen <= x_screen - incoming_byte_1;
			end else begin
				if (x_screen > (MAX_X - { 3'b0, incoming_byte_1 }))
					x_screen <= MAX_X;
				else
					x_screen <= x_screen + incoming_byte_1;
			end

			if (incoming_byte_1[BIT_Y_SIGN]) begin
				if (y_screen < { 3'b0, scan_code_in })
					y_screen <= 'd0;
				else
					y_screen <= y_screen - scan_code_in;
			end else begin
				if (y_screen > (MAX_Y - { 3'b0, scan_code_in }))
					y_screen <= MAX_Y;
				else
					y_screen <= y_screen + scan_code_in;
			end
		/*end else begin
			state <= STATE_BYTE_2;
		end*/
	end
endtask

task state_send;
	begin
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
		mouse_state_ready <= FALSE;
		button_left <= FALSE;
		button_middle <= FALSE;
		button_right <= FALSE;
		x_text <= 'd0;
		y_text <= 'd0;
		x_screen <= 'd0;
		y_screen <= 'd0;
		incoming_byte_1 <= 'd0;
		incoming_byte_2 <= 'd0;
		register_index <= VIDEO_NOP;
		register_value <= 'd0;
	end else begin
		case (state)
			STATE_IDLE: state_idle();
			STATE_BYTE_1: state_byte_1();
			STATE_BYTE_2: state_byte_2();
			STATE_SEND: state_send();
		endcase
	end
endmodule
