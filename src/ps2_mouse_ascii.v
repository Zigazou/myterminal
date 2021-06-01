module ps2_mouse_ascii (
	input wire clk,
	input wire reset, 

	input wire [1:0] mouse_control,

	input wire keyboard_shift,
	input wire keyboard_alt,
	input wire keyboard_ctrl,
	input wire keyboard_meta,

	input wire mouse_state_ready,
	input wire button_left,
	input wire button_middle,
	input wire button_right,
	input wire [6:0] x_text,
	input wire [5:0] y_text,
	input wire [10:0] x_screen,
	input wire [9:0] y_screen,

	output reg [31:0] sequence_out = 0,	
	output reg [2:0] sequence_out_count = 0
);

`include "constant.v"

wire [7:0] event_modifier = {
	HIGH,
	keyboard_meta,
	keyboard_alt,
	keyboard_ctrl,
	keyboard_shift,
	button_middle,
	button_right,
	button_left
};

wire [7:0] event_x = { HIGH, x_text };
wire [7:0] event_y = { HIGH, LOW, y_text };

task send_nothing;
	begin
		sequence_out <= 32'h00000000;
		sequence_out_count <= 'd0;
	end
endtask

task send_event;
	begin
		sequence_out <= {
			event_y,
			event_x,
			event_modifier,
			8'h1E
		};
		sequence_out_count <= 'd4;
	end
endtask

always @(posedge clk)
	if (reset)
		send_nothing();
	else if (mouse_state_ready) /* && (mouse_control != 'd0))*/
		send_event();
	else
		send_nothing();
endmodule
