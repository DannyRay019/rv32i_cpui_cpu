`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 12:42:16
// Design Name: 
// Module Name: NPC
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

module NPC#(
    parameter   DATAWIDTH = 32
)(
    input  logic                   isTrue   ,
    input  logic [1:0]             npc_op   ,
    input  logic [DATAWIDTH - 1:0] pc       ,
    input  logic [DATAWIDTH - 1:0] offset   ,
    output logic [DATAWIDTH - 1:0] npc      ,
    output logic [DATAWIDTH - 1:0] pcadd4 
);
    logic [DATAWIDTH-1:0] add4;
    logic [DATAWIDTH-1:0] addimm;
    adder #(.DATAWIDTH(DATAWIDTH)) pc_adder1 (
        .A      (pc),       // 输入 A = pc
        .B      (32'h4),     // 输入 B = 4（固定值）
        .Result (add4)        // 输出 npc = pc + 4
    );
    adder #(.DATAWIDTH(DATAWIDTH)) pc_adder2 (
        .A      (pc),       // 输入 A = pc
        .B      (offset),     // 输入 B = 4（固定值）
        .Result (addimm)        // 输出 npc = pc + 4
    );
    
    always_comb begin
        case (npc_op)
            2'b00: begin
                npc = add4;
            end
            2'b01: begin
                if (isTrue) npc = addimm;
                else npc = add4;
            end
            2'b10: begin
                npc = offset & ~1;
            end
            2'b11: begin
                npc = addimm;
            end
            default: begin
                npc = 0;
            end
        endcase
    end
    assign pcadd4 = add4;

endmodule