module serial_in #(
	parameter CLK_FREQUENCY_HZ = 50_000_000,
	parameter SERIAL_BPS = 230_400,
	parameter DATA_WIDTH = 8
) (
	input wire clk,
	input wire reset,
	
	input wire rx,

	output reg [DATA_WIDTH - 1:0] data,
	output reg oe
);

// Definitions to make code easier to read and understand.
localparam
	HIGH  = 1'b1,
	LOW   = 1'b0,

	TRUE  = HIGH,
	FALSE = LOW;

// The serial automaton converts a packet to a byte.
localparam
	BIT_DURATION      = CLK_FREQUENCY_HZ / SERIAL_BPS,
	HALF_BIT_DURATION = BIT_DURATION / 2,

	WAIT_FALLING_EDGE = 'd0,
	WAIT_START_BIT    = 'd1,
	WAIT_STOP_BIT     = WAIT_START_BIT + DATA_WIDTH + 1,
	MAX_STATE         = WAIT_STOP_BIT + 1,

	START_BIT         = LOW,
	STOP_BIT          = HIGH;

reg [$clog2(BIT_DURATION):0] counter = 'd0;
reg [$clog2(MAX_STATE):0] state = 'd0;
reg [DATA_WIDTH - 1:0] _data = 'd0;

always @(posedge clk)
	case (state)
		WAIT_FALLING_EDGE: begin
			oe <= FALSE;
			_data <= 'd0;
			if (rx == LOW) begin
				state <= state + 'd1;
				counter <= 'd0;
			end
		end
			
		WAIT_START_BIT:
			if (rx == HIGH)
				state <= WAIT_FALLING_EDGE;
			else if (counter == HALF_BIT_DURATION) begin
				state <= state + 'd1;
				counter <= 'd0;
			end else
				counter <= counter + 'd1;

		WAIT_STOP_BIT:
			if (counter == BIT_DURATION) begin
				state <= WAIT_FALLING_EDGE;
				counter <= 'd0;
				if (rx == STOP_BIT) begin
					data <= _data;
					oe <= TRUE;
				end
			end else
				counter <= counter + 'd1;

		default:
			if (counter == BIT_DURATION) begin
				state <= state + 'd1;
				counter <= 'd0;
				_data <= { rx, _data[DATA_WIDTH - 1:1] };
			end else
				counter <= counter + 'd1;
	endcase
endmodule
