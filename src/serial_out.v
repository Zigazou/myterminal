module serial_out #(
	parameter CLK_FREQUENCY_HZ = 50_000_000,
	parameter SERIAL_BPS = 230_400,
	parameter DATA_WIDTH = 8
) (
	input wire clk,
	input wire reset,

	input wire ie,
	input wire [DATA_WIDTH - 1:0] data,
	
	output reg tx,
	output reg sending = 0
);

// Definitions to make code easier to read and understand.
localparam
	HIGH  = 1'b1,
	LOW   = 1'b0,

	TRUE  = HIGH,
	FALSE = LOW;

localparam
	BIT_DURATION = CLK_FREQUENCY_HZ / SERIAL_BPS;

reg [$clog2(BIT_DURATION):0] counter = 'd0;
reg serial_tick = LOW;

always @(posedge clk)
	if (counter == 'd0) begin
		serial_tick <= LOW;
		counter <= counter + 'd1;
	end else if (counter == BIT_DURATION) begin
		serial_tick <= HIGH;
		counter <= 'd0;
	end else begin
		counter <= counter + 'd1;
	end

// The serial automaton converts a packet to a byte.
localparam
	FIRST_STEP = 'd0,
	LAST_STEP  = DATA_WIDTH + 2 - 1,
	END_STEP   = DATA_WIDTH + 2,
	MAX_STEP   = END_STEP + 1,

	START_BIT  = LOW,
	STOP_BIT   = HIGH;

reg [$clog2(MAX_STEP):0] serial_step = 'd0;
reg [DATA_WIDTH - 1:0] _data = 'd0;

always @(posedge clk)
	if (!sending) begin
		if (ie) begin
			sending <= TRUE;
			_data <= data;
		end
	end else
		if (serial_tick)
			case (serial_step)
				FIRST_STEP: begin
					serial_step <= serial_step + 'd1;
					tx <= START_BIT;
				end

				LAST_STEP: begin
					serial_step <= serial_step + 'd1;
					tx <= STOP_BIT;
				end

				END_STEP: begin
					serial_step <= FIRST_STEP;
					tx <= HIGH;
					sending <= FALSE;
				end

				default: begin
					serial_step <= serial_step + 'd1;
					tx <= _data[0];
					_data <= { 1'b0, _data[DATA_WIDTH - 1:1] };
				end
			endcase

endmodule
