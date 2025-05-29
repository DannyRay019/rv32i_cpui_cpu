`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/18 11:22:17
// Design Name: 
// Module Name: IMMGEN
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

module IMMGEN#(
    parameter   DATAWIDTH = 32	
)(
    input  logic [31:0]            instr   ,
    output logic [DATAWIDTH - 1:0] imm       
);
   // imm generator
   logic [6:0] opcode;
    always_comb begin
        opcode = instr[6:0];

        case (opcode)
            // I-type: addi, andi, ori, lw, jalr
            7'b0010011, 7'b0000011, 7'b1100111: begin
                imm = {{20{instr[31]}}, instr[31:20]};
            end

            // S-type: sw, sb, sh
            7'b0100011: begin
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type: beq, bne, blt, bge
            7'b1100011: begin
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            // U-type: lui, auipc
            7'b0110111: begin
                imm = {instr[31:12], 12'b0};  // 左移12位
            end

            // J-type: jal
            7'b1101111: begin
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            7'b0010111: begin
                imm = {instr[31:12], 12'b0};
            end

            default: begin
                imm = 32'b0;  // 无立即数（如R型）默认值
            end
        endcase
    end
endmodule