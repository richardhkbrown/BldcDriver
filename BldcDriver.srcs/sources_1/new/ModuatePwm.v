`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/15/2023 10:17:47 PM
// Design Name: 
// Module Name: ModuatePwm
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


module ModulatePwm
#(parameter [63:0] CLK_RATE = 100000000, parameter FREQUENCY=10000, parameter MAXAMP=256) (
    input clk,
    input [9:0] amp,
    output reg D // changes on negedge clk
    );
    
    localparam [63:0] RESET_COUNT = $rtoi((1.0/FREQUENCY)/(1.0/CLK_RATE));
    wire [31:0] Q;
    wire TC;
    wire CLK;
    wire CE;
    wire RST;
    assign CLK = clk;
    assign CE = 1'b1;
    assign RST = 1'b0;
    
    wire [31:0] LEVEL_VALS [MAXAMP:0];
    genvar i;
    generate
        for ( i = 0; i < (MAXAMP+1); i = i + 1 ) begin
            assign LEVEL_VALS[i] = $rtoi( 1.0*RESET_COUNT*i/MAXAMP );
        end
    endgenerate
        
    always @ ( negedge(clk) ) begin
        if ( Q <= LEVEL_VALS[amp[($clog2(MAXAMP+1)-1):0]] ) begin
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
