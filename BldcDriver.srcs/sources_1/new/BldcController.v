`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2023 01:11:51 PM
// Design Name: 
// Module Name: BldcController
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


module BldcController
#(parameter PWM = 20000, parameter DUTY_LEVELS = 512) (
    input clk,
    input [9:0] amp,
    input [9:0] rpm,
    output [2:0] en,
    output [2:0] hi,
    output [2:0] lo
    );
    
    // Create internal clock
    wire clkPwm;
    SquareWave #(.FREQUENCY(PWM*DUTY_LEVELS)) squareWare(.clk(clk),.out(clkLatch),.dutyFactor(8'd127));
    
endmodule
