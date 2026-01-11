module data_mem(
    input clk,
    input we,
    input [31:0] addr,
    input [31:0] wd,
    output [31:0] rd
);
    parameter MEM_DEPTH = 256;
    reg [31:0] RAM [0:MEM_DEPTH-1];
    
    always @(posedge clk) begin
        if (we)
            RAM[addr[31:2]] <= wd;
    end
    
    assign rd = RAM[addr[31:2]];
endmodule