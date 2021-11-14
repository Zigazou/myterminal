// Verilog netlist created by TD v5.0.38657
// Sun Nov 14 09:19:06 2021

`timescale 1ns / 1ps
module charattr_row  // charattr_row.v(14)
  (
  addra,
  addrb,
  cea,
  clka,
  clkb,
  dia,
  dob
  );

  input [6:0] addra;  // charattr_row.v(35)
  input [6:0] addrb;  // charattr_row.v(36)
  input cea;  // charattr_row.v(37)
  input clka;  // charattr_row.v(38)
  input clkb;  // charattr_row.v(39)
  input [31:0] dia;  // charattr_row.v(34)
  output [31:0] dob;  // charattr_row.v(31)

  parameter ADDR_WIDTH_A = 7;
  parameter ADDR_WIDTH_B = 7;
  parameter DATA_DEPTH_A = 88;
  parameter DATA_DEPTH_B = 88;
  parameter DATA_WIDTH_A = 32;
  parameter DATA_WIDTH_B = 32;
  parameter REGMODE_A = "NOREG";
  parameter REGMODE_B = "NOREG";
  parameter WRITEMODE_A = "NORMAL";
  parameter WRITEMODE_B = "NORMAL";

  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  // address_offset=0;data_offset=0;depth=88;width=18;num_section=1;width_per_section=18;section_size=32;working_depth=512;working_width=18;working_numbyte=1;mode_ecc=0;address_step=1;bytes_in_per_section=1;
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
    inst_88x32_sub_000000_000 (
    .addra({2'b00,addra,4'b1111}),
    .addrb({2'b00,addrb,4'b1111}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n49,open_n50}),
    .dia(dia[8:0]),
    .dib(dia[17:9]),
    .doa(dob[8:0]),
    .dob(dob[17:9]));
  // address_offset=0;data_offset=18;depth=88;width=14;num_section=1;width_per_section=14;section_size=32;working_depth=512;working_width=18;working_numbyte=1;mode_ecc=0;address_step=1;bytes_in_per_section=1;
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
    inst_88x32_sub_000000_018 (
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

