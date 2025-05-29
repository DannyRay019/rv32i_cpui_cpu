module id_ex_transition (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] id_pc,
    input  logic [31:0] id_instr,

    input  logic [31:0] id_regs_A,
    input  logic [31:0] id_regs_B,
    input  logic [31:0] id_imm_num,
    input  logic [3:0]  id_funct,
    input  logic [4:0]  id_rd_num,
    input  logic [4:0]  id_rs1,
    input  logic [4:0]  id_rs2,
    
    input  logic        id_RegWrite,
    input  logic [1:0]  id_MemToReg,
    input  logic        id_MemWrite,
    input  logic        id_OffsetOrigin,
    input  logic        id_ALUSrc,
    input  logic [2:0]  id_br_type,

    input  logic [3:0]  id_alu_control,
    input  logic        id_isBranch,

    input  logic        id_ex_stall,
    input  logic        id_ex_flush,

    output logic [31:0] ex_pc,
    output logic [31:0] ex_instr,
    output logic [31:0] ex_regs_A,
    output logic [31:0] ex_regs_B,
    output logic [31:0] ex_imm_num,
    output logic [3:0]  ex_funct,
    output logic [4:0]  ex_rd_num,
    output logic [4:0]  ex_rs1,
    output logic [4:0]  ex_rs2,
    
    output logic        ex_RegWrite,
    output logic [1:0]  ex_MemToReg,
    output logic        ex_MemWrite,
    output logic        ex_OffsetOrigin,
    output logic        ex_ALUSrc,
    output logic [2:0]  ex_br_type,

    output logic [3:0]  ex_alu_control,
    output logic        ex_isBranch
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_pc           <= 32'b0;
            ex_instr        <= 32'b0;
            ex_regs_A       <= 32'b0;
            ex_regs_B       <= 32'b0;
            ex_imm_num      <= 32'b0;
            ex_funct        <= 4'b0;
            ex_rd_num       <= 5'b0;
            ex_rs1          <= 5'b0;
            ex_rs2          <= 5'b0;
            ex_RegWrite     <= 1'b0;
            ex_MemToReg     <= 2'b0;
            ex_MemWrite     <= 1'b0;
            ex_OffsetOrigin <= 1'b0;
            ex_ALUSrc       <= 1'b0;
            ex_br_type      <= 3'b0;
            ex_alu_control  <= 4'b0;
            ex_isBranch     <= 1'b0;
        end else begin
            if (id_ex_flush || id_ex_stall) begin
                ex_pc           <= 32'b0;
                ex_instr        <= 32'b0;
                ex_regs_A       <= 32'b0;
                ex_regs_B       <= 32'b0;
                ex_imm_num      <= 32'b0;
                ex_funct        <= 4'b0;
                ex_rd_num       <= 5'b0;
                ex_rs1          <= 5'b0;
                ex_rs2          <= 5'b0;
                ex_RegWrite     <= 1'b0;
                ex_MemToReg     <= 2'b0;
                ex_MemWrite     <= 1'b0;
                ex_OffsetOrigin <= 1'b0;
                ex_ALUSrc       <= 1'b0;
                ex_br_type      <= 3'b0;
                ex_alu_control  <= 4'b0;
                ex_isBranch     <= 1'b0;
            end else begin
                ex_pc           <= id_pc;
                ex_instr        <= id_instr;
                ex_regs_A       <= id_regs_A;
                ex_regs_B       <= id_regs_B;
                ex_imm_num      <= id_imm_num;
                ex_funct        <= id_funct;
                ex_rd_num       <= id_rd_num;
                ex_rs1          <= id_rs1;
                ex_rs2          <= id_rs2;
                ex_RegWrite     <= id_RegWrite;
                ex_MemToReg     <= id_MemToReg;
                ex_MemWrite     <= id_MemWrite;
                ex_OffsetOrigin <= id_OffsetOrigin;
                ex_ALUSrc       <= id_ALUSrc;
                ex_br_type      <= id_br_type;
                ex_alu_control  <= id_alu_control;
                ex_isBranch     <= id_isBranch;
            end
        end
    end


endmodule
