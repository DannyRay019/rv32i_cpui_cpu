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

module controller(
    input  logic [6:0]  opcode      ,
    output logic        RegWrite    ,
    output logic [1:0]  MemToReg    ,
    output logic        MemWrite    ,
    output logic        OffsetOrigin,
    output logic        ALUSrc ,     
    output logic [2:0]  br_type
);
   // controller module
    always_comb begin
        case(opcode)
            7'b0110011 : begin  //R
                RegWrite = 1;
                MemToReg = 2'b01;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrc = 0;
                br_type = 3'b000;
            end
            7'b0010011 : begin //I
                RegWrite = 1;
                MemToReg = 2'b01;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrc = 1;
                br_type = 3'b000;
            end
            7'b0000011 : begin //L
                RegWrite = 1;
                MemToReg = 2'b10;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrc = 1;
                br_type = 3'b000;
            end
            7'b1100111 : begin  //jalr
                RegWrite = 1;
                MemToReg = 2'b01;
                MemWrite = 0;
                OffsetOrigin = 1;
                ALUSrc = 1;
                br_type = 3'b001;
            end
            7'b0100011 : begin   // S
                RegWrite = 0;
                MemToReg = 2'b01;
                MemWrite = 1;
                OffsetOrigin = 0;
                ALUSrc = 1;
                br_type = 3'b000;
            end
            7'b1100011 : begin     //  B
                RegWrite = 0;
                MemToReg = 2'b01;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrc = 0;
                br_type = 3'b010;
            end
            7'b0110111 : begin   //  lui
                RegWrite = 1;
                MemToReg = 2'b11    ;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrc = 1;
                br_type = 3'b000;
            end
            7'b1101111 : begin   //  jal
                RegWrite = 1;
                MemToReg = 2'b01;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrc = 0;
                br_type = 3'b011;
            end
            7'b0010111 : begin  //aupic
                RegWrite = 1;
                MemToReg = 2'b01;
                MemWrite = 0;
                OffsetOrigin = 0;
                ALUSrc = 0;
                br_type = 3'b100;
            end
            default: begin
                RegWrite     = 0;
                MemToReg     = 2'b00;
                MemWrite     = 0;
                OffsetOrigin = 0;
                ALUSrc       = 0;
                br_type      = 3'b000; 
            end
        endcase
    end
endmodule

