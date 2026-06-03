`timescale 1ns / 1ps

module Shift_mod #(parameter N = 260)(
    input  wire [N-1:0] in,
    output wire [N-1:0] out
);
    wire [257:0] shifted = {in[254:0], 3'b000};  // (S % 2^255) << 3
    assign out = {{(N-258){1'b0}}, shifted};     // zero-extend lên 260 bit
    
endmodule

