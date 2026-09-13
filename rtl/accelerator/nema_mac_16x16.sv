module nema_mac_16x16 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        enable,
    input  logic        clear_acc,
    input  logic signed [7:0]  act_in[16],
    input  logic signed [7:0]  weight[16][16],
    output logic signed [31:0] accum_out[16]
);

    logic signed [31:0] psum[16][16];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 16; i++) begin
                accum_out[i] <= 32'sd0;
                for (int j = 0; j < 16; j++) begin
                    psum[i][j] <= 32'sd0;
                end
            end
        end else if (enable) begin
            for (int col = 0; col < 16; col++) begin
                automatic logic signed [31:0] col_sum = 32'sd0;
                for (int row = 0; row < 16; row++) begin
                    col_sum = col_sum + (act_in[row] * weight[row][col]);
                end
                
                if (clear_acc) begin
                    accum_out[col] <= col_sum;
                end else begin
                    accum_out[col] <= accum_out[col] + col_sum;
                end
            end
        end
    end

endmodule
