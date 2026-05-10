`timescale 1ns / 1ps

// riscv_fpga_top.v
//
// FPGA top-level wrapper for the single-cycle RISC-V processor.
// Targets Basys3 (Artix-7 XC7A35T-1CPG236C).
//
// Board connections:
//   CLK100MHZ -> 100 MHz on-board oscillator
//   btnC      -> centre button = reset (active high)
//   sw[15:0]  -> slide switches  = switch input  (address 0x300 / 768)
//   led[15:0] -> on-board LEDs   = LED output    (address 0x200 / 512)
//
// Before programming the board, open clock_divider.v and change:
//     localparam MAX_COUNT = 2;                <- simulation speed
// to:
//     localparam MAX_COUNT = 50_000_000 - 1;   <- 1 Hz on board

module riscv_fpga_top #(
    parameter INIT_FILE = "taskc.mem"
) (
    input  wire        CLK100MHZ,
    input  wire        btnC,
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire [3:0]  an
);

    wire clk_slow;
    wire rst;
    wire [15:0] seg_data;

    debouncer dbnc (
        .clk   (CLK100MHZ),
        .pbin  (btnC),
        .pbout (rst)
    );

    clock_divider clkdiv (
        .clk_in  (CLK100MHZ),
        .rst     (rst),
        .clk_out (clk_slow)
    );

    TopLevelProcessor #(
        .INIT_FILE(INIT_FILE)
    ) cpu (
        .clk (clk_slow),
        .rst (rst),
        .sw  (sw),
        .led (led),
        .seg_data (seg_data)
    );

    seven_seg_controller seg_ctrl (
        .clk  (CLK100MHZ), // use fast clock for multiplexing
        .rst  (rst),
        .data (seg_data),
        .seg  (seg),
        .an   (an)
    );

endmodule
