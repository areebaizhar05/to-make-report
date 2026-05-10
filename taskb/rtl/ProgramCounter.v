`timescale 1ns / 1ps
// ProgramCounter.v
// Stores and updates the PC on every positive clock edge.
// Resets to 0 on rst.

module ProgramCounter (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] PCNext,   //next PC value (from mux2)
    output reg  [31:0] PC        // current PC value
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'd0;
        else
            PC <= PCNext;
    end
endmodule
