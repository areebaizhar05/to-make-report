`timescale 1ns / 1ps

// TopLevelProcessor.v
// Single-cycle RISC-V processor datapath.
//
// Hierarchy:
//   TopLevelProcessor
//     u_pc          ProgramCounter
//     u_pcAdder     pcAdder          (PC + 4)
//     u_brAdder     branchAdder      (PC + imm, used for branches and JAL)
//     u_jumpMux     mux2             (selects between PC+4 and branch/JAL target)
//     u_jalrMux     mux2             (selects between jumpMux output and ALUResult for JALR)
//     u_instrMem    instructionMemory
//     ctrl_inst     main_control
//     u_immGen      immGen
//     u_regFile     RegisterFile
//     u_aluCtrl     alu_control
//     alu_inst      alu_32bit
//     u_mmio        addressDecoderTop

module TopLevelProcessor #(
    parameter INIT_FILE = "taskc.mem"
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] sw,   // physical switches -> address 768 (0x300)
    output wire [15:0] led,  // physical LEDs     <- address 512 (0x200) lower 16 bits
    output wire [15:0] seg_data // 7-segment data <- address 512 (0x200) upper 16 bits
);

    // ================================================================
    // 1. WIRES
    // ================================================================

    wire [31:0] PC;
    wire [31:0] PC_plus_4;
    wire [31:0] target_PC;
    wire [31:0] jump_mux_out;
    wire [31:0] next_PC;
    wire [31:0] instruction;

    wire        RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg;
    wire        Branch, Jump, JumpR, LUI, AUIPC, WritePC, InstrValid;
    wire [2:0]  ImmSrc;
    wire [1:0]  ALUOp;
    wire [3:0]  ALUControl;

    wire [31:0] ReadData1, ReadData2;
    wire [31:0] imm;
    wire [31:0] SrcA, SrcB;
    wire [31:0] ALUResult;
    wire        Zero;
    wire [31:0] ReadDataMem;
    wire [31:0] WriteData;

    // BEQ (funct3=000): branch when Zero=1  ->  Zero ^ 0 = 1
    // BNE (funct3=001): branch when Zero=0  ->  Zero ^ 1 = 1
    wire take_branch = Branch & (Zero ^ instruction[12]);
    wire jump_select = Jump | take_branch;

    // ================================================================
    // 2. PROGRAM COUNTER
    // ================================================================
    ProgramCounter u_pc (
        .clk    (clk),
        .rst    (rst),
        .PCNext (next_PC),
        .PC     (PC)
    );

    // ================================================================
    // 3. PC + 4
    // ================================================================
    pcAdder u_pcAdder (
        .PC      (PC),
        .PCPlus4 (PC_plus_4)
    );

    // ================================================================
    // 4. BRANCH / JAL TARGET  (PC + imm)
    // ================================================================
    branchAdder u_brAdder (
        .PC           (PC),
        .imm          (imm),
        .BranchTarget (target_PC)
    );

    // ================================================================
    // 5. NEXT-PC MUXES
    // Mux 1: PC+4 vs branch/JAL target
    // Mux 2: override with ALUResult for JALR
    // ================================================================
    mux2 u_jumpMux (
        .select (jump_select),
        .in0    (PC_plus_4),
        .in1    (target_PC),
        .out    (jump_mux_out)
    );

    mux2 u_jalrMux (
        .select (JumpR),
        .in0    (jump_mux_out),
        .in1    (ALUResult),
        .out    (next_PC)
    );

    // ================================================================
    // 6. INSTRUCTION MEMORY
    // ================================================================
    instructionMemory #(
        .INIT_FILE(INIT_FILE)
    ) u_instrMem (
        .instAddress (PC),
        .instruction (instruction)
    );

    // ================================================================
    // 7. MAIN CONTROL UNIT
    // ================================================================
    main_control ctrl_inst (
        .opcode    (instruction[6:0]),
        .RegWrite  (RegWrite),
        .ALUOp     (ALUOp),
        .MemRead   (MemRead),
        .MemWrite  (MemWrite),
        .ALUSrc    (ALUSrc),
        .MemtoReg  (MemtoReg),
        .Branch    (Branch),
        .Jump      (Jump),
        .JumpR     (JumpR),
        .LUI       (LUI),
        .AUIPC     (AUIPC),
        .WritePC   (WritePC),
        .ImmSrc    (ImmSrc),
        .InstrValid(InstrValid)
    );

    // ================================================================
    // 8. IMMEDIATE GENERATOR
    // ================================================================
    immGen u_immGen (
        .instruction (instruction),
        .imm         (imm)
    );

    // ================================================================
    // 9. REGISTER FILE + WRITE-BACK MUX
    // Priority: JAL/JALR -> PC+4, Load -> memory, else -> ALU
    // ================================================================
    wire [31:0] mem_or_alu = MemtoReg ? ReadDataMem : ALUResult;
    assign WriteData = WritePC ? PC_plus_4 : mem_or_alu;

    RegisterFile u_regFile (
        .clk        (clk),
        .rst        (rst),
        .WriteEnable(RegWrite),
        .rs1        (instruction[19:15]),
        .rs2        (instruction[24:20]),
        .rd         (instruction[11:7]),
        .WriteData  (WriteData),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );

    // ================================================================
    // 10. ALU INPUT MUXES
    // SrcA: LUI forces 0, AUIPC forces PC
    // SrcB: immediate or rs2
    // ================================================================
    assign SrcA = AUIPC ? PC : (LUI ? 32'd0 : ReadData1);
    assign SrcB = ALUSrc ? imm : ReadData2;

    // ================================================================
    // 11. ALU CONTROL
    // ================================================================
    alu_control u_aluCtrl (
        .ALUOp     (ALUOp),
        .funct3    (instruction[14:12]),
        .funct7    (instruction[31:25]),
        .ALUControl(ALUControl)
    );

    // ================================================================
    // 12. ALU
    // ================================================================
    alu_32bit alu_inst (
        .A         (SrcA),
        .B         (SrcB),
        .ALUControl(ALUControl),
        .ALUResult (ALUResult),
        .Zero      (Zero)
    );

    // ================================================================
    // 13. DATA MEMORY + MEMORY-MAPPED I/O
    // address[9]=0          -> DataMemory  (words 0-511)
    // address[9:8]=10 (512) -> LED output
    // address[9:8]=11 (768) -> Switch input
    // ================================================================
    addressDecoderTop u_mmio (
        .clk        (clk),
        .rst        (rst),
        .address    (ALUResult),
        .readEnable (MemRead),
        .writeEnable(MemWrite),
        .writeData  (ReadData2),
        .switches   (sw),
        .readData   (ReadDataMem),
        .leds       (led),
        .seg_data   (seg_data)
    );

endmodule