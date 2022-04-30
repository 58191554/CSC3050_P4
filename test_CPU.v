`timescale 1ns/1ns
`include "CPU.v"

module test_cpu;

reg CLK = 0;
reg Show_EN = 0;

cpu cpu_1(CLK, Show_EN);
integer  i;
initial begin
    $dumpfile("cpu_test.vcd");
    $dumpvars(0,cpu_1);
    CLK = ~CLK; #10;
    CLK = ~CLK; #10;
    for (i = 0;i<=5000 ;i = i+1 ) begin
        if(cpu_1.instruction != 32'hffffffff) begin
            CLK = ~CLK; #10;
            CLK = ~CLK; #10;
        end
    end
    // SHOW ME THE OUTPUT
    CLK = ~CLK; #10;
    CLK = ~CLK; #10; 
    CLK = ~CLK; #10;
    CLK = ~CLK; #10; 
    CLK = ~CLK; #10;
    CLK = ~CLK; #10; 
    CLK = ~CLK; #10;
    CLK = ~CLK; #10;
    Show_EN = 1;   
    CLK = ~CLK; #10;
    CLK = ~CLK; #10; 
end

endmodule