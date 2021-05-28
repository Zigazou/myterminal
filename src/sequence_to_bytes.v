module sequence_to_bytes (
	input wire clk,
	input wire reset,

	input wire [34:0] in_sequence,
	input wire in_sequence_available,
	output reg in_sequence_ready,

	input wire receiver_ready,
	output reg [7:0] out_data,
	output reg out_data_available
);

`include "constant.v"

reg [2:0] sequence_remain = 3'd0;
reg [31:0] sequence = 32'd0;

always @(posedge clk)
    if (reset) begin
        sequence_remain <= 3'd0;
        sequence <= 32'd0;
        out_data_available <= FALSE;
        in_sequence_ready <= FALSE;
    end else if (sequence_remain == 3'd0) begin
        if (in_sequence_available) begin
            sequence <= in_sequence[31:0];
            sequence_remain <= in_sequence[34:32];
            in_sequence_ready <= FALSE;
        end else begin
            in_sequence_ready <= TRUE;
            out_data_available <= FALSE;
        end
    end else if (~out_data_available & receiver_ready) begin
        case (sequence_remain)
            3'd4: out_data <= sequence[31:24];
            3'd3: out_data <= sequence[23:16];
            3'd2: out_data <= sequence[15:8];
            3'd1: out_data <= sequence[7:0];
            default:
                out_data <= 8'd0;
        endcase

        sequence_remain <= sequence_remain - 3'd1;
        out_data_available <= TRUE;
    end else
        out_data_available <= FALSE;
endmodule
