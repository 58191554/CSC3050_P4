module Reg_File(
    input CLK,
    input wire [4:0] read_add1,
    input wire [4:0] read_add2,
    input wire [4:0] write_add,
    input wire [31:0] write_data,
    input wire RegWrite,
    input wire Jal_WB_W,
    input Show_EN,
    output wire [31:0] read_out_data1,
    output wire [31:0] read_out_data2
);
// 1024bit for 32 32-bit register
    reg [31:0] regs_data [0:31];
    reg [31:0] read_reg_1;  assign read_out_data1 = read_reg_1;
    reg [31:0] read_reg_2;  assign read_out_data2 = read_reg_2;
    integer i;
    integer output_file;

    // assign read_out_data1 = regs_data[read_add1];
    // assign read_out_data1 = regs_data[read_add2];

    initial begin
// assign regs number
        output_file = $fopen("Register File Ram.txt", "w");
        for (i = 0;i < 32; i=i+1) begin
            regs_data[i] = 32'h0000_0000;
        end
    end

// writable
    always @(negedge CLK) begin
        if(RegWrite == 1  & write_add != 0) begin    
            $display("[Reg_File] wrote data [%d] into reg $[%d]", 
            write_data, write_add);
 
            $display("Write Data Into RF Successfully...");
            regs_data[write_add] = write_data;
        end        
        if(Jal_WB_W == 1)begin
            $display("Jal write the link PC address[%d] into [$ra]", write_data);
            regs_data[31] = write_data*4;
        end
    end
    
    always @(*) begin
        read_reg_1 <= regs_data[read_add1];
        // $display("1. pick out reg[%d] data = %b", read_add1, read_reg_1);

        read_reg_2 <= regs_data[read_add2];
        // $display("2. pick out reg[%d] data = %b", read_add2, read_reg_2);
    end
    // always @(Show_EN) begin
    //     if(Show_EN) begin
    //         $display("------------register file------------");
    //         for(i = 0;i<32;i = i+1) begin
    //             $display("%b",regs_data[i]);
    //             // $fdisplay(output_file,"%b",regs_data[i]);
    //         end
    //         // $fclose(output_file);
    //         // $finish(); 
    //     end
    // end

endmodule
