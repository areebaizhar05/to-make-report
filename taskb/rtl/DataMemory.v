`timescale 1ns / 1ps
module DataMemory (
    input  wire        clk,
    input  wire        rst,
    input  wire        MemWrite,
    input  wire        MemRead,
    input  wire [8:0]  address,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);
    reg [31:0] mem [0:511];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 512; i = i + 1)
                mem[i] <= 32'd0;
        end else if (MemWrite) begin
            mem[address] <= write_data;
        end
    end

    always @(*) begin
        if (MemRead)
            read_data = mem[address];
        else
            read_data = 32'd0;
    end
endmodule
