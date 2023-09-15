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
#(parameter FREQUENCY = 9600, parameter DUTY_FACTOR = 0.5) (
    input clk_48mhz,
    output reg D = 1'b0
    );

    localparam [63:0] CLK_RATE = 48000000; // 48 Mhz
    localparam [63:0] RESET_COUNT = $rtoi((1.0/FREQUENCY)/(1.0/CLK_RATE));
    localparam [63:0] DUTY_COUNT = $rtoi(DUTY_FACTOR*(1.0/FREQUENCY)/(1.0/CLK_RATE));

    wire [31:0] Q;
    wire TC;
    wire CLK;
    wire CE;
    wire RST;
    assign CLK = clk_48mhz;
    assign CE = 1'b1;
    assign RST = 1'b0;

    reg D2 = 1'b0;
    always @ ( posedge(clk_48mhz) ) begin
            
        if ( Q <= DUTY_COUNT ) begin
            D <= 1'b1;
        end else begin
            D <= 1'b0;
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
      .WIDTH_DATA(32)              // Counter output bus width, 1-48
   ) COUNTER_TC_MACRO_inst (
      .Q(Q),     // Counter output bus, width determined by WIDTH_DATA parameter
      .TC(TC),   // 1-bit terminal count output, high = terminal count is reached
      .CLK(CLK), // 1-bit positive edge clock input
      .CE(CE),   // 1-bit active high clock enable input
      .RST(RST)  // 1-bit active high synchronous reset
   );

   // End of COUNTER_TC_MACRO_inst instantiation
					 
endmodule
