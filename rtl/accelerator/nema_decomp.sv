`timescale 1ns/1ps

module nema_decomp #(
    parameter int N = 4
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic signed [7:0] palette[4],       // 4-entry INT8 weight lookup table
    input  logic [1:0]        indices[N][N],     // 2-bit packed weight indices
    output logic signed [7:0] weight_out[N][N]   // Reconstructed 8-bit weight matrix
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int r = 0; r < N; r++) begin
                for (int c = 0; c < N; c++) begin
                    weight_out[r][c] <= 8'sd0;
                end
            end
        end else if (enable) begin
            for (int r = 0; r < N; r++) begin
                for (int c = 0; c < N; c++) begin
                    // Map 2-bit index to 8-bit palette weight value
                    weight_out[r][c] <= palette[indices[r][c]];
                end
            end
        end
    end

endmodule
