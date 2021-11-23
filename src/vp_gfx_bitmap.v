module vp_gfx_bitmap (
	// Base signals
	input wire clk,

	// Inputs
	input wire [3:0] foreground,
	input wire [3:0] background,
	input wire [19:0] gfx_bits,
	input wire [4:0] char_row,
	input wire mosaic,
	input wire enabled,

	// Outputs
	output reg [3:0] gfx_foreground,
	output reg [3:0] gfx_background,
	output reg [15:0] gfx_bitmap,
	output reg enable
);

`include "constant.v"

always @(posedge clk) begin
	enable <= enabled;
	gfx_foreground <= foreground;
	gfx_background <= background;
	if (mosaic) begin
		case (char_row)
			'd01, 'd02: gfx_bitmap <= {
				1'b0, gfx_bits[19], gfx_bits[19], 1'b0,
				1'b0, gfx_bits[18], gfx_bits[18], 1'b0,
				1'b0, gfx_bits[17], gfx_bits[17], 1'b0,
				1'b0, gfx_bits[16], gfx_bits[16], 1'b0
			};

			'd05, 'd06: gfx_bitmap <= {
				1'b0, gfx_bits[15], gfx_bits[15], 1'b0,
				1'b0, gfx_bits[14], gfx_bits[14], 1'b0,
				1'b0, gfx_bits[13], gfx_bits[13], 1'b0,
				1'b0, gfx_bits[12], gfx_bits[12], 1'b0
			};

			'd09, 'd10: gfx_bitmap <= {
				1'b0, gfx_bits[11], gfx_bits[11], 1'b0,
				1'b0, gfx_bits[10], gfx_bits[10], 1'b0,
				1'b0, gfx_bits[ 9], gfx_bits[ 9], 1'b0,
				1'b0, gfx_bits[ 8], gfx_bits[ 8], 1'b0
			};

			'd13, 'd14: gfx_bitmap <= {
				1'b0, gfx_bits[ 7], gfx_bits[ 7], 1'b0,
				1'b0, gfx_bits[ 6], gfx_bits[ 6], 1'b0,
				1'b0, gfx_bits[ 5], gfx_bits[ 5], 1'b0,
				1'b0, gfx_bits[ 4], gfx_bits[ 4], 1'b0
			};

			'd00, 'd04, 'd08, 'd12, 'd16, 'd03, 'd07, 'd11, 'd15, 'd19:
				gfx_bitmap <= 16'b0;

			default: gfx_bitmap <= {
				1'b0, gfx_bits[ 3], gfx_bits[ 3], 1'b0,
				1'b0, gfx_bits[ 2], gfx_bits[ 2], 1'b0,
				1'b0, gfx_bits[ 1], gfx_bits[ 1], 1'b0,
				1'b0, gfx_bits[ 0], gfx_bits[ 0], 1'b0
			};
		endcase
	end else begin
		case (char_row)
			'd00, 'd01, 'd02, 'd03: gfx_bitmap <= {
				gfx_bits[19], gfx_bits[19], gfx_bits[19], gfx_bits[19],
				gfx_bits[18], gfx_bits[18], gfx_bits[18], gfx_bits[18],
				gfx_bits[17], gfx_bits[17], gfx_bits[17], gfx_bits[17],
				gfx_bits[16], gfx_bits[16], gfx_bits[16], gfx_bits[16]
			};

			'd04, 'd05, 'd06, 'd07: gfx_bitmap <= {
				gfx_bits[15], gfx_bits[15], gfx_bits[15], gfx_bits[15],
				gfx_bits[14], gfx_bits[14], gfx_bits[14], gfx_bits[14],
				gfx_bits[13], gfx_bits[13], gfx_bits[13], gfx_bits[13],
				gfx_bits[12], gfx_bits[12], gfx_bits[12], gfx_bits[12]
			};

			'd08, 'd09, 'd10, 'd11: gfx_bitmap <= {
				gfx_bits[11], gfx_bits[11], gfx_bits[11], gfx_bits[11],
				gfx_bits[10], gfx_bits[10], gfx_bits[10], gfx_bits[10],
				gfx_bits[ 9], gfx_bits[ 9], gfx_bits[ 9], gfx_bits[ 9],
				gfx_bits[ 8], gfx_bits[ 8], gfx_bits[ 8], gfx_bits[ 8]
			};

			'd12, 'd13, 'd14, 'd15: gfx_bitmap <= {
				gfx_bits[ 7], gfx_bits[ 7], gfx_bits[ 7], gfx_bits[ 7],
				gfx_bits[ 6], gfx_bits[ 6], gfx_bits[ 6], gfx_bits[ 6],
				gfx_bits[ 5], gfx_bits[ 5], gfx_bits[ 5], gfx_bits[ 5],
				gfx_bits[ 4], gfx_bits[ 4], gfx_bits[ 4], gfx_bits[ 4]
			};

			default: gfx_bitmap <= {
				gfx_bits[ 3], gfx_bits[ 3], gfx_bits[ 3], gfx_bits[ 3],
				gfx_bits[ 2], gfx_bits[ 2], gfx_bits[ 2], gfx_bits[ 2],
				gfx_bits[ 1], gfx_bits[ 1], gfx_bits[ 1], gfx_bits[ 1],
				gfx_bits[ 0], gfx_bits[ 0], gfx_bits[ 0], gfx_bits[ 0]
			};
		endcase
	end
end
endmodule