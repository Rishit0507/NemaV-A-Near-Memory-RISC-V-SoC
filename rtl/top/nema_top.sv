`timescale 1ns/1ps

module nema_top #(
    parameter int N = 4,
    parameter int DATA_WIDTH = 8,
    parameter int ACCUM_WIDTH = 32
)(
    input  logic clk,
    input  logic rst_n,

    // RISC-V Decoder Interface
    input  logic [31:0] instr,
    input  logic        instr_valid,
    output logic        is_nema_instr,
    output logic        nema_stat,

    // Control & Data Interface
    input  logic enable,
    input  logic clear_acc,
    input  logic signed [DATA_WIDTH-1:0] act_in[N],

    // Decompression Interface
    input  logic signed [DATA_WIDTH-1:0] palette[4],
    input  logic [1:0]                   indices[N][N],

    // Activation & Requantization Parameters
    input  logic [4:0]                  shift_amt,
    input  logic signed [DATA_WIDTH-1:0] zero_point,

    // Final Accelerator Output
    output logic signed [DATA_WIDTH-1:0] act_out[N]
);

    // Internal Signal Interconnects
    logic nema_ldw, nema_mac, nema_act;
    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic [2:0] funct3;

    logic signed [DATA_WIDTH-1:0] decomp_weights[N][N];
    logic signed [ACCUM_WIDTH-1:0] raw_accum[N];

    // 1. Instruction Decoder Sub-block
    nema_decoder u_decoder (
        .instr(instr),
        .instr_valid(instr_valid),
        .is_nema_instr(is_nema_instr),
        .nema_ldw(nema_ldw),
        .nema_mac(nema_mac),
        .nema_act(nema_act),
        .nema_stat(nema_stat),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .funct3(funct3)
    );

    // 2. Weight Decompression Sub-block
    nema_decomp #(.N(N)) u_decomp (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .palette(palette),
        .indices(indices),
        .weight_out(decomp_weights)
    );

    // 3. Systolic MAC Compute Engine
    nema_mac_array #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) u_mac_array (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .clear_acc(clear_acc),
        .act_in(act_in),
        .weight(decomp_weights),
        .accum_out(raw_accum)
    );

    // 4. Activation & Requantization Output Stage
    nema_act #(.N(N)) u_act (
        .accum_in(raw_accum),
        .shift_amt(shift_amt),
        .zero_point(zero_point),
        .act_out(act_out)
    );

endmodule
