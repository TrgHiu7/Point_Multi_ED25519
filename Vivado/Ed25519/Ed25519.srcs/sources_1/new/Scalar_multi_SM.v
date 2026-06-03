//`timescale 1ns / 1ps

//module Scalar_multi_SM #(
//    parameter WID = 256
//)(
//    input wire clk,
//    input wire rst,
//    input wire start,
//    input wire [WID-1:0] k,
//    input wire [WID-1:0] px, py, pz, pt,   // P(X, Y, Z,T)
//    output reg done,

//    // Control to ALU
//    output reg  rst_alu,
//    output reg  start_alu,
//    input  wire alu_done,
//    output reg  op_alu,
//    input  wire [WID-1:0] qx_alu, qy_alu, qz_alu, qt_alu,
//    output reg [WID-1:0] px_alu, py_alu, pz_alu, pt_alu,
   
//    output reg [WID-1:0] result_x, result_y, result_z, result_t
//);

//    localparam 
//        IDLE       = 4'd0,
//        LOAD       = 4'd1,
//        INIT       = 4'd2,
//        LOOP_START = 4'd3,
//        SHIFT_K    = 4'd4,
//        ECPD       = 4'd5,
//        PREPARE    = 4'd6,
//        ECPA       = 4'd7,
//        DEC        = 4'd8,
//        DONE       = 4'd9;

//    reg [3:0] state;
//    reg [8:0] bit_index;
//    reg [WID-1:0] scalar_k;
//    reg [WID-1:0] qx_reg, qy_reg, qz_reg, qt_reg;
//    reg kbit;    
    
//    // FSM: state transitions
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            state <= IDLE;
//        end else begin
//            case (state)
//                IDLE:
//                    if (start) state <= LOAD;

//                LOAD:
//                    state <= INIT;

//                INIT:
//                    state <= LOOP_START;

//                LOOP_START:
//                    state <= SHIFT_K;

//                SHIFT_K:
//                    state <= ECPD;

//                ECPD:
//                    if (alu_done) begin
//                        if (kbit == 1)
//                            state <= PREPARE;
//                        else
//                            state <= DEC;
//                    end
                
//                PREPARE:
//                    state <= ECPA;
                
//                ECPA:
//                    if (alu_done)
//                        state <= DEC;

//                DEC:
//                    if (bit_index == 0)
//                        state <= DONE;
//                    else
//                        state <= SHIFT_K;

//                DONE:
//                    state <= IDLE;

//                default:
//                    state <= IDLE;
//            endcase
//        end
//    end

//    // FSM: operations
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            done <= 0;
//            bit_index <= 9'd255;
//            scalar_k <= 0;
//            rst_alu <= 1;
//            start_alu <= 0;
//            op_alu <= 1;
//            qx_reg <= 0; qy_reg <= 1; qz_reg <= 1; qt_reg <= 0;
//            px_alu <= 0; py_alu <= 0; pz_alu <= 0; pt_alu <= 0;
//        end else begin
//            start_alu <= 0;
//            case (state)
//                IDLE: begin
//                    done <= 0;
//                end
//                LOAD: begin
//                    start_alu <= 0;
//                    op_alu <= 1;
//                    rst_alu <= 1;
//                    px_alu <= px;
//                    py_alu <= py;
//                    pz_alu <= pz;
//                    pt_alu <= pt;
//                end

//                INIT: begin
//                    rst_alu <= 0;
//                    qx_reg <= 0;
//                    qy_reg <= 1;
//                    qz_reg <= 1;
//                    qt_reg <= 0;
//                end

//                LOOP_START: begin
//                    scalar_k <= k;
//                    bit_index <= 9'd255;
//                end

//                SHIFT_K: begin
//                    kbit <= scalar_k[bit_index];
//                    start_alu <= 1;
//                    op_alu <= 1;  // ECPD
//                    px_alu <= qx_reg;
//                    py_alu <= qy_reg;
//                    pz_alu <= qz_reg;
//                    pt_alu <= qt_reg;
//                end

//                ECPD: begin
//                    if (alu_done) begin
//                        start_alu <= 0;
//                        qx_reg <= qx_alu;
//                        qy_reg <= qy_alu;
//                        qz_reg <= qz_alu;
//                        qt_reg <= qt_alu;
//                    end
//                end

//                PREPARE: begin
//                    start_alu <= 1;
//                    op_alu <= 0;  // ECPA
//                    px_alu <= qx_reg;
//                    py_alu <= qy_reg;
//                    pz_alu <= qz_reg;
//                    pt_alu <= qt_reg;
//                 end    
                 
//                 ECPA: begin
//                    if (alu_done) begin
//                        start_alu <= 0;
//                        qx_reg <= qx_alu;
//                        qy_reg <= qy_alu;
//                        qz_reg <= qz_alu;
//                        qt_reg <= qt_alu;
//                    end
//                end

//                DEC: begin
//                    bit_index <= bit_index - 1;  // CHỈ GIẢM Ở ĐÂY
//                end

//                DONE: begin
//                    done <= 1;
//                    result_x <= qx_reg;
//                    result_y <= qy_reg;
//                    result_z <= qz_reg;
//                    result_t <= qt_reg;
//                end

//                default: begin
//                    done <= 0;
//                end
//            endcase
//        end
//    end

//endmodule
`timescale 1ns / 1ps

module Scalar_multi_SM(

    input  wire clk,
    input  wire rst,
    input  wire start,

    input  wire [255:0] k,

    input  wire [255:0] px,
    input  wire [255:0] py,
    input  wire [255:0] pz,
    input  wire [255:0] pt,

    output reg done,

    // ALU control
    output reg rst_alu,
    output reg start_alu,
    output reg op_alu,      // 1=Double, 0=Add

    input wire alu_done,

    input wire [255:0] qx_alu,
    input wire [255:0] qy_alu,
    input wire [255:0] qz_alu,
    input wire [255:0] qt_alu,

    output reg [255:0] px_alu,
    output reg [255:0] py_alu,
    output reg [255:0] pz_alu,
    output reg [255:0] pt_alu,

    output reg [255:0] result_x,
    output reg [255:0] result_y,
    output reg [255:0] result_z,
    output reg [255:0] result_t
);

localparam
    IDLE         = 4'd0,
    LOAD         = 4'd1,
    INIT         = 4'd2,
    DOUBLE_START = 4'd3,
    DOUBLE_WAIT  = 4'd4,
    ADD_START    = 4'd5,
    ADD_WAIT     = 4'd6,
    NEXT_BIT     = 4'd7,
    DONE_STATE   = 4'd8;

reg [3:0] state;

reg [7:0] bit_index;

reg [255:0] scalar_k;

reg [255:0] qx_reg;
reg [255:0] qy_reg;
reg [255:0] qz_reg;
reg [255:0] qt_reg;

always @(posedge clk or posedge rst) begin

    if(rst) begin

        state <= IDLE;

        done <= 0;

        rst_alu <= 1;
        start_alu <= 0;
        op_alu <= 1;

        bit_index <= 8'd255;
        scalar_k <= 0;

        qx_reg <= 0;
        qy_reg <= 1;
        qz_reg <= 1;
        qt_reg <= 0;

        px_alu <= 0;
        py_alu <= 0;
        pz_alu <= 0;
        pt_alu <= 0;

        result_x <= 0;
        result_y <= 0;
        result_z <= 0;
        result_t <= 0;

    end
    else begin

        start_alu <= 0;

        case(state)

        IDLE:
        begin
            done <= 0;

            if(start)
                state <= LOAD;
        end

        LOAD:
        begin

            scalar_k <= k;

            rst_alu <= 1;

            bit_index <= 8'd255;

            state <= INIT;
        end

        INIT:
        begin

            rst_alu <= 0;

            qx_reg <= 0;
            qy_reg <= 1;
            qz_reg <= 1;
            qt_reg <= 0;

            state <= DOUBLE_START;
        end

        DOUBLE_START:
        begin

            op_alu <= 1;

            px_alu <= qx_reg;
            py_alu <= qy_reg;
            pz_alu <= qz_reg;
            pt_alu <= qt_reg;

            start_alu <= 1;

            state <= DOUBLE_WAIT;
        end

        DOUBLE_WAIT:
        begin

            if(alu_done) begin

                qx_reg <= qx_alu;
                qy_reg <= qy_alu;
                qz_reg <= qz_alu;
                qt_reg <= qt_alu;

                if(scalar_k[bit_index])
                    state <= ADD_START;
                else
                    state <= NEXT_BIT;
            end
        end

        ADD_START:
        begin

            op_alu <= 0;

            px_alu <= qx_reg;
            py_alu <= qy_reg;
            pz_alu <= qz_reg;
            pt_alu <= qt_reg;

            start_alu <= 1;

            state <= ADD_WAIT;
        end

        ADD_WAIT:
        begin

            if(alu_done) begin

                qx_reg <= qx_alu;
                qy_reg <= qy_alu;
                qz_reg <= qz_alu;
                qt_reg <= qt_alu;

                state <= NEXT_BIT;
            end
        end

        NEXT_BIT:
        begin

            if(bit_index == 0) begin
                state <= DONE_STATE;
            end
            else begin
                bit_index <= bit_index - 1;
                state <= DOUBLE_START;
            end
        end

        DONE_STATE:
        begin

            result_x <= qx_reg;
            result_y <= qy_reg;
            result_z <= qz_reg;
            result_t <= qt_reg;

            done <= 1;

            state <= IDLE;
        end

        default:
            state <= IDLE;

        endcase
    end
end

endmodule