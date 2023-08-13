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
#(parameter [63:0] CLK_RATE = 100000000, parameter MAXRPM=256) (
    input clk,
    input signed [9:0] rpm,
    output reg [$clog2(6):0] seq = 0 // changes on negedge clk
    );

    localparam integer RESET_WIDTH = $clog2(60*CLK_RATE);
    localparam time RESET_COUNT = 60*CLK_RATE-1;
    wire [31:0] Q;
    wire TC;
    wire CLK;
    wire CE;
    reg RST = 0;
    assign CLK = clk;
    assign CE = 1'b1;
    
    wire [(RESET_WIDTH-1):0] LEVEL_VALS [MAXRPM:0];
    genvar i;
    generate
        for ( i = 0; i < (MAXRPM+1); i = i + 1 ) begin
            // 1/rpm = minutes per revolution 1/6 = 6 phase changes per revolution
            // RESET_COUNT = count to 1 minute
            if ( i>0 ) begin
                assign LEVEL_VALS[i] = $rtoi( (1.0/i/6.0)*RESET_COUNT );
            end else begin
                assign LEVEL_VALS[i] = RESET_COUNT;
            end
        end
    endgenerate

    wire dir;
    assign dir = rpm > 0;
    wire [9:0] absRpm;
    assign absRpm = dir ? rpm :
                    -rpm;
    reg [9:0] absRpmLatch = 0;
    always @ ( posedge(clk) ) begin
        absRpmLatch <= absRpm;
    end
    always @ ( negedge(clk) ) begin
        if ( Q >= LEVEL_VALS[absRpmLatch[($clog2(MAXRPM+1)-1):0]] ) begin
            if ( !RST ) begin
                RST <= 1'b1;
                if ( dir ) begin
                    if ( seq < 5 ) begin
                        seq <= seq + 1;
                    end else begin
                        seq <= 0;
                    end
                end else begin
                    if ( seq > 0 ) begin
                        seq <= seq - 1;
                    end else begin
                        seq <= 5;
                    end 
                end
            end
        end else if ( RST ) begin
            RST <= 0;
        end
    end
    
// COUNTER_TC_MACRO : In order to incorporate this function into the design,
//     Verilog      : the following instance declaration needs to be placed
//    instance      : in the body of the design code.  The instance name
//   declaration    : (COUNTER_TC_MACRO_inst) and/or the port declarations within the
//      code        : parenthesis may be changed to properly reference and
//                  : connect this function to the design.  All inputs
//                  : and outputs must be connected.

//  <-----Cut code below this line---->

   // COUNTER_TC_MACRO: Counter with terminal count implemented in a DSP48E
   //                   Artix-7
   // Xilinx HDL Language Template, version 2023.1

   COUNTER_TC_MACRO #(
      .COUNT_BY(48'h000000000001), // Count by value
      .DEVICE("7SERIES"),          // Target Device: "7SERIES" 
      .DIRECTION("UP"),            // Counter direction, "UP" or "DOWN" 
      .RESET_UPON_TC("TRUE"),      // Reset counter upon terminal count, "TRUE" or "FALSE" 
      .TC_VALUE(RESET_COUNT),      // Terminal count value
      .WIDTH_DATA(RESET_WIDTH)              // Counter output bus width, 1-48
   ) COUNTER_TC_MACRO_inst (
      .Q(Q),     // Counter output bus, width determined by WIDTH_DATA parameter
      .TC(TC),   // 1-bit terminal count output, high = terminal count is reached
      .CLK(CLK), // 1-bit positive edge clock input
      .CE(CE),   // 1-bit active high clock enable input
      .RST(RST)  // 1-bit active high synchronous reset
   );

   // End of COUNTER_TC_MACRO_inst instantiation
   
endmodule
