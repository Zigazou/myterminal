`timescale 1 ns / 100 ps
`include "vp_pipeline.v"
`include "../font/font_sim.v"
module vp_pipeline_tb ();
`include "constant.v"

reg clk;
reg reset;

reg [31:0] charattr;
reg [4:0]  char_row_in;
reg [3:0]  ypos;
reg        enabled;

wire [14:0] font_address;
wire [15:0] char_row_bitmap;

wire [63:0] pixels;
wire enable;

vp_pipeline vp_pipeline (
	// Base signals
	.clk (clk),
	.reset (reset),

	// Inputs
	.charattr (charattr),
	.char_row_in (char_row_in),
	.ypos (ypos),
	.enabled (enabled),

	// Intermediate inputs/outputs
	.txt_font_address (font_address),
	.txt_char_row_bitmap (char_row_bitmap),

	// Outputs
	.pixels (pixels),
	.enable (enable)
);

font font (
	.clk (clk),

	.font_address (font_address),
	.char_row_bitmap (char_row_bitmap)
);

always #10 clk <= ~clk;

reg [15:0] ticks = 'd0;
always @(posedge clk) ticks <= ticks + 'd1;

always @(posedge clk)
	case (ticks)
		'd1: begin
			charattr <= {
				4'd00,    // Background
				4'd15,    // Foreground
				4'b1111,  // Pattern/border
				2'd11,    // Function = BORDER
				FALSE,    // Underline
				FALSE,    // Invert
				2'd00,    // Blink
				2'd00,    // Part
				2'b01,    // Size
				10'h040   // Character '@'
			};
			char_row_in <= 'd00;
			ypos <= 'd00;
			enabled <= TRUE;
		end

		'd02: begin char_row_in <= 'd01; ypos <= 'd01; enabled <= TRUE; end
		'd03: begin char_row_in <= 'd02; ypos <= 'd02; enabled <= TRUE; end
		'd04: begin char_row_in <= 'd03; ypos <= 'd03; enabled <= TRUE; end
		'd05: begin char_row_in <= 'd04; ypos <= 'd04; enabled <= TRUE; end
		'd06: begin char_row_in <= 'd05; ypos <= 'd05; enabled <= TRUE; end
		'd07: begin char_row_in <= 'd06; ypos <= 'd06; enabled <= TRUE; end
		'd08: begin char_row_in <= 'd07; ypos <= 'd07; enabled <= TRUE; end
		'd09: begin char_row_in <= 'd08; ypos <= 'd08; enabled <= TRUE; end
		'd10: begin char_row_in <= 'd09; ypos <= 'd09; enabled <= TRUE; end
		'd11: begin char_row_in <= 'd10; ypos <= 'd10; enabled <= TRUE; end
		'd12: begin char_row_in <= 'd11; ypos <= 'd11; enabled <= TRUE; end
		'd13: begin char_row_in <= 'd12; ypos <= 'd12; enabled <= TRUE; end
		'd14: begin char_row_in <= 'd13; ypos <= 'd13; enabled <= TRUE; end
		'd15: begin char_row_in <= 'd14; ypos <= 'd14; enabled <= TRUE; end
		'd16: begin char_row_in <= 'd15; ypos <= 'd15; enabled <= TRUE; end
		'd17: begin char_row_in <= 'd16; ypos <= 'd16; enabled <= TRUE; end
		'd18: begin char_row_in <= 'd17; ypos <= 'd17; enabled <= TRUE; end
		'd19: begin char_row_in <= 'd18; ypos <= 'd18; enabled <= TRUE; end
		'd20: begin char_row_in <= 'd19; ypos <= 'd19; enabled <= TRUE; end

		'd31: begin
			charattr <= {
				4'b00,   // Background
				4'd15,   // Foreground
				4'b1010, // First 10 bits
				4'b0101,
				2'b11__, 
				2'b01,   // Part
				2'd00,   // Size
				2'b11,   // Last 10 bits
				4'b1001,
				4'b0110
			};
			char_row_in <= 'd00;
			ypos <= 'd00;
			enabled <= TRUE;
		end

		'd32: begin char_row_in <= 'd01; ypos <= 'd01; enabled <= TRUE; end
		'd33: begin char_row_in <= 'd02; ypos <= 'd02; enabled <= TRUE; end
		'd34: begin char_row_in <= 'd03; ypos <= 'd03; enabled <= TRUE; end
		'd35: begin char_row_in <= 'd04; ypos <= 'd04; enabled <= TRUE; end
		'd36: begin char_row_in <= 'd05; ypos <= 'd05; enabled <= TRUE; end
		'd37: begin char_row_in <= 'd06; ypos <= 'd06; enabled <= TRUE; end
		'd38: begin char_row_in <= 'd07; ypos <= 'd07; enabled <= TRUE; end
		'd39: begin char_row_in <= 'd08; ypos <= 'd08; enabled <= TRUE; end
		'd40: begin char_row_in <= 'd09; ypos <= 'd09; enabled <= TRUE; end
		'd41: begin char_row_in <= 'd10; ypos <= 'd10; enabled <= TRUE; end
		'd42: begin char_row_in <= 'd11; ypos <= 'd11; enabled <= TRUE; end
		'd43: begin char_row_in <= 'd12; ypos <= 'd12; enabled <= TRUE; end
		'd44: begin char_row_in <= 'd13; ypos <= 'd13; enabled <= TRUE; end
		'd45: begin char_row_in <= 'd14; ypos <= 'd14; enabled <= TRUE; end
		'd46: begin char_row_in <= 'd15; ypos <= 'd15; enabled <= TRUE; end
		'd47: begin char_row_in <= 'd16; ypos <= 'd16; enabled <= TRUE; end
		'd48: begin char_row_in <= 'd17; ypos <= 'd17; enabled <= TRUE; end
		'd49: begin char_row_in <= 'd18; ypos <= 'd18; enabled <= TRUE; end
		'd50: begin char_row_in <= 'd19; ypos <= 'd19; enabled <= TRUE; end

		'd64: $finish;

		default:
			enabled <= FALSE;
	endcase

always @(posedge clk)
	if (enable) begin
		$display($time, " ticks=%d, pixels=%b", ticks, pixels);
	end else begin
		$display($time, " ticks=%d", ticks);
	end

initial begin
	clk <= 1'b0;
	reset <= TRUE;

	#10	reset <= FALSE;
end

endmodule