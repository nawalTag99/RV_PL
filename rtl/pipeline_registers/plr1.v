module plr1(
    input clk,
    input rst_n,
    input en,
    input clr,
    input [31:0] F_PC,
    input [31:0] F_PC_P4,
    input [31:0] F_instr,
    output reg [31:0] D_PC,
    output reg [31:0] D_PC_P4,
    output reg [31:0] D_instr
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            D_PC <= 32'h0;
            D_PC_P4 <= 32'h0;
            D_instr <= 32'h00000013; //NOP (addi x0, x0, 0)
        end else if (clr) begin
            D_PC <= 32'h0;
            D_PC_P4 <= 32'h0;
            D_instr <= 32'h00000013; // NOP
        end else if (en) begin
            D_PC <= F_PC;
            D_PC_P4 <= F_PC_P4;
            D_instr <= F_instr;
        end
    end
endmodule