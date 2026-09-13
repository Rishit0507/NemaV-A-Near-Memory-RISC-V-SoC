`timescale 1ns/1ps

module nema_decoder (
    input  logic [31:0] instr,
    input  logic        instr_valid,
    output logic        is_nema_instr,
    output logic        nema_ldw,
    output logic        nema_mac,
    output logic        nema_act,
    output logic        nema_stat,
    output logic [4:0]  rs1_addr,
    output logic [4:0]  rs2_addr,
    output logic [4:0]  rd_addr,
    output logic [2:0]  funct3
);

    // RISC-V custom-0 unprivileged opcode allocation
    localparam logic [6:0] OPCODE_CUSTOM0 = 7'b0001011;

    logic [6:0] opcode;

    assign opcode   = instr[6:0];
    assign rd_addr  = instr[11:7];
    assign funct3   = instr[14:12];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];

    assign is_nema_instr = instr_valid && (opcode == OPCODE_CUSTOM0);

    always_comb begin
        nema_ldw  = 1'b0;
        nema_mac  = 1'b0;
        nema_act  = 1'b0;
        nema_stat = 1'b0;

        if (is_nema_instr) begin
            case (funct3)
                3'b000: nema_ldw  = 1'b1; // NEMA.LDW  (Load Weights)
                3'b001: nema_mac  = 1'b1; // NEMA.MAC  (Execute MAC)
                3'b010: nema_act  = 1'b1; // NEMA.ACT  (Requantize/Activation)
                3'b011: nema_stat = 1'b1; // NEMA.STAT (Read Status)
                default: ;
            endcase
        end
    end

endmodule
