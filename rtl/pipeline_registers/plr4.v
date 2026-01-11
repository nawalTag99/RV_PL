module plr4(
    input clk,
    input rst_n,
    input [31:0] M_alu_o,
    input [31:0] M_dm_rd,
    input [4:0] M_rf_a3,
    input [31:0] M_PC_P4,
    input M_sel_result,
    input M_we_rf,
    output reg [31:0] W_alu_o,
    output reg [31:0] W_dm_rd,
    output reg [4:0] W_rf_a3,
    output reg [31:0] W_PC_P4,
    output reg W_sel_result,
    output reg W_we_rf
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            W_alu_o <= 32'h0;
            W_dm_rd <= 32'h0;
            W_rf_a3 <= 5'h0;
            W_PC_P4 <= 32'h0;
            W_sel_result <= 1'b0;
            W_we_rf <= 1'b0;
        end else begin
            W_alu_o <= M_alu_o;
            W_dm_rd <= M_dm_rd;
            W_rf_a3 <= M_rf_a3;
            W_PC_P4 <= M_PC_P4;
            W_sel_result <= M_sel_result;
            W_we_rf <= M_we_rf;
        end
    end
endmodule
