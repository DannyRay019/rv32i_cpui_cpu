`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/30 8:26:09
// Design Name: 
// Module Name: Control
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
`include "defines.sv"

module Control(
    input  logic [6:0]  opcode      ,
    output logic [1:0]  NpcOp       ,
    output logic        RegWrite    ,
    output logic [2:0]  MemToReg    ,
    output logic        MemWrite    ,
    output logic        OffsetOrigin,
    output logic        ALUSrcA     ,
    output logic        ALUSrcB
);
   // controller module
    always_comb begin
        case(opcode)
            7'b0110011 : begin  //R
                NpcOp = 2'b00;
                RegWrite = 1;
                MemToReg = 3'b001;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrcA = 0;
                ALUSrcB = 0;
            end
            7'b0010011 : begin //I
                NpcOp = 2'b00;
                RegWrite = 1;
                MemToReg = 3'b001;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrcA = 0;
                ALUSrcB = 1;
            end
            7'b0000011 : begin //L
                NpcOp = 2'b00;
                RegWrite = 1;
                MemToReg = 3'b010;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrcA = 0;
                ALUSrcB = 1;
            end
            7'b1100111 : begin  //jalr
                NpcOp = 2'b10;
                RegWrite = 1;
                MemToReg = 3'b000;
                MemWrite = 0;
                OffsetOrigin = 1;
                ALUSrcA = 0;
                ALUSrcB = 1;
            end
            7'b0100011 : begin   // S
                NpcOp = 2'b00;
                RegWrite = 0;
                MemToReg = 3'b001;
                MemWrite = 1;
                OffsetOrigin = 0;
                ALUSrcA = 0;
                ALUSrcB = 1;
            end
            7'b1100011 : begin     //  B
                NpcOp = 2'b01;
                RegWrite = 0;
                MemToReg = 3'b001;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrcA = 0;
                ALUSrcB = 0;
            end
            7'b0110111 : begin   //  lui
                NpcOp = 2'b00;
                RegWrite = 1;
                MemToReg = 3'b011    ;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrcA = 0;
                ALUSrcB = 0;
            end
            7'b1101111 : begin   //  jal
                NpcOp = 2'b11;
                RegWrite = 1;
                MemToReg = 3'b000;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrcA = 0;
                ALUSrcB = 0;
            end
            7'b0010111 : begin  //aupic
                NpcOp = 2'b00;
                RegWrite = 1;
                MemToReg = 3'b001;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrcA = 1;
                ALUSrcB = 1;
            end
        endcase
    end
endmodule

