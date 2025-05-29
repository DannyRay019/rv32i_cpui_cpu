module Scheduler #(
    parameter   DATAWIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  tick,      // 定时器中断触发
    input  logic                  trap_taken, // 中断或异常触发
    input  logic [DATAWIDTH-1:0]  current_pc, // 当前PC
    input  logic [DATAWIDTH-1:0]  task_sp,   // 当前任务的堆栈指针
    output logic [DATAWIDTH-1:0]  next_pc,    // 下一个任务的PC
    output logic [DATAWIDTH-1:0]  next_sp     // 下一个任务的堆栈指针
);

    // 存储任务的上下文
    reg [DATAWIDTH-1:0] task_pc [0:7];  // 假设有8个任务
    reg [DATAWIDTH-1:0] task_sp [0:7];
    reg [2:0] current_task; // 当前任务标识
    reg [2:0] next_task;    // 下一个任务标识

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_task <= 3'b000; // 默认选择第一个任务
        end else if (tick) begin
            current_task <= next_task; // 每次定时器溢出时切换任务
        end
    end

    // 更新任务堆栈和PC
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            task_pc[0] <= 32'h0;  // 第一个任务的PC
            task_sp[0] <= 32'h0;  // 第一个任务的堆栈指针
            // 其余任务可以初始化为不同的值
        end else if (trap_taken) begin
            // 保存当前任务的上下文
            task_pc[current_task] <= current_pc;
            task_sp[current_task] <= task_sp[current_task];
        end
    end

    // 选择下一个任务
    always_comb begin
        next_task = current_task + 1;  // 这里可以通过更复杂的调度算法来选择任务
        next_pc = task_pc[next_task];  // 加载下一个任务的PC
        next_sp = task_sp[next_task];  // 加载下一个任务的堆栈指针
    end

endmodule
