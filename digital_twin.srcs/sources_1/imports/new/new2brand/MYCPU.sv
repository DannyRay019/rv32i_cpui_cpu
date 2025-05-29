

module MYCPU (
    input  logic         cpu_rst,
    input  logic         cpu_clk,

    // Interface to IROM
    input  logic [31:0] instr,     // 从 IROM 读取的指令
    output logic [31:0] if_pc,      // 给 IROM 的 PC 地址

    output logic [31:0]   mem_daddr     ,  
    output logic          mem_wen        ,  
    output logic [1:0]    mem_mask        ,
    output logic [31:0]   mem_din      ,
    input logic [31:0]    mem_dout     
);

    // ==========================
    // IF 阶段
    // ==========================
    logic [31:0] if_instr;         // IF 阶段指令

    // ==========================
    // IF/ID 中转寄存器（IF → ID）
    // ==========================
    logic        br_sign;
    logic [31:0] br_addr;

    // ==========================
    // ID 阶段
    // ==========================
    logic [31:0] id_pc, id_instr;
    logic [31:0] regs_A, regs_B, imm_num;
    logic [3:0]  funct;
    logic [4:0]  rd_num, rs1, rs2;
    logic        RegWrite, MemWrite, OffsetOrigin, ALUSrc, isBranch;
    logic [1:0]  MemToReg;
    logic [2:0]  br_type;
    logic [3:0]  alu_control;

    // === 命名更规范的 ID 阶段信号（可替代上面信号使用）===
    logic [31:0] id_regs_A, id_regs_B, id_imm_num;
    logic [3:0]  id_funct;
    logic [4:0]  id_rd_num, id_rs1, id_rs2;
    logic        id_RegWrite, id_MemWrite;
    logic [1:0]  id_MemToReg;
    logic        id_OffsetOrigin, id_ALUSrc, id_isBranch, id_ex_flush;
    logic [2:0]  id_br_type;
    logic [3:0]  id_alu_control;

    // ==========================
    // ID/EX 中转寄存器（ID → EX）
    // ==========================
    logic [31:0] ex_pc, ex_instr, ex_regs_A, ex_regs_B, ex_imm_num;
    logic [3:0]  ex_funct;
    logic [4:0]  ex_rd_num, ex_rs1, ex_rs2;
    logic        ex_RegWrite, ex_MemWrite;
    logic [1:0]  ex_MemToReg;
    logic        ex_OffsetOrigin, ex_ALUSrc, ex_isBranch;
    logic [2:0]  ex_br_type;
    logic [3:0]  ex_alu_control;
    logic id_forward_rs1;
    logic id_forward_rs2;

    // ==========================
    // EX 阶段
    // ==========================
    logic [31:0] ex_alu_result;

    // ==========================
    // EX/MM 中转寄存器（EX → MM）
    // ==========================
    logic [31:0] mm_regs_B, mm_alu_result, mm_imm_num;
    logic [1:0]  mm_MemToReg;
    logic        mm_MemWrite;
    logic [3:0]  mm_funct;
    logic [4:0] mm_rd_num;
    logic [4:0] mm_rs2;

    // 分支判断结果（EX 阶段）
    logic [31:0] br_pc;
    logic        br_ctrl;

    // ==========================
    // MM/WB 中转寄存器（MM → WB）
    // ==========================
    logic [31:0] wb_alu_result, wb_imm_num, mm_rdata,wb_rdata;
    logic [1:0]  wb_MemToReg;
    logic [3:0]  wb_funct;

    // ==========================
    // WB 阶段
    // ==========================
    logic        wb_RegWrite;
    logic [4:0]  wb_rd_num, w_regs_addr;
    logic [31:0] final_write_data, w_regs_data;
    logic        w_regs_en;
    logic [1:0]  mm_offset,wb_offset;

    // ==========================
    // Forwarding 单元
    // ==========================
    logic [1:0] forwardA, forwardB;
    logic       forward_data;

    // ==========================
    // 冒险控制单元
    // ==========================
    logic flush;
    logic stall;



    assign br_sign = br_ctrl;
    assign br_addr = br_pc;
    assign w_regs_addr = wb_rd_num;
    assign w_regs_data = final_write_data;
    assign w_regs_en = wb_RegWrite;

    // ---------- 模块实例化 ----------

    IF_moment if_inst (
        .clk(cpu_clk),
        .rst(cpu_rst),
        .stall(stall),
        .br_sign(br_sign),
        .br_addr(br_addr),
        .if_pc(if_pc),
        .instr(instr),
        .if_instr(if_instr)
    );
    
    if_id_transition if_id_inst (
        .clk          (cpu_clk),
        .rst          (cpu_rst),
        .if_pc        (if_pc),
        .if_inst      (if_instr),
        .if_id_flush  (flush),
        .if_id_stall  (stall),
        .id_pc        (id_pc),
        .id_inst      (id_instr)
    );

    ID_moment id_inst (
        .clk(cpu_clk),
        .rst(cpu_rst),
        .id_pc(id_pc),
        .id_instr(id_instr),
        .w_regs_en(w_regs_en),
        .w_regs_addr(w_regs_addr),
        .w_regs_data(w_regs_data),
        .id_res1(id_regs_A),
        .id_res2(id_regs_B),
        .id_imm_num(id_imm_num),
        .id_funct(id_funct),
        .id_rd_num(id_rd_num),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_forward_rs1(id_forward_rs1),
        .id_forward_rs2(id_forward_rs2),
        .id_RegWrite(id_RegWrite),
        .id_MemToReg(id_MemToReg),
        .id_MemWrite(id_MemWrite),
        .id_OffsetOrigin(id_OffsetOrigin),
        .id_ALUSrc(id_ALUSrc),
        .id_br_type(id_br_type),
        .id_alu_control(id_alu_control),
        .id_isBranch(id_isBranch)
    );


    id_ex_transition u_id_ex_transition (
        .clk           (cpu_clk),
        .rst           (cpu_rst),
        .id_pc         (id_pc),
        .id_instr      (id_instr),
        .id_regs_A     (id_regs_A),
        .id_regs_B     (id_regs_B),
        .id_imm_num    (id_imm_num),
        .id_funct      (id_funct),
        .id_rd_num     (id_rd_num),
        .id_rs1        (id_rs1),
        .id_rs2        (id_rs2),
        .id_RegWrite   (id_RegWrite),
        .id_MemToReg   (id_MemToReg),
        .id_MemWrite   (id_MemWrite),
        .id_OffsetOrigin(id_OffsetOrigin),
        .id_ALUSrc     (id_ALUSrc),
        .id_br_type    (id_br_type),
        .id_alu_control(id_alu_control),
        .id_isBranch   (id_isBranch),

        .id_ex_stall   (stall),
        .id_ex_flush   (flush),

        .ex_pc         (ex_pc),
        .ex_instr      (ex_instr),
        .ex_regs_A     (ex_regs_A),
        .ex_regs_B     (ex_regs_B),
        .ex_imm_num    (ex_imm_num),
        .ex_funct      (ex_funct),
        .ex_rd_num     (ex_rd_num),
        .ex_rs1        (ex_rs1),
        .ex_rs2        (ex_rs2),
        .ex_RegWrite   (ex_RegWrite),
        .ex_MemToReg   (ex_MemToReg),
        .ex_MemWrite   (ex_MemWrite),
        .ex_OffsetOrigin(ex_OffsetOrigin),
        .ex_ALUSrc     (ex_ALUSrc),
        .ex_br_type    (ex_br_type),
        .ex_alu_control(ex_alu_control),
        .ex_isBranch   (ex_isBranch)
    );


    EX_moment u_EX_moment (
        .clk           (cpu_clk),
        .rst           (cpu_rst),
        .ex_rs1        (ex_rs1),
        .ex_rs2        (ex_rs2),
        .ex_pc         (ex_pc),
        .ex_regs_A     (ex_regs_A),
        .ex_regs_B     (ex_regs_B),
        .ex_funct      (ex_funct),
        .ex_rd_num     (ex_rd_num),
        .ex_imm_num    (ex_imm_num),

        .forwardA      (forwardA),
        .forwardB      (forwardB),
        .mm_alu_result (mm_alu_result),
        .w_regs_data   (w_regs_data),

        .ex_RegWrite   (ex_RegWrite),
        .ex_MemToReg   (ex_MemToReg),
        .ex_MemWrite   (ex_MemWrite),
        .ex_OffsetOrigin(ex_OffsetOrigin),
        .ex_ALUSrc     (ex_ALUSrc),
        .ex_br_type    (ex_br_type),
        .ex_alu_control(ex_alu_control),
        .ex_isBranch   (ex_isBranch),

        .ex_alu_result (ex_alu_result),
        .br_pc         (br_pc),
        .br_ctrl       (br_ctrl)
    );

    ex_mm_transition ex_mm_inst (
        .clk           (cpu_clk),
        .rst           (cpu_rst),
        .ex_imm_num    (ex_imm_num),
        .ex_RegWrite   (ex_RegWrite),
        .ex_MemWrite   (ex_MemWrite),
        .ex_MemToReg   (ex_MemToReg),
        .ex_funct      (ex_funct),
        .ex_rs2        (ex_rs2),
        .ex_regs_B     (ex_regs_B),
        .ex_alu_result (ex_alu_result),
        .ex_rd_num     (ex_rd_num),


        .mm_imm_num    (mm_imm_num),
        .mm_RegWrite   (mm_RegWrite),
        .mm_MemWrite   (mm_MemWrite),
        .mm_MemToReg   (mm_MemToReg),
        .mm_funct      (mm_funct),
        .mm_rs2        (mm_rs2),
        .mm_regs_B     (mm_regs_B),
        .mm_alu_result (mm_alu_result),
        .mm_rd_num     (mm_rd_num)
    );

    MM_moment mm_inst (
        .mm_imm_num(mm_imm_num),
        .mm_RegWrite(mm_RegWrite),
        .mm_MemToReg(mm_MemToReg),
        .mm_alu_result(mm_alu_result),
        .mm_regs_B(mm_regs_B),
        .mm_funct(mm_funct),
        .mm_MemWrite(mm_MemWrite),
        .w_regs_data(w_regs_data),
        .forward_data(forward_data),

        .mem_daddr(mem_daddr),
        .mem_wen(mem_wen),
        .mem_mask(mem_mask),
        .mem_din(mem_din),
        .mem_dout(mem_dout),
        .mm_offset(mm_offset),
        .mm_rdata(mm_rdata)
    );

    mm_wb_transition mm_wb_inst (
        .clk           (cpu_clk),
        .rst           (cpu_rst),

        .mm_alu_result (mm_alu_result),
        .mm_imm_num    (mm_imm_num),
        .mm_MemToReg   (mm_MemToReg),
        .mm_funct      (mm_funct),
        .mm_MemWrite   (mm_MemWrite),
        .mm_rd_num     (mm_rd_num),
        .mm_RegWrite   (mm_RegWrite),
        .mm_offset     (mm_offset),
        .mm_rdata      (mm_rdata),

        .wb_alu_result (wb_alu_result),
        .wb_imm_num    (wb_imm_num),
        .wb_MemToReg   (wb_MemToReg),
        .wb_funct      (wb_funct),
        .wb_MemWrite   (wb_MemWrite),
        .wb_rd_num     (wb_rd_num),
        .wb_RegWrite   (wb_RegWrite),
        .wb_offset     (wb_offset),
        .wb_rdata      (wb_rdata)
    );

    WB_moment wb_inst (
        .wb_alu_result(wb_alu_result),
        .wb_imm_num(wb_imm_num),
        .wb_rdata(wb_rdata),
        .wb_MemToReg(wb_MemToReg),
        .wb_funct(wb_funct),
        .wb_offset(wb_offset),
        .w_regs_data(final_write_data)
    );

    forward forward_inst (
        .id_rs1        (id_rs1),
        .id_rs2        (id_rs2),
        .ex_rs1        (ex_rs1),         // EX阶段源寄存器rs1
        .ex_rs2        (ex_rs2),         // EX阶段源寄存器rs2
        .mm_rd_num     (mm_rd_num),      // MEM阶段目的寄存器rd
        .wb_rd_num     (wb_rd_num),      // WB阶段目的寄存器rd
        .mm_regs_B_num (mm_rs2),      // MEM阶段store指令的rs2寄存器（用于forward_data）
        .mm_RegWrite   (mm_RegWrite),    // MEM阶段是否写寄存器
        .wb_RegWrite   (wb_RegWrite),    // WB阶段是否写寄存器

        .forwardA      (forwardA),       // Forward路径A的控制信号
        .forwardB      (forwardB),       // Forward路径B的控制信号
        .forward_data  (forward_data),    // store数据是否需要forward
        .id_forward_rs1(id_forward_rs1),
        .id_forward_rs2(id_forward_rs2)
    );

    hard_check hazard_init (
        .ex_MemToReg(ex_MemToReg),         // MEM阶段指令是否是load
        .id_rs1(id_rs1),                   // ID阶段 rs1
        .id_rs2(id_rs2),                   // ID阶段 rs2
        .ex_rd_num(ex_rd_num),            // EX阶段的写回目标寄存器号
        .forward_data(forward_data),      // 是否满足load+store转发条件
        .br_ctrl(br_ctrl),           // 分支跳转信号（为1时flush）

        .stall(stall),                    // 输出：是否插入气泡
        .flush(flush)                     // 输出：是否清空IF/ID、ID/EX等寄存器
    );

endmodule
