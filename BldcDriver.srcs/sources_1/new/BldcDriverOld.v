`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2023 08:06:27 PM
// Design Name: 
// Module Name: BldcDriver
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


module BldcDriver(
input clk,
output [6:0] seg,
output dp,
output [3:0] an,
input btnC,
input btnU,
input btnL,
input btnR,
input btnD,
output [15:0] led,
input [9:0] sw
    );
    
    wire [3:0] decimals;
    wire [9:0] digits;
    SegmentDisplay segDisp( .clk(clk), .digits(digits), .decimals(decimals), .seg(seg), .dp(dp), .an(an) );
    
    wire [4:0] btns;
    assign btns = {btnC,btnU,btnL,btnR,btnD};
    wire [4:0] btnsDbc;
    Debouncer #( .INPUT_WIDTH(5) ) dbc( .clk(clk), .raw(btns), .debounced(btnsDbc) );
    
    reg [4:0] btnsDbcLast = 5'b00000;
    reg modeRpm = 1'b1;
    always @ (negedge(clk)) begin
    
        if ( (btnsDbcLast[2] && !btnsDbc[2]) ||
             (btnsDbcLast[1] && !btnsDbc[1]) ) begin
            modeRpm <= 1;
        end else if ( (btnsDbcLast[3] && !btnsDbc[3]) ||
                      (btnsDbcLast[0] && !btnsDbc[0]) ) begin
            modeRpm <= 0;
        end
        btnsDbcLast <= btnsDbc;
        
    end
    
    wire [4:0] btnsMask;
    assign btnsMask = btnsDbc & {1'b1,~modeRpm,modeRpm,modeRpm,~modeRpm};

    wire [9:0] rpm;
    wire [9:0] amp;
    SetValue sv( .clk(clk), .btns(btnsMask), .rpm(rpm), .amp(amp) );
    
    assign decimals = {modeRpm,~modeRpm,~modeRpm,modeRpm};
    assign digits = (modeRpm ? rpm : amp) | sw;
    assign led[14:10] = btnsMask;
    assign led[9:0] = digits;
    assign led[15] = modeRpm;
    
endmodule
