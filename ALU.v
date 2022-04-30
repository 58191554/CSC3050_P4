// Definition Declaration
    `define ALU_OP_ADD  4'b0000
    `define ALU_OP_SUB  4'b0001
    `define ALU_OP_SRL  4'b0010
    `define ALU_OP_OR   4'b0011
    `define ALU_OP_AND  4'b0100
    `define ALU_OP_NOR  4'b0101
    `define ALU_OP_SLT  4'b0110
    `define ALU_OP_XOR  4'b0111
    `define ALU_OP_SLL  4'b1000 
    `define ALU_OP_SRA  4'b1001

    `define OP_BNE 6'h5 


module alu(reg_A, reg_B, alu_op, opcode_E, result, zero, sign);

input [31:0] reg_A;
input [31:0] reg_B;
input [3:0] alu_op;
input [5:0] opcode_E;

output reg [31:0] result;
output reg zero;
output reg sign;

initial begin
    result = 0;
    zero = 0;
    sign = 0;
end

always @(reg_A, reg_B, alu_op)
begin

    case (alu_op)
        `ALU_OP_ADD: result = (reg_A + reg_B);
        `ALU_OP_SUB: result = (reg_A - reg_B);
        `ALU_OP_SRL: result = (reg_B >> reg_A);
        `ALU_OP_OR:  result = (reg_A | reg_B);
        `ALU_OP_AND: result = (reg_A & reg_B);
        `ALU_OP_NOR: result = ~(reg_A | reg_B);
        `ALU_OP_SLT: result = (((reg_A < reg_B) && (reg_A[31] == reg_B[31])) || 
        ((reg_A[31] && !reg_B[31]))) ? 1 : 0;
        `ALU_OP_XOR: result = (reg_A ^ reg_B);
        `ALU_OP_SLL: result = (reg_B << reg_A);
        `ALU_OP_SRA: result = ($signed(reg_B)) >>> reg_A;
    endcase
    // $display("result =", result, "reg_A =", reg_A , "ALUOp = ", alu_op, "reg_B = ",reg_B);
    zero = (result == 0) ? 1 : 0;
    sign = result[31];
    if(opcode_E == `OP_BNE)begin
        $display("############## BNE ##############");
        zero = ~zero;
    end
end

endmodule