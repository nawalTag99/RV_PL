`timescale 1ns/1ps

module tb_rv_pl;
    reg clk;
    reg rst_n;
    
    // 0 = Independent , 1 = RAW , 2 = LW , 3 = Control , 4 = Check (JAL, sub, branch NT)
    reg [2:0] test_case = 4; 

    rv_pl dut(
        .clk(clk),
        .rst_n(rst_n)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        initialize_memories(test_case);
        rst_n = 0;
        #20;
        rst_n = 1;
        #500;
        display_registers();
        $finish;
    end
    
    //definitions
    task initialize_memories;
        input [2:0] sel;
        integer i;
        begin
            for (i = 0; i < 256; i = i + 1) begin
                dut.IMEM.RAM[i] = 32'h00000013;
                dut.DMEM.RAM[i] = 32'h0;
            end
            
            case (sel)
                0: begin
                    dut.IMEM.RAM[0] = 32'h00100093; // addi x1, x0, 1
                    dut.IMEM.RAM[1] = 32'h00200113; // addi x2, x0, 2
                    dut.IMEM.RAM[2] = 32'h00300193; // addi x3, x0, 3
                    dut.IMEM.RAM[3] = 32'h00400213; // addi x4, x0, 4
                    dut.IMEM.RAM[4] = 32'h00500293; // addi x5, x0, 5
                end
                1: begin
                    dut.IMEM.RAM[0] = 32'h00100093; // x1 = 1
                    dut.IMEM.RAM[1] = 32'h00108113; // x2 = x1 + 1 ,forwarding
                    dut.IMEM.RAM[2] = 32'h00208193; // x3 = x1 + 2
                    dut.IMEM.RAM[3] = 32'h00308213; // x4 = x1 + 3
                end
                2: begin
                    dut.DMEM.RAM[10] = 32'h00000000;
                    dut.IMEM.RAM[0] = 32'h02002423; // sw x0, 40(x0)
                    dut.IMEM.RAM[1] = 32'h02802083; // lw x1, 40(x0)
                    dut.IMEM.RAM[2] = 32'h00208113; // addi x2, x1, 2 ,stall
                    dut.IMEM.RAM[3] = 32'h00308193; // addi x3, x1, 3
                end
                3: begin
                    dut.IMEM.RAM[0] = 32'h00100093; // x1 = 1
                    dut.IMEM.RAM[1] = 32'h00100113; // x2 = 1
                    dut.IMEM.RAM[2] = 32'h00208663; // beq x1, x2, 12
                    dut.IMEM.RAM[3] = 32'h00300193; // Flush me
                    dut.IMEM.RAM[4] = 32'h00400213; // Flush me
                    dut.IMEM.RAM[5] = 32'h00D00293; // x5 = 13
                end
                4: begin
                
                    //10,20
                    dut.IMEM.RAM[0] = 32'h00a00093; // addi x1, x0, 10
                    dut.IMEM.RAM[1] = 32'h01400113; // addi x2, x0, 20
                    dut.IMEM.RAM[2] = 32'h401101b3; // sub x3, x2, x1
                    dut.IMEM.RAM[3] = 32'h00208463; // beq x1, x2, 8 
                    dut.IMEM.RAM[4] = 32'h00500213; // addi x4, x0, 5
                    dut.IMEM.RAM[5] = 32'h0080006f; 
                    dut.IMEM.RAM[6] = 32'h06300293; // addi x5, x0, 99
                    dut.IMEM.RAM[7] = 32'h00700313; // addi x6, x0, 7
                end
            endcase
        end
    endtask
    
    task display_registers;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                if (dut.RF.regs[i] !== 32'h0)
                    $display("x%0d = 0x%h (%0d)", i, dut.RF.regs[i], dut.RF.regs[i]);
            end
        end
    endtask
    
    initial begin
        $dumpfile("rv_pl.vcd");
        $dumpvars(0, tb_rv_pl);
    end
endmodule