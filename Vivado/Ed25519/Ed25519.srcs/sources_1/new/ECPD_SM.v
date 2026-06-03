`timescale 1ns / 1ps

module ECPD_SM #( parameter REG_BANK = 5)(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    output reg         done,

    // Control signals to ALU
    output reg  [1:0]  alu_op,      // 00: ADD, 01: SUB, 10: MUL
    output reg         alu_start,
    input  wire        alu_done,

    // Select lines for operands and destination
    output reg  [REG_BANK -1 :0]  src1_sel,
    output reg  [REG_BANK -1 :0]  src2_sel,
    output reg                    we,
    output reg  [2:0]             din_sel,
    output reg  [REG_BANK -1 :0]  dst_sel
    );
    
    localparam 
           IDLE      = 5'd0,
           LV1_ADD   = 5'd1,
           LV1_MUL   = 5'd2,
           LV2_MUL   = 5'd3,
           LV3_MUL   = 5'd4,
           LV3_ADD   = 5'd5,
           LV3_SUB   = 5'd6,
           LV4_MUL   = 5'd7,
           LV5_MUL   = 5'd8,
           LV5_ADD   = 5'd9,
           MUL_Y3    = 5'd10,
           LV6_SUB   = 5'd11,
           MUL_X3    = 5'd12,
           MUL_Z3    = 5'd13,
           MUL_T3    = 5'd14,
           DONE      = 5'd15,
           LOAD_X1   = 5'd16,
           LOAD_Y1   = 5'd17,
           LOAD_Z1   = 5'd18,
           LOAD_T1   = 5'd19;

    reg [4:0] state, next_state;
    
    // Sequential FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            alu_op    = 2'b00;
            alu_start = 0;
            done      = 0;
            src1_sel  = 0;
            src2_sel  = 0;
            we        = 0;
            din_sel   = 3'b000;
            dst_sel   = 0;
        end else
            state <= next_state;
    end 
    
    always @(*) begin
        alu_op    = 2'b00;
        alu_start = 0;
        done      = 0;
        src1_sel  = 0;
        src2_sel  = 0;
        we        = 0;
        din_sel   = 3'b000;
        dst_sel   = 0;
        next_state = state;
        
        case (state)
            IDLE: begin
                done = 0;
                if (start) next_state = LOAD_X1;
            end
            
            LOAD_X1: begin
                din_sel = 3'b001; we = 1;
                dst_sel = 0;
                next_state = LOAD_Y1;
            end
             
            LOAD_Y1: begin
                din_sel = 3'b010; we = 1;
                dst_sel = 1;
                next_state = LOAD_Z1;
            end 
            
            LOAD_Z1: begin
                din_sel = 3'b011; we = 1;
                dst_sel = 2;
                next_state = LOAD_T1;
            end
            
            LOAD_T1: begin
                din_sel = 3'b100; we = 1;
                dst_sel = 14;
                next_state = LV1_ADD;
            end
             
            LV1_ADD: begin
                alu_op = 2'b00; alu_start = 1; we = 1; din_sel = 3'b000;
                src1_sel = 0; src2_sel = 1; dst_sel = 16;
                if (alu_done) begin
                    next_state = LV1_MUL;
                    alu_start = 0;
                end 
            end
            
            LV1_MUL: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 0; src2_sel = 0; dst_sel = 6;
                if (alu_done) begin
                    next_state = LV2_MUL;
                    alu_start = 0;
                end 
            end
            
            LV2_MUL: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 1; src2_sel = 1; dst_sel = 7;
                if (alu_done) begin
                    next_state = LV3_MUL;
                    alu_start = 0;
                end 
            end
            
            LV3_MUL: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 2; src2_sel = 2; dst_sel = 18;
                if (alu_done) begin
                    next_state = LV3_ADD;
                    alu_start = 0;
                end 
            end
            
            LV3_ADD: begin
                alu_op = 2'b00; alu_start = 1; we = 1;
                src1_sel = 6; src2_sel = 7; dst_sel = 13;
                if (alu_done) begin
                    next_state = LV3_SUB;
                    alu_start = 0;
                end 
            end
            
            LV3_SUB: begin
                alu_op = 2'b01; alu_start = 1; we = 1;
                src1_sel = 6; src2_sel = 7; dst_sel = 12;
                if (alu_done) begin
                    next_state = LV4_MUL;
                    alu_start = 0;
                end 
            end
            
            LV4_MUL: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 26; src2_sel = 18; dst_sel = 8;
                if (alu_done) begin
                    next_state = LV5_MUL;
                    alu_start = 0;
                end 
            end
            
            LV5_MUL: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 16; src2_sel = 16; dst_sel = 20;
                if (alu_done) begin
                    next_state = LV5_ADD;
                    alu_start = 0;
                end 
            end
            
            LV5_ADD: begin
                alu_op = 2'b00; alu_start = 1; we = 1;
                src1_sel = 8; src2_sel = 12; dst_sel = 11;
                if (alu_done) begin     
                    next_state = MUL_Y3;
                    alu_start = 0;
                end 
            end
            
            MUL_Y3: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 12; src2_sel = 13; dst_sel = 23;
                if (alu_done) begin
                    next_state = LV6_SUB;
                    alu_start = 0;
                end 
            end
            
            LV6_SUB: begin
                alu_op = 2'b01; alu_start = 1; we = 1;
                src1_sel = 13; src2_sel = 20; dst_sel = 10;
                if (alu_done) begin     
                    next_state = MUL_X3;
                    alu_start = 0;
                end 
            end 
            
            MUL_X3: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 10; src2_sel = 11; dst_sel = 22;
                if (alu_done) begin
                    next_state = MUL_Z3;
                    alu_start = 0;
                end 
            end
            
            MUL_Z3: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 11; src2_sel = 12; dst_sel = 24;
                if (alu_done) begin
                    next_state = MUL_T3;
                    alu_start = 0;
                end 
            end
            
            MUL_T3: begin
                alu_op = 2'b10; alu_start = 1; we = 1;
                src1_sel = 10; src2_sel = 13; dst_sel = 27;
                if (alu_done) begin
                    next_state = DONE;
                    alu_start = 0;
                end 
            end
            
            DONE: begin
                done = 1;
                if (!start) next_state = IDLE;
            end
        endcase
    end
    
endmodule
