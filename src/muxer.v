module muxer #(
	parameter DATA_WIDTH = 8
) (
	input wire clk,
	input wire reset,

	input wire [DATA_WIDTH - 1:0] in_data_0,
	input wire in_data_0_available,
	output wire in_data_0_ready,

	input wire [DATA_WIDTH - 1:0] in_data_1,
	input wire in_data_1_available,
	output wire in_data_1_ready,

	input wire receiver_ready,
	output reg [DATA_WIDTH - 1:0] out_data,
	output reg out_data_available
);

`include "constant.v"

reg [1:0] current_channel = 1'd0;
assign in_data_0_ready =
	current_channel & receiver_ready & ~out_data_available;

assign in_data_1_ready =
	~current_channel & receiver_ready & ~out_data_available;

always @(posedge clk)
	if (reset) begin
		current_channel <= 1'd0;
		out_data_available <= FALSE;
	end else begin
		if (current_channel == 0) begin
			if (in_data_0_available) begin
				out_data_available <= TRUE;
				out_data <= in_data_0;
			end else begin
				out_data_available <= FALSE;
				current_channel <= 1;
			end
		end else begin
			if (in_data_1_available) begin
				out_data_available <= TRUE;
				out_data <= in_data_1;
			end else begin
				out_data_available <= FALSE;
				current_channel <= 0;
			end
		end
	end
 
endmodule