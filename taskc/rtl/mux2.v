`timescale 1ns / 1ps
// mux2.v
// 32-bit 2-to-1 multiplexer.
//sel = 0 -> out = in0
//sel = 1 -> out = in1

module mux2 (
    input wire select,
    input  wire [31:0] in0,
    input  wire [31:0] in1,
    output reg  [31:0] out  
);
    always @(*) begin
        if (select==0) begin
            out = in0;
        end else begin
            out = in1;
        end
    end

endmodule