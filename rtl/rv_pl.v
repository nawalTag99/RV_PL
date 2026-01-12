// Top-level core + memory
module rv_pl(
    clk,
    rst_n
);
    input clk;
    input rst_n;
    
    // IF Stage signals
    wire [31:0] F_PC, F_PC_P4, F_instr;
    wire PC_en, PLR1_clr;
    
    // ID Stage signals
    wire [31:0] D_PC, D_PC_P4, D_instr;
    wire [31:0] D_rf_rd1, D_rf_rd2, D_ext;
    wire [4:0] D_rf_a1, D_rf_a2, D_rf_a3;
    wire [1:0] D_sel_result;
    wire D_we_dm, D_sel_alu_src_b, D_we_rf, D_branch, D_jump;
    wire [2:0] D_sel_ext;
    wire [3:0] D_alu_control;
    
    // EX Stage signals
    wire [31:0] E_PC, E_PC_P4, E_ext;
    wire [31:0] E_rf_rd1, E_rf_rd2;
    wire [31:0] E_alu_o, E_target_PC, E_dm_wd;
    wire [4:0] E_rf_a1, E_rf_a2, E_rf_a3;
    wire [1:0] E_sel_result;
    wire E_we_dm, E_sel_alu_src_b, E_we_rf, E_branch, E_jump;
    wire [3:0] E_alu_control;
    wire E_zero;
    wire [31:0] E_alu_op1, E_alu_op2;
    wire [1:0] E_forward_alu_op1, E_forward_alu_op2;
    
    // MA Stage signals
    wire [31:0] M_alu_o, M_dm_wd, M_PC_P4, M_dm_rd;
    wire [4:0] M_rf_a3;
    wire [1:0] M_sel_result;
    wire M_we_dm, M_we_rf;
    
    // WB Stage signals
    wire [31:0] W_alu_o, W_dm_rd, W_PC_P4, W_result;
    wire [4:0] W_rf_a3;
    wire [1:0] W_sel_result;
    wire W_we_rf;
    
    // Hazard signals
    wire PLR1_en, PLR2_clr, PLR2_en;
    wire take_branch;
    
    //IF Stage 
    assign F_PC_P4 = F_PC + 4;
    assign take_branch = (E_branch & E_zero) | E_jump;
    
    pc_reg PC(
        .clk(clk),
        .rst_n(rst_n),
        .en(PLR1_en),
        .pc_next(take_branch ? E_target_PC : F_PC_P4),
        .pc(F_PC)
    );
    
    inst_mem IMEM(
        .addr(F_PC),
        .instr(F_instr)
    );
    
    //LR1: IF/ID Pipeline Register
    plr1 PLR1(
        .clk(clk),
        .rst_n(rst_n),
        .en(PLR1_en),
        .clr(PLR1_clr),
        .F_PC(F_PC),
        .F_PC_P4(F_PC_P4),
        .F_instr(F_instr),
        .D_PC(D_PC),
        .D_PC_P4(D_PC_P4),
        .D_instr(D_instr)
    );
    
    //ID Stage 
    assign D_rf_a1 = D_instr[19:15];
    assign D_rf_a2 = D_instr[24:20];
    assign D_rf_a3 = D_instr[11:7];
    
    reg_file RF(
        .clk(clk),
        .rst_n(rst_n),
        .we(W_we_rf),
        .a1(D_rf_a1),
        .a2(D_rf_a2),
        .a3(W_rf_a3),
        .wd(W_result),
        .rd1(D_rf_rd1),
        .rd2(D_rf_rd2)
    );
    
    extender EXT(
        .instr(D_instr[31:7]),
        .sel(D_sel_ext),
        .ext_out(D_ext)
    );
    
    controller CTRL(
        .op(D_instr[6:0]),
        .funct3(D_instr[14:12]),
        .funct7(D_instr[30]),
        .sel_result(D_sel_result),
        .we_dm(D_we_dm),
        .alu_control(D_alu_control),
        .sel_alu_src_b(D_sel_alu_src_b),
        .sel_ext(D_sel_ext),
        .we_rf(D_we_rf),
        .branch(D_branch),
        .jump(D_jump)
    );
    
    //PLR2: ID/EX Pipeline Register
    plr2 PLR2(
        .clk(clk),
        .rst_n(rst_n),
        .en(PLR2_en),
        .clr(PLR2_clr),
        .D_PC(D_PC),
        .D_PC_P4(D_PC_P4),
        .D_ext(D_ext),
        .D_rf_a1(D_rf_a1),
        .D_rf_a2(D_rf_a2),
        .D_rf_a3(D_rf_a3),
        .D_rf_rd1(D_rf_rd1),
        .D_rf_rd2(D_rf_rd2),
        .D_sel_result(D_sel_result),
        .D_we_dm(D_we_dm),
        .D_alu_control(D_alu_control),
        .D_sel_alu_src_b(D_sel_alu_src_b),
        .D_we_rf(D_we_rf),
        .D_branch(D_branch),
        .D_jump(D_jump),
        .E_PC(E_PC),
        .E_PC_P4(E_PC_P4),
        .E_ext(E_ext),
        .E_rf_a1(E_rf_a1),
        .E_rf_a2(E_rf_a2),
        .E_rf_a3(E_rf_a3),
        .E_rf_rd1(E_rf_rd1),
        .E_rf_rd2(E_rf_rd2),
        .E_sel_result(E_sel_result),
        .E_we_dm(E_we_dm),
        .E_alu_control(E_alu_control),
        .E_sel_alu_src_b(E_sel_alu_src_b),
        .E_we_rf(E_we_rf),
        .E_branch(E_branch),
        .E_jump(E_jump)
    );
    
    //EX Stage
    assign E_alu_op1 = (E_forward_alu_op1 == 2'b10) ? M_alu_o :
                       (E_forward_alu_op1 == 2'b01) ? W_result :
                       E_rf_rd1;
    
    assign E_dm_wd = (E_forward_alu_op2 == 2'b10) ? M_alu_o :
                     (E_forward_alu_op2 == 2'b01) ? W_result :
                     E_rf_rd2;
    
    
    assign E_alu_op2 = E_sel_alu_src_b ? E_ext : E_dm_wd;
    
    alu ALU(
        .a(E_alu_op1),
        .b(E_alu_op2),
        .alu_control(E_alu_control),
        .result(E_alu_o),
        .zero(E_zero)
    );
    
    // Branch/Jump target address
    assign E_target_PC = (E_jump && E_alu_control == 4'b0000 && E_sel_alu_src_b) ? (E_alu_op1 + E_ext) : (E_PC + E_ext);

    // PLR3: EX/MA Pipeline Register
    plr3 PLR3(
        .clk(clk),
        .rst_n(rst_n),
        .E_alu_o(E_alu_o),
        .E_dm_wd(E_dm_wd),
        .E_rf_a3(E_rf_a3),
        .E_PC_P4(E_PC_P4),
        .E_sel_result(E_sel_result),
        .E_we_dm(E_we_dm),
        .E_we_rf(E_we_rf),
        .M_alu_o(M_alu_o),
        .M_dm_wd(M_dm_wd),
        .M_rf_a3(M_rf_a3),
        .M_PC_P4(M_PC_P4),
        .M_sel_result(M_sel_result),
        .M_we_dm(M_we_dm),
        .M_we_rf(M_we_rf)
    );
    
    //MA Stage
    data_mem DMEM(
        .clk(clk),
        .we(M_we_dm),
        .addr(M_alu_o),
        .wd(M_dm_wd),
        .rd(M_dm_rd)
    );
    
    //PLR4: MA/WB Pipeline Register
    plr4 PLR4(
        .clk(clk),
        .rst_n(rst_n),
        .M_alu_o(M_alu_o),
        .M_dm_rd(M_dm_rd),
        .M_rf_a3(M_rf_a3),
        .M_PC_P4(M_PC_P4),
        .M_sel_result(M_sel_result),
        .M_we_rf(M_we_rf),
        .W_alu_o(W_alu_o),
        .W_dm_rd(W_dm_rd),
        .W_rf_a3(W_rf_a3),
        .W_PC_P4(W_PC_P4),
        .W_sel_result(W_sel_result),
        .W_we_rf(W_we_rf)
    );
    
    //WB stage
    assign W_result = (W_sel_result == 2'b01) ? W_dm_rd : 
                  (W_sel_result == 2'b10) ? W_PC_P4 : W_alu_o;
    
    //hazard_unit
    hazard_unit HU(
        .D_rs1(D_rf_a1),
        .D_rs2(D_rf_a2),
        .E_rs1(E_rf_a1),
        .E_rs2(E_rf_a2),
        .E_rf_a3(E_rf_a3),
        .E_we_rf(E_we_rf),
        .E_sel_result(E_sel_result[0]),
        .M_rf_a3(M_rf_a3),
        .M_we_rf(M_we_rf),
        .W_rf_a3(W_rf_a3),
        .W_we_rf(W_we_rf),
        .E_branch(E_branch),
        .E_jump(E_jump),
        .E_zero(E_zero),
        .E_forward_alu_op1(E_forward_alu_op1),
        .E_forward_alu_op2(E_forward_alu_op2),
        .PLR1_en(PLR1_en),
        .PLR1_clr(PLR1_clr),
        .PLR2_en(PLR2_en),
        .PLR2_clr(PLR2_clr)
    );
    
endmodule