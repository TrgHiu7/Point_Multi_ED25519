`timescale 1ns / 1ps

module point_multi_core(
    input  wire           clk,
    input  wire           rst,
    input  wire           start,
    input  wire           valid,
    input  wire [255:0] k,
    input  wire [255:0] px,
    input  wire [255:0] py,
    output reg  [255:0] qx,
    output reg  [255:0] qy,
    output reg            done,
    output reg            ready
);

    localparam
        IDLE          = 4'd0,
        CALC_P_START  = 4'd1,
        CALC_P_WAIT   = 4'd2,
        CALC_Q_START  = 4'd3,
        CALC_Q_WAIT   = 4'd4,
        INV_Z_START   = 4'd5,
        INV_Z_WAIT    = 4'd6,
        CALC_QX_START = 4'd7,
        CALC_QX_WAIT  = 4'd8,
        CALC_QY_START = 4'd9,
        CALC_QY_WAIT  = 4'd10,
        DONE_ST       = 4'd11;

    reg [3:0] state;

    reg [255:0] Z_qx, Z_qy;

    reg rst_SMSM;
    reg start_SMSM;
    reg [255:0] pt;

    wire SMSM_done;
    wire [255:0] result_x, result_y, result_z, result_t;

    wire rst_alu;
    wire start_alu;
    wire alu_done;
    wire op_alu;
    wire [255:0] qx_alu, qy_alu, qz_alu, qt_alu;
    wire [255:0] px_alu, py_alu, pz_alu, pt_alu;

    reg rst_mul;
    reg [255:0] X, Y;
    wire [255:0] Z;
    wire mul_done;
    reg start_mul;

    reg rst_inv;
    reg [255:0] a;
    wire [255:0] a_inv;
    reg start_inv;
    wire inv_done;

    wire inputs_valid;
    wire fire;
    
    assign inputs_valid =
           (k  != 0) &&
           (px != 0) &&
           (py != 0);
    
    assign fire = start & valid & ready;

    Scalar_multi_SM SMSM (
        .clk(clk),
        .rst(rst_SMSM),
        .start(start_SMSM),
        .k(k),
        .px(px),
        .py(py),
        .pz(256'h1),
        .pt(pt),
        .done(SMSM_done),
        .rst_alu(rst_alu),
        .start_alu(start_alu),
        .alu_done(alu_done),
        .op_alu(op_alu),
        .qx_alu(qx_alu),
        .qy_alu(qy_alu),
        .qz_alu(qz_alu),
        .qt_alu(qt_alu),
        .px_alu(px_alu),
        .py_alu(py_alu),
        .pz_alu(pz_alu),
        .pt_alu(pt_alu),
        .result_x(result_x),
        .result_y(result_y),
        .result_z(result_z),
        .result_t(result_t)
    );

    ALU_UNIT #(
        .DEPTH(32),
        .REG_BANK(5)
    ) alu_unit (
        .clk(clk),
        .rst(rst_alu),
        .start(start_alu),
        .op(op_alu),
        .px(px_alu),
        .py(py_alu),
        .pz(pz_alu),
        .pt(pt_alu),
        .qx(qx_alu),
        .qy(qy_alu),
        .qz(qz_alu),
        .qt(qt_alu),
        .done(alu_done)
    );

    Interleaved_Modular_Multi multi_unit (
        .clk(clk),
        .reset(rst_mul),
        .start(start_mul),
        .X(X),
        .Y(Y),
        .Z(Z),
        .done(mul_done)
    );

    invert  inv_unit (
        .clk(clk),
        .rst(rst_inv),
        .start(start_inv),
        .a(a),
        .done(inv_done),
        .result(a_inv)
    );

    // FSM state
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (fire)
                        state <= CALC_P_START;
                    else
                        state <= IDLE;
                end

                CALC_P_START:
                    state <= CALC_P_WAIT;

                CALC_P_WAIT:
                    if (mul_done) state <= CALC_Q_START;

                CALC_Q_START:
                    state <= CALC_Q_WAIT;

                CALC_Q_WAIT:
                    if (SMSM_done) state <= INV_Z_START;

                INV_Z_START:
                    state <= INV_Z_WAIT;

                INV_Z_WAIT:
                    if (inv_done) state <= CALC_QX_START;

                CALC_QX_START:
                    state <= CALC_QX_WAIT;

                CALC_QX_WAIT:
                    if (mul_done) state <= CALC_QY_START;

                CALC_QY_START:
                    state <= CALC_QY_WAIT;

                CALC_QY_WAIT:
                    if (mul_done) state <= DONE_ST;

                DONE_ST:
                    state <= IDLE;

                default:
                    state <= IDLE;
            endcase
        end
    end

    // Outputs / control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rst_SMSM   <= 1'b1;
            rst_mul    <= 1'b1;
            rst_inv    <= 1'b1;
            start_mul  <= 1'b0;
            start_SMSM <= 1'b0;
            start_inv  <= 1'b0;
            X          <= 0;
            Y          <= 0;
            pt         <= 0;
            a          <= 0;
            done       <= 1'b0;
            ready      <= 1'b0;
            qx         <= 0;
            qy         <= 0;
            Z_qx       <= 0;
            Z_qy       <= 0;
        end else begin
            // mặc định mỗi chu kỳ
            start_mul  <= 1'b0;
            start_SMSM <= 1'b0;
            start_inv  <= 1'b0;
            rst_SMSM   <= 1'b0;
            rst_mul    <= 1'b0;
            rst_inv    <= 1'b0;
            done       <= 1'b0;

            case (state)
                IDLE: begin
                    rst_SMSM <= 1'b1;
                    rst_mul  <= 1'b1;
                    rst_inv  <= 1'b1;
                
                    if (inputs_valid)
                        ready <= 1'b1;
                    else
                        ready <= 1'b0;
                end

                CALC_P_START: begin
                    ready     <= 1'b0;
                    start_mul <= 1'b1;
                    X         <= px;
                    Y         <= py;
                end

                CALC_P_WAIT: begin
                    ready <= 1'b0;
                    if (mul_done) begin
                        pt <= Z;
                    end
                end

                CALC_Q_START: begin
                    ready      <= 1'b0;
                    start_SMSM <= 1'b1;
                end

                CALC_Q_WAIT: begin
                    ready <= 1'b0;
                end

                INV_Z_START: begin
                    ready     <= 1'b0;
                    start_inv <= 1'b1;
                    a         <= result_z;
                end

                INV_Z_WAIT: begin
                    ready <= 1'b0;
                end

                CALC_QX_START: begin
                    ready     <= 1'b0;
                    start_mul <= 1'b1;
                    X         <= result_x;
                    Y         <= a_inv;
                end

                CALC_QX_WAIT: begin
                    ready <= 1'b0;
                    if (mul_done) begin
                        Z_qx <= Z;
                    end
                end

                CALC_QY_START: begin
                    ready     <= 1'b0;
                    start_mul <= 1'b1;
                    X         <= result_y;
                    Y         <= a_inv;
                end

                CALC_QY_WAIT: begin
                    ready <= 1'b0;
                    if (mul_done) begin
                        Z_qy <= Z;
                    end
                end

                DONE_ST: begin
                    ready <= 1'b0;
                    done  <= 1'b1;
                    qx    <= Z_qx;
                    qy    <= Z_qy;
                end

                default: begin
                    ready <= 1'b0;
                end
            endcase
        end
    end

endmodule