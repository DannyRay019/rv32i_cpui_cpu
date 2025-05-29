`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/24 10:51:04
// Design Name: 
// Module Name: myCPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module myCPU (
    input  logic         cpu_rst,
    input  logic         cpu_clk,

    // Interface to IROM, you need add some signals
    input logic [31:0] instr,
    output logic [31:0] pc_addr,
    // Interface to DRAM, you need add some signals
    output logic         wen,
    input logic [31:0]   dout,
    output logic [31:0]  din,
    output logic  [31:0] daddr,
    output logic [1:0] mask

);

    logic [31:0] npc_num;
    logic [31:0] pc_num;
    PC #(
        .DATAWIDTH  (32),
        .RESET_VAL  (32'h8000_0000)
    ) pc_inst(
        .clk        (cpu_clk),
        .rst        (cpu_rst),
        .npc        (npc_num), 
        .pc_out     (pc_num)
    );
    assign pc_addr = pc_num[31:0];

    logic [31:0] instr_num;
    assign instr_num = instr;
    
    logic [31:0] imm_num;
    IMMGEN #(
        .DATAWIDTH  (32)	
    )imm_gen_inst (
        .instr   (instr_num),
        .imm     (imm_num)  
    );

    logic [31:0] alu_A;
    logic [31:0] alu_B;
    logic [31:0] wdata_num;
    logic regwrite_num;

    RF #(
        .ADDR_WIDTH (5),
        .DATAWIDTH  (32)
    )reg_file_inst (
        .clk             (cpu_clk),
        .rst             (cpu_rst),
        .wen       (regwrite_num),
        .waddr     (instr_num[11:7]),
        .wdata        (wdata_num),
        .rR1    (instr_num[19:15]),
        .rR2    (instr_num[24:20]),
        .rR1_data   (alu_A),
        .rR2_data   (alu_B)
    );

    logic [1:0] npcop_num;
    logic [2:0] memtoreg_num;
    logic memwrite_num;
    logic offsetchoose_num;
    logic alusrca_num;
    logic alusrcb_num;

    Control control_inst (
        .opcode(instr_num[6:0]),
        .NpcOp(npcop_num),
        .RegWrite(regwrite_num),
        .MemToReg(memtoreg_num), 
        .MemWrite(memwrite_num), 
        .OffsetOrigin(offsetchoose_num),
        .ALUSrcA(alusrca_num),
        .ALUSrcB(alusrcb_num)
    );

    logic [31:0] res_A;
    logic [31:0] res_B;

    assign res_A = (alusrca_num==0)?alu_A:pc_num;
    assign res_B = (alusrcb_num==0)?alu_B:imm_num;

    logic [3:0] alucontrol_num;
    ACTL ALU_controller_inst(
        .opcode(instr_num[6:0]),
        .funct({instr_num[30],instr_num[14:12]}),
        .ALUControl(alucontrol_num)
    );

    logic [31:0] alu_res;
    logic isTrue;
    ALU# (
        .DATAWIDTH  (32)	
    ) alu_inst (
        .A           (res_A),
        .B           (res_B),
        .ALUControl  (alucontrol_num),
        .Result      (alu_res),
        .isTrue      (isTrue)
    );

    logic [31:0] dout_num;
    assign wen = memwrite_num;
    assign mask = instr_num[13:12];

    mask #(
        .DATAWIDTH(32)
    ) mask_init (
        .mask(instr_num[14:12]),
        .dout(dout),
        .mdata(dout_num)
    );

    assign din = alu_B;

    assign daddr = alu_res;

    MUX5_1 #(
        .WIDTH      (32)
    ) mux_wdata(
        .A          (pcadd4_num),
        .B          (alu_res),
        .C          (dout_num),
        .D          (imm_num),
        .Control    (memtoreg_num),
        .Result     (wdata_num)
    );

    logic [31:0] offset_num;
    MUX2_1 #(
        .WIDTH      (32)
    ) mux_pc(
        .A          (imm_num),
        .B          (alu_res),
        .Control    (offsetchoose_num),
        .Result     (offset_num)
    );
    
    logic [31:0] pcadd4_num;
    NPC #(
        .DATAWIDTH(32)
    ) npc_inst(
        .isTrue(isTrue),
        .npc_op(npcop_num),
        .pc(pc_num),
        .offset(offset_num),
        .npc(npc_num),
        .pcadd4(pcadd4_num)
    );


endmodule
