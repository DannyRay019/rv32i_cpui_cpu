
module ID_moment(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] id_pc,
    input  logic [31:0] id_instr,
    input  logic        w_regs_en,
    input  logic [4:0]  w_regs_addr,
    input  logic [31:0] w_regs_data,

    output logic [31:0] id_res1,
    output logic [31:0] id_res2,
    output logic [31:0] id_imm_num,
    output logic [3:0]  id_funct,
    output logic [4:0]  id_rd_num,
    output logic [4:0]  id_rs1,
    output logic [4:0]  id_rs2,
    input logic id_forward_rs1,
    input logic id_forward_rs2,
    output logic        id_RegWrite,
    output logic [1:0]  id_MemToReg,
    output logic        id_MemWrite,
    output logic        id_OffsetOrigin,
    output logic        id_ALUSrc,
    output logic [2:0]  id_br_type,

    output logic [3:0] id_alu_control,
    output logic id_isBranch
);

    logic [31:0] id_regs_A;
    logic [31:0] id_regs_B;

    assign id_rs1        = id_instr[19:15];
    assign id_rs2        = id_instr[24:20];
    assign id_rd_num     = id_instr[11:7];
    assign id_funct = {id_instr[30],id_instr[14:12]};

    // 寄存器堆例化
    regs #(
        .ADDR_WIDTH(5),
        .DATAWIDTH(32)
    ) u_reg(
        .clk      (clk),
        .rst      (rst),
        .wen      (w_regs_en),
        .waddr    (w_regs_addr),
        .wdata    (w_regs_data),
        .rR1      (id_rs1),
        .rR2      (id_rs2),
        .rR1_data (id_regs_A),
        .rR2_data (id_regs_B)
    );
    assign id_res1 = (id_forward_rs1==1)?w_regs_data:id_regs_A;
    assign id_res2 = (id_forward_rs2==1)?w_regs_data:id_regs_B;

    // 立即数生成器例化
    immgen u_immgen (
        .instr (id_instr),
        .imm   (id_imm_num)
    );

    // 控制单元例化
    controller u_ctrl (
        .opcode       (id_instr[6:0]),
        .RegWrite     (id_RegWrite),
        .MemToReg     (id_MemToReg),
        .MemWrite     (id_MemWrite),
        .OffsetOrigin (id_OffsetOrigin),
        .ALUSrc       (id_ALUSrc),
        .br_type   (id_br_type)
    );
    // 调用 ACTL 子模块，生成 ALU 控制信号
    alu_control u_actl (
        .opcode      (id_instr[6:0]), // 假设你把 ex_alu_op 映射为 opcode 的低位
        .funct       (id_funct),
        .ALUControl  (id_alu_control),
        .isBranch    (id_isBranch)
    );

endmodule