module hazard_unit(
    input [4:0] D_rs1,
    input [4:0] D_rs2,
    input [4:0] E_rs1,
    input [4:0] E_rs2,
    input [4:0] E_rf_a3,
    input E_we_rf,
    input E_sel_result,
    input [4:0] M_rf_a3,
    input M_we_rf,
    input [4:0] W_rf_a3,
    input W_we_rf,
    input E_branch,
    input E_jump,
    input E_zero,
    output reg [1:0] E_forward_alu_op1,
    output reg [1:0] E_forward_alu_op2,
    output reg PLR1_en,
    output reg PLR1_clr,
    output reg PLR2_en,
    output reg PLR2_clr
);
    wire lw_stall;
    wire take_branch;
    
    // LW hazard detection using D
    assign lw_stall = E_sel_result && E_we_rf && 
                      ((E_rf_a3 == D_rs1 && D_rs1 != 5'h0) || 
                       (E_rf_a3 == D_rs2 && D_rs2 != 5'h0));
    
  
    assign take_branch = (E_branch && E_zero) || E_jump;
    
    // data forwarding for ALU operand 1
    always @(*) begin
        if (M_we_rf && (M_rf_a3 != 5'h0) && (M_rf_a3 == E_rs1))
            E_forward_alu_op1 = 2'b10;
        else if (W_we_rf && (W_rf_a3 != 5'h0) && (W_rf_a3 == E_rs1))
            E_forward_alu_op1 = 2'b01;
        else
            E_forward_alu_op1 = 2'b00;
    end
    
    //data forwarding for ALU operand 2
    always @(*) begin
        if (M_we_rf && (M_rf_a3 != 5'h0) && (M_rf_a3 == E_rs2))
            E_forward_alu_op2 = 2'b10;
        else if (W_we_rf && (W_rf_a3 != 5'h0) && (W_rf_a3 == E_rs2))
            E_forward_alu_op2 = 2'b01;
        else
            E_forward_alu_op2 = 2'b00;
    end

    always @(*) begin
        if (lw_stall) begin
            //stall PC and IF/ID and flush ID/EX
            PLR1_en = 1'b0;
            PLR1_clr = 1'b0;
            PLR2_en = 1'b1;
            PLR2_clr = 1'b1;
        end else if (take_branch) begin
            // Flush IF/ID and ID/EX on branch/jump
            PLR1_en = 1'b1;
            PLR1_clr = 1'b1;
            PLR2_en = 1'b1;
            PLR2_clr = 1'b1;
        end else begin
            PLR1_en = 1'b1;
            PLR1_clr = 1'b0;
            PLR2_en = 1'b1;
            PLR2_clr = 1'b0;
        end
    end
endmodule