`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2023 10:44:18 AM
// Design Name: 
// Module Name: Proto
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


module Proto(
input clk,
output [6:0] seg,
output dp,
output [3:0] an,
input RsRx,
output RsTx,
input btnC,
input btnU,
input btnL,
input btnR,
input btnD
    );
    
    // Clocks
    wire CLKOUT_1200;
    wire CLKOUT_48;
    wire CLKOUT_10;
    wire CLKOUT_100;
    wire CLKOUT_33_3;
    wire CLKOUT_9_475;
    wire CLKFBOUT;
    wire LOCKED;
    wire CLKIN1;
    wire PWRDWN;
    wire RST;
    assign CLKIN1 = clk;
    assign PWRDWN = 1'b0;
    assign RST = 1'b0;
    assign CLKFBIN = CLKFBOUT;
        
    // User interface implementation
    
    wire [3:0] decimals;
    wire [9:0] digits;
    SegmentDisplay segDisp( .clk_48mhz(CLKOUT_48), .digits(digits), .decimals(decimals), .seg(seg), .dp(dp), .an(an) );
    
    wire uinDatAvail;
    wire uinReq;
    wire uinAck;
    wire [7:0] uinDataOut;
    UartIn uin( .clk_48mhz(CLKOUT_48), .RsRx(RsRx), .dataAvail(uinDatAvail), .req(uinReq),
        .ack(uinAck), .dataOut(uinDataOut) );
        
    wire uoutDataFull;
    wire uoutReq;
    wire uoutAck;
    wire [7:0] uoutDataIn;
    UartOut uout( .clk_48mhz(CLKOUT_48), .RsTx(RsTx), .dataFull(uoutDataFull), .req(uoutReq),
        .ack(uoutAck), .dataIn(uoutDataIn) );

    wire [4:0] btns;
    assign btns = {btnC,btnU,btnL,btnR,btnD};
    wire [4:0] btnsDbc;
    Debouncer #( .INPUT_WIDTH(5) ) dbc( .clk_48mhz(CLKOUT_48), .raw(btns), .debounced(btnsDbc) );

    wire setReq;
    reg setAck = 0;
    wire setType;
    wire [9:0] setData;
    BldcUart bldcUart( .clk_48mhz(CLKOUT_48), .btns(btnsDbc),
        .dataAvail(uinDatAvail), .inData(uinDataOut), .inReq(uinReq), .inAck(uinAck),
        .outData(uoutDataIn), .outReq(uoutReq), .outAck(uoutAck),
        .setReq(setReq), .setAck(setAck), .setType(setType), .setData(setData) );

    reg signed [9:0] ampData = 50;
    reg signed [9:0] rpmData = 0;
    reg [($clog2(2+1)-1):0] state = 0;
    always @ ( posedge(CLKOUT_48) ) begin
    
        case(state)
        
            0:
                if ( setReq ) begin
                    setAck <= 1;
                    if ( setType==0 ) begin
                        ampData <= setData;
                    end else if ( setType==1 ) begin
                        rpmData <= setData;
                    end
                    state <= 1;
                end
            
            1:
                if ( !setReq ) begin
                    setAck <= 0;
                    state <= 0;
                end

        endcase
        
    end

    assign digits = setType==1 ? rpmData :
                    ampData;
    assign decimals = setType==1 ? {4'b0000} :
                      {4'b1111};

//    ModulatePwm #( .FREQUENCY(10000), .MAXAMP(100) ) modPwm(
//        .clk_48mhz(CLKOUT_48), .amp(ampData), .D(led[0]) );
//    assign led[15:1] = 15'b101010101010101;
    
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
      .CLKFBOUT_MULT(12),        // Multiply value for all CLKOUT, (2-64), PLL VCO fequency (800.000 - 1600.000 MHz)
      .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
      .CLKIN1_PERIOD(10.0),      // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
      .CLKOUT0_DIVIDE(1),   // 1200 MHz
      .CLKOUT1_DIVIDE(25),  // 48 MHz
      .CLKOUT2_DIVIDE(120), // 10 MHz
      .CLKOUT3_DIVIDE(12),  // 100 MHz
      .CLKOUT4_DIVIDE(36),  // 33.3 MHz
      .CLKOUT5_DIVIDE(128), // 9.375 MHz
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
      .STARTUP_WAIT("FALSE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
   )
   PLLE2_BASE_inst (
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
      .CLKOUT0(CLKOUT_1200),   // 1-bit output: CLKOUT0
      .CLKOUT1(CLKOUT_48),   // 1-bit output: CLKOUT1
      .CLKOUT2(CLKOUT_10),   // 1-bit output: CLKOUT2
      .CLKOUT3(CLKOUT_100),   // 1-bit output: CLKOUT3
      .CLKOUT4(CLKOUT_33_3),   // 1-bit output: CLKOUT4
      .CLKOUT5(CLKOUT_9_475),   // 1-bit output: CLKOUT5
      // Feedback Clocks: 1-bit (each) output: Clock feedback ports
      .CLKFBOUT(CLKFBOUT), // 1-bit output: Feedback clock
      .LOCKED(LOCKED),     // 1-bit output: LOCK
      .CLKIN1(CLKIN1),     // 1-bit input: Input clock
      // Control Ports: 1-bit (each) input: PLL control ports
      .PWRDWN(PWRDWN),     // 1-bit input: Power-down
      .RST(RST),           // 1-bit input: Reset
      // Feedback Clocks: 1-bit (each) input: Clock feedback ports
      .CLKFBIN(CLKFBIN)    // 1-bit input: Feedback clock
   );

   // End of PLLE2_BASE_inst instantiation

endmodule
