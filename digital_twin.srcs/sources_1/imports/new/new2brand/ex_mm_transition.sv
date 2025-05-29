module ex_mm_transition(
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] ex_imm_num,
    input  logic        ex_RegWrite,
    input  logic        ex_MemWrite,
    input  logic [1:0]  ex_MemToReg,
    input  logic [3:0]  ex_funct,
    input  logic [4:0]  ex_rs2,
    input  logic [31:0] ex_regs_B,
    input  logic [31:0] ex_alu_result,
    input  logic [4:0]  ex_rd_num,

    output logic [31:0] mm_imm_num,
    output logic        mm_RegWrite,
    output logic        mm_MemWrite,
    output logic [1:0]  mm_MemToReg,
    output logic [3:0]  mm_funct,
    output logic [4:0]  mm_rs2,
    output logic [31:0] mm_regs_B,
    output logic [31:0] mm_alu_result,
    output logic [4:0]  mm_rd_num
);

// 内部寄存器（可选添加）
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        mm_imm_num    <= 32'b0;
        mm_RegWrite   <= 1'b0;
        mm_MemWrite   <= 1'b0;
        mm_MemToReg   <= 2'b0;
        mm_funct      <= 4'b0;
        mm_rs2        <= 5'b0;
        mm_regs_B     <= 32'b0;
        mm_alu_result <= 32'b0;
        mm_rd_num     <= 5'b0;
    end else begin
        mm_imm_num    <= ex_imm_num;
        mm_RegWrite   <= ex_RegWrite;
        mm_MemWrite   <= ex_MemWrite;
        mm_MemToReg   <= ex_MemToReg;
        mm_funct      <= ex_funct;
        mm_rs2        <= ex_rs2;
        mm_regs_B     <= ex_regs_B;
        mm_alu_result <= ex_alu_result;
        mm_rd_num     <= ex_rd_num;
    end
end

endmodule
