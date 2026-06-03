`timescale 1ns / 1ps


module modular_sub(
    input  wire [255:0] A,
    input  wire [255:0] B,
    input  wire [255:0] P,
    output wire [255:0] result
);
    wire [255:0] B_inv;
    assign B_inv = ~B;
    wire [255:0] s1, c1, s2, c2;
    wire [255:0] res1, res2;
    wire cout1, cout2;

    // CSA1: A + (~B)
    CSA csa1 (
        .in1(A), .in2(B_inv), .in3({{(256){1'b0}}}),
        .sum(s1), .carry(c1)
    );

    // CPA1: A - B 
    CPA_sub cpa1 (
        .sum_in(s1), .carry_in(c1), .C_in({{(255){1'b0}}, 1'b1}),
        .result(res1), .cout(cout1)
    );

    // CSA2: A + (~B) + P
    CSA csa2 (
        .in1(A), .in2(B_inv), .in3(P),
        .sum(s2), .carry(c2)
    );

    // CPA2: A - B + P
    CPA_sub cpa2 (
        .sum_in(s2), .carry_in(c2), .C_in({{(255){1'b0}}, 1'b1}),
        .result(res2), .cout(cout2)
    );

    // MUX
    assign result = cout1 ? res1 : res2;
endmodule

