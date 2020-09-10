function [15:0] generate_pattern;
	input [3:0] pattern_id;
	input [3:0] vertical_offset;
	case (pattern_id)
		4'd1:
			if (vertical_offset[0])
				generate_pattern = 16'b01010101_01010101;
			else
				generate_pattern = 16'b10101010_10101010;
		4'd2:
			if (vertical_offset[1])
				generate_pattern = 16'b00110011_00110011;
			else
				generate_pattern = 16'b11001100_11001100;
		4'd3:
			if (vertical_offset[2])
				generate_pattern = 16'b00001111_00001111;
			else
				generate_pattern = 16'b11110000_11110000;
		4'd4:
			if (vertical_offset[3])
				generate_pattern = 16'b00000000_11111111;
			else
				generate_pattern = 16'b11111111_00000000;
		4'd5:
			case (vertical_offset[2:1])
				2'b00: generate_pattern = 16'b10001000_10001000;
				2'b01: generate_pattern = 16'b01000100_01000100;
				2'b10: generate_pattern = 16'b00100010_00100010;
				2'b11: generate_pattern = 16'b00010001_00010001;
			endcase
		4'd6:
			case (vertical_offset[2:1])
				2'b00: generate_pattern = 16'b00010001_00010001;
				2'b01: generate_pattern = 16'b00100010_00100010;
				2'b10: generate_pattern = 16'b01000100_01000100;
				2'b11: generate_pattern = 16'b10001000_10001000;
			endcase
		4'd7:
			case (vertical_offset[1:0])
				2'b00: generate_pattern = 16'b10001000_10001000;
				2'b01: generate_pattern = 16'b01000100_01000100;
				2'b10: generate_pattern = 16'b00100010_00100010;
				2'b11: generate_pattern = 16'b00010001_00010001;
			endcase
		4'd8:
			case (vertical_offset[1:0])
				2'b00: generate_pattern = 16'b00010001_00010001;
				2'b01: generate_pattern = 16'b00100010_00100010;
				2'b10: generate_pattern = 16'b01000100_01000100;
				2'b11: generate_pattern = 16'b10001000_10001000;
			endcase
		4'd9:
			case (vertical_offset[1:0])
				2'b00: generate_pattern = 16'b01000100_01000100;
				2'b01: generate_pattern = 16'b11101110_11101110;
				2'b10: generate_pattern = 16'b01000100_01000100;
				2'b11: generate_pattern = 16'b00000000_00000000;
			endcase
		4'd10:
			if (vertical_offset[0])
				generate_pattern = 16'b00000000_00000000;
			else
				generate_pattern = 16'b10101010_10101010;
		4'd11:
			case (vertical_offset[2:0])
				3'd0: generate_pattern = 16'b11110000_11110000;
				3'd1: generate_pattern = 16'b01111000_01111000;
				3'd2: generate_pattern = 16'b00111100_00111100;
				3'd3: generate_pattern = 16'b00011110_00011110;
				3'd4: generate_pattern = 16'b00001111_00001111;
				3'd5: generate_pattern = 16'b10000111_10000111;
				3'd6: generate_pattern = 16'b11000011_11000011;
				3'd7: generate_pattern = 16'b11100001_11100001;
			endcase
		4'd12:
			case (vertical_offset[2:0])
				3'd0: generate_pattern = 16'b11100001_11100001;
				3'd1: generate_pattern = 16'b11000011_11000011;
				3'd2: generate_pattern = 16'b10000111_10000111;
				3'd3: generate_pattern = 16'b00001111_00001111;
				3'd4: generate_pattern = 16'b00011110_00011110;
				3'd5: generate_pattern = 16'b00111100_00111100;
				3'd6: generate_pattern = 16'b01111000_01111000;
				3'd7: generate_pattern = 16'b11110000_11110000;
			endcase
		4'd13:
			case (vertical_offset[2:0])
				3'd0: generate_pattern = 16'b00000000_00000000;
				3'd1: generate_pattern = 16'b01111110_01111110;
				3'd2: generate_pattern = 16'b01000010_01000010;
				3'd3: generate_pattern = 16'b01000010_01000010;
				3'd4: generate_pattern = 16'b01000010_01000010;
				3'd5: generate_pattern = 16'b01000010_01000010;
				3'd6: generate_pattern = 16'b01111110_01111110;
				3'd7: generate_pattern = 16'b00000000_00000000;
			endcase
		4'd14:
			case (vertical_offset[2:0])
				3'd0: generate_pattern = 16'b10001000_10001000;
				3'd1: generate_pattern = 16'b00010000_00010000;
				3'd2: generate_pattern = 16'b00100000_00100000;
				3'd3: generate_pattern = 16'b01000010_01000000;
				3'd4: generate_pattern = 16'b10001000_10001000;
				3'd5: generate_pattern = 16'b00000100_00000100;
				3'd6: generate_pattern = 16'b00000010_00000010;
				3'd7: generate_pattern = 16'b00000001_00000001;
			endcase
		default: generate_pattern = 16'b11111111_11111111;
	endcase
endfunction
