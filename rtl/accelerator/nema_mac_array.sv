`timescale 1ns/1ps

module nema_mac_array #(
    parameter int N = 4,             // Set to 4 for fast verification/FPGA, 16 for final ASIC signoff
    parameter int DATA_WIDTH = 8,    // INT8 inputs and weights
    parameter int ACCUM_WIDTH = 32   // 32-bit accumulators to prevent overflow
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic clear_acc,
    input  logic signed [DATA_WIDTH-1:0]  act_in[N],
    input  logic signed [DATA_WIDTH-1:0]  weight[N][N],
    output logic signed [ACCUM_WIDTH-1:0] accum_out[N]
);

    // Internal accumulator registers for each column
    logic signed [ACCUM_WIDTH-1:0] acc_reg[N];

    // Array Compute Engine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int col = 0; col < N; col++) begin
                acc_reg[col] <= '0;
            end
        end else if (enable) begin
            for (int col = 0; col < N; col++) begin
                logic signed [ACCUM_WIDTH-1:0] col_sum;
                col_sum = clear_acc ? '0 : acc_reg[col];

                // Perform dot-product accumulation across row inputs for column 'col'
                for (int row = 0; row < N; row++) begin
                    col_sum = col_sum + (ACCUM_WIDTH'(act_in[row]) * ACCUM_WIDTH'(weight[row][col]));
                end

                acc_reg[col] <= col_sum;
            end
        end
    end

    // Drive outputs continuously
    always_comb begin
        for (int col = 0; col < N; col++) begin
            accum_out[col] = acc_reg[col];
        end
    end

endmodule
