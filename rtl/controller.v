module controller(
    input [6:0] op,
    input [2:0] funct3,
    input funct7,
    output reg sel_result,
    output reg we_dm,
    output reg [3:0] alu_control,
    output reg sel_alu_src_b,
    output reg [2:0] sel_ext,
    output reg we_rf,
    output reg branch,
    output reg jump
);
    always @(*) begin
        sel_result = 1'b0;
        we_dm = 1'b0;
        alu_control = 4'b0000;
        sel_alu_src_b = 1'b0;
        sel_ext = 3'b000;
        we_rf = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        
        case (op)
            7'b0110011: begin // R
                we_rf = 1'b1;
                sel_alu_src_b = 1'b0;
                case (funct3)
                    3'b000: alu_control = funct7 ? 4'b0001 : 4'b0000; // SUB/ADD
                    3'b001: alu_control = 4'b0101; // SLL
                    3'b010: alu_control = 4'b1000; // SLT
                    3'b011: alu_control = 4'b1001; // SLTU
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b101: alu_control = funct7 ? 4'b0111 : 4'b0110; // SRA/SRL
                    3'b110: alu_control = 4'b0011; // OR
                    3'b111: alu_control = 4'b0010; // AND
                    default: alu_control = 4'b0000;
                endcase
            end
            
            7'b0010011: begin //I
                we_rf = 1'b1;
                sel_alu_src_b = 1'b1;
                sel_ext = 3'b000;
                case (funct3)
                    3'b000: alu_control = 4'b0000; // ADDI
                    3'b001: alu_control = 4'b0101; // SLLI
                    3'b010: alu_control = 4'b1000; // SLTI
                    3'b011: alu_control = 4'b1001; // SLTIU
                    3'b100: alu_control = 4'b0100; // XORI
                    3'b101: alu_control = funct7 ? 4'b0111 : 4'b0110; // SRAI/SRLI
                    3'b110: alu_control = 4'b0011; // ORI
                    3'b111: alu_control = 4'b0010; // ANDI
                    default: alu_control = 4'b0000;
                endcase
            end
            
            7'b0000011: begin //LW
                we_rf = 1'b1;
                sel_result = 1'b1; //select data
                sel_alu_src_b = 1'b1;
                sel_ext = 3'b000; // I-type immediate
                alu_control = 4'b0000;  //for address calculation
            end
            
            7'b0100011: begin //SW
                we_dm = 1'b1;
                sel_alu_src_b = 1'b1;
                sel_ext = 3'b001; // S-type immediate
                alu_control = 4'b0000;
            end
            
            7'b1100011: begin //branch
                branch = 1'b1;
                sel_alu_src_b = 1'b0;
                sel_ext = 3'b010; // B-type immediate
                case (funct3)
                    3'b000: alu_control = 4'b0001; // BEQ: SUB for comparison
                    3'b001: alu_control = 4'b0001; // BNE: SUB for comparison
                    3'b100: alu_control = 4'b1000; // BLT: SLT
                    3'b101: alu_control = 4'b1000; // BGE: SLT
                    3'b110: alu_control = 4'b1001; // BLTU: SLTU
                    3'b111: alu_control = 4'b1001; // BGEU: SLTU
                    default: alu_control = 4'b0001;
                endcase
            end
            
            7'b1101111: begin //JAL
                we_rf = 1'b1;
                jump = 1'b1;
                sel_ext = 3'b100; // J-type immediate
                //in top module later
            end
            
            7'b1100111: begin //JALR
                we_rf = 1'b1;
                jump = 1'b1;
                sel_ext = 3'b000; // I-type immediate
                sel_alu_src_b = 1'b1;
                alu_control = 4'b0000;
            end
            
            7'b0110111: begin // LUI
                we_rf = 1'b1;
                sel_alu_src_b = 1'b1;
                sel_ext = 3'b011; // U-type immediate
                alu_control = 4'b0000; // Pass-through
            end
            
            7'b0010111: begin // AUIPC
                we_rf = 1'b1;
                sel_alu_src_b = 1'b1;
                sel_ext = 3'b011;
                alu_control = 4'b0000; //handled in datapath
            end
            
            default: begin
        // ask about it
            end
        endcase
    end
endmodule