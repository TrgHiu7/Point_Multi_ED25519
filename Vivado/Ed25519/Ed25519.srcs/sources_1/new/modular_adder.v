`timescale 1ns / 1ps

module modular_adder #(parameter WIDTH = 256)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire [WIDTH-1:0] P,
    output wire [WIDTH-1:0] result
);

    // ----- CPA1: A + B -----
    wire [WIDTH-1:0] sum_ab;
    assign sum_ab = A + B;

    // ----- NEG(P): -P = ~P + 1 -----
    wire [WIDTH-1:0] negP;
    assign negP = ~P + 1'b1;

    // ----- CSA: A + B + (-P) -----
    wire [WIDTH-1:0] csa_sum;
    wire [WIDTH-1:0] csa_carry;

    CSA #(WIDTH) u_csa (
        .in1(A),
        .in2(B),
        .in3(negP),
        .sum(csa_sum),
        .carry(csa_carry)
    );

    // ----- CPA2: sum + carry -----
    wire [WIDTH-1:0] reduced;
    wire             cout;

    CPA #(WIDTH) u_cpa (
        .sum_in(csa_sum),
        .carry_in(csa_carry),
        .result(reduced),
        .cout(cout)
    );

    // ----- MUX chọn kết quả cuối -----
    assign result = cout ? reduced : sum_ab;

endmodule
