// Verilog netlist created by TD v4.6.14314
// Thu Sep  3 19:52:24 2020

`timescale 1ns / 1ps
module charattr_row  // al_ip/charattr_row.v(14)
  (
  addra,
  addrb,
  cea,
  clka,
  clkb,
  dia,
  dob
  );

  input [6:0] addra;  // al_ip/charattr_row.v(23)
  input [6:0] addrb;  // al_ip/charattr_row.v(24)
  input cea;  // al_ip/charattr_row.v(25)
  input clka;  // al_ip/charattr_row.v(26)
  input clkb;  // al_ip/charattr_row.v(27)
  input [31:0] dia;  // al_ip/charattr_row.v(22)
  output [31:0] dob;  // al_ip/charattr_row.v(19)


  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  // address_offset=0;data_offset=0;depth=80;width=18;num_section=1;width_per_section=18;section_size=32;working_depth=512;working_width=18;address_step=1;bytes_in_per_section=1;
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
    .DATA_WIDTH_B("18"),
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
    inst_80x32_sub_000000_000 (
    .addra({2'b00,addra,4'b1111}),
    .addrb({2'b00,addrb,4'b1111}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n49,open_n50}),
    .dia(dia[8:0]),
    .dib(dia[17:9]),
    .doa(dob[8:0]),
    .dob(dob[17:9]));
  // address_offset=0;data_offset=18;depth=80;width=14;num_section=1;width_per_section=14;section_size=32;working_depth=512;working_width=18;address_step=1;bytes_in_per_section=1;
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
    .DATA_WIDTH_B("18"),
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
    inst_80x32_sub_000000_018 (
    .addra({2'b00,addra,4'b1111}),
    .addrb({2'b00,addrb,4'b1111}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n62,open_n63}),
    .dia(dia[26:18]),
    .dib({open_n67,open_n68,open_n69,open_n70,dia[31:27]}),
    .doa(dob[26:18]),
    .dob({open_n77,open_n78,open_n79,open_n80,dob[31:27]}));

endmodule 

