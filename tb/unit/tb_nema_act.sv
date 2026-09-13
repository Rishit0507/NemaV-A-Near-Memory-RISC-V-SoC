`timescale 1ns/1ps

module tb_nema_act;

    parameter int N = 4;

    logic signed [31:0] accum_in[N];
    logic [4:0]         shift_amt;
    logic signed [7:0]  zero_point;
    logic signed [7:0]  act_out[N];

    nema_act #(.N(N)) dut (.*);

    initial begin
        // Test 1: Standard INT8 Scaling (100 >> 2 = 25)
        accum_in[0] = 32'sd100;
        accum_in[1] = 32'sd200;
        accum_in[2] = -32'sd80;
        accum_in[3] = 32'sd0;
        shift_amt  = 5'd2;
        zero_point = 8'sd0;
        #10;
        if (act_out[0] === 8'sd25 && act_out[1] === 8'sd50 && act_out[2] === -8'sd20) begin
            $display("[PASS] Standard INT8 scaling");
        end else begin
            $display("[FAIL] INT8 scaling mismatch: col0=%0d", act_out[0]);
        end

        // Test 2: Upper Saturation Clamp (1000 >> 1 = 500 -> Clamp to 127)
        accum_in[0] = 32'sd1000;
        shift_amt  = 5'd1;
        #10;
        if (act_out[0] === 8'sd127) begin
            $display("[PASS] Upper saturation clamp (500 -> 127)");
        end else begin
            $display("[FAIL] Upper saturation failed: %0d", act_out[0]);
        end

        // Test 3: Lower Saturation Clamp (-1000 >> 1 = -500 -> Clamp to -128)
        accum_in[0] = -32'sd1000;
        shift_amt  = 5'd1;
        #10;
        if (act_out[0] === -8'sd128) begin
            $display("[PASS] Lower saturation clamp (-500 -> -128)");
        end else begin
            $display("[FAIL] Lower saturation failed: %0d", act_out[0]);
        end

        $finish;
    end

endmodule
