module inst_mem(
    input [31:0] addr,
    output [31:0] instr
);
    parameter MEM_DEPTH = 256;
    reg [31:0] RAM [0:MEM_DEPTH-1];
    
    assign instr = RAM[addr[31:2]];
endmodule