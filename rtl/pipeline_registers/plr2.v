module plr2(
    input clk,
    input rst_n,
    input en,
    input clr,
    input [31:0] D_PC,
    input [31:0] D_PC_P4,
    input [31:0] D_ext,
    input [4:0] D_rf_a1,
    input [4:0] D_rf_a2,
    input [4:0] D_rf_a3,
    input [31:0] D_rf_rd1,
    input [31:0] D_rf_rd2,
    input D_sel_result,
    input D_we_dm,
    input [3:0] D_alu_control,
    input D_sel_alu_src_b,
    input D_we_rf,
    input D_branch,
    input D_jump,
    output reg [31:0] E_PC,
    output reg [31:0] E_PC_P4,
    output reg [31:0] E_ext,
    output reg [4:0] E_rf_a1,
    output reg [4:0] E_rf_a2,
    output reg [4:0] E_rf_a3,
    output reg [31:0] E_rf_rd1,
    output reg [31:0] E_rf_rd2,
    output reg E_sel_result,
    output reg E_we_dm,
    output reg [3:0] E_alu_control,
    output reg E_sel_alu_src_b,
    output reg E_we_rf,
    output reg E_branch,
    output reg E_jump
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            E_PC <= 32'h0;
            E_PC_P4 <= 32'h0;
            E_ext <= 32'h0;
            E_rf_a1 <= 5'h0;
            E_rf_a2 <= 5'h0;
            E_rf_a3 <= 5'h0;
            E_rf_rd1 <= 32'h0;
            E_rf_rd2 <= 32'h0;
            E_sel_result <= 1'b0;
            E_we_dm <= 1'b0;
            E_alu_control <= 4'h0;
            E_sel_alu_src_b <= 1'b0;
            E_we_rf <= 1'b0;
            E_branch <= 1'b0;
            E_jump <= 1'b0;
        end else if (clr) begin
            E_PC <= 32'h0;
            E_PC_P4 <= 32'h0;
            E_ext <= 32'h0;
            E_rf_a1 <= 5'h0;
            E_rf_a2 <= 5'h0;
            E_rf_a3 <= 5'h0;
            E_rf_rd1 <= 32'h0;
            E_rf_rd2 <= 32'h0;
            E_sel_result <= 1'b0;
            E_we_dm <= 1'b0;
            E_alu_control <= 4'h0;
            E_sel_alu_src_b <= 1'b0;
            E_we_rf <= 1'b0;
            E_branch <= 1'b0;
            E_jump <= 1'b0;
        end else if (en) begin
            E_PC <= D_PC;
            E_PC_P4 <= D_PC_P4;
            E_ext <= D_ext;
            E_rf_a1 <= D_rf_a1;
            E_rf_a2 <= D_rf_a2;
            E_rf_a3 <= D_rf_a3;
            E_rf_rd1 <= D_rf_rd1;
            E_rf_rd2 <= D_rf_rd2;
            E_sel_result <= D_sel_result;
            E_we_dm <= D_we_dm;
            E_alu_control <= D_alu_control;
            E_sel_alu_src_b <= D_sel_alu_src_b;
            E_we_rf <= D_we_rf;
            E_branch <= D_branch;
            E_jump <= D_jump;
        end
    end
endmodule