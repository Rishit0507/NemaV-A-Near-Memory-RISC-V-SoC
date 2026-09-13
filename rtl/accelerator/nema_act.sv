`timescale 1ns/1ps

module nema_act #(
    parameter int N = 4
)(
    input  logic signed [31:0] accum_in[N],
    input  logic [4:0]         shift_amt,
    input  logic signed [7:0]  zero_point,
    output logic signed [7:0]  act_out[N]
);

    always_comb begin
        for (int i = 0; i < N; i++) begin
            logic signed [31:0] scaled;
            logic signed [31:0] offset_val;

            // 1. Arithmetic Right Shift (Scaling)
            scaled = accum_in[i] >>> shift_amt;

            // 2. Add Zero-Point Offset
            offset_val = scaled + 32'(zero_point);

            // 3. INT8 Saturation Clamping [-128, 127]
            if (offset_val > 32'sd127)
                act_out[i] = 8'sd127;
            else if (offset_val < -32'sd128)
                act_out[i] = -8'sd128;
            else
                act_out[i] = 8'(offset_val);
        end
    end

endmodule
