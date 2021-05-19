module dual_serializer #(
	parameter FIFO_SIZE = 32
) (
	input wire clk,
	input wire reset,

	input wire [31:0] in_data_0,
	input wire [2:0] in_data_count_0,

	input wire [31:0] in_data_1,
	input wire [2:0] in_data_count_1,

	input wire receiver_ready,
	output reg [7:0] out_data,
	output reg out_data_available
);

`include "constant.v"

localparam
	INDEX_SIZE = $clog2(FIFO_SIZE);

wire in_data_available_0 = in_data_count_0 != 'd0;
wire in_data_available_1 = in_data_count_1 != 'd0;

reg [31:0] fifo_0 [0:FIFO_SIZE - 1];
reg [2:0] fifo_count_0 [0:FIFO_SIZE - 1];
reg [31:0] fifo_1 [0:FIFO_SIZE - 1];
reg [2:0] fifo_count_1 [0:FIFO_SIZE - 1];
reg [INDEX_SIZE - 1:0] fifo_in_index;
reg [INDEX_SIZE - 1:0] fifo_out_index;

// Data coming in
always @(posedge clk)
	if (reset)
		fifo_in_index <= 'd0;
	else case ({ in_data_available_1, in_data_available_0 })
		2'b01: begin
			fifo_0[fifo_in_index] <= in_data_0;
			fifo_count_0[fifo_in_index] <= in_data_count_0;
			fifo_1[fifo_in_index] <= 32'h00000000;
			fifo_count_1[fifo_in_index] <= 8'h00;
			fifo_in_index <= fifo_in_index + 'd1;
		end

		2'b10: begin
			fifo_0[fifo_in_index] <= 32'h00000000;
			fifo_count_0[fifo_in_index] <= 8'h00;
			fifo_1[fifo_in_index] <= in_data_1;
			fifo_count_1[fifo_in_index] <= in_data_count_1;
			fifo_in_index <= fifo_in_index + 'd1;
		end

		2'b11: begin
			fifo_0[fifo_in_index] <= in_data_0;
			fifo_count_0[fifo_in_index] <= in_data_count_0;
			fifo_1[fifo_in_index] <= in_data_1;
			fifo_count_1[fifo_in_index] <= in_data_count_1;
			fifo_in_index <= fifo_in_index + 'd1;
		end
	endcase

localparam
	SEND_IDLE   = 'd0,
	SEND_BYTE_0 = 'd1,
	SEND_BYTE_1 = 'd2,
	SEND_BYTE_2 = 'd3,
	SEND_BYTE_3 = 'd4,
	SEND_BYTE_4 = 'd5,
	SEND_BYTE_5 = 'd6,
	SEND_BYTE_6 = 'd7,
	SEND_BYTE_7 = 'd8;

reg [3:0] state = SEND_IDLE;
task send_bytes;
	begin
		out_data_available <= FALSE;
		case (state)
			SEND_IDLE: begin
				if (fifo_count_0[fifo_out_index] > 'd0)
			end

		endcase
	end
endtask

// Data going out
always @(posedge clk)
	if (reset) begin
		fifo_out_index <= 'd0;
		out_data_available <= FALSE;
		out_data <= 'd0;
	end else if (out_data_available)
		out_data_available <= FALSE;
	else if (receiver_ready && fifo_in_index != fifo_out_index) begin
		send_bytes();
		out_data <= fifo[fifo_out_index];
		out_data_available <= TRUE;
		fifo_out_index <= fifo_out_index + 'd1;
	end else
		out_data_available <= FALSE;

endmodule