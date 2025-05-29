module EX_moment(
    input  logic        clk, // yjk add
    input  logic        rst, // yjk add
    input  logic [4:0]  ex_rs1,
    input  logic [4:0]  ex_rs2,
    input  logic [31:0] ex_pc,
    input  logic [31:0] ex_regs_A,   // rs1
    input  logic [31:0] ex_regs_B,   // rs2
    input logic [3:0]  ex_funct,
    input logic [4:0]   ex_rd_num,
    input  logic [31:0] ex_imm_num,          // 立即数

    input  logic[1:0]   forwardA,
    input  logic[1:0]   forwardB,
    input  logic[31:0]  mm_alu_result,
    input  logic[31:0]  w_regs_data,
    
    input logic        ex_RegWrite,
    input logic [1:0]  ex_MemToReg,
    input logic        ex_MemWrite,
    input logic        ex_OffsetOrigin,
    input logic        ex_ALUSrc,
    input logic [2:0]  ex_br_type,

    input logic [3:0] ex_alu_control,
    input logic ex_isBranch,

    output logic [31:0] ex_alu_result,
    output logic [31:0] br_pc,           
    output logic        br_ctrl          

);

    // 内部连线
    logic [31:0] ex_alu_input1;
    logic [31:0] ex_alu_input2;
    logic        is_true;

    logic [31:0] ex_alu_A,ex_alu_pre_A;
    logic [31:0] ex_alu_B,ex_alu_pre_B;

    assign ex_alu_pre_B        = (forwardB == 2'b10)? mm_alu_result : (forwardB == 2'b01)? w_regs_data : ex_regs_B;
    assign ex_alu_pre_A        = (forwardA == 2'b10)? mm_alu_result : (forwardA == 2'b01)? w_regs_data : ex_regs_A;

    assign ex_alu_A = ex_alu_pre_A;
    
    always_comb begin
        case(ex_ALUSrc)
            1:ex_alu_B = ex_imm_num;
            0:ex_alu_B = ex_alu_pre_B;
        endcase
    end

    always_comb begin
        case(ex_br_type)
            3'b001:begin
                ex_alu_input1 = ex_pc;
                ex_alu_input2 = 32'h4;
            end
            3'b011:begin
                ex_alu_input1 = ex_pc;
                ex_alu_input2 = 32'h4;
            end
            3'b100:begin
                ex_alu_input1 = ex_pc;
                ex_alu_input2 = ex_imm_num;
            end
            default: begin
                ex_alu_input1 = ex_alu_A;
                ex_alu_input2 = ex_alu_B;
            end
        endcase
    end

    // 调用 ALU 执行器
    alu u_alu (
        .A          (ex_alu_input1),
        .B          (ex_alu_input2),
        .ALUControl (ex_alu_control),
        .isBranch   (ex_br_type),
        .Result     (ex_alu_result),
        .is_True    (is_true)
    );

    // 分支判断逻辑
    assign br_ctrl = ((ex_br_type==2'b10) & is_true)|(ex_br_type==2'b01)|(ex_br_type==2'b11);
    always_comb begin
        br_pc = 32'b0;  // 默认值，防止锁存器

        case(ex_br_type)
            3'b001: br_pc = (ex_alu_pre_A + ex_imm_num) & ~1;
            3'b010: br_pc = ex_pc + ex_imm_num;
            3'b011: br_pc = ex_pc + ex_imm_num;
            // 其他情况默认保持 0（或根据需求设置）
        endcase
    end

endmodule
