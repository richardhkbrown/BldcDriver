`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2023 05:41:19 AM
// Design Name: 
// Module Name: SegmentDisplay
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


module SegmentDisplay
#(parameter REFRESH = 240) (
    input clk,
    input [9:0] digits,
    input [3:0] decimals,
    output [6:0] seg,
    output dp,
    output [3:0] an
    );

// 7-segment encoding
//      0
//     ---
//  5 |   | 1
//     --- <--6
//  4 |   | 2
//     ---
//      3

    localparam DIG_MAX = 1023;
    localparam DIG_WIDTH = $clog2(DIG_MAX+1);

    // Zero is active
    wire [7:0] SEGMENTS [15:0];
    assign SEGMENTS[0] = 7'b1000000;
    assign SEGMENTS[1] = 7'b1111001;
    assign SEGMENTS[2] = 7'b0100100;
    assign SEGMENTS[3] = 7'b0110000;
    assign SEGMENTS[4] = 7'b0011001;
    assign SEGMENTS[5] = 7'b0010010;
    assign SEGMENTS[6] = 7'b0000010;
    assign SEGMENTS[7] = 7'b1111000;
    assign SEGMENTS[8] = 7'b0000000;
    assign SEGMENTS[9] = 7'b0010000;
    assign SEGMENTS[10] = 7'b0001000;
    assign SEGMENTS[11] = 7'b0000011;
    assign SEGMENTS[12] = 7'b1000110;
    assign SEGMENTS[13] = 7'b0100001;
    assign SEGMENTS[14] = 7'b0000110;
    assign SEGMENTS[15] = 7'b0001110;
    
    wire [6:0] TENBIT [DIG_MAX:0][2:0];
    wire [$clog2(10+1):0] ones;
    wire [$clog2(10+1):0] tens;
    wire [$clog2(10+1):0] hundreds;
    genvar idx;
    generate
        for (idx=0;idx<2**(DIG_WIDTH-1);idx=idx+1) begin
            assign TENBIT[idx][0] = SEGMENTS[idx%10];
            assign TENBIT[idx][1] = SEGMENTS[$rtoi($floor($itor(idx%100)/10.0))];
            assign TENBIT[idx][2] = SEGMENTS[$rtoi($floor($itor(idx%1000)/100.0))];
        end
        for (idx=(2**(DIG_WIDTH-1));idx<(2**DIG_WIDTH);idx=idx+1) begin
            // IDXI = 2**DIG_WIDTH-idx
            assign TENBIT[idx][0] = SEGMENTS[(2**DIG_WIDTH-idx)%10];
            assign TENBIT[idx][1] = SEGMENTS[$rtoi($floor($itor((2**DIG_WIDTH-idx)%100)/10.0))];
            assign TENBIT[idx][2] = SEGMENTS[$rtoi($floor($itor((2**DIG_WIDTH-idx)%1000)/100.0))];
        end
    endgenerate
    
    wire clkSegment;
    SquareWave #(.FREQUENCY(REFRESH)) squareWare(.clk(clk),.out(clkSegment),.dutyFactor(8'd127));
    
    reg [1:0] counter = 0;
    always @ (posedge(clkSegment)) begin
        counter = counter+1;
    end

    wire [6:0] segWire;
    wire dpWire;
    wire [3:0] anWire;
    reg [6:0] segReg = 0;
    reg dpReg = 0;
    reg [3:0] anReg = 0;
    assign seg = segReg;
    assign dp = dpReg;
    assign an = anReg;
    
    assign anWire = counter==0 ? 4'b1110 :
                    counter==1 ? 4'b1101 :
                    counter==2 ? 4'b1011 :
                    counter==3 ? 4'b0111 :
                    4'b1111;
    
    assign segWire = counter==0 ? TENBIT[digits[(DIG_WIDTH-1):0]][0] :
                     counter==1 ? TENBIT[digits[(DIG_WIDTH-1):0]][1] :
                     counter==2 ? TENBIT[digits[(DIG_WIDTH-1):0]][2] :
                     counter==3 && digits[(DIG_WIDTH-1)] ? 7'b0111111 :
                     7'b1111111;
                 
    assign dpWire = ~decimals[counter];
        
    always @ (negedge(clkSegment)) begin
        anReg <= anWire;
        segReg <= segWire;
        dpReg <= dpWire;
    end
    
endmodule
