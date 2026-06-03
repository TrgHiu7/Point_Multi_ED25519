`timescale 1ns / 1ps

module modular_adder (
    input  wire [255:0] A,
    input  wire [255:0] B,
    input  wire [255:0] P,
    output wire [255:0] result
);

    // ----- CPA1: A + B -----
    wire [255:0] sum_ab;
    assign sum_ab = A + B;

    // ----- NEG(P): -P = ~P + 1 -----
    wire [255:0] negP;
    assign negP = ~P + 1'b1;

    // ----- CSA: A + B + (-P) -----
    wire [255:0] csa_sum;
    wire [255:0] csa_carry;

    CSA  u_csa (
        .in1(A),
        .in2(B),
        .in3(negP),
        .sum(csa_sum),
        .carry(csa_carry)
    );

    // ----- CPA2: sum + carry -----
    wire [255:0] reduced;
    wire             cout;

    CPA  u_cpa (
        .sum_in(csa_sum),
        .carry_in(csa_carry),
        .result(reduced),
        .cout(cout)
    );

    // ----- MUX chọn kết quả cuối -----
    assign result = cout ? reduced : sum_ab;

endmodule
