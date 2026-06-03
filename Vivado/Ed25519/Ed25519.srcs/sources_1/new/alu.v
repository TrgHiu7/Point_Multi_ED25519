`timescale 1ns / 1ps

module alu #(
    parameter WID = 256
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              start,
    input  wire [1:0]        op,       // 00: ADD, 01: SUB, 10: MUL
    input  wire [WID-1:0]    a,
    input  wire [WID-1:0]    b,
    output reg  [WID-1:0]    result,
    output reg               done
);
    localparam [WID-1:0] P = 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED;
    // Internal wires for add/sub
    wire [WID-1:0] result_add, result_sub;
    
    // Instantiate modular_add (combinational)
    modular_adder #(.WIDTH(WID)) mod_add (
        .A(a),
        .B(b),
        .P(P),
        .result(result_add)
    );

    // Instantiate modular_sub (combinational)
    modular_sub #(.WIDTH(WID)) mod_sub (
        .A(a),
        .B(b),
        .P(P),
        .result(result_sub)
    );
    
    // Interleaved multiplier signals
    reg                start_mul;
    wire               done_mul;
    wire [WID-1:0]     result_mul;

    Interleaved_Modular_Multi mod_mul (
        .clk(clk),
        .reset(rst),
        .start(start_mul),
        .X(a),
        .Y(b),
        .Z(result_mul),
        .done(done_mul)
    );
    
    localparam IDLE = 2'd0,
               WAIT_MUL = 2'd1,
               DONE = 2'd2;

    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            done      <= 0;
            start_mul <= 0;
            result    <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done      <= 0;
                    start_mul <= 0;

                    if (start) begin
                        case (op)
                            2'b00: begin
                                result <= result_add;
                                done   <= 1;
                                state  <= DONE;
                            end
                            2'b01: begin
                                result <= result_sub;
                                done   <= 1;
                                state  <= DONE;
                            end
                            2'b10: begin
                                start_mul <= 1;
                                state     <= WAIT_MUL;
                            end
                        endcase
                    end
                end

                WAIT_MUL: begin
                    start_mul <= 0;
                    if (done_mul) begin
                        result <= result_mul;
                        done   <= 1;
                        state  <= DONE;
                    end
                end

                DONE: begin
                    done   <= 0;
                    if (!start) state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
