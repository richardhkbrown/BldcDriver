`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2023 08:37:38 PM
// Design Name: 
// Module Name: SquareWave
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


module SquareWave
#(parameter FREQUENCY = 9600) (
    input clk,
    output reg out = 0,
    input [7:0] dutyFactor
    );

    // Compute break points
    localparam real PERIOD = 100000000/FREQUENCY;
    localparam integer BITS_NEEDED = $clog2($rtoi(PERIOD+1)); 
    wire [(BITS_NEEDED-1):0] breakPoints [255:0];
    genvar idx;
    generate
        for (idx=0;idx<256;idx=idx+1) begin
            assign breakPoints[idx] = $rtoi(PERIOD*idx/255);
        end
    endgenerate

    // Create counter
    localparam integer PULSE_PERIOD = $rtoi(PERIOD);
    reg [(BITS_NEEDED-1):0] counter = 0;
    always @ (negedge(clk)) begin
        if ( counter < PULSE_PERIOD ) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
        end
    end
    
    // Latch output at positive edge
    wire outWire;
    assign outWire = (counter <= breakPoints[dutyFactor]);
    always @ (posedge(clk)) begin
        out <= outWire;
    end
            
endmodule
