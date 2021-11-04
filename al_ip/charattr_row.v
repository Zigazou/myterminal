/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	/home/fred/Documents/dev/FPGA/myterminal-5.0.5/al_ip/charattr_row.v
 ** Date	:	2021 11 02
 ** TD version	:	5.0.38657
\************************************************************/

`timescale 1ns / 1ps

module charattr_row ( 
	dia, addra, cea, clka,
	dob, addrb, clkb, rstb
);


	parameter DATA_WIDTH_A = 32; 
	parameter ADDR_WIDTH_A = 7;
	parameter DATA_DEPTH_A = 88;
	parameter DATA_WIDTH_B = 32;
	parameter ADDR_WIDTH_B = 7;
	parameter DATA_DEPTH_B = 88;
	parameter REGMODE_A    = "NOREG";
	parameter REGMODE_B    = "OUTREG";
	parameter WRITEMODE_A  = "NORMAL";
	parameter WRITEMODE_B  = "NORMAL";

	output [DATA_WIDTH_B-1:0] dob;


	input  [DATA_WIDTH_A-1:0] dia;
	input  [ADDR_WIDTH_A-1:0] addra;
	input  [ADDR_WIDTH_B-1:0] addrb;
	input  cea;
	input  clka;
	input  clkb;
	input  rstb;




	EG_LOGIC_BRAM #( .DATA_WIDTH_A(DATA_WIDTH_A),
				.DATA_WIDTH_B(DATA_WIDTH_B),
				.ADDR_WIDTH_A(ADDR_WIDTH_A),
				.ADDR_WIDTH_B(ADDR_WIDTH_B),
				.DATA_DEPTH_A(DATA_DEPTH_A),
				.DATA_DEPTH_B(DATA_DEPTH_B),
				.MODE("PDPW"),
				.REGMODE_A(REGMODE_A),
				.REGMODE_B(REGMODE_B),
				.WRITEMODE_A(WRITEMODE_A),
				.WRITEMODE_B(WRITEMODE_B),
				.RESETMODE("SYNC"),
				.IMPLEMENT("9K"),
				.INIT_FILE("NONE"),
				.FILL_ALL("NONE"))
			inst(
				.dia(dia),
				.dib({32{1'b0}}),
				.addra(addra),
				.addrb(addrb),
				.cea(cea),
				.ceb(1'b1),
				.ocea(1'b0),
				.oceb(1'b1),
				.clka(clka),
				.clkb(clkb),
				.wea(1'b1),
				.web(1'b0),
				.bea(1'b0),
				.beb(1'b0),
				.rsta(1'b0),
				.rstb(rstb),
				.doa(),
				.dob(dob));


endmodule