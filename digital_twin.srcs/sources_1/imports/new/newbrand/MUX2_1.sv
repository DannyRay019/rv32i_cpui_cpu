`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/18 11:42:16
// Design Name: 
// Module Name: MUX2_1
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

module MUX2_1 #(
    parameter WIDTH = 32
)
(
    input  logic [WIDTH - 1:0] A          ,
    input  logic [WIDTH - 1:0] B          ,
    input  logic Control    ,
    output logic [WIDTH - 1:0] Result
);
    // 2-1 mux
    always_comb begin
        if(Control==1'b0) Result = A;
        else if(Control==1'b1) Result = B;
    end
endmodule