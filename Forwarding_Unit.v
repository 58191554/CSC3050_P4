module Forwarding_Unit (
    input CLK,
    input [4:0]     rs_exe,
    input [4:0]     rt_exe,
    input [31:0]    alu_result_M,
    input [4:0]     WriteReg_M,
    input [31:0]    Result_W_2,
    input [4:0]     WriteReg_W,

    input           RegWrite_M,
    input           RegWrite_W,

    output reg [1:0] Forward_A,
    output reg [1:0] Forward_B);

    initial begin
        Forward_A = 0;
        Forward_B = 0;
    end

    always@(negedge CLK) begin

    // EX Hazard    get data from the previous alu_result_M
        if(RegWrite_M & (WriteReg_M != 0) & (WriteReg_M == rs_exe)) begin
            Forward_A = 2'b10;
            $display("发生旁路Forward_A = 2'b10;");
        end
        else if(
            RegWrite_W  
            &   WriteReg_M != 0
            &   !(RegWrite_M    &   (WriteReg_M != 0) &   (WriteReg_M != rs_exe)) 
            &   (WriteReg_W == rs_exe)
        )begin
            Forward_A = 2'b01;
            $display("发生旁路Forward_A = 2'b01;");
        end
        else begin
            Forward_A = 2'b00;
        end


        if(RegWrite_M & (WriteReg_M != 0) & (WriteReg_M == rt_exe)) begin
            Forward_B = 2'b10;
            $display("发生旁路Forward_B = 2'b10;");
        end
        else if(
            RegWrite_W 
            &   WriteReg_M != 0 
            &   (WriteReg_W == rt_exe)
        ) begin
            Forward_B = 2'b01;
            $display("发生旁路Forward_B = 2'b01;");
        end   
        else begin
            Forward_B = 2'b00;
        end


    // MEM Hazard   1


        #6;
        $display("rs_exe = [%d]", rs_exe);
        $display("rt_exe = [%d]", rt_exe);
        $display("alu_result_M  =[%d]", alu_result_M   );
        $display("WriteReg_M        =[%d]", WriteReg_M         );
        $display("Result_W_2    =[%d]", Result_W_2 );
        $display("WriteReg_W          =[%d]", WriteReg_W       );
        $display("RegWrite_M        -> ", RegWrite_M);
        $display("RegWrite_W        -> ", RegWrite_W);

    end
    
endmodule