`timescale 1ns / 1ps


module CSA (
    input  wire [255:0] in1,
    input  wire [255:0] in2,
    input  wire [255:0] in3,
    output wire [255:0] sum,
    output wire [255:0] carry
);
    wire [255:0] majority = (in1 & in2) | (in2 & in3) | (in1 & in3);
    assign sum   = in1 ^ in2 ^ in3;
    assign carry = majority << 1;
endmodule
