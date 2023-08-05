`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2023 06:30:57 AM
// Design Name: 
// Module Name: TestModulatePwn
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


module TestModulatePwn();

    // generate clock
    localparam CLK_PERIOD = 10; //ns, 100MHz
    reg clk = 0;
    initial clk = 1'b0;
    always #( CLK_PERIOD/2.0 )
    clk = ~clk;
  
    wire [9:0] ampData;
    assign ampData = 50;

    wire [31:0] counter;
    wire [31:0] resetCount;
    ModulatePwm #(.CLK_RATE(100000000),.FREQUENCY(10000)) modPwm( .clk(clk), .amp(ampData), .counter(counter), .resetCount(resetCount) );
    
    wire [31:0] Q;
    wire TC;
    wire CLK;
    wire CE;
    reg RST = 1'b0;
    
    assign CLK = clk;
    assign CE = 1'b1;
        
    // reset test
    initial begin
    
        #200;
        RST <= 1'b1;
        
        #10;
        RST <= 1'b0;
            
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
      .TC_VALUE(32'h00000005),     // Terminal count value
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
