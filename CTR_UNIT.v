// ALU opcode table
    `define ALU_OP_ADD 4'b0000
    `define ALU_OP_SUB 4'b0001
    `define ALU_OP_SRL 4'b0010
    `define ALU_OP_OR  4'b0011
    `define ALU_OP_AND 4'b0100
    `define ALU_OP_NOR 4'b0101
    `define ALU_OP_SLT 4'b0110
    `define ALU_OP_XOR 4'b0111
    `define ALU_OP_SLL 4'b1000
    `define ALU_OP_SRA 4'b1001
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
// Opcode table
    `define OP_ANDI 6'hc
    `define OP_ADDI 6'h8 
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


module control_unit(
    input CLK,
    input wire [5:0] opcode, 
    input wire [5:0] funct,
    input CTRL_UNIT_RST,
    output RegDst,
    output Jump,
    output Branch,
    output MemRead,
    output MemtoReg,
    output RegWrite,
    output MemWrite,
   
    output wire [3:0] ALUOp,
    output ALU_SrcA,
    output ALU_SrcB,
    output reg [5:0] opcode_D,
    output reg Jal_WB_D);

    reg RegDst_reg;     assign RegDst = RegDst_reg;
    reg MemRead_reg;    assign MemRead  = MemRead_reg;
    reg MemWrite_reg;   assign MemWrite = MemWrite_reg;
    reg MemtoReg_reg;   assign MemtoReg = MemtoReg_reg;
    reg RegWrite_reg;   assign RegWrite = RegWrite_reg; 
    reg [3:0] ALUOp_reg;assign ALUOp    = ALUOp_reg ;
    reg ALU_SrcA_reg;   assign ALU_SrcA = ALU_SrcA_reg;
    reg ALU_SrcB_reg;   assign ALU_SrcB = ALU_SrcB_reg;
    reg Branch_reg;     assign Branch   = Branch_reg;
    reg Jump_reg;       assign Jump     = Jump_reg;

    initial begin
        MemRead_reg  = 0;
        MemWrite_reg = 0;
        MemtoReg_reg = 0;
        RegWrite_reg = 0;
        ALUOp_reg    = 0;
        ALU_SrcA_reg = 0;
        ALU_SrcB_reg = 0;
        Branch_reg   = 0; 
        Jump_reg     = 0;
        opcode_D     = 0;
        Jal_WB_D     = 0;
    end

    always @(*) begin
        #1
        $display("触发control unit");
        opcode_D = opcode;
// do the ALU_OP classification

        if(CTRL_UNIT_RST == 1)begin
            $display("reset控制装置复位...");
            MemRead_reg  = 0;
            MemWrite_reg = 0;
            MemtoReg_reg = 0;
            RegWrite_reg = 0;
            ALUOp_reg    = 0;
            ALU_SrcA_reg = 0;
            ALU_SrcB_reg = 0;
            Branch_reg   = 0; 
            Branch_reg   = 0;
            Jump_reg     = 0;
            Jal_WB_D     = 0;
        end
        else begin
            $display("opcode        == %h", opcode);
    // do ALUOp
            if(opcode == 6'b000000) begin
                case(funct)
                    `FCT_ADD, `FCT_ADDU: ALUOp_reg = `ALU_OP_ADD;
                    `FCT_SUB, `FCT_SUBU: ALUOp_reg = `ALU_OP_SUB;
                    `FCT_SLL, `FCT_SLLV: ALUOp_reg = `ALU_OP_SLL;
                    `FCT_SRA, `FCT_SRAV: ALUOp_reg = `ALU_OP_SRA;
                    `FCT_SRL, `FCT_SRLV: ALUOp_reg = `ALU_OP_SRL;
                    `FCT_AND: ALUOp_reg = `ALU_OP_AND;
                    `FCT_SLT: ALUOp_reg = `ALU_OP_SLT;
                    `FCT_XOR: ALUOp_reg = `ALU_OP_XOR;
                    `FCT_NOR: ALUOp_reg = `ALU_OP_NOR;
                    `FCT_OR:  ALUOp_reg = `ALU_OP_OR;
                endcase
            end
            
            case (opcode)
                `OP_ADDI, `OP_ADDIU, `OP_SW, `OP_LW: ALUOp_reg = `ALU_OP_ADD;
                `OP_BEQ, `OP_BNE: ALUOp_reg = `ALU_OP_SUB;
                `OP_ORI:  ALUOp_reg = `ALU_OP_OR;
                `OP_ANDI: ALUOp_reg = `ALU_OP_AND;
                `OP_XORI: ALUOp_reg = `ALU_OP_XOR;
            endcase
    
    // do the RegDst classification
        // JAL in ID stage is b'00; 
        // ADDI, ADDIU, ANDI, ORI, XORI, SLTI and LW in WB stage are b'01; 
        // otherwise, they are ALL b'10
            case (opcode)
                `OP_ADDI, `OP_ADDIU, `OP_ANDI, `OP_ORI, `OP_XORI,
                `OP_LW:RegDst_reg = 2'b00;
                `OP_JAL: RegDst_reg = 2'b00;
                default: RegDst_reg = 2'b01;
            endcase
    
            MemRead_reg = opcode  == `OP_LW ? 1 : 0;
            MemWrite_reg = opcode == `OP_SW ? 1 : 0;
            MemtoReg_reg = opcode == `OP_LW ? 1 : 0;
    
    // do the RegWrite register file write enable 
            case (opcode)
                6'b000000:
                    case (funct)
                        `FCT_JR: RegWrite_reg = 0;
                        default: RegWrite_reg = 1;
                    endcase
                `OP_SW, `OP_BEQ, `OP_BNE, `OP_J: RegWrite_reg = 0;
                default: RegWrite_reg = 1;
            endcase
    // do the ALU_src_A_reg: sll has special ALU_src_A
            ALU_SrcA_reg = (opcode == 0 && 
            (funct == `FCT_SLL | funct == `FCT_SRL | funct == `FCT_SRA)) ? 1 :0;
    // do the ALU_SrcB_reg: I_format: ADDI, ADDIU,ANDI,ORI,XORI,SW ,LW  ALU_SRC_B -> imm
            case (opcode)
                `OP_ADDI, `OP_ADDIU,`OP_ANDI, `OP_ORI, `OP_XORI, `OP_SW, `OP_LW: 
                ALU_SrcB_reg =  1;
                default:  ALU_SrcB_reg = 0;
            endcase
    // do the Jump classification
            if((opcode == 0 & funct == `FCT_JR)
            | opcode == `OP_J
            | opcode == `OP_JAL)begin
                $display("跳转指令");
                Jump_reg = 1;

            // do the Jal_WB_D

                if(opcode == `OP_JAL)begin
                    Jal_WB_D = 1;
                    $display("jal申请写入寄存器许可。。。");
                end
                else begin
                    Jal_WB_D = 0;
                end
            end

            else begin
                Jump_reg = 0;
                Jal_WB_D = 0;
            end
    // do the branch
            case (opcode)
                `OP_BEQ,`OP_BNE: Branch_reg = 1; 
                default:  Branch_reg = 0;
            endcase
    // 
        end
    

    end
endmodule