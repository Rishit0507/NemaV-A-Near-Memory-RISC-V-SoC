`timescale 1ns/1ps

module tb_nema_mac_16x16;

    // Clock and Reset Signals
    logic clk;
    logic rst_n;
    logic enable;
    logic clear_acc;

    // Inputs & Outputs
    logic signed [7:0]  act_in[16];
    logic signed [7:0]  weight[16][16];
    logic signed [31:0] accum_out[16];

    // DUT (Device Under Test) Instantiation
    nema_mac_16x16 dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .clear_acc(clear_acc),
        .act_in(act_in),
        .weight(weight),
        .accum_out(accum_out)
    );

    // Clock Generator (300 MHz -> 3.33 ns period)
    always #1.665 clk = ~clk;

    // Test Sequence
    initial begin
        // Initialize Signals
        clk = 0;
        rst_n = 0;
        enable = 0;
        clear_acc = 0;

        for (int i = 0; i < 16; i++) begin
            act_in[i] = 8'sd0;
            for (int j = 0; j < 16; j++) begin
                weight[i][j] = 8'sd0;
            end
        end

        // Apply Reset
        #10 rst_n = 1;
        #5;

        // Test Vector 1: Set identity weight matrix and constant activations
        clear_acc = 1;
        enable = 1;

        for (int i = 0; i < 16; i++) begin
            act_in[i] = 8'sd2; // Activation value = 2
            for (int j = 0; j < 16; j++) begin
                if (i == j) weight[i][j] = 8'sd3; // Diagonal weight = 3
                else        weight[i][j] = 8'sd0;
            end
        end

        #3.33; // Wait 1 clock cycle

        // Verify Output: Expected Accumulator Output = 2 * 3 = 6
        $display("=== Checking Array Results ===");
        for (int col = 0; col < 16; col++) begin
            if (accum_out[col] === 32'sd6) begin
                $display("[PASS] Column %0d Output = %0d", col, accum_out[col]);
            end else begin
                $display("[FAIL] Column %0d Output = %0d (Expected: 6)", col, accum_out[col]);
            end
        end

        $finish;
    end

endmodule
