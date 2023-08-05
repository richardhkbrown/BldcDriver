`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/04/2023 05:32:09 PM
// Design Name: 
// Module Name: ModulateBldc
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


module ModulateBldc
#(parameter CLK_RATE = 100000000, parameter MAXRPM=256) (
    input clk,
    input [9:0] rpm,
    output [15:0] test
    );

    reg [15:0] counter = 0;
    always @ ( posedge( clk ) ) begin
        counter <= counter + 1;
    end
    assign test = counter;

endmodule
