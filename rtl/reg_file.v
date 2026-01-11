module reg_file(
    input clk,
    input rst_n,
    input we,
    input [4:0] a1,
    input [4:0] a2,
    input [4:0] a3,
    input [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);
    reg [31:0] regs [0:31];
    integer i;
    
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'h0;
        end else if (we && a3 != 5'h0) begin
            regs[a3] <= wd;
        end
    end
    
    assign rd1 = (a1 == 5'h0) ? 32'h0 : 
                 (we && (a3 == a1) && (a3 != 5'h0)) ? wd : regs[a1];
    assign rd2 = (a2 == 5'h0) ? 32'h0 : 
                 (we && (a3 == a2) && (a3 != 5'h0)) ? wd : regs[a2];
endmodule