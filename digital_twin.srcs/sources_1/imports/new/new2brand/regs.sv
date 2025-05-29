


module regs #(
    parameter   ADDR_WIDTH = 5  ,
    parameter   DATAWIDTH  = 32
)(
    input  logic                    clk            ,
    input  logic                    rst            ,
    // Write rd                   
    input  logic                    wen      ,
    input  logic [ADDR_WIDTH - 1:0] waddr    ,
    input  logic [DATAWIDTH - 1:0]  wdata       ,
    // Read  rs1 rs2
    input  logic [ADDR_WIDTH - 1:0] rR1   ,
    input  logic [ADDR_WIDTH - 1:0] rR2   ,

    output logic [DATAWIDTH - 1:0]  rR1_data  ,
    output logic [DATAWIDTH - 1:0]  rR2_data
);
    logic [DATAWIDTH - 1:0] reg_bank [31:0];
    always_comb begin
        rR1_data = reg_bank[rR1];
        rR2_data = reg_bank[rR2];
    end

    integer i;
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            for (i = 0; i < 32; i = i + 1)
                reg_bank[i] <= '0;
        end
        else begin
            if(wen == 1 && waddr != 0) begin 
                reg_bank[waddr] <= wdata;
            end
        end
    end
endmodule