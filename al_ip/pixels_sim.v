// Verilog netlist created by TD v4.6.14314
// Thu Sep  3 20:43:28 2020

`timescale 1ns / 1ps
module pixels  // al_ip/pixels.v(14)
  (
  addra,
  addrb,
  cea,
  clka,
  clkb,
  dia,
  dob
  );

  input [6:0] addra;  // al_ip/pixels.v(23)
  input [10:0] addrb;  // al_ip/pixels.v(24)
  input cea;  // al_ip/pixels.v(25)
  input clka;  // al_ip/pixels.v(26)
  input clkb;  // al_ip/pixels.v(27)
  input [63:0] dia;  // al_ip/pixels.v(22)
  output [3:0] dob;  // al_ip/pixels.v(19)


  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  // address_offset=0;data_offset=0;depth=80;width=16;num_section=16;width_per_section=1;section_size=4;working_depth=512;working_width=16;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEAMUX("1"),
    .CEBMUX("1"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("SIG"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("18"),
    .DATA_WIDTH_B("1"),
    .MODE("PDPW8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTAMUX("0"),
    .RSTBMUX("0"),
    .WEAMUX("1"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_80x64_sub_000000_000 (
    .addra({2'b00,addra,4'b1111}),
    .addrb({2'b00,addrb}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n49,open_n50}),
    .dia({open_n54,dia[28],dia[24],dia[20],dia[16],dia[12],dia[8],dia[4],dia[0]}),
    .dib({open_n55,dia[60],dia[56],dia[52],dia[48],dia[44],dia[40],dia[36],dia[32]}),
    .dob({open_n71,open_n72,open_n73,open_n74,open_n75,open_n76,open_n77,open_n78,dob[0]}));
  // address_offset=0;data_offset=1;depth=80;width=16;num_section=16;width_per_section=1;section_size=4;working_depth=512;working_width=16;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEAMUX("1"),
    .CEBMUX("1"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("SIG"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("18"),
    .DATA_WIDTH_B("1"),
    .MODE("PDPW8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTAMUX("0"),
    .RSTBMUX("0"),
    .WEAMUX("1"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_80x64_sub_000000_001 (
    .addra({2'b00,addra,4'b1111}),
    .addrb({2'b00,addrb}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n81,open_n82}),
    .dia({open_n86,dia[29],dia[25],dia[21],dia[17],dia[13],dia[9],dia[5],dia[1]}),
    .dib({open_n87,dia[61],dia[57],dia[53],dia[49],dia[45],dia[41],dia[37],dia[33]}),
    .dob({open_n103,open_n104,open_n105,open_n106,open_n107,open_n108,open_n109,open_n110,dob[1]}));
  // address_offset=0;data_offset=2;depth=80;width=16;num_section=16;width_per_section=1;section_size=4;working_depth=512;working_width=16;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEAMUX("1"),
    .CEBMUX("1"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("SIG"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("18"),
    .DATA_WIDTH_B("1"),
    .MODE("PDPW8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTAMUX("0"),
    .RSTBMUX("0"),
    .WEAMUX("1"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_80x64_sub_000000_002 (
    .addra({2'b00,addra,4'b1111}),
    .addrb({2'b00,addrb}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n113,open_n114}),
    .dia({open_n118,dia[30],dia[26],dia[22],dia[18],dia[14],dia[10],dia[6],dia[2]}),
    .dib({open_n119,dia[62],dia[58],dia[54],dia[50],dia[46],dia[42],dia[38],dia[34]}),
    .dob({open_n135,open_n136,open_n137,open_n138,open_n139,open_n140,open_n141,open_n142,dob[2]}));
  // address_offset=0;data_offset=3;depth=80;width=16;num_section=16;width_per_section=1;section_size=4;working_depth=512;working_width=16;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEAMUX("1"),
    .CEBMUX("1"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("SIG"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("18"),
    .DATA_WIDTH_B("1"),
    .MODE("PDPW8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTAMUX("0"),
    .RSTBMUX("0"),
    .WEAMUX("1"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_80x64_sub_000000_003 (
    .addra({2'b00,addra,4'b1111}),
    .addrb({2'b00,addrb}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n145,open_n146}),
    .dia({open_n150,dia[31],dia[27],dia[23],dia[19],dia[15],dia[11],dia[7],dia[3]}),
    .dib({open_n151,dia[63],dia[59],dia[55],dia[51],dia[47],dia[43],dia[39],dia[35]}),
    .dob({open_n167,open_n168,open_n169,open_n170,open_n171,open_n172,open_n173,open_n174,dob[3]}));

endmodule 

