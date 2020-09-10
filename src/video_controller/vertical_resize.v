function [4:0] vertical_resize;
	input double_size;
	input double_part;
	input [4:0] row;
	case ({ double_part, double_size })
		{ PART_FIRST, SIZE_NORMAL },
		{ PART_LAST, SIZE_NORMAL }:	vertical_resize = row;

		{ PART_FIRST, SIZE_DOUBLE }: vertical_resize = { 1'b0, row[4:1] };

		{ PART_LAST, SIZE_DOUBLE }:
			vertical_resize = { 1'b0, row[4:1] } + (CHAR_HEIGHT / 2);
	endcase
endfunction
