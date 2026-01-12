module plr3(
    input clk,
    input rst_n,
    input [31:0] E_alu_o,
    input [31:0] E_dm_wd,
    input [4:0] E_rf_a3,
    input [31:0] E_PC_P4,
    input [1:0] E_sel_result,
    input E_we_dm,
    input E_we_rf,
    output reg [31:0] M_alu_o,
    output reg [31:0] M_dm_wd,
    output reg [4:0] M_rf_a3,
    output reg [31:0] M_PC_P4,
    output reg [1:0] M_sel_result,
    output reg M_we_dm,
    output reg M_we_rf
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            M_alu_o <= 32'h0;
            M_dm_wd <= 32'h0;
            M_rf_a3 <= 5'h0;
            M_PC_P4 <= 32'h0;
            M_sel_result <= 1'b0;
            M_we_dm <= 1'b0;
            M_we_rf <= 1'b0;
        end else begin
            M_alu_o <= E_alu_o;
            M_dm_wd <= E_dm_wd;
            M_rf_a3 <= E_rf_a3;
            M_PC_P4 <= E_PC_P4;
            M_sel_result <= E_sel_result;
            M_we_dm <= E_we_dm;
            M_we_rf <= E_we_rf;
        end
    end
endmodule