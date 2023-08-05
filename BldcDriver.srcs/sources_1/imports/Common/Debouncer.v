`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 05:08:23 AM
// Design Name: 
// Module Name: Debouncer
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


module Debouncer
#(parameter LATCH_RATE = 1000, parameter LATCH_COUNT = 3, parameter INPUT_WIDTH = 5) (
    input clk,
    input [(INPUT_WIDTH-1):0] raw,
    output reg [(INPUT_WIDTH-1):0] debounced = {INPUT_WIDTH{1'b0}}
    );

    // Create internal clock
    wire clkLatch;
    SquareWave #(.FREQUENCY(LATCH_RATE)) squareWare(.clk(clk),.out(clkLatch),.dutyFactor(8'd127));
    
    // Create counter for each debounce signal
    reg [$clog2(LATCH_COUNT+1):0] counterArray [(INPUT_WIDTH-1):0];
    integer idx;
    initial begin
        for (idx=0;idx<INPUT_WIDTH;idx=idx+1) begin
            counterArray[idx] <= 0;
        end
    end
    
    // Set counter at negative clock edge
    always @ (negedge(clkLatch)) begin

        for (idx=0;idx<INPUT_WIDTH;idx=idx+1) begin
            if ( !debounced[idx] ) begin
                if ( raw[idx] ) begin
                    if ( counterArray[idx] < LATCH_COUNT ) begin
                        counterArray[idx] <= counterArray[idx] + 1;
                    end
                end else begin
                    counterArray[idx] <= 0;
                end
            end else begin
                if ( !raw[idx] ) begin
                    if ( counterArray[idx] > 0 ) begin
                        counterArray[idx] <= counterArray[idx] - 1;
                    end
                end else begin
                    counterArray[idx] <= LATCH_COUNT;
                end
            end
        end
        
    end
    
    // Latch debug on positive clock edge
    always @ (posedge(clkLatch)) begin
    
        for (idx=0;idx<INPUT_WIDTH;idx=idx+1) begin
            if ( ( counterArray[idx] == LATCH_COUNT ) && !debounced[idx] ) begin
                debounced[idx] <= 1'b1;
            end else if ( ( counterArray[idx] == 0 ) && debounced[idx] ) begin
                debounced[idx] <= 1'b0;
            end
        end
        
    end

endmodule
