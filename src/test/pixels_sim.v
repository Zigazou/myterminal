module pixels (
	input wire clka,
	input wire [63:0] dia,
	input wire [6:0] addra,
	input wire cea,

	input wire clkb,
	input wire [10:0] addrb,
	output reg [3:0] dob
);

reg wr_pixel_enable;
reg [63:0] wr_pixel_data;
reg [6:0] wr_pixel_addr;
wire [3:0] current_pixel_index;

reg [3:0] memory [2047:0];

always @(posedge clka) if (cea) begin
    memory[addra * 16 + 15] <= dia[63:60];
    memory[addra * 16 + 14] <= dia[59:56];
    memory[addra * 16 + 13] <= dia[55:52];
    memory[addra * 16 + 12] <= dia[51:48];
    memory[addra * 16 + 11] <= dia[47:44];
    memory[addra * 16 + 10] <= dia[43:40];
    memory[addra * 16 + 9] <= dia[39:36];
    memory[addra * 16 + 8] <= dia[35:32];
    memory[addra * 16 + 7] <= dia[31:28];
    memory[addra * 16 + 6] <= dia[27:24];
    memory[addra * 16 + 5] <= dia[23:20];
    memory[addra * 16 + 4] <= dia[19:16];
    memory[addra * 16 + 3] <= dia[15:12];
    memory[addra * 16 + 2] <= dia[11:8];
    memory[addra * 16 + 1] <= dia[7:4];
    memory[addra * 16 + 0] <= dia[3:0];
end

reg [21:0] fifo = 22'd0;
always @(posedge clkb) begin
	fifo <= { addrb, fifo[21:11] };
	dob <= memory[fifo[10:0]];
end

endmodule
