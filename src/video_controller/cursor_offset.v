function [3:0] cursor_offset_x;
	input [2:0] cursor_id;
	case (cursor_id)
		CURSOR_DEFAULT: cursor_offset_x = 'd0;
		CURSOR_POINTER: cursor_offset_x = 'd4;
		CURSOR_NOT_ALLOWED: cursor_offset_x = 'd7;
		CURSOR_WAIT: cursor_offset_x = 'd11;
		CURSOR_MOVE: cursor_offset_x = 'd7;
		CURSOR_GRAB: cursor_offset_x = 'd8;
		CURSOR_CROSSHAIR: cursor_offset_x = 'd7;
		CURSOR_CELL: cursor_offset_x = 'd7;
	endcase
endfunction

function [4:0] cursor_offset_y;
	input [2:0] cursor_id;
	case (cursor_id)
		CURSOR_DEFAULT: cursor_offset_y = 'd0;
		CURSOR_POINTER: cursor_offset_y = 'd0;
		CURSOR_NOT_ALLOWED: cursor_offset_y = 'd7;
		CURSOR_WAIT: cursor_offset_y = 'd6;
		CURSOR_MOVE: cursor_offset_y = 'd8;
		CURSOR_GRAB: cursor_offset_y = 'd5;
		CURSOR_CROSSHAIR: cursor_offset_y = 'd7;
		CURSOR_CELL: cursor_offset_y = 'd7;
	endcase
endfunction
