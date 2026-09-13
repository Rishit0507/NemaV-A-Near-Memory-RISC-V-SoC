`timescale 1ns/1ps

module tb_nema_top;

    parameter int N = 4;
    parameter int DATA_WIDTH = 8;
    parameter int ACCUM_WIDTH = 32;

    logic clk, rst_n;
    logic [31:0] instr;
    logic instr_valid;
    logic is_nema_instr, nema_stat;

    logic enable, clear_acc;
    logic signed [DATA_WIDTH-1:0] act_in[N];
    logic signed [DATA_WIDTH-1:0] palette[4];
    logic [1:0]                   indices[N][N];
    logic [4:0]                   shift_amt;
    logic signed [DATA_WIDTH-1:0] zero_point;
    logic signed [DATA_WIDTH-1:0] act_out[N];

    // Instantiate Top-Level Design
    nema_top #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (.*);

    // Clock Generator (300 MHz)
    always #1.665 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        enable = 0;
        clear_acc = 0;
        instr_valid = 0;

        // Palette Setup: Index 0=0, 1=2, 2=-4, 3=8
        palette[0] = 8'sd0;
        palette[1] = 8'sd2;
        palette[2] = -8'sd4;
        palette[3] = 8'sd8;

        for (int i = 0; i < N; i++) begin
            act_in[i] = 8'sd0;
            for (int j = 0; j < N; j++) begin
                indices[i][j] = 2'd0;
            end
        end

        #10 rst_n = 1;
        #5;

        // Step 1: Issue NEMA.MAC Instruction (custom-0, funct3=001)
        instr = {7'b0000000, 5'b01011, 5'b01010, 3'b001, 5'b00101, 7'b0001011};
        instr_valid = 1;
        #3.33;

        // Step 2: Stream Activations & Weight Indices
        enable = 1;
        clear_acc = 1;

        act_in[0] = 8'sd4;
        act_in[1] = 8'sd2;
        act_in[2] = 8'sd0;
        act_in[3] = 8'sd0;

        // Identity-like index matrix pointing to palette[1] (value 2)
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                indices[i][j] = (i == j) ? 2'd1 : 2'd0;
            end
        end

        shift_amt  = 5'd1; // Right shift by 1
        zero_point = 8'sd0;

        #6.66; // Wait pipeline latency

        // Verify End-to-End Execution
        $display("=== Checking Top-Level Integrated SoC Pipeline ===");
        if (is_nema_instr) begin
            $display("[PASS] Custom RISC-V Instruction Decoded Successfully");
        end else begin
            $display("[FAIL] Instruction Decoding Failed");
        end

        // Column 0 Expected: (4 * 2 + 2 * 0 + 0 + 0) >> 1 = 8 >> 1 = 4
        // Column 1 Expected: (4 * 0 + 2 * 2 + 0 + 0) >> 1 = 4 >> 1 = 2
        if (act_out[0] === 8'sd4 && act_out[1] === 8'sd2) begin
            $display("[PASS] End-to-End Pipeline Execution (Decomp -> MAC -> Act)");
            $display("       Col 0 Output = %0d (Expected: 4)", act_out[0]);
            $display("       Col 1 Output = %0d (Expected: 2)", act_out[1]);
        end else begin
            $display("[FAIL] Pipeline Mismatch: Col 0=%0d (Exp 4), Col 1=%0d (Exp 2)", act_out[0], act_out[1]);
        end

        $finish;
    end

endmodule
