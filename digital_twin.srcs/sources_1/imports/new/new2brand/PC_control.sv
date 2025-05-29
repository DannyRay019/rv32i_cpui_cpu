module PC_control(
    input  logic        clk,
    input  logic        rst,
    input  logic        stall,
    input  logic        br_sign,
    input  logic [31:0] br_pc,
    output logic [31:0] pc
);

    logic [31:0] pc_next;
    logic [31:0] reg_pc;
    logic rst_delay;

    always_comb begin
        if (br_sign) begin
            pc_next = br_pc;
        end else begin
            pc_next = pc + 4;
        end
    end

    always_ff @(posedge clk) begin
        rst_delay <= rst;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst|rst_delay) begin
            reg_pc <= 32'h8000_0000;
        end
        else if(stall==1) begin
            reg_pc <= reg_pc;
        end
        else begin
            reg_pc <= pc_next;
        end
    end

    assign pc = reg_pc;

endmodule
