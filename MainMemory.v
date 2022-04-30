module MainMemory
    ( // Inputs
    input CLK, // clock
    input READ_EN,
    input WRITE_EN,
    input wire [31:0] READ_ADDRESS,
    input wire [31:0] WRITE_ADDRESS,
    input wire [31:0] WRITE_DATA,
    input Show_EN,

    output wire [31:0] READ_DATA );

    integer output_file;
    // blockRam begin
    reg [31:0] DATA_RAM [0:512-1];
    reg [31:0] READ_DATA_reg;
    integer i;

    initial begin
        output_file = $fopen("RAM.txt", "w");
        for( i = 0; i < 512; i = i+1) begin
            DATA_RAM[i] = 32'h0000_0000;
        end
    end

    assign READ_DATA = READ_DATA_reg;

    always @(posedge CLK) begin 
        if (WRITE_EN) begin
            DATA_RAM[WRITE_ADDRESS/4] <= WRITE_DATA;
            $display("------Write data[%b] in address[%d]-----",WRITE_DATA, WRITE_ADDRESS/4);
        end
    end
    always @(*) begin
        if (READ_EN) begin
            READ_DATA_reg <= DATA_RAM[READ_ADDRESS/4];
        end
    end

    always@(Show_EN)begin
        if(Show_EN)begin
            for(i = 0;i<512;i = i+1) begin
                $fdisplay(output_file,"%b",DATA_RAM[i]);
            end
            $fclose(output_file);
            $finish();
        end
    end

endmodule

