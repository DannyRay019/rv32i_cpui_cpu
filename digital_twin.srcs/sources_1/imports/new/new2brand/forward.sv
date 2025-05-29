module forward (
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    input logic [4:0] ex_rs1,
    input logic [4:0] ex_rs2,
    input logic [4:0] mm_rd_num,
    input logic [4:0] wb_rd_num,
    input logic [4:0] mm_regs_B_num,            // ⬅️ 额外增加 MEM 阶段的 rs2（store 要用它）
    input logic       mm_RegWrite,
    input logic       wb_RegWrite,

    output logic [1:0] forwardA,
    output logic [1:0] forwardB,
    output logic forward_data,
    output logic id_forward_rs1,
    output logic id_forward_rs2
);

    // Forwarding conditions
    logic ex_hazard_a, ex_hazard_b;
    logic mem_hazard_a, mem_hazard_b;
    logic hazard_data_mem;

    assign ex_hazard_a   = mm_RegWrite && (mm_rd_num != 0) && (mm_rd_num == ex_rs1);
    assign ex_hazard_b   = mm_RegWrite && (mm_rd_num != 0) && (mm_rd_num == ex_rs2);
    assign mem_hazard_a  = wb_RegWrite && (wb_rd_num != 0) && (wb_rd_num == ex_rs1);
    assign mem_hazard_b  = wb_RegWrite && (wb_rd_num != 0) && (wb_rd_num == ex_rs2);
    assign id_forward_rs1 = wb_RegWrite && (wb_rd_num != 0) && (wb_rd_num == id_rs1);
    assign id_forward_rs2 = wb_RegWrite && (wb_rd_num != 0) && (wb_rd_num == id_rs2);


    // 补全这里：检测 load -> store 冒险
    assign hazard_data_mem = wb_RegWrite && (wb_rd_num != 0) && (wb_rd_num == mm_regs_B_num);

    // 若发生 load -> store 的前递需求，forward_data 拉高
    assign forward_data = hazard_data_mem ? 1'b1 : 1'b0;

    assign forwardA = ex_hazard_a ? 2'b10 : 
                      mem_hazard_a ? 2'b01 : 
                      2'b00;

    assign forwardB = ex_hazard_b ? 2'b10 : 
                      mem_hazard_b ? 2'b01 : 
                      2'b00;

endmodule
