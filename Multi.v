module mult_32_2to1(
    input wire[31:0] A,
    input wire[31:0] B,
    input wire sig,
    output wire [31:0] C
);
    reg C_reg;  
    assign C = ({32{sig}} & B) | ((~{32{sig}}) & A) ;
endmodule

module mult_5_Bit_2to1(
    input wire[4:0] A,
    input wire[4:0] B,
    input wire sig,
    output wire [4:0] C
);

    assign C = sig == 1 ? B : A;
    
endmodule

module mult_32_3to1(
    input wire[31:0] A,
    input wire[31:0] B,
    input wire[31:0] C,
    input wire [1:0] sig,
    output wire [31:0] D
);
    reg [31:0] reg_D;
    assign D = reg_D;
    always @* begin
        case (sig)
            2'b00: reg_D = A;
            2'b01: reg_D = B;
            2'b10: reg_D = C;
            default: reg_D = 0; 
        endcase
    end
endmodule