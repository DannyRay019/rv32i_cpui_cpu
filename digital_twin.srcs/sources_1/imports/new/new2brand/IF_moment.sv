
module IF_moment(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic br_sign,
    input logic [31:0] br_addr,
    output logic [31:0] if_pc,
    input logic [31:0] instr,
    output logic [31:0] if_instr
);

PC_control pc_inst(
    .clk(clk)  ,
    .rst(rst),    
    .stall(stall),
    .br_sign(br_sign),
    .br_pc(br_addr),
    .pc(if_pc)
);

assign if_instr=instr;

endmodule
