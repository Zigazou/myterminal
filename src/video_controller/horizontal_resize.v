localparam
	SIZE_NORMAL = 1'b0,
	SIZE_DOUBLE = 1'b1,
	PART_FIRST = 1'b0,
	PART_LAST = 1'b1;

function [15:0] horizontal_resize;
	input double_size;
	input double_part;
	input [15:0] pixels;
	case ({ double_part, double_size })
		{ PART_FIRST, SIZE_NORMAL }, { PART_LAST, SIZE_NORMAL }:
			horizontal_resize = pixels;

		{ PART_FIRST, SIZE_DOUBLE }:
			horizontal_resize = {
				pixels[15], pixels[15],
				pixels[14], pixels[14],
				pixels[13], pixels[13],
				pixels[12], pixels[12],
				pixels[11], pixels[11],
				pixels[10], pixels[10],
				pixels[9], pixels[9],
				pixels[8], pixels[8]
			};

		{ PART_LAST, SIZE_DOUBLE }:
			horizontal_resize = {
				pixels[7], pixels[7],
				pixels[6], pixels[6],
				pixels[5], pixels[5],
				pixels[4], pixels[4],
				pixels[3], pixels[3],
				pixels[2], pixels[2],
				pixels[1], pixels[1],
				pixels[0], pixels[0]
			};
	endcase
endfunction
