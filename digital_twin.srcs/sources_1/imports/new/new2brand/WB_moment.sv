
module WB_moment (
    input  logic [31:0]  wb_alu_result,   // ALU 计算结果（例如：地址或计算值）
    input  logic [31:0]  wb_imm_num,      // 立即数（可选，用于某些情况）
    input  logic [31:0]  wb_rdata,        // 从内存中读取出来的数据
    input  logic [1:0]   wb_MemToReg,     // 写回来源选择
    input  logic [3:0]   wb_funct,        // funct 用于判断 load 类型（低 3 位）
    input logic [1:0] wb_offset,

    output logic [31:0]  w_regs_data      // 要写回寄存器堆的数据
);

    logic [2:0] mask;
    assign mask = wb_funct[2:0];

    logic [31:0] load_result;

    always_comb begin
        // 默认值
        load_result = 32'b0;

        case (mask)
            3'b000: begin // LB
                load_result = {{24{wb_rdata[7]}}, wb_rdata[7:0]}; // 符号扩展
            end
            3'b001: begin // LH
                load_result = {{16{wb_rdata[15]}}, wb_rdata[15:0]}; // 符号扩展
            end
            3'b010: begin // LW（必须自然对齐）
                load_result = wb_rdata;
            end
            3'b100: begin // LBU
                load_result = wb_rdata; // 零扩展
            end
            3'b101: begin // LHU
                load_result = wb_rdata; 
            end
            default: load_result = 32'b0;
        endcase
    end

    always_comb begin
        case (wb_MemToReg)
            2'b01: w_regs_data = wb_alu_result;  // 通常用于 R 类型指令
            2'b10: w_regs_data = load_result;    // Load 类型指令
            2'b11: w_regs_data = wb_imm_num;     // JAL、AUIPC 等立即数写回
            default: w_regs_data = 32'b0;
        endcase
    end

endmodule
