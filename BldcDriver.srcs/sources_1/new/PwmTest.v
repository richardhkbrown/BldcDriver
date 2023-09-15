`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2023 08:03:59 PM
// Design Name: 
// Module Name: PwmTest
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


module PwmTest(
input clk,
output led
);

    reg test = 1'b0;
    always @ (negedge(clk)) begin
       test = !test;
    end
    assign led = test;
    
endmodule
