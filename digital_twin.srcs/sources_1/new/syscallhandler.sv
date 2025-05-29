module syscallhandler #(
    parameter   DATAWIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  syscall_taken,   // 软中断信号，表示发生系统调用
    input  logic [DATAWIDTH-1:0]  syscall_cause,   // 系统调用的具体原因
    input  logic [DATAWIDTH-1:0]  syscall_pc,      // 系统调用前的PC
    input  logic [DATAWIDTH-1:0]  syscall_sp,      // 系统调用时的堆栈指针

    output logic [DATAWIDTH-1:0]  syscall_return_pc,  // 系统调用完成后，返回的PC
    output logic [DATAWIDTH-1:0]  syscall_return_sp   // 系统调用完成后，返回的堆栈指针
);

    // 系统调用处理逻辑
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            syscall_return_pc <= 32'h0;
            syscall_return_sp <= 32'h0;
        end else if (syscall_taken) begin
            // 模拟保存系统调用前的上下文，处理系统调用
            syscall_return_pc <= syscall_pc + 4;  // 返回到系统调用后的位置
            syscall_return_sp <= syscall_sp;      // 恢复堆栈指针
        end
    end

endmodule
