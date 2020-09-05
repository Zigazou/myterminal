module four_byte (
	input wire clk,
	input wire reset,

	input wire [7:0] current_byte,
	input wire ie,

	output reg [31:0] value,
	output reg oe
);

localparam
	TRUE = 'd1,
	FALSE = 'd0;

reg [2:0] count;
reg [31:0] bytes;
always @(posedge clk)
	if (reset) begin
        count <= 'd0;
        bytes <= 'd0;
		oe <= FALSE;
	end else if (ie == TRUE) begin
        if (count == 'd3) begin
            oe <= TRUE;
            value <= { bytes[23:0], current_byte };
            count <= 'd0;
        end else begin
            bytes <= { bytes[23:0], current_byte };
            oe <= FALSE;
            count <= count + 'd1;
        end
    end else
		oe <= FALSE;
endmodule