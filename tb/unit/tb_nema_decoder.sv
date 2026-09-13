`timescale 1ns/1ps

module tb_nema_decoder;

    logic [31:0] instr;
    logic        instr_valid;
    logic        is_nema_instr;
    logic        nema_ldw;
    logic        nema_mac;
    logic        nema_act;
    logic        nema_stat;
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [2:0]  funct3;

    nema_decoder dut (.*);

    initial begin
        instr_valid = 1'b1;

        // Test 1: NEMA.MAC (custom-0, funct3=001, rd=x5, rs1=x10, rs2=x11)
        instr = {7'b0000000, 5'b01011, 5'b01010, 3'b001, 5'b00101, 7'b0001011};
        #10;
        if (is_nema_instr && nema_mac && (rd_addr == 5) && (rs1_addr == 10) && (rs2_addr == 11)) begin
            $display("[PASS] Decoded NEMA.MAC (rd=x%0d, rs1=x%0d, rs2=x%0d)", rd_addr, rs1_addr, rs2_addr);
        end else begin
            $display("[FAIL] NEMA.MAC decoding error");
        end

        // Test 2: NEMA.LDW (funct3=000)
        instr = {7'b0000000, 5'b00000, 5'b00001, 3'b000, 5'b00010, 7'b0001011};
        #10;
        if (is_nema_instr && nema_ldw) begin
            $display("[PASS] Decoded NEMA.LDW");
        end else begin
            $display("[FAIL] NEMA.LDW decoding error");
        end

        // Test 3: Standard RISC-V ADD instruction (Opcode: 0110011) -> Should NOT trigger NEMA
        instr = 32'h00b502b3;
        #10;
        if (!is_nema_instr) begin
            $display("[PASS] Standard RISC-V instruction ignored cleanly");
        end else begin
            $display("[FAIL] False positive on standard RISC-V instruction");
        end

        $finish;
    end

endmodule
