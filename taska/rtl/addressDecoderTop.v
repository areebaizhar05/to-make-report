`timescale 1ns / 1ps

module addressDecoderTop (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] address,
    input  wire        readEnable,
    input  wire        writeEnable,
    input  wire [31:0] writeData,
    input  wire [15:0] switches,
    output wire [31:0] readData,
    output wire [15:0] leds,
    output wire [15:0] seg_data
);
    wire DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable;
    wire [31:0] dataMemReadData, ledReadData, switchReadData;

    AddressDecoder dec (
        .address         (address[9:0]),
        .readEnable      (readEnable),
        .writeEnable     (writeEnable),
        .DataMemWrite    (DataMemWrite),
        .DataMemRead     (DataMemRead),
        .LEDWrite        (LEDWrite),
        .SwitchReadEnable(SwitchReadEnable)
    );

    DataMemory dm (
        .clk        (clk),
        .rst        (rst),
        .MemWrite   (DataMemWrite),
        .MemRead    (DataMemRead),
        .address    (address[8:0]),
        .write_data (writeData),
        .read_data  (dataMemReadData)
    );

    // 'switches' module drives physical LEDs
    // Fires when address[9:8]=10 i.e. address=32'd512
    switches led_periph (
        .clk        (clk),
        .rst        (rst),
        .writeData  (writeData),
        .writeEnable(LEDWrite),
        .readEnable (1'b0),
        .memAddress (address[29:0]),
        .readData   (ledReadData),
        .leds       (leds),
        .seg_data   (seg_data)
    );

    // 'leds' module reads physical switches
    // Fires when address[9:8]=11 i.e. address=32'd768
    leds sw_periph (
        .clk        (clk),
        .rst        (rst),
        .btns       (16'b0),
        .writeData  (32'b0),
        .writeEnable(1'b0),
        .readEnable (SwitchReadEnable),
        .memAddress (address[29:0]),
        .switches   (switches),
        .readData   (switchReadData)
    );

    // Read data mux
    assign readData = (address[9]   == 1'b0)  ? dataMemReadData :
                      (address[9:8] == 2'b11) ? switchReadData  :
                      32'b0;

endmodule
