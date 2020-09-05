module utf8_decode(
	input wire clk,
	input wire reset,

	input wire [7:0] current_byte,
	input wire ie,

	output reg [20:0] unicode,
	output reg oe
);

// https://fr.wikipedia.org/wiki/UTF-8
localparam
	TRUE = 'd1,
	FALSE = 'd0;

localparam
	STATE_FIRST_BYTE = 'd0,
	STATE_TWO_BYTES = 'd1,
	STATE_THREE_BYTES_SECOND = 'd2,
	STATE_THREE_BYTES_THIRD = 'd3,
	STATE_FOUR_BYTES_SECOND = 'd4,
	STATE_FOUR_BYTES_THIRD = 'd5,
	STATE_FOUR_BYTES_FOURTH = 'd6;

reg [7:0] first_byte;
reg [7:0] second_byte;
reg [7:0] third_byte;
reg [2:0] state;

task state_first_byte;
	begin
		first_byte <= current_byte;
		oe <= current_byte[7] == 1'b0;

		if (current_byte[7] == 1'b0) begin
			// 1-byte UTF-8 sequence
			unicode <= { 13'b0, current_byte };
			state <= STATE_FIRST_BYTE;
		end else if (current_byte[7:5] == 3'b110)
			// 2-byte UTF-8 sequence
			state <= STATE_TWO_BYTES;
		else if (current_byte[7:4] == 4'b1110)
			// 3-byte UTF-8 sequence
			state <= STATE_THREE_BYTES_SECOND;
		else if (current_byte[7:3] == 'b11110) begin
			// 4-byte UTF-8 sequence
			if (current_byte[2:0] > 3'b100)
				// Not a valid 4-byte starting value
				state <= STATE_FIRST_BYTE;
			else
				state <= STATE_FOUR_BYTES_SECOND;
		end else
			// Invalid UTF-8 codes are ignored
			state <= STATE_FIRST_BYTE;
	end
endtask

task state_two_bytes;
	if (current_byte[7:6] == 2'b10) begin
		oe <= TRUE;
		unicode <= { 1'b1, first_byte[4:0], current_byte[4:0] };
		state <= STATE_FIRST_BYTE;
	end else
		state_first_byte();
endtask

task state_three_bytes_second;
	if (current_byte[7:6] == 2'b10 && (
		(first_byte[3:0] == 4'b0000 && current_byte[7] == 1'b1) ||
		(first_byte[3:0] == 4'b1101 && current_byte[7] == 1'b0) ||
		(first_byte[3:0] != 4'b0000 && first_byte[3:0] != 4'b1101)
	)) begin
		oe <= FALSE;
		second_byte <= current_byte;
		state <= STATE_THREE_BYTES_THIRD;
	end else
		state_first_byte();
endtask

task state_three_bytes_third;
	if (current_byte[7:6] == 2'b10) begin
		oe <= TRUE;
		unicode <=
			{ 2'b11, first_byte[3:0], second_byte[5:0], current_byte[5:0] };
		state <= STATE_FIRST_BYTE;
	end else
		state_first_byte();
endtask

task state_four_bytes_second;
	if (current_byte[7:6] == 2'b10 && (
		(first_byte[2:0] == 3'b000 && current_byte[5:4] == 2'b01) ||
		(first_byte[2:0] == 3'b000 && current_byte[5] == 1'b1) ||
		(first_byte[2:0] == 3'b100 && current_byte[5:4] == 2'b00) ||
		first_byte[2:0] == 3'b001 ||
		first_byte[2:0] == 3'b010 ||
		first_byte[2:0] == 3'b011
	)) begin
		oe <= FALSE;
		second_byte <= current_byte;
		state <= STATE_THREE_BYTES_THIRD;
	end else
		state_first_byte();
endtask

task state_four_bytes_third;
	if (current_byte[7:6] == 'b10) begin
		oe <= FALSE;
		third_byte <= current_byte;
		state <= STATE_FIRST_BYTE;
	end else
		state_first_byte();
endtask

task state_four_bytes_fourth;
	if (current_byte[7:6] == 'b10) begin
		oe <= TRUE;
		unicode <= {
			3'b1, first_byte[2:0], second_byte[5:0],
			third_byte[5:0], current_byte[5:0]
		};
		state <= STATE_FIRST_BYTE;
	end else
		state_first_byte();
endtask

always @(posedge clk)
	if (reset) begin
		first_byte <= 8'd0;
		second_byte <= 8'd0;
		third_byte <= 8'd0;
		unicode <= 21'd0;
		oe <= FALSE;
		state <= STATE_FIRST_BYTE;
	end else if (ie == TRUE)
		case (state)
			STATE_FIRST_BYTE: state_first_byte();
			STATE_TWO_BYTES: state_two_bytes();
			STATE_THREE_BYTES_SECOND: state_three_bytes_second();
			STATE_THREE_BYTES_THIRD: state_three_bytes_third();
			STATE_FOUR_BYTES_SECOND: state_four_bytes_second();
			STATE_FOUR_BYTES_THIRD: state_four_bytes_third();
			STATE_FOUR_BYTES_FOURTH: state_four_bytes_fourth();
			default: state_first_byte();
		endcase
	else
		oe <= FALSE;
endmodule