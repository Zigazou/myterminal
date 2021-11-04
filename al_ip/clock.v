/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	/home/fred/Documents/dev/FPGA/myterminal-5.0.5/al_ip/clock.v
 ** Date	:	2021 10 20
 ** TD version	:	5.0.38657
\************************************************************/

///////////////////////////////////////////////////////////////////////////////
//	Input frequency:             24.000Mhz
//	Clock multiplication factor: 9
//	Clock division factor:       2
//	Clock information:
//		Clock name	| Frequency 	| Phase shift
//		C0        	| 108.000000MHZ	| 0  DEG     
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 fs

module clock(refclk,
		reset,
		clk0_out);

	input refclk;
	input reset;
	output clk0_out;

	wire clk0_buf;

	EG_LOGIC_BUFG bufg_feedback( .i(clk0_buf), .o(clk0_out) );

	EG_PHY_PLL #(.DPHASE_SOURCE("DISABLE"),
		.DYNCFG("DISABLE"),
		.FIN("24.000"),
		.FEEDBK_MODE("NORMAL"),
		.FEEDBK_PATH("CLKC0_EXT"),
		.STDBY_ENABLE("DISABLE"),
		.PLLRST_ENA("ENABLE"),
		.SYNC_ENABLE("DISABLE"),
		.DERIVE_PLL_CLOCKS("ENABLE"),
		.GEN_BASIC_CLOCK("DISABLE"),
		.GMC_GAIN(0),
		.ICP_CURRENT(9),
		.KVCO(2),
		.LPF_CAPACITOR(2),
		.LPF_RESISTOR(8),
		.REFCLK_DIV(2),
		.FBCLK_DIV(9),
		.CLKC0_ENABLE("ENABLE"),
		.CLKC0_DIV(9),
		.CLKC0_CPHASE(8),
		.CLKC0_FPHASE(0)	)
	pll_inst (.refclk(refclk),
		.reset(reset),
		.stdby(1'b0),
		.extlock(open),
		.load_reg(1'b0),
		.psclk(1'b0),
		.psdown(1'b0),
		.psstep(1'b0),
		.psclksel(3'b000),
		.psdone(open),
		.dclk(1'b0),
		.dcs(1'b0),
		.dwe(1'b0),
		.di(8'b00000000),
		.daddr(6'b000000),
		.do({open, open, open, open, open, open, open, open}),
		.fbclk(clk0_out),
		.clkc({open, open, open, open, clk0_buf}));

endmodule
