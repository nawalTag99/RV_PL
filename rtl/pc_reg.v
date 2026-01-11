module pc_reg(
    input clk,
    input rst_n,
    input en,
    input [31:0] pc_next,
    output reg [31:0] pc
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'h0;
        else if (en)
            pc <= pc_next;
    end
endmodule