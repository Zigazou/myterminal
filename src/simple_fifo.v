module simple_fifo #(
	parameter DATA_WIDTH = 21
) (
	input wire clk,
	input wire reset,

	input wire [DATA_WIDTH - 1:0] in_data,
	input wire in_data_available,

	input wire receiver_ready,
	output reg out_data_available,
	output reg [DATA_WIDTH - 1:0] out_data
);

`include "constant.v"

reg [DATA_WIDTH - 1:0] fifo [0:15];
reg [3:0] fifo_in_index;
reg [3:0] fifo_out_index;

// Data coming in
always @(posedge clk)
	if (reset)
		fifo_in_index <= 'd0;
	else if (in_data_available) begin
		fifo[fifo_in_index] <= in_data;
		fifo_in_index <= fifo_in_index + 'd1;
	end

// Data going out
always @(posedge clk)
	if (reset) begin
		fifo_out_index <= 'd0;
		out_data_available <= FALSE;
		out_data <= 'd0;
	end else if (out_data_available)
		out_data_available <= FALSE;
	else if (receiver_ready && fifo_in_index != fifo_out_index) begin
		out_data <= fifo[fifo_out_index];
		out_data_available <= TRUE;
		fifo_out_index <= fifo_out_index + 'd1;
	end else
		out_data_available <= FALSE;

endmodule
