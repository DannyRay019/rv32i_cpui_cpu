module hard_check (
    input  logic [1:0] ex_MemToReg,         // EX阶段指令是否是load
    input  logic [4:0] id_rs1,             // ID阶段指令的rs1
    input  logic [4:0] id_rs2,             // ID阶段指令的rs2
    input  logic [4:0] ex_rd_num,              // EX阶段指令的rd
    input  logic       forward_data, // ID阶段指令是否是store并可能forward数据
    input  logic       br_ctrl,

    output logic       stall,              // 是否暂停流水线（插入气泡）
    output logic       flush               // 是否清除ID/EX（分支或ret）
);

    logic load_stall;
    logic stall_exception;

    // 如果当前EX是load，且其rd和ID阶段rs1或rs2冲突，说明是典型的load-use冒险
    assign load_stall = (ex_MemToReg==2'b10) && ((ex_rd_num == id_rs1) || (ex_rd_num == id_rs2));

    // 特殊例外：load紧跟store，且store要写入的rs2正是load目标，允许forward，不用stuck
    assign stall_exception =  (ex_MemToReg==2'b10) && forward_data && (ex_rd_num == id_rs2);

    // 是否需要清空流水线
    assign flush = br_ctrl;

    // 是否需要暂停（stall）
    assign stall = load_stall && ~stall_exception;

endmodule
