module Timer #(
    parameter   DATAWIDTH = 32,
    parameter   TICK_FREQ = 1000000  // 定时器频率（例如 1 MHz）
)(
    input  logic                  clk,
    input  logic                  rst,
    output logic                  tick,  // 每次定时器溢出时触发tick
    input  logic [DATAWIDTH-1:0]  current_time
);

    reg [DATAWIDTH-1:0] counter;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 32'h0;
        end else begin
            if (counter == TICK_FREQ - 1) begin
                counter <= 32'h0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    // 定时器溢出时触发tick信号
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            tick <= 0;
        end else if (counter == TICK_FREQ - 1) begin
            tick <= 1;  // 计时器溢出，发出tick信号
        end else begin
            tick <= 0;
        end
    end

endmodule
