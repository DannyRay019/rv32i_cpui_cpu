module mm_wb_transition(
    input  logic        clk,
    input  logic        rst,

    // 从 MM 阶段传来的输入
    input  logic [31:0] mm_alu_result,
    input  logic [31:0] mm_imm_num,
    input  logic [1:0]  mm_MemToReg,
    input  logic [3:0]  mm_funct,
    input  logic        mm_MemWrite,
    input  logic [4:0]  mm_rd_num,
    input  logic        mm_RegWrite,
    input  logic [1:0]  mm_offset,
    input  logic [31:0] mm_rdata,
    // 传给 WB 阶段的输出
    output logic [31:0] wb_alu_result,
    output logic [31:0] wb_imm_num,
    output logic [1:0]  wb_MemToReg,
    output logic [3:0]  wb_funct,
    output logic        wb_MemWrite,
    output  logic [4:0]  wb_rd_num,
    output  logic       wb_RegWrite,
    output  logic [1:0]  wb_offset,
    output  logic [31:0] wb_rdata

);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        wb_alu_result <= 32'b0;
        wb_imm_num    <= 32'b0;
        wb_MemToReg   <= 2'b0;
        wb_funct      <= 4'b0;
        wb_MemWrite   <= 1'b0;
        wb_rd_num     <= 5'b0;
        wb_RegWrite   <= 1'b0;
        wb_offset     <= 2'b0;
        wb_rdata      <= 31'b0;
    end else begin
        wb_alu_result <= mm_alu_result;
        wb_imm_num    <= mm_imm_num;
        wb_MemToReg   <= mm_MemToReg;
        wb_funct      <= mm_funct;
        wb_MemWrite   <= mm_MemWrite;
        wb_rd_num     <= mm_rd_num;
        wb_RegWrite   <= mm_RegWrite;
        wb_offset     <= mm_offset;
        wb_rdata      <= mm_rdata;
    end
end

endmodule
