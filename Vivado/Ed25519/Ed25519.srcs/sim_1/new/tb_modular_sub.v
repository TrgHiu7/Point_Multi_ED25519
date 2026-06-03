`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/05/2025 12:08:43 PM
// Design Name: 
// Module Name: tb_modular_sub
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_modular_sub();
parameter WIDTH = 256;

    // Đếm số test
    integer num_passed = 0;
    integer num_total  = 0;

    // Inputs
    reg  [WIDTH-1:0] A, B, P;

    // Output từ DUT
    wire [WIDTH-1:0] result;

    // Reference result từ mô hình hành vi (behavioral)
    reg  [WIDTH-1:0] ref_result;

    // Instantiate DUT
    modular_sub #(WIDTH) dut (
        .A(A),
        .B(B),
        .P(P),
        .result(result)
    );

    // Mô hình hành vi tham chiếu
    function [WIDTH-1:0] mod_sub_ref;
        input [WIDTH-1:0] a, b, p;
        reg [WIDTH:0] diff;
        begin
            if (a >= b)
                diff = a - b;
            else
                diff = a + p - b;
            mod_sub_ref = diff[WIDTH-1:0];
        end
    endfunction

    // Một testcase đơn
    task run_case;
        input [WIDTH-1:0] a, b, p;
        begin
            A = a;
            B = b;
            P = p;
            ref_result = mod_sub_ref(a, b, p);
            #10;
            num_total = num_total + 1;

            $display("==== Testcase %0d ====", num_total);
            $display("A         = %h", A);
            $display("B         = %h", B);
            $display("P         = %h", P);
            $display("Result    = %h", result);
            $display("Expected  = %h", ref_result);

            if (result === ref_result) begin
                $display("✅ PASS\n");
                num_passed = num_passed + 1;
            end else begin
                $display("❌ FAIL\n");
            end
        end
    endtask

    initial begin
        $display("=== Modular Subtractor Self-Checking Testbench ===");

        // Prime: 2^255 - 19
        P = 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED;

        // Testcases
        run_case(256'd20, 256'd10, P);  // Expect: 10
        run_case(256'd10, 256'd20, P);  // Expect: P - 10
        run_case(P - 5, 256'd5, P);     // Expect: P - 10
        run_case(256'd0, 256'd0, P);    // Expect: 0
        run_case(P - 1, P - 1, P);      // Expect: 0

        // Overflow test
        run_case({256{1'b1}}, {256{1'b1}}, P); // Expect: 0
        run_case({256{1'b1}}, 256'd0, P);      // Expect: all-1s % P

        // Summary
        $display("============================================");
        $display("Total tests: %0d, Passed: %0d, Failed: %0d", 
                 num_total, num_passed, num_total - num_passed);
        $display("============================================");

        $finish;
    end

endmodule