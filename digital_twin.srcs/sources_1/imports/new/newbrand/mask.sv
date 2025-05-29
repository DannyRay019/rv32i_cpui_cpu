`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/01 23:37:25
// Design Name: 
// Module Name: mask
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


module mask#(
    parameter   DATAWIDTH = 32	
)(
    input  logic [2:0]             mask   ,
    input  logic [DATAWIDTH - 1:0] dout	  ,
	output logic [DATAWIDTH - 1:0] mdata
);
    logic op_other, op_lb, op_lh;

    assign op_lb = mask == 3'b000;
    assign op_lh = mask == 3'b001;
    assign op_other = ~(op_lh | op_lb);

    assign mdata = {32{op_lb}} & {{25{dout[7]}}, dout[6:0]} |
                {32{op_lh}} & {{17{dout[15]}}, dout[14:0]} |
                {32{op_other}} & dout;

endmodule