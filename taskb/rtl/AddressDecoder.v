`timescale 1ns / 1ps

module AddressDecoder (
    input  wire [9:0] address,
    input  wire       readEnable,
    input  wire       writeEnable,
    output wire       DataMemWrite,
    output wire       DataMemRead,
    output wire       LEDWrite,
    output wire       SwitchReadEnable
);
    assign DataMemWrite     = (address[9]   == 1'b0)  && writeEnable;
    assign DataMemRead      = (address[9]   == 1'b0)  && readEnable;
    assign LEDWrite         = (address[9:8] == 2'b10) && writeEnable;
    assign SwitchReadEnable = (address[9:8] == 2'b11) && readEnable;
endmodule
