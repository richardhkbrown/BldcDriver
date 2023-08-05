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


module GhzPll(
    input clk,
    output clk1Ghz
    );
                      
    wire CLKOUT0;
    wire CLKOUT0_buf;
    wire CLKOUT1;
    wire CLKOUT2;
    wire CLKOUT3;
    wire CLKOUT4;
    wire LOCKED;
    wire CLKIN1;
    wire PWRDWN;
    wire RST;

    assign CLKIN1 = clk;
    assign PWRDWN = 1'b0;
    assign RST = 1'b0;
    
    assign clk1Ghz = CLKOUT0_buf;
    
// PLLE2_BASE  : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (PLLE2_BASE_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // PLLE2_BASE: Base Phase Locked Loop (PLL)
   //             Artix-7
   // Xilinx HDL Language Template, version 2023.1

   PLLE2_BASE #(
      .BANDWIDTH("OPTIMIZED"),  // OPTIMIZED, HIGH, LOW
      .CLKFBOUT_MULT(10),        // Multiply value for all CLKOUT, (2-64), PLL VCO fequency (800.000 - 1600.000 MHz)
      .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
      .CLKIN1_PERIOD(10.0),      // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
      .CLKOUT0_DIVIDE(1),
      .CLKOUT1_DIVIDE(2),
      .CLKOUT2_DIVIDE(3),
      .CLKOUT3_DIVIDE(4),
      .CLKOUT4_DIVIDE(5),
      .CLKOUT5_DIVIDE(6),
      // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .DIVCLK_DIVIDE(1),        // Master division value, (1-56)
      .REF_JITTER1(0.0),        // Reference input jitter in UI, (0.000-0.999).
      .STARTUP_WAIT("TRUE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
   )
   PLLE2_BASE_inst (
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
      .CLKOUT0(CLKOUT0),   // 1-bit output: CLKOUT0
      .CLKOUT1(CLKOUT1),   // 1-bit output: CLKOUT1
      .CLKOUT2(CLKOUT2),   // 1-bit output: CLKOUT2
      .CLKOUT3(CLKOUT3),   // 1-bit output: CLKOUT3
      .CLKOUT4(CLKOUT4),   // 1-bit output: CLKOUT4
      .CLKOUT5(CLKOUT5),   // 1-bit output: CLKOUT5
      // Feedback Clocks: 1-bit (each) output: Clock feedback ports
      .CLKFBOUT(CLKFB), // 1-bit output: Feedback clock
      .LOCKED(LOCKED),     // 1-bit output: LOCK
      .CLKIN1(CLKIN1),     // 1-bit input: Input clock
      // Control Ports: 1-bit (each) input: PLL control ports
      .PWRDWN(PWRDWN),     // 1-bit input: Power-down
      .RST(RST),           // 1-bit input: Reset
      // Feedback Clocks: 1-bit (each) input: Clock feedback ports
      .CLKFBIN(CLKFB)    // 1-bit input: Feedback clock
   );

// End of PLLE2_BASE_inst instantiation
//    BUFG     : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (BUFG_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // BUFG: Global Clock Simple Buffer
   //       Artix-7
   // Xilinx HDL Language Template, version 2023.1

   BUFG BUFG_inst (
      .O(CLKOUT0_buf), // 1-bit output: Clock output
      .I(CLKOUT0)  // 1-bit input: Clock input
   );
   
   // End of BUFG_inst instantiation

endmodule