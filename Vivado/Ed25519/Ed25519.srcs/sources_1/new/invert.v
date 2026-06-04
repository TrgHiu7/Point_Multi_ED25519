`timescale 1ns / 1ps

module invert(
    input  wire           clk,
    input  wire           rst,
    input  wire           start,
    input  wire [255:0] a,
    output wire [255:0] result,
    output reg            done
);
    localparam
        IDLE              = 6'd0,
        CALC_A2_START     = 6'd1,
        CALC_A2_WAIT      = 6'd2,
        CALC_A4_START     = 6'd3,
        CALC_A4_WAIT      = 6'd4,
        CALC_A8_START     = 6'd5,
        CALC_A8_WAIT      = 6'd6,
        CALC_A9_START     = 6'd7,
        CALC_A9_WAIT      = 6'd8,
        CALC_A11_START    = 6'd9,
        CALC_A11_WAIT     = 6'd10,
        CALC_A22_START    = 6'd11,
        CALC_A22_WAIT     = 6'd12,
        CALC_2_5_1_START  = 6'd13,
        CALC_2_5_1_WAIT   = 6'd14,
        CALC_2_10_1_START = 6'd15,
        CALC_2_10_1_WAIT  = 6'd16,
        CALC_2_20_1_START = 6'd17,
        CALC_2_20_1_WAIT  = 6'd18,
        CALC_2_40_1_START = 6'd19,
        CALC_2_40_1_WAIT  = 6'd20,
        CALC_2_50_1_START = 6'd21,
        CALC_2_50_1_WAIT  = 6'd22,
        CALC_2_100_1_START= 6'd23,
        CALC_2_100_1_WAIT = 6'd24,
        CALC_2_200_1_START= 6'd25,
        CALC_2_200_1_WAIT = 6'd26,
        CALC_2_250_1_START= 6'd27,
        CALC_2_250_1_WAIT = 6'd28,
        INV_A_START       = 6'd29,
        INV_A_WAIT        = 6'd30,
        DONE_ST           = 6'd31;

    reg [5:0] state, next_state;
    reg  [255:0] op_a, op_b;
    reg            mul_start;
    wire [255:0] mul_result;
    wire           mul_done;

    Interleaved_Modular_Multi multiplier (
        .clk(clk),
        .reset(rst),
        .start(mul_start),
        .X(op_a),
        .Y(op_b),
        .Z(mul_result),
        .done(mul_done)
    );

    reg [255:0] r_a2, r_a4, r_a8, r_a9, r_a11, r_a22;
    reg [255:0] r_a2_5_1;
    reg [255:0] r_a2_10_1;
    reg [255:0] r_a2_20_1;
    reg [255:0] r_a2_40_1;
    reg [255:0] r_a2_50_1;
    reg [255:0] r_a2_100_1;
    reg [255:0] r_a2_200_1;
    reg [255:0] r_a2_250_1;
    reg [255:0] r_t;
    reg [6:0] counter;
    reg [255:0] result_reg;

    assign result = result_reg;

    // state register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:               if (start)    next_state = CALC_A2_START;
            CALC_A2_START:                      next_state = CALC_A2_WAIT;
            CALC_A2_WAIT:      if (mul_done)  next_state = CALC_A4_START;
            CALC_A4_START:                      next_state = CALC_A4_WAIT;
            CALC_A4_WAIT:      if (mul_done)  next_state = CALC_A8_START;
            CALC_A8_START:                      next_state = CALC_A8_WAIT;
            CALC_A8_WAIT:      if (mul_done)  next_state = CALC_A9_START;
            CALC_A9_START:                      next_state = CALC_A9_WAIT;
            CALC_A9_WAIT:      if (mul_done)  next_state = CALC_A11_START;
            CALC_A11_START:                     next_state = CALC_A11_WAIT;
            CALC_A11_WAIT:     if (mul_done)  next_state = CALC_A22_START;
            CALC_A22_START:                     next_state = CALC_A22_WAIT;
            CALC_A22_WAIT:     if (mul_done)  next_state = CALC_2_5_1_START;
            CALC_2_5_1_START:                   next_state = CALC_2_5_1_WAIT;
            CALC_2_5_1_WAIT:   if (mul_done)  next_state = CALC_2_10_1_START;
            CALC_2_10_1_START:                  next_state = CALC_2_10_1_WAIT;
            CALC_2_10_1_WAIT: begin
                if (mul_done) begin
                    if (counter < 5)
                        next_state = CALC_2_10_1_START;
                    else
                        next_state = CALC_2_20_1_START;
                end
            end
            CALC_2_20_1_START:                  next_state = CALC_2_20_1_WAIT;
            CALC_2_20_1_WAIT: begin
                if (mul_done) begin
                    if (counter < 10)
                        next_state = CALC_2_20_1_START;
                    else
                        next_state = CALC_2_40_1_START;
                end
            end
            CALC_2_40_1_START:                  next_state = CALC_2_40_1_WAIT;
            CALC_2_40_1_WAIT: begin
                // ĐÃ SỬA LỖI TẠI ĐÂY: Xoá lệnh gán Sequential, chỉ giữ lại Next State logic
                if (mul_done) begin
                    if (counter < 20)
                        next_state = CALC_2_40_1_START;
                    else
                        next_state = CALC_2_50_1_START;
                end
            end
            CALC_2_50_1_START:                  next_state = CALC_2_50_1_WAIT;
            CALC_2_50_1_WAIT: begin
                if (mul_done) begin
                    if (counter < 10)
                        next_state = CALC_2_50_1_START;
                    else
                        next_state = CALC_2_100_1_START;
                end
            end
            CALC_2_100_1_START:                 next_state = CALC_2_100_1_WAIT;
            CALC_2_100_1_WAIT: begin
                if (mul_done) begin
                    if (counter < 50)
                        next_state = CALC_2_100_1_START;
                    else
                        next_state = CALC_2_200_1_START;
                end
            end
            CALC_2_200_1_START:                 next_state = CALC_2_200_1_WAIT;
            CALC_2_200_1_WAIT: begin
                if (mul_done) begin
                    if (counter < 100)
                        next_state = CALC_2_200_1_START;
                    else
                        next_state = CALC_2_250_1_START;
                end
            end
            CALC_2_250_1_START:                 next_state = CALC_2_250_1_WAIT;
            CALC_2_250_1_WAIT: begin
                if (mul_done) begin
                    if (counter < 50)
                        next_state = CALC_2_250_1_START;
                    else
                        next_state = INV_A_START;
                end
            end
            INV_A_START:                        next_state = INV_A_WAIT;
            INV_A_WAIT: begin
                if (mul_done) begin
                    if (counter < 5)
                        next_state = INV_A_START;
                    else
                        next_state = DONE_ST;
                end
            end
            DONE_ST:                            next_state = IDLE;
            default:                            next_state = IDLE;
        endcase
    end

    // datapath / outputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mul_start   <= 1'b0;
            done        <= 1'b0;
            op_a        <= 0;
            op_b        <= 0;
            r_a2        <= 0;
            r_a4        <= 0;
            r_a8        <= 0;
            r_a9        <= 0;
            r_a11       <= 0;
            r_a22       <= 0;
            r_a2_5_1    <= 0;
            r_a2_10_1   <= 0;
            r_a2_20_1   <= 0;
            r_a2_40_1   <= 0;
            r_a2_50_1   <= 0;
            r_a2_100_1  <= 0;
            r_a2_200_1  <= 0;
            r_a2_250_1  <= 0;
            r_t         <= 0;
            counter     <= 7'd0;
            result_reg  <= 0;
        end else begin
            mul_start <= 1'b0;
            done      <= 1'b0;
            case (state)
                IDLE: begin
                    counter <= 7'd0;
                end
                CALC_A2_START: begin
                    mul_start <= 1'b1;
                    op_a <= a;
                    op_b <= a;
                end
                CALC_A2_WAIT: begin
                    if (mul_done) r_a2 <= mul_result;
                end
                CALC_A4_START: begin
                    mul_start <= 1'b1;
                    op_a <= r_a2;
                    op_b <= r_a2;
                end
                CALC_A4_WAIT: begin
                    if (mul_done) r_a4 <= mul_result;
                end
                CALC_A8_START: begin
                    mul_start <= 1'b1;
                    op_a <= r_a4;
                    op_b <= r_a4;
                end
                CALC_A8_WAIT: begin
                    if (mul_done) r_a8 <= mul_result;
                end
                CALC_A9_START: begin
                    mul_start <= 1'b1;
                    op_a <= r_a8;
                    op_b <= a;
                end
                CALC_A9_WAIT: begin
                    if (mul_done) r_a9 <= mul_result;
                end
                CALC_A11_START: begin
                    mul_start <= 1'b1;
                    op_a <= r_a9;
                    op_b <= r_a2;
                end
                CALC_A11_WAIT: begin
                    if (mul_done) r_a11 <= mul_result;
                end
                CALC_A22_START: begin
                    mul_start <= 1'b1;
                    op_a <= r_a11;
                    op_b <= r_a11;
                end
                CALC_A22_WAIT: begin
                    if (mul_done) r_a22 <= mul_result;
                end
                CALC_2_5_1_START: begin
                    mul_start <= 1'b1;
                    op_a <= r_a22;
                    op_b <= r_a9;
                end
                CALC_2_5_1_WAIT: begin
                    if (mul_done) begin
                        r_t      <= mul_result;
                        r_a2_5_1 <= mul_result;
                        counter  <= 7'd0;
                    end
                end
                CALC_2_10_1_START: begin
                    mul_start <= 1'b1;
                    if (counter < 5) begin
                        op_a <= r_t;
                        op_b <= r_t;
                    end else begin
                        op_a <= r_t;
                        op_b <= r_a2_5_1;
                    end
                end
                CALC_2_10_1_WAIT: begin
                    if (mul_done) begin
                        r_t <= mul_result;
                        if (counter < 5) begin
                            counter <= counter + 1'b1;
                        end else begin
                            r_a2_10_1 <= mul_result;
                            counter   <= 7'd0;
                        end
                    end
                end
                CALC_2_20_1_START: begin
                    mul_start <= 1'b1;
                    if (counter < 10) begin
                        op_a <= r_t;
                        op_b <= r_t;
                    end else begin
                        op_a <= r_t;
                        op_b <= r_a2_10_1;
                    end
                end
                CALC_2_20_1_WAIT: begin
                    if (mul_done) begin
                        r_t <= mul_result;
                        if (counter < 10) begin
                            counter <= counter + 1'b1;
                        end else begin
                            r_a2_20_1 <= mul_result;
                            counter   <= 7'd0;
                        end
                    end
                end
                CALC_2_40_1_START: begin
                    mul_start <= 1'b1;
                    if (counter < 20) begin
                        op_a <= r_t;
                        op_b <= r_t;
                    end else begin
                        op_a <= r_t;
                        op_b <= r_a2_20_1;
                    end
                end
                CALC_2_40_1_WAIT: begin
                    if (mul_done) begin
                        r_t <= mul_result;
                        if (counter < 20)
                            counter <= counter + 1'b1;
                        else
                            counter <= 7'd0;
                    end
                end
                CALC_2_50_1_START: begin
                    mul_start <= 1'b1;
                    if (counter < 10) begin
                        op_a <= r_t;
                        op_b <= r_t;
                    end else begin
                        op_a <= r_t;
                        op_b <= r_a2_10_1;
                    end
                end
                CALC_2_50_1_WAIT: begin
                    if (mul_done) begin
                        r_t <= mul_result;
                        if (counter < 10) begin
                            counter <= counter + 1'b1;
                        end else begin
                            r_a2_50_1 <= mul_result;
                            counter   <= 7'd0;
                        end
                    end
                end
                CALC_2_100_1_START: begin
                    mul_start <= 1'b1;
                    if (counter < 50) begin
                        op_a <= r_t;
                        op_b <= r_t;
                    end else begin
                        op_a <= r_t;
                        op_b <= r_a2_50_1;
                    end
                end
                CALC_2_100_1_WAIT: begin
                    if (mul_done) begin
                        r_t <= mul_result;
                        if (counter < 50) begin
                            counter <= counter + 1'b1;
                        end else begin
                            r_a2_100_1 <= mul_result;
                            counter    <= 7'd0;
                        end
                    end
                end
                CALC_2_200_1_START: begin
                    mul_start <= 1'b1;
                    if (counter < 100) begin
                        op_a <= r_t;
                        op_b <= r_t;
                    end else begin
                        op_a <= r_t;
                        op_b <= r_a2_100_1;
                    end
                end
                CALC_2_200_1_WAIT: begin
                    if (mul_done) begin
                        r_t <= mul_result;
                        if (counter < 100) begin
                            counter <= counter + 1'b1;
                        end else begin
                            counter <= 7'd0;
                        end
                    end
                end
                CALC_2_250_1_START: begin
                    mul_start <= 1'b1;
                    if (counter < 50) begin
                        op_a <= r_t;
                        op_b <= r_t;
                    end else begin
                        op_a <= r_t;
                        op_b <= r_a2_50_1;
                    end
                end
                CALC_2_250_1_WAIT: begin
                    if (mul_done) begin
                        r_t <= mul_result;
                        if (counter < 50) begin
                            counter <= counter + 1'b1;
                        end else begin
                            r_a2_250_1 <= mul_result;
                            counter    <= 7'd0;
                        end
                    end
                end
                INV_A_START: begin
                    mul_start <= 1'b1;
                    if (counter < 5) begin
                        op_a <= r_t;
                        op_b <= r_t;
                    end else begin
                        op_a <= r_t;
                        op_b <= r_a11;
                    end
                end
                INV_A_WAIT: begin
                    if (mul_done) begin
                        r_t <= mul_result;
                        if (counter < 5) begin
                            counter <= counter + 1'b1;
                        end else begin
                            result_reg <= mul_result;
                        end
                    end
                end
                DONE_ST: begin
                    done <= 1'b1;
                end
                default: begin
                end
            endcase
        end
    end

endmodule