`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 07:50:59 PM
// Design Name: 
// Module Name: shifter_32bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module shifter_32bit(
    input [31:0] in,
    input [4:0] shamt,
    input is_srl,     
    output [31:0] out
);
    assign out = is_srl ? (in >> shamt) : (in << shamt);
endmodule
