`timescale 1ns / 1ps

module ECPA_SM #(parameter REG_BANK = 5)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  done,

    // Control signals to ALU
    output reg [1:0] alu_op,      // 00: ADD, 01: SUB, 10: MUL
    output reg       alu_start,
    input  wire      alu_done,

    // Register bank control
    output reg [REG_BANK-1:0] src1_sel,
    output reg [REG_BANK-1:0] src2_sel,
    output reg                we,
    output reg [2:0]          din_sel,
    output reg [REG_BANK-1:0] dst_sel
);

localparam
    IDLE      = 5'd0,
    LV1_ADD   = 5'd1,
    LV1_SUB   = 5'd2,
    LV2_ADD   = 5'd3,
    LV2_SUB   = 5'd4,
    LV3_MUL   = 5'd5,
    LV4_MUL   = 5'd6,
    LV5_MUL   = 5'd7,
    LV5_ADD   = 5'd8,
    LV5_SUB   = 5'd9,
    LV6_MUL   = 5'd10,
    LV7_MUL   = 5'd11,
    LV8_MUL   = 5'd12,
    LV9_ADD   = 5'd13,
    LV9_SUB   = 5'd14,
    MUL_X3    = 5'd15,
    MUL_Y3    = 5'd16,
    MUL_Z3    = 5'd17,
    MUL_T3    = 5'd18,
    DONE_ST   = 5'd19,
    LOAD_X1   = 5'd20,
    LOAD_Y1   = 5'd21,
    LOAD_Z1   = 5'd22,
    LOAD_T1   = 5'd23;

reg [4:0] state;

always @(posedge clk or posedge rst) begin

    if(rst) begin

        state <= IDLE;

        done <= 0;
        alu_op <= 0;
        alu_start <= 0;

        src1_sel <= 0;
        src2_sel <= 0;
        dst_sel  <= 0;

        we <= 0;
        din_sel <= 0;

    end
    else begin

        done      <= 0;
        alu_start <= 0;

        we        <= 0;
        din_sel   <= 3'b000;

        case(state)

        //--------------------------------------------------
        IDLE:
        begin
            if(start)
                state <= LOAD_X1;
        end

        //--------------------------------------------------
        LOAD_X1:
        begin
            we      <= 1;
            din_sel <= 3'b001;
            dst_sel <= 0;

            state <= LOAD_Y1;
        end

        LOAD_Y1:
        begin
            we      <= 1;
            din_sel <= 3'b010;
            dst_sel <= 1;

            state <= LOAD_Z1;
        end

        LOAD_Z1:
        begin
            we      <= 1;
            din_sel <= 3'b011;
            dst_sel <= 2;

            state <= LOAD_T1;
        end

        LOAD_T1:
        begin
            we      <= 1;
            din_sel <= 3'b100;
            dst_sel <= 14;

            state <= LV1_ADD;
        end

        //--------------------------------------------------
        LV1_ADD:
        begin
            alu_op    <= 2'b00;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 1;
            src2_sel  <= 0;
            dst_sel   <= 16;

            if(alu_done)
                state <= LV1_SUB;
        end

        LV1_SUB:
        begin
            alu_op    <= 2'b01;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 1;
            src2_sel  <= 0;
            dst_sel   <= 17;

            if(alu_done)
                state <= LV2_ADD;
        end

        LV2_ADD:
        begin
            alu_op    <= 2'b00;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 4;
            src2_sel  <= 3;
            dst_sel   <= 18;

            if(alu_done)
                state <= LV2_SUB;
        end

        LV2_SUB:
        begin
            alu_op    <= 2'b01;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 4;
            src2_sel  <= 3;
            dst_sel   <= 19;

            if(alu_done)
                state <= LV3_MUL;
        end

        LV3_MUL:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 17;
            src2_sel  <= 19;
            dst_sel   <= 6;

            if(alu_done)
                state <= LV4_MUL;
        end

        LV4_MUL:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 16;
            src2_sel  <= 18;
            dst_sel   <= 7;

            if(alu_done)
                state <= LV5_MUL;
        end

        LV5_MUL:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 14;
            src2_sel  <= 15;
            dst_sel   <= 20;

            if(alu_done)
                state <= LV5_ADD;
        end

        LV5_ADD:
        begin
            alu_op    <= 2'b00;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 7;
            src2_sel  <= 6;
            dst_sel   <= 13;

            if(alu_done)
                state <= LV5_SUB;
        end

        LV5_SUB:
        begin
            alu_op    <= 2'b01;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 7;
            src2_sel  <= 6;
            dst_sel   <= 10;

            if(alu_done)
                state <= LV6_MUL;
        end

        LV6_MUL:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 20;
            src2_sel  <= 25;
            dst_sel   <= 8;

            if(alu_done)
                state <= LV7_MUL;
        end

        LV7_MUL:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 2;
            src2_sel  <= 5;
            dst_sel   <= 21;

            if(alu_done)
                state <= LV8_MUL;
        end

        LV8_MUL:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 26;
            src2_sel  <= 21;
            dst_sel   <= 9;

            if(alu_done)
                state <= LV9_ADD;
        end

        LV9_ADD:
        begin
            alu_op    <= 2'b00;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 9;
            src2_sel  <= 8;
            dst_sel   <= 12;

            if(alu_done)
                state <= LV9_SUB;
        end

        LV9_SUB:
        begin
            alu_op    <= 2'b01;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 9;
            src2_sel  <= 8;
            dst_sel   <= 11;

            if(alu_done)
                state <= MUL_X3;
        end

        //--------------------------------------------------
        MUL_X3:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 11;
            src2_sel  <= 10;
            dst_sel   <= 22;

            if(alu_done)
                state <= MUL_Y3;
        end

        MUL_Y3:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 12;
            src2_sel  <= 13;
            dst_sel   <= 23;

            if(alu_done)
                state <= MUL_Z3;
        end

        MUL_Z3:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 11;
            src2_sel  <= 12;
            dst_sel   <= 24;

            if(alu_done)
                state <= MUL_T3;
        end

        MUL_T3:
        begin
            alu_op    <= 2'b10;
            alu_start <= 1;

            we        <= 1;
            src1_sel  <= 10;
            src2_sel  <= 13;
            dst_sel   <= 27;

            if(alu_done)
                state <= DONE_ST;
        end

        //--------------------------------------------------
        DONE_ST:
        begin
            done <= 1;

            if(!start)
                state <= IDLE;
        end

        //--------------------------------------------------
        default:
            state <= IDLE;

        endcase
    end
end

endmodule