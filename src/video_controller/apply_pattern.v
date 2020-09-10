localparam
	LOGICAL_AND = 2'b00,
	LOGICAL_OR = 2'b01,
	LOGICAL_XOR = 2'b10,
	LOGICAL_NONE = 2'b11;

function [15:0] apply_pattern;
	input [1:0] logical_operator;
	input [15:0] value;
	input [15:0] pattern;
	case (logical_operator)
		LOGICAL_AND: apply_pattern = value & pattern;
		LOGICAL_OR: apply_pattern = value | pattern;
		LOGICAL_XOR: apply_pattern = value ^ pattern;
		LOGICAL_NONE: apply_pattern = value;
	endcase
endfunction
