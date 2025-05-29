
module MM_moment(
    input logic [31:0] mm_imm_num,
    input logic mm_RegWrite,
    input logic [1:0] mm_MemToReg,
    input  logic [31:0]  mm_alu_result			,
    input  logic [31:0]  mm_regs_B		,
	input  logic [3:0]	 mm_funct			,
    input  logic         mm_MemWrite        ,
    input  logic[31:0]  w_regs_data         ,
    input  logic        forward_data        ,

    output logic [31:0]   mem_daddr     ,  
    output logic          mem_wen        ,  
    output logic [1:0]    mem_mask        ,
    output logic [31:0]   mem_din      ,
    input logic [31:0]    mem_dout    ,

    output logic [1:0] mm_offset                     ,
    output logic [31:0] mm_rdata
);

    logic [31:0] dram_data_pre;

    assign mem_daddr = mm_alu_result;
    assign mm_rdata = mem_dout;
    assign mem_mask = mm_funct[1:0];
    assign mm_offset = mm_alu_result[1:0];
    assign mem_wen = mm_MemWrite;
    assign dram_data_pre = forward_data ? w_regs_data : mm_regs_B;
    assign mem_din = dram_data_pre;


endmodule
