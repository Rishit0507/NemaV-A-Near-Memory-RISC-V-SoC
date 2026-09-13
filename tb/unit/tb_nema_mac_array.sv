`timescale 1ns/1ps

module tb_nema_mac_array;

    parameter int N = 4;
    parameter int DATA_WIDTH = 8;
    parameter int ACCUM_WIDTH = 32;

    logic clk;
    logic rst_n;
    logic enable;
    logic clear_acc;

    logic signed [DATA_WIDTH-1:0]  act_in[N];
    logic signed [DATA_WIDTH-1:0]  weight[N][N];
    logic signed [ACCUM_WIDTH-1:0] accum_out[N];

    // DUT Instantiation with N=4
    nema_mac_array #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
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

    initial begin
        clk = 0;
        rst_n = 0;
        enable = 0;
        clear_acc = 0;

        for (int i = 0; i < N; i++) begin
            act_in[i] = 8'sd0;
            for (int j = 0; j < N; j++) begin
                weight[i][j] = 8'sd0;
            end
        end

        #10 rst_n = 1;
        #5;

        // Apply Test Vectors
        clear_acc = 1;
        enable = 1;

        act_in[0] = 8'sd2;
        act_in[1] = 8'sd3;
        act_in[2] = 8'sd4;
        act_in[3] = 8'sd5;

        // Diagonal weight matrix (scaling factor of 3)
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                weight[i][j] = (i == j) ? 8'sd3 : 8'sd0;
            end
        end

        #3.33; // Wait 1 clock cycle

        $display("=== Checking 4x4 MAC Array Results ===");
        for (int col = 0; col < N; col++) begin
            logic signed [ACCUM_WIDTH-1:0] expected;
            expected = act_in[col] * 3;
            if (accum_out[col] === expected) begin
                $display("[PASS] Column %0d Output = %0d", col, accum_out[col]);
            end else begin
                $display("[FAIL] Column %0d Output = %0d (Expected: %0d)", col, accum_out[col], expected);
            end
        end

        $finish;
    end

endmodule
