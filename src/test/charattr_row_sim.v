module charattr_row ( 
	input wire clka,
	input wire [6:0] addra,
	input wire [31:0] dia,
	input wire cea,

	input wire clkb,
	input wire [6:0] addrb,
	output reg [31:0] dob
);

reg [31:0] memory [127:0];

always @(posedge clka) if (cea) memory[addra] <= dia;

reg [13:0] fifo = 14'd0;
always @(posedge clkb) begin
	fifo <= { addrb, fifo[13:7] };
	dob <= memory[fifo[6:0]];
end

endmodule
