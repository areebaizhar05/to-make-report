`timescale 1ns / 1ps
module RegisterFile (
    input  wire clk,
    input  wire rst,
    input  wire WriteEnable,
    input  wire [4:0]  rs1,   // reg 1
    input  wire [4:0]  rs2, // reg 2
    input  wire [4:0]  rd,    // destination reg
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1, //reg 1 data
    output wire [31:0] ReadData2 //reg 2 data
);

    reg [31:0] regs [31:0]; //32 registers, each 32 bits wide
    integer k; // value 32 for loop
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //reset clears reg 
            for (k = 0; k < 32; k = k + 1)
                regs[k] <= 32'd0;
        end else begin
            if (WriteEnable && (rd != 5'd0))
                regs[rd] <= WriteData;
        end
    end
    assign ReadData1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    assign ReadData2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

endmodule