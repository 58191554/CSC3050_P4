`include "InstructionRAM.v"
`include "MainMemory.v"
`include "ALU.v"
`include "CTR_UNIT.v"
`include "Reg_File.v"
`include "Multi.v"
`include "Stall_Control.v"
`include "Forwarding_Unit.v"

// definition
// ALU_OP
    `define ALU_OP_ADD 4'b0000
    `define ALU_OP_SUB 4'b0001
    `define ALU_OP_SRL 4'b0010
    `define ALU_OP_OR  4'b0011
    `define ALU_OP_AND 4'b0100
    `define ALU_OP_NOR 4'b0101
    `define ALU_OP_SLT 4'b0110
    `define ALU_OP_XOR 4'b0111
    `define ALU_op_SLL 4'b1000

// Instrution opcode table
    `define OP_ANDI 6'hc
    `define OP_ADDIU 6'h9
    `define OP_ORI 6'hd
    `define OP_SLTI 6'ha
    `define OP_XORI 6'he

    `define OP_SW 6'h2b
    `define OP_LW 6'h23
    `define OP_BEQ 6'h4
    `define OP_BNE 6'h5
    `define OP_J 6'h2
    `define OP_JAL 6'h3
// Funct table
    `define FCT_ADD 6'h20 
    `define FCT_ADDU 6'h21 
    `define FCT_SUB 6'h22
    `define FCT_SUBU 6'h23
    `define FCT_AND 6'h24
    `define FCT_OR 6'h25
    `define FCT_XOR 6'h26
    `define FCT_NOR 6'h27
    `define FCT_SLT 6'h2a
    `define FCT_SLTU 6'h2b
    `define FCT_SLL 6'h0
    `define FCT_SLLV 6'h4
    `define FCT_SRL 6'h2
    `define FCT_SRLV 6'h6
    `define FCT_SRA 3'h3
    `define FCT_SRAV 6'h7
    `define FCT_JR 6'h8


module PC_Reg(
    input CLK,
    input wire [31:0] PC_in_2,
    input PC_NOPE,
    output reg [31:0] PCF
    );
    initial PCF = -1;

    always @(posedge CLK) begin
        if(!PC_NOPE)begin
            PCF = PC_in_2;
        end
    end

endmodule

module IF_ID_Reg(
    input CLK,
    input IF_ID_Reg_Rst,
    input wire [31:0] instruction,
    input wire [31:0] PC_plus_4,
    output reg [31:0] instrD,
    output reg [31:0] PC_plus_4_D);

    initial begin
        instrD = 0;
        PC_plus_4_D = 0;
    end

    always @(posedge CLK) begin
        instrD <= instruction;
        PC_plus_4_D <= PC_plus_4;
        if(IF_ID_Reg_Rst) begin
            $display("instD归零");
            instrD <= 0;
            PC_plus_4_D <= 0;
        end
    end
endmodule
//  16 0s' concatanate imm
module SignExtend(
    input wire [15:0] imm,
    input wire [5:0]opcode,
    output wire [31:0] extend_32);
    reg [31:0] result;
    always @(imm) begin
        if(opcode == `OP_ANDI | opcode == `OP_ORI | opcode == `OP_XORI) begin
            result= {{16{1'b0}}, imm};
        end
        else begin
            result= {{16{imm[15]}}, imm};
        end
    
    end
    assign extend_32 = result;
endmodule
//              ####    DELAY #3    ####
module ID_EXE_Reg(
    input CLK,
    input wire RegDst_D, 
    input wire Jump_D,  
    input wire Branch_D, 
    input wire MemRead_D,
    input wire MemtoReg_D,
    input wire RegWrite_D,
    input wire MemWrite_D,
    input wire [3:0] ALUOp_D,
    input wire ALU_SrcA_D,
    input wire ALU_SrcB_D,

    input wire [31:0] reg_read_out_1_D,
    input wire [31:0] reg_read_out_2_D,

    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [4:0] rd,
    input wire [4:0] shamt,
    input wire [31:0] sign_ext,
    input wire [31:0] PC_plus_4_D,
    input[5:0] opcode_D,
    input Jal_WB_D,

    output  reg RegDst_E_reg,
    output  reg Jump_E_reg,
    output  reg Branch_E_reg,
    output  reg MemRead_E_reg,
    output  reg MemtoReg_E_reg,
    output  reg RegWrite_E_reg,
    output  reg MemWrite_E_reg,
    output  reg [3:0] ALUOp_E_reg,
    output  reg ALU_SrcA_E_reg,
    output  reg ALU_SrcB_E_reg,

    output reg [31:0] reg_read_out_1_E_reg,
    output reg [31:0] reg_read_out_2_E_reg,

    output reg [4:0] rs_exe_reg,
    output reg [4:0] rt_exe_reg,
    output reg [4:0] rd_exe_reg,
    output reg [31:0] shamt_exe_reg,
    output reg [31:0] sign_ext_exe_reg,
    output reg [31:0] PC_plus_4_E_reg,
    output reg [5:0] opcode_E_reg,
    output reg Jal_WB_E_reg);

    
    initial begin
        RegDst_E_reg            = 0;
        Jump_E_reg              = 0;
        Branch_E_reg            = 0;
        MemRead_E_reg           = 0;
        MemtoReg_E_reg          = 0;
        RegWrite_E_reg          = 0;
        MemWrite_E_reg          = 0;
        ALUOp_E_reg             = 0;
        ALU_SrcA_E_reg          = 0;
        ALU_SrcB_E_reg          = 0;
        reg_read_out_1_E_reg    = 0;
        reg_read_out_2_E_reg    = 0;
        rs_exe_reg              = 0;
        rt_exe_reg              = 0;
        rd_exe_reg              = 0;
        shamt_exe_reg           = 0;
        sign_ext_exe_reg        = 0;
        PC_plus_4_E_reg         = 0;
        opcode_E_reg            = 0;
        Jal_WB_E_reg            = 0;
    end

    always @(posedge CLK) begin

        RegDst_E_reg                <= RegDst_D;
        Jump_E_reg                  <= Jump_D;
        Branch_E_reg                <= Branch_D;
        MemRead_E_reg               <= MemRead_D;
        MemtoReg_E_reg              <= MemtoReg_D;
        RegWrite_E_reg              <= RegWrite_D;
        MemWrite_E_reg              <= MemWrite_D;
        ALUOp_E_reg                 <= ALUOp_D;
        ALU_SrcA_E_reg              <= ALU_SrcA_D;
        ALU_SrcB_E_reg              <= ALU_SrcB_D;
        reg_read_out_1_E_reg        <= reg_read_out_1_D;
        reg_read_out_2_E_reg        <= reg_read_out_2_D;
        rs_exe_reg                  <= rs;
        rt_exe_reg                  <= rt;
        rd_exe_reg                  <= rd;
        shamt_exe_reg               <= shamt;
        sign_ext_exe_reg            <= sign_ext;
        PC_plus_4_E_reg             <= PC_plus_4_D;
        opcode_E_reg                <= opcode_D;
        Jal_WB_E_reg                <= Jal_WB_D;
    end

endmodule

module Branch_Shift_Add(
    input [31:0] SignImmE,
    input [31:0] PC_plus_4_E,
    output reg [31:0] PCBranch_E);
    always @* begin
        // we didn't do the move << 2 here cause the PC is normal integer without *4
        PCBranch_E = PC_plus_4_E + SignImmE;
    end
    
endmodule

module EXE_MEM_Reg(
    input CLK,
    input RegWrite_E,
    input MemtoReg_E,
    input MemWrite_E,
    input MemRead_E,
    input Branch_E,
    input Jump_E,
    input alu_zero,
    input [31:0] alu_result,
    input [31:0] WriteData_E,
    input [4:0] WriteReg_E,
    input [31:0] PCBranch_E,
    input [31:0] SrcAE_1,
    input Jal_WB_E,
    input [31:0] PC_plus_4_E,
    input [4:0] rd_exe,


    output reg RegWrite_M_reg,        
    output reg MemtoReg_M_reg,        
    output reg MemWrite_M_reg,        
    output reg MemRead_M_reg,         
    output reg Branch_M_reg,    
    output reg Jump_M_reg,     
    output reg alu_zero_M_reg,        
    output reg [31:0] alu_result_M_reg,
    output reg [31:0] WriteData_M_reg,
    output reg [4:0] WriteReg_M_reg,
    output reg [31:0] PCBranch_M_reg,
    output reg [31:0] reg_read_out_1_M_reg,
    output reg Jal_WB_M_reg,
    output reg [31:0] PC_plus_4_M_reg,
    output reg [4:0] rd_mem_reg    );

    initial begin
        RegWrite_M_reg      = 0;            WriteData_M_reg     = 0;
        MemtoReg_M_reg      = 0;            WriteReg_M_reg      = 0;
        MemWrite_M_reg      = 0;            PCBranch_M_reg      = 0;
        MemRead_M_reg       = 0;            reg_read_out_1_M_reg= 0;
        Branch_M_reg        = 0;            Jal_WB_M_reg        = 0;
        Jump_M_reg          = 0;            PC_plus_4_M_reg     = 0;
        alu_zero_M_reg      = 0;            rd_mem_reg          = 0;
        alu_result_M_reg    = 0;
    end

    always @ (posedge CLK) begin
        RegWrite_M_reg      <= RegWrite_E;
        MemtoReg_M_reg      <= MemtoReg_E;
        MemWrite_M_reg      <= MemWrite_E;
        MemRead_M_reg       <= MemRead_E;
        Branch_M_reg        <= Branch_E;
        Jump_M_reg          <= Jump_E;
        alu_zero_M_reg      <= alu_zero;
        alu_result_M_reg    <= alu_result;
        WriteData_M_reg     <= WriteData_E;
        WriteReg_M_reg      <= WriteReg_E;
        PCBranch_M_reg      <= PCBranch_E;
        reg_read_out_1_M_reg<= SrcAE_1;
        Jal_WB_M_reg        <= Jal_WB_E;
        PC_plus_4_M_reg     <= PC_plus_4_E;
        rd_mem_reg          <= rd_exe;
    end
    
endmodule

module MEM_WB_Reg(
    input CLK,
    input RegWrite_M,
    input MemtoReg_M,
    input [31:0] alu_result_M,
    input [31:0] ReadData_M,
    input [4:0] WriteReg_M,
    input Jal_WB_M,
    input [31:0] PC_plus_4_M,
    input [4:0] rd_mem,

    output reg RegWrite_W_reg,        
    output reg MemtoReg_W_reg,        
    output reg [31:0] alu_result_W_reg,
    output reg [31:0] ReadData_W_reg,
    output reg [4:0] WriteReg_W_reg,
    output reg Jal_WB_W_reg,
    output reg [31:0]PC_plus_4_W_reg,
    output reg [4:0] rd_W_reg);   

    initial begin
        RegWrite_W_reg   = 0;
        MemtoReg_W_reg   = 0;
        alu_result_W_reg = 0;
        ReadData_W_reg   = 0;
        WriteReg_W_reg   = 0;
        Jal_WB_W_reg     = 0;
        PC_plus_4_W_reg  = 0;
        rd_W_reg         = 0;
    end

    always @(posedge CLK) begin
        RegWrite_W_reg    <= RegWrite_M;
        MemtoReg_W_reg    <= MemtoReg_M;
        alu_result_W_reg  <= alu_result_M;
        ReadData_W_reg    <= ReadData_M;
        WriteReg_W_reg    <= WriteReg_M;
        Jal_WB_W_reg      <= Jal_WB_M;
        PC_plus_4_W_reg   <= PC_plus_4_M;
        rd_W_reg          <= rd_mem;
    end      
endmodule

module cpu(input CLK, input Show_EN);


//        ###############       REGISTERS DECLARATION      ###############       
//        ###############  wire for the IF part            ###############       
    // registers used for decode instruction
    wire [31:0] PC_in_1;      
    wire [31:0] PC_in_2;
    wire [31:0] PCF;        
    wire[31:0] PC_plus_4;   wire[31:0] PC_plus_4_D; wire[31:0] PC_plus_4_E;
    wire [31:0]instruction; wire[31:0] instrD;      
    wire [5:0] opcode;      wire [4:0] rs;  wire [4:0] rt;  wire [4:0] rd;
    wire [5:0] funct;   wire [4:0] shamt;   wire [15:0] imm;
    // Branch control
    wire PC_NOPE;           wire CTRL_UNIT_RST;     wire IF_ID_Reg_Rst;
//        ###############  wire for control in ID part     ###############       
    wire RegDst_D;  
    wire Jump_D;
    wire Branch_D;
    wire MemRead_D;
    wire MemtoReg_D;
    wire RegWrite_D;
    wire MemWrite_D;
    wire ALU_SrcA_D;
    wire ALU_SrcB_D;
    wire [3:0] ALUOp_D;
    // register data read out in ID part
    wire [31:0] reg_read_out_1_D;
    wire [31:0] reg_read_out_2_D;
    // Extend imm to 32
    wire [31:0] imm_extend_32_D;

    wire [5:0] opcode_D;
    wire Jal_WB_D;
//        ###############  wire in the EXE part            ###############       
    // inherit from the pre stage
    wire RegDst_E;
    wire Jump_E;    
    wire Branch_E;
    wire MemRead_E;
    wire MemtoReg_E;
    wire RegWrite_E;
    wire MemWrite_E;
    wire [3:0] ALUOp_E;
    wire ALU_SrcA_E;
    wire ALU_SrcB_E;
    wire [31:0] reg_read_out_1_E;
    wire [31:0] reg_read_out_2_E;
    wire [4:0] rs_exe;
    wire [4:0] rt_exe;
    wire [4:0] rd_exe;
    wire [31:0] shamt_exe;
    wire [31:0] sign_ext_exe;

    wire [31:0] SrcAE_1;    //first selection by ALU_SrcA_E 
    wire [31:0] SrcBE_1;    //first selection by ALU_SrcB_E 
    wire [31:0] SrcAE_2;    //second select if hazard
    wire [31:0] SrcBE_2;    //second select if hazard

    wire [31:0] alu_result;
    wire alu_zero;
    wire [4:0] WriteReg_E;
    wire [31:0] WriteData_E;     assign WriteData_E = SrcBE_1;
    wire [31:0] PCBranch_E;

    wire [5:0] opcode_E;
    wire Jal_WB_E;
//        ###############  wire in the MEM part            ###############       
    wire RegWrite_M;        wire alu_zero_M;
    wire MemtoReg_M;        wire [31:0] alu_result_M;
    wire MemWrite_M;        wire [31:0] WriteData_M;
    wire MemRead_M;         wire [4:0] WriteReg_M;
    wire Branch_M;          wire [31:0] PCBranch_M;
    wire Jump_M;        

    wire PCSrcM;                assign PCSrcM = Branch_M & alu_zero_M;
    wire [31:0] ReadData_M;     //Data read form Main memory
    // use the reg_read_out_1_M for jr Jump
    wire [31:0] reg_read_out_1_M;
    wire Jal_WB_M;
    wire [31:0] PC_plus_4_M;
    wire [4:0] rd_mem;

//        ###############  wire for WB part                ###############       
    wire RegWrite_W;
    wire MemtoReg_W;
    wire [31:0] alu_result_W;  // finally write to register 
    wire [31:0] ReadData_W;
    wire [31:0] ALUOUT_W;
    wire [4:0] WriteReg_W;
    wire [31:0] Result_W_1;
    wire [31:0] Result_W_2;
    wire Jal_WB_W;
    wire [31:0] PC_plus_4_W;
    wire [4:0] rd_W;
//        ###############       Jump wire                  ###############
    wire [31:0] Jump_PC;
    wire [31:0] Jump_const_PC;
    assign Jump_const_PC = instruction[25:0];
    wire Jump_kind  ;
//        ###############       Forwarding wire            ###############
    wire [1:0] Forward_A;
    wire [1:0] Forward_B;
//        ###############       other things               ###############
    integer output_file;
    integer i;
//        ###############       MODULE DECLARATION         ###############
// PC_Reg module
PC_Reg pc_reg_module(
    .CLK(CLK),
    .PC_in_2(PC_in_2),
    .PC_NOPE(PC_NOPE),
    .PCF(PCF));
// Branch Control
Stall_Control stall_ctr(
    .CLK            (CLK),
    .instruction    (instruction),
    .PC_NOPE        (PC_NOPE),
    .CTRL_UNIT_RST  (CTRL_UNIT_RST),
    .IF_ID_Reg_Rst  (IF_ID_Reg_Rst),
    .Jump_kind(Jump_kind));

// Instruction Fetch
InstructionRAM IF(CLK,0, 1, PCF, instruction);
// pipline register             IF_ID
IF_ID_Reg if_id_reg(
    .CLK(CLK), 
    .instruction(instruction), 
    .PC_plus_4(PC_plus_4), 
    .IF_ID_Reg_Rst(IF_ID_Reg_Rst),
    .instrD(instrD), 
    .PC_plus_4_D(PC_plus_4_D));
// control unit in ID part
control_unit ctr_unit(
    .CLK(CLK),
    .opcode(opcode),    
    .funct(funct),    

    .RegDst(RegDst_D),
    .Jump(Jump_D),    
    .Branch(Branch_D),  
    .MemRead(MemRead_D),  
    .MemtoReg(MemtoReg_D),
    .RegWrite(RegWrite_D),   
    .MemWrite(MemWrite_D),    
    .ALUOp(ALUOp_D),    
    .ALU_SrcA(ALU_SrcA_D),    
    .ALU_SrcB(ALU_SrcB_D),
    .opcode_D(opcode_D),
    .Jal_WB_D(Jal_WB_D)    );
// register file read and wirte operation
Reg_File reg_file(
    .CLK(CLK),
    .read_add1(rs), 
    .read_add2(rt), 
    .write_add(WriteReg_W),
    .write_data(Result_W_2),
    .RegWrite(RegWrite_W),  
    .Jal_WB_W(Jal_WB_W),
    .Show_EN(Show_EN),
    .read_out_data1(reg_read_out_1_D),  
    .read_out_data2(reg_read_out_2_D));
// imm 16 -> 32
SignExtend sign_extend_D(    
    .imm(imm),
    .opcode(opcode),  
    .extend_32(imm_extend_32_D));
//pipline register              ID_EXE 
ID_EXE_Reg id_exe_reg(
    .CLK(CLK),
    .RegDst_D(RegDst_D),
    .Jump_D(Jump_D),
    .Branch_D(Branch_D),
    .MemRead_D(MemRead_D),
    .MemtoReg_D(MemtoReg_D),
    .RegWrite_D(RegWrite_D),
    .MemWrite_D(MemWrite_D),
    .ALUOp_D(ALUOp_D),
    .ALU_SrcA_D(ALU_SrcA_D),
    .ALU_SrcB_D(ALU_SrcB_D),
    .reg_read_out_1_D(reg_read_out_1_D),
    .reg_read_out_2_D(reg_read_out_2_D),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .shamt(shamt),
    .sign_ext(imm_extend_32_D),
    .PC_plus_4_D(PC_plus_4_D),
    .opcode_D(opcode_D),
    .Jal_WB_D(Jal_WB_D),

    .RegDst_E_reg                   (RegDst_E),
    .Jump_E_reg                     (Jump_E),
    .Branch_E_reg                   (Branch_E),
    .MemRead_E_reg                  (MemRead_E),
    .MemtoReg_E_reg                 (MemtoReg_E),
    .RegWrite_E_reg                 (RegWrite_E),
    .MemWrite_E_reg                 (MemWrite_E),
    .ALUOp_E_reg                    (ALUOp_E),
    .ALU_SrcA_E_reg                 (ALU_SrcA_E),
    .ALU_SrcB_E_reg                 (ALU_SrcB_E),
    .reg_read_out_1_E_reg           (reg_read_out_1_E),
    .reg_read_out_2_E_reg           (reg_read_out_2_E),
    .rs_exe_reg                     (rs_exe),
    .rt_exe_reg                     (rt_exe),
    .rd_exe_reg                     (rd_exe),
    .shamt_exe_reg                  (shamt_exe),
    .sign_ext_exe_reg               (sign_ext_exe),
    .PC_plus_4_E_reg                (PC_plus_4_E),
    .opcode_E_reg                   (opcode_E),
    .Jal_WB_E_reg                   (Jal_WB_E));
// alu first grade A selector
mult_32_3to1 alu_srcA1_selector(
    .A(reg_read_out_1_E),
    .B(Result_W_2),
    .C(alu_result_M),
    .sig(Forward_A),
    .D(SrcAE_1));

// ALU Sourse A Multiplexer
mult_32_2to1 alu_srcA2_selector(
    .A(SrcAE_1), 
    .B(shamt_exe), 
    .sig(ALU_SrcA_E),
    .C(SrcAE_2));

// alu first grade B selector
mult_32_3to1 alu_srcB1_selector(
    .A(reg_read_out_2_E),
    .B(Result_W_2),
    .C(alu_result_M),
    .sig(Forward_B),
    .D(SrcBE_1));


// ALU Sourse B Multiplexer
mult_32_2to1 alu_regB2_selector(
    .A(SrcBE_1),
    .B(sign_ext_exe),
    .sig(ALU_SrcB_E),
    .C(SrcBE_2));
// Important ALU!
alu alu_for_cpu(
    .reg_A(SrcAE_2), 
    .reg_B(SrcBE_2), 
    .alu_op(ALUOp_E), 
    .opcode_E(opcode_E),
    .result(alu_result), 
    .zero(alu_zero));
// WriteReg_E Multiplexer
mult_5_Bit_2to1 WriteReg_Mulx(
    .A(rt_exe),
    .B(rd_exe),
    .sig(RegDst_E),
    .C(WriteReg_E));
// PC Branch addition part : Branch_Shift_Add
Branch_Shift_Add pc_branch_shift_addition(
    .SignImmE(sign_ext_exe),
    .PC_plus_4_E(PC_plus_4_E),
    .PCBranch_E(PCBranch_E)    );
// PIPLINE REGISTER             EXE_MEM
EXE_MEM_Reg exe_mem_reg(
    .CLK(CLK),
    .RegWrite_E(RegWrite_E),
    .MemtoReg_E(MemtoReg_E),
    .MemWrite_E(MemWrite_E),
    .MemRead_E(MemRead_E),
    .Branch_E(Branch_E),
    .Jump_E(Jump_E),
    .alu_zero(alu_zero),
    .alu_result(alu_result),
    .WriteData_E(WriteData_E),
    .WriteReg_E(WriteReg_E),
    .PCBranch_E(PCBranch_E),
    .SrcAE_1(SrcAE_1),
    .Jal_WB_E(Jal_WB_E),
    .PC_plus_4_E(PC_plus_4_E),
    .rd_exe(rd_exe),

    .RegWrite_M_reg         (RegWrite_M),
    .MemtoReg_M_reg         (MemtoReg_M),
    .MemWrite_M_reg         (MemWrite_M),
    .MemRead_M_reg          (MemRead_M),
    .Branch_M_reg           (Branch_M),
    .Jump_M_reg             (Jump_M),
    .alu_zero_M_reg         (alu_zero_M),
    .alu_result_M_reg       (alu_result_M),
    .WriteData_M_reg        (WriteData_M),
    .WriteReg_M_reg         (WriteReg_M),
    .PCBranch_M_reg         (PCBranch_M),
    .reg_read_out_1_M_reg   (reg_read_out_1_M),
    .Jal_WB_M_reg           (Jal_WB_M),
    .PC_plus_4_M_reg        (PC_plus_4_M),
    .rd_mem_reg             (rd_mem));

// MainMemory RAM input aluout, input WirteDataM
MainMemory main_memory(    
    .CLK(CLK), 
    .READ_EN(MemRead_M),
    .WRITE_EN(MemWrite_M),
    .READ_ADDRESS(alu_result_M),
    .WRITE_ADDRESS(alu_result_M),
    .WRITE_DATA(WriteData_M),
    .Show_EN(Show_EN),
    .READ_DATA(ReadData_M) );

// PIPELINE REGISTER            MEM_WB
MEM_WB_Reg mem_wb_reg(
    .CLK(CLK),
    .RegWrite_M(RegWrite_M),
    .MemtoReg_M(MemtoReg_M),
    .alu_result_M(alu_result_M),
    .ReadData_M(ReadData_M),
    .WriteReg_M(WriteReg_M),
    .Jal_WB_M(Jal_WB_M),
    .PC_plus_4_M(PC_plus_4_M),
    .rd_mem(rd_mem),

    .RegWrite_W_reg     (RegWrite_W),
    .MemtoReg_W_reg     (MemtoReg_W),
    .alu_result_W_reg   (alu_result_W),
    .ReadData_W_reg     (ReadData_W),
    .WriteReg_W_reg     (WriteReg_W),
    .Jal_WB_W_reg       (Jal_WB_W),
    .PC_plus_4_W_reg    (PC_plus_4_W),
    .rd_W_reg           (rd_W));
// Select ALUOut_W and ReadDataW by MemtoReg_W
mult_32_2to1 write_back_aluout_w_read_Data_W_selector(
    .A(alu_result_W),
    .B(ReadData_W),
    .sig(MemtoReg_W),
    .C(Result_W_1));
// select result 1 and P
mult_32_2to1 select_PC_plus_4_W_or_Result_W_1(
    .A(Result_W_1),
    .B(PC_plus_4_W),
    .sig(Jal_WB_W),
    .C(Result_W_2));
// select between pc+4 and branch
mult_32_2to1 select_PC4_or_Branch(
    .A(PC_plus_4),
    .B(PCBranch_M),
    .sig(PCSrcM),
    .C(PC_in_1));
// select between PC_in_1 or Jump_PC
mult_32_2to1 select_PC_in_1_or_Jump_PC(
    .A(PC_in_1),
    .B(Jump_PC),
    .sig(Jump_M),
    .C(PC_in_2));
// select between reg_read_out_1_M and Jump_const_PC
mult_32_2to1 select_jump_pc(
    .A(Jump_const_PC),
    .B(reg_read_out_1_M/4),
    .sig(Jump_kind),
    .C(Jump_PC)
);
// Forwarding_Unit
Forwarding_Unit forward_unit(

    .CLK(CLK),
    .rs_exe(rs_exe),
    .rt_exe(rt_exe),
    .alu_result_M(alu_result_M),
    .WriteReg_M(WriteReg_M),
    .Result_W_2(Result_W_2),
    .WriteReg_W(WriteReg_W),
    .RegWrite_M(RegWrite_M),
    .RegWrite_W(RegWrite_W),

    .Forward_A(Forward_A),
    .Forward_B(Forward_B)       );


// Instruction Decode
    assign opcode = instrD[31:26];
    assign rs = instrD[25:21];
    assign rt = instrD[20:16];
    assign rd = instrD[15:11];
    assign funct = instrD[5:0];
    assign shamt = instrD[10:6];
    assign imm = instrD[15:0];

// PC+4
assign  PC_plus_4 = PCF + 1;

initial begin
// First CHECK
    $display("-------First--------");
    $display("PCF         = ", PCF);
    $display("instruction = %b", instruction);
    $display("instrD      = %b", instrD);
    // $display("rs          = %b", rs);
    // $display("rt          = %b", rt);
    // $display("rd          = %b", rd);
    // $display("reg_read_out_1_D = ", reg_read_out_1_D);
    // $display("reg_read_out_2_D = ", reg_read_out_2_D);
    // $display("ALUOp_E    = ",ALUOp_E      ); 

    // $display("SrcAE_1      = ", SrcAE_1);
    // $display("SrcBE_1      = ", SrcBE_1);
    // $display("RegWrite_W = ", RegWrite_W);

    // $display("alu_result = %d", alu_result);
    // $display("Jump_M        = ", Jump_M);
    // $display("Jump_PC       = ", Jump_PC);
    #1;
// Second CHECK
    $display("-------Second--------");
    $display("PCF         = ", PCF);
    $display("instruction = %b", instruction);
    // $display("instrD      = %b", instrD);
    // $display("rs          = %b", rs);
    // $display("rt          = %b", rt);
    // $display("rd          = %b", rd);
    // $display("reg_read_out_1_D = ", reg_read_out_1_D);
    // $display("reg_read_out_2_D = ", reg_read_out_2_D);
    // $display("ALUOp_E    = ",ALUOp_E      ); 

    // $display("SrcAE_1      = ", SrcAE_1);
    // $display("SrcBE_1      = ", SrcBE_1);

    // $display("alu_result = %d", alu_result);
    $display("RegWrite_W = ", RegWrite_W);
    // $display("Jump_M        = ", Jump_M);
    // $display("Jump_PC       = ", Jump_PC);

end

always @(posedge CLK) begin
// CHECK PC_in_1 are ok...
    #9;
    $display("\n\n\n");
    $display("------------------------IF------------------------", PC_in_1);
    // $display("PC_in_1       = ", PC_in_1);
    $display("PCF         = ", PCF);
    $display("instruction = %b", instruction);
    // $display("PC_plus_4 = ", PC_plus_4);

    $display("------------------------ID------------------------", PC_in_1-1);
    $display("instrD      = %b", instrD);
    // $display("IF_ID_Reg_Rst     -> ",IF_ID_Reg_Rst);
    // $display("IF_ID_Reg_Rst             -> ", IF_ID_Reg_Rst);
    // $display("CTRL_UNIT_RST             -> ", CTRL_UNIT_RST);
    // $display("rs          = %b", rs);
    // $display("rt          = %b", rt);
    // $display("rd          = %b", rd);

// CONTROL DISPLAY
    // $display("controls:");
    // $display("opcode = %h", opcode); 
    // $display("funct  = %h", funct);
    // $display("RegDst_D      ",RegDst_D       );
    // $display("Jump_D        ",Jump_D         );
    // $display("Jal_WB_D              -> ", Jal_WB_D);
    // $display("Branch_D      ",Branch_D       );
    // $display("MemRead_D     ",MemRead_D      );
    // $display("MemtoReg_D    ",MemtoReg_D     );
    // $display("MemWrite_D       ", MemWrite_D);
    // $display("RegWrite_D   ->  ",RegWrite_D     );
    // $display("ALU_OP = %b",ALUOp_D);
    // $display("ALU_SrcA_D    ",ALU_SrcA_D     );
    // $display("ALU_SrcB_D    ",ALU_SrcB_D     );
// DISPLAY THE Reg File
    // $display("read_write_regs = ", reg_read_out_1_D, ", ", reg_read_out_2_D);
    // $display("reg_read_out_1_D = ", reg_read_out_1_D);
    // $display("reg_read_out_2_D = ", reg_read_out_2_D);
    // $display("extend = %b", imm_extend_32_D);
    // $display("extend            -> %b", imm_extend_32_D);
// ------------------------EXE-----------------------
    $display("------------------------EXE-----------------------", PC_in_1-2);

    // $display("reg_read_out_1_E = ", reg_read_out_1_E);
    // $display("sign extend exe  = ", sign_ext_exe);
    // Check the extend in ID part
    // CHECK THE ID_EXE PIPELINE REGISTER
    // $display("RegDst_E      ",RegDst_E      );
    // $display("The register to be written is -> [%d]",WriteReg_E);
    // $display("Jump_E        ",Jump_E        );
    // $display("Jump_kind         _> ", Jump_kind);

    // $display("PC_plus_4_E               --------", PC_plus_4_E);
    // $display("Jal_WB_E              -> ", Jal_WB_E);

    // $display("Branch_E      ",Branch_E      );
    // $display("MemRead_E     ",MemRead_E     );
    // $display("MemtoReg_E    ",MemtoReg_E    );
    // $display("MemWrite_E    ",MemWrite_E    );
    // $display("RegWrite_E   ->  ",RegWrite_E     );
    // $display("ALUOp_E      ",ALUOp_E      ); 
    // $display("ALU_SrcA_E = ",ALU_SrcA_E    );
    // $display("ALU_SrcB_E    ",ALU_SrcB_E    );
    // $display("WriteData_E     -> ", WriteData_E);
    // $display("shamt_exe  = ", shamt_exe);
// CHECK ALU...
    // $display("ALUOp_E    = ",ALUOp_E      ); 
    #3;
    $display("SrcAE_1      = %b", SrcAE_1);
    $display("SrcBE_1      = %b", SrcBE_1);

    $display("SrcAE_2      = %b", SrcAE_2);
    $display("SrcBE_2      = %b", SrcBE_2);

    // $display("ALUOp_E    = ", ALUOp_E);
    $display("alu_result = %b", alu_result);
    // $display("sign_ext_exe      -> %b %d", sign_ext_exe, sign_ext_exe);
    // $display("PC_plus_4_E           -> %d", PC_plus_4_E);
// ------------------------MEM-----------------------
    $display("------------------------MEM-----------------------", PC_in_1-3);

    $display("alu_result_M   = %d", alu_result_M);
    // $display("ReadData_M            -> %b", ReadData_M);
    // $display("I am able to read     -> ", MemRead_M);
    // $display("READ_ADDRESS          -> ", alu_result_M);
    // $display("PCBranch_M                    -> ", PCBranch_M);
    // $display("PCSrcM                        -> ", PCSrcM);
    // $display("RegWrite_M   ->  ",RegWrite_M     );
    // $display("Jump_M                _> ", Jump_M);
    // $display("The register to be written is -> [%d]",WriteReg_M);

    // $display("PC_plus_4_M               ------------", PC_plus_4_M);
    // $display("Jal_WB_M              -> ", Jal_WB_M);

    // $display("Memory_ADDRESS  -> %d", alu_result_M);
    $display("MemWrite_M   ->          ", MemWrite_M);
    $display("Mem_WRITE_DATA  -> %d", WriteData_M);

// CHECK WRITE REGISTER
    $display("------------------------WB-----------------------", PC_in_1-4);
    // $display("MemtoReg_W            -> %b", MemtoReg_W);
    // $display("WB Result_W_1         -> %b", Result_W_1);
    // $display("WB Result_W_2         -> %b", Result_W_2);

    $display("The register to be written is -> [%d]",WriteReg_W);

    // $display("Whether is able to write? ",RegWrite_W);
    // $display("PC_plus_4_W               ------------", PC_plus_4_W);
    // $display("------------------------Jump info-----------------------");
    // $display("Jump_const_PC = ", Jump_const_PC);
    // $display("reg_read_out_1_M  = ", reg_read_out_1_M);
    // $display("Jump_kind         = ", Jump_kind);
    // $display("Jump_PC           = ", Jump_PC);
    // $display("Jal_WB_W          _.", Jal_WB_W);
    $display("------------------------Forward-------------------");
    // $display("Forward_A         -> ", Forward_A);
    // $display("Forward_B         -> ", Forward_B);
end


endmodule