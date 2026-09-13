`timescale 1ns/1ps

module tb_nema_decomp;

    parameter int N = 4;

    logic clk;
    logic rst_n;
    logic enable;
    logic signed [7:0] palette[4];
    logic [1:0]        indices[N][N];
    logic signed [7:0] weight_out[N][N];

    nema_decomp #(.N(N)) dut (.*);

    // Clock Generation (3.33 ns period)
    always #1.665 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        enable = 0;

        // Define Palette: Index 0 = 0, Index 1 = 3, Index 2 = -5, Index 3 = 12
        palette[0] = 8'sd0;
        palette[1] = 8'sd3;
        palette[2] = -8'sd5;
        palette[3] = 8'sd12;

        for (int r = 0; r < N; r++) begin
            for (int c = 0; c < N; c++) begin
                indices[r][c] = 2'd0;
            end
        end

        #10 rst_n = 1;
        #5;

        // Apply compressed indices pattern
        enable = 1;
        indices[0][0] = 2'd1; // Expected: 3
        indices[0][1] = 2'd2; // Expected: -5
        indices[1][0] = 2'd3; // Expected: 12
        indices[3][3] = 2'd1; // Expected: 3

        #3.33; // Wait 1 clock cycle

        if (weight_out[0][0] === 8'sd3  && 
            weight_out[0][1] === -8'sd5 && 
            weight_out[1][0] === 8'sd12 && 
            weight_out[3][3] === 8'sd3) begin
            $display("[PASS] Weight decompression palette mapping");
        end else begin
            $display("[FAIL] Decompression error: [0][0]=%0d, [0][1]=%0d", weight_out[0][0], weight_out[0][1]);
        end

        $finish;
    end

endmodule
