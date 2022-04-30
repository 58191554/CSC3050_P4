`define OP_BEQ 6'h4
`define OP_BNE 6'h5
`define OP_J 6'h2
`define OP_JAL 6'h3
`define OP_LW 6'h23

`define FCT_JR 6'h8

module Stall_Control(
    input CLK,
    input [31:0] instruction,
    output reg PC_NOPE,
    output reg CTRL_UNIT_RST,
    output reg IF_ID_Reg_Rst,
    output reg Jump_kind);

    reg [4:0]COUNT;

    initial begin
        PC_NOPE = 0;
        CTRL_UNIT_RST = 0;
        IF_ID_Reg_Rst = 0;
        COUNT = 0;
        Jump_kind = 0;
    end

    always @(negedge CLK) begin

        if((instruction[31:26] == `OP_BEQ |instruction[31:26] == `OP_BNE 
        | instruction[31:26] == `OP_J | instruction[31:26] == `OP_JAL 
        |(instruction[31:26] == 0 & instruction[5:0] == `FCT_JR)
        | instruction[31:26] == `OP_LW) 
        & (COUNT != 5)
        & (COUNT != 4)
        & (COUNT != 3)
        & (COUNT != 2)
        & (COUNT != 1))begin
            COUNT = 5;
            if(instruction[5:0] == `FCT_JR) begin
                Jump_kind = 1;
                $display("Jr instruction");
            end
            else begin
                Jump_kind = 0;
                $display("Jal or J instruction");
            end
        end
        if(COUNT == 5 | COUNT == 4 | COUNT == 3 | COUNT == 2 | COUNT == 1) begin
            $display("[COUNT = %d]", COUNT);
            PC_NOPE = 1;
            IF_ID_Reg_Rst = 1;

            if (COUNT == 2) begin
                PC_NOPE = 0;
            end

            if(COUNT == 4 | COUNT == 5)begin
                IF_ID_Reg_Rst = 0;
            end

            COUNT = COUNT - 1;

        end
        else begin
            $display("没有NOPE");
            PC_NOPE = 0;
            CTRL_UNIT_RST = 0;
            IF_ID_Reg_Rst = 0;
        end
    end

endmodule