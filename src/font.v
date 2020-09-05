module font #(
    parameter CHAR_WIDTH = 'd16,
    parameter ROWS_PER_CHAR = 'd20,
    parameter CHARS = 'd1024,
    parameter RAM_WIDTH = 15
) (
    input wire clk,

    input wire [RAM_WIDTH - 1:0] font_address,
    output wire [CHAR_WIDTH - 1:0] char_row_bitmap
);

wire [CHAR_WIDTH - 1:0] dummy_input = 'd0;
wire dummy_write_enable = 1'b0;

font_ram font_ram (
	.doa (char_row_bitmap),
	.dia (dummy_input),
	.addra (font_address),
	.clka (clk),
	.wea (dummy_write_enable)
);

endmodule
