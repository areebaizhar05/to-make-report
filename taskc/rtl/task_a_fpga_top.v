`timescale 1ns / 1ps

module task_a_fpga_top (
    input  wire        CLK100MHZ,
    input  wire        btnC,
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire [3:0]  an
);
   
    riscv_fpga_top #(
        .INIT_FILE("taskc.mem")
    ) top (
        .CLK100MHZ(CLK100MHZ),
        .btnC(btnC),
        .sw(sw),
        .led(led),
        .seg(seg),
        .an(an)
    );

endmodule
