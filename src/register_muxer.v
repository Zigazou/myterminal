module register_muxer (
    input wire clk,
    input wire reset,

    input wire [3:0] register_index_0,
    input wire [3:0] register_index_1,

    input wire [22:0] register_value_0,
    input wire [22:0] register_value_1,

    output reg [3:0] register_index,
    output reg [22:0] register_value
);

reg switch = 1'b0;

always @(posedge clk)
    if (reset) begin
        switch <= 1'b0;
        register_index <= 'd0;
        register_value <= 'd0;
    end else if (switch == 1'b0) begin
        switch <= 1'b1;
        register_index <= register_index_0;
        register_value <= register_value_0;
    end else begin
        switch <= 1'b0;
        register_index <= register_index_1;
        register_value <= register_value_1;
    end

endmodule
