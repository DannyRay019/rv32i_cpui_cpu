module if_id_transition (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] if_pc,
    input  logic [31:0] if_inst,
    input  logic        if_id_flush,
    input  logic        if_id_stall,
    output logic [31:0] id_pc,
    output logic [31:0] id_inst
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            id_pc   <= 32'b0;
            id_inst <= 32'b0;
        end
        else begin
            if (if_id_flush) begin
                id_pc   <= 32'b0;
                id_inst <= 32'b0;
            end else if (if_id_stall) begin
                id_pc   <= id_pc;
                id_inst <= id_inst;
            end else if (!if_id_stall) begin
                id_pc   <= if_pc;
                id_inst <= if_inst;
            end
        end 
    end

endmodule
