/* AUTOMATICALLY GENERATED VERILOG-2001 SOURCE CODE.
** GENERATED BY CLASH 1.2.0. DO NOT MODIFY.
*/
`timescale 100fs/100fs
module InstructionRAM
    ( // Inputs
      input  CLOCK // clock
    , input  RESET // reset
    , input  ENABLE
    , input [31:0] FETCH_ADDRESS

      // Outputs
    , output reg [31:0] DATA
    );
  wire signed [63:0] c$wild_app_arg;
  wire signed [63:0] c$wild_app_arg_0;
  wire [31:0] x1;
  wire signed [63:0] wild;
  wire signed [63:0] wild_0;
  wire [63:0] DATA_0;
  wire [63:0] x1_projection;

  assign c$wild_app_arg = $unsigned({{(64-32) {1'b0}},FETCH_ADDRESS});

  assign c$wild_app_arg_0 = $unsigned({{(64-32) {1'b0}},x1});

  assign DATA_0 = {64 {1'bx}};

  // blockRamFile begin
  reg [31:0] RAM [0:512-1];

  initial begin
    $readmemb("instructions8.bin",RAM);
    $display("%d : %b", 1, RAM[1]);
    $display("read instruction RAM over!");
    DATA = 0;
  end

  always @(posedge CLOCK) begin : InstructionRAM_blockRamFile
    if (1'b0 & ENABLE) begin
      RAM[(wild_0)] <= DATA_0[31:0];
    end
    if (ENABLE) begin
      DATA <= RAM[(wild)];
    end
  end
  // blockRamFile end

  assign x1_projection = {64 {1'bx}};

  assign x1 = x1_projection[63:32];

  assign wild = $signed(c$wild_app_arg);

  assign wild_0 = $signed(c$wild_app_arg_0);

endmodule


