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
    input clk_48mhz,
    input [(INPUT_WIDTH-1):0] raw,
    output reg [(INPUT_WIDTH-1):0] debounced = {INPUT_WIDTH{1'b0}}
    );

    // Create internal clock
    wire D;
    reg nD;
    wire clkLatchBuf;
    SquareWave #(.FREQUENCY(LATCH_RATE)) squareWare(.clk_48mhz(clk_48mhz),.D(D));
    
    // Create counter for each debounce signal
    reg [$clog2(LATCH_COUNT+1):0] counterArray [(INPUT_WIDTH-1):0];
    integer idx;
    initial begin
        for ( idx=0; idx<INPUT_WIDTH; idx=idx+1 ) begin
            counterArray[idx] <= {($clog2(LATCH_COUNT+1)+1){1'b0}};
        end
    end
    
    always @ ( posedge(clk_48mhz) ) begin
    
        nD <= !D; // value @ next clock cycle
    
        // Latch positive D edge
        if ( D && nD ) begin

            // set counterArray
            for ( idx=0; idx<INPUT_WIDTH; idx=idx+1 ) begin
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

            // Set debounce value based on counter array
            for ( idx=0; idx<INPUT_WIDTH; idx=idx+1 ) begin
                if ( ( counterArray[idx] == LATCH_COUNT ) && !debounced[idx] ) begin
                    debounced[idx] <= 1'b1;
                end else if ( ( counterArray[idx] == 0 ) && debounced[idx] ) begin
                    debounced[idx] <= 1'b0;
                end
            end
               
        end
        
    end

endmodule
