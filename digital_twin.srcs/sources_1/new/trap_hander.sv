module trap_hander #(
    parameter   DATAWIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  trap_taken,    // 触发异常或中断
    input  logic [DATAWIDTH-1:0]  trap_cause,    // 异常或中断的原因
    input  logic [DATAWIDTH-1:0]  trap_pc,       // 异常时的PC
    input  logic [DATAWIDTH-1:0]  trap_epc,      // 异常返回地址（M-mode中对应mePC）

    output logic [DATAWIDTH-1:0]  new_pc,        // 异常处理后的PC
    output logic                  context_restore,  // 恢复上下文标志
    output logic                  trap_handled    // 异常是否已处理标志
);

    // 状态机状态定义
    typedef enum logic [1:0] {
        IDLE    = 2'b00, // 空闲状态
        HANDLE  = 2'b01, // 异常处理中
        RESTORE = 2'b10  // 恢复上下文
    } state_t;

    state_t state, next_state;

    // 状态机逻辑
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // 状态转移
    always_comb begin
        case (state)
            IDLE: begin
                if (trap_taken) begin
                    next_state = HANDLE;  // 当有异常或中断时转到HANDLE
                end else begin
                    next_state = IDLE;    // 否则保持空闲状态
                end
            end
            HANDLE: begin
                next_state = RESTORE;  // 异常处理中，转到恢复上下文阶段
            end
            RESTORE: begin
                next_state = IDLE;     // 恢复上下文后返回空闲
            end
            default: next_state = IDLE;
        endcase
    end

    // 控制信号
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            new_pc <= 32'h0;          // 默认PC为0
            context_restore <= 0;     // 默认不恢复上下文
            trap_handled <= 0;        // 默认没有处理完异常
        end else begin
            case (state)
                IDLE: begin
                    new_pc <= 32'h0; // 等待异常触发
                    context_restore <= 0;
                    trap_handled <= 0;
                end
                HANDLE: begin
                    // 异常处理中，设置新的PC
                    new_pc <= trap_pc;   // 将异常触发前的PC保存到新的PC
                    context_restore <= 1; // 设置上下文恢复标志
                    trap_handled <= 0;    // 异常处理尚未完成
                end
                RESTORE: begin
                    // 恢复上下文，准备跳转
                    new_pc <= trap_epc;   // 恢复到异常发生前的地址
                    context_restore <= 0;  // 清除上下文恢复标志
                    trap_handled <= 1;     // 异常处理完成
                end
                default: begin
                    new_pc <= 32'h0;
                    context_restore <= 0;
                    trap_handled <= 0;
                end
            endcase
        end
    end

endmodule
