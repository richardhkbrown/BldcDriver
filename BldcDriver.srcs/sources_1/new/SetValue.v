`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2023 04:51:57 AM
// Design Name: 
// Module Name: SetValue
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


module SetValue(
    input clk,
    input [4:0] btns,
    output reg signed [9:0] rpm = {10'b0},
    output reg signed [9:0] amp = {10'b0}
    );
    
    // assign btns = {btnC,btnU,btnL,btnR,btnD};
    reg [4:0] btnsLock = {5'b0};
    integer idx;
    integer pick;
    always  @ (negedge(clk)) begin
    
        pick = 0;

        for ( idx=0; idx<5; idx = idx+1 ) begin
        
            if ( btns[idx] && !btnsLock[idx] ) begin
                btnsLock[idx] <= 1;
                pick[idx] = 1'b1;
                
                if ( idx==4 ) begin // 4 btnC
                    rpm <= 0;
                    amp <= 0;
                    pick[idx+10] = 1'b1;
                end else if ( idx==0 && amp!=10'b1000000001 ) begin // 0 btnD
                    amp <= amp - 1;
                    pick[idx+10] = 1'b1;
                end else if ( idx==3 && amp!=10'b0111111111 ) begin // 3 btnU
                    amp <= amp + 1;
                    pick[idx+10] = 1'b1;
                end else if ( idx==2 && rpm!=10'b1000000001 ) begin // 2 btnL
                    rpm <= rpm - 1;
                    pick[idx+10] = 1'b1;
                end else if ( idx==1 && rpm!=10'b0111111111 ) begin // 1 btnU
                    rpm <= rpm + 1;
                    pick[idx+10] = 1'b1;
                end
                
            end else if ( !btns[idx] && btnsLock[idx] ) begin
                btnsLock[idx] <= 0;
                pick[idx+20] = 1'b1;
            end
            
        end

    end

endmodule
