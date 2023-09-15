`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2023 09:56:49 AM
// Design Name: 
// Module Name: TestDelay
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


module TestDelay();

    // generate clock
    localparam CLK_PERIOD = 10; //ns, 100MHz
    reg clk = 0;
    initial clk = 1'b0;
    always #( CLK_PERIOD/2.0 )
    clk = ~clk;
    
    wire CE;
    assign CE = 1'b1;
    wire CLR;
    assign CLR = 1'b0;
    wire I;
    assign I = clk;
    wire O;
    wire clk2;
    assign clk2 = O;
    
    reg setType = 0; // 0=amp, 1=rpm
    localparam MAX_AMP = 100;
    reg signed [9:0] setData = $rtoi(0.5*MAX_AMP);
    
    // setData in ascii
    wire [7:0] SET_DATA_TYPE;
    assign SET_DATA_TYPE = setType==1 ? 82 : // R
                           65;               // A
    wire [7:0] SET_DATA_SIGN;
    assign SET_DATA_SIGN = setData<0 ? 45 : // -
                           43;              // +
    wire [7:0] SET_DATA_100;
    assign SET_DATA_100 = setData%1000>=900 || setData%1000<=-900 ? 57 :
                          setData%1000>=800 || setData%1000<=-800 ? 56 :
                          setData%1000>=700 || setData%1000<=-700 ? 55 :
                          setData%1000>=600 || setData%1000<=-600 ? 54 :
                          setData%1000>=500 || setData%1000<=-500 ? 53 :
                          setData%1000>=400 || setData%1000<=-400 ? 52 :
                          setData%1000>=300 || setData%1000<=-300 ? 51 :
                          setData%1000>=200 || setData%1000<=-200 ? 50 :
                          setData%1000>=100 || setData%1000<=-100 ? 49 :
                          48;
                          
    wire [7:0] SET_DATA_10;
    assign SET_DATA_10 = setData%100>=90 || setData%100<=-90 ? 57 :
                         setData%100>=80 || setData%100<=-80 ? 56 :
                         setData%100>=70 || setData%100<=-70 ? 55 :
                         setData%100>=60 || setData%100<=-60 ? 54 :
                         setData%100>=50 || setData%100<=-50 ? 53 :
                         setData%100>=40 || setData%100<=-40 ? 52 :
                         setData%100>=30 || setData%100<=-30 ? 51 :
                         setData%100>=20 || setData%100<=-20 ? 50 :
                         setData%100>=10 || setData%100<=-10 ? 49 :
                         48;
    wire [7:0] SET_DATA_1;
    assign SET_DATA_1 = setData%10>=9 || setData%10<=-9 ? 57 :
                        setData%10>=8 || setData%10<=-8 ? 56 :
                        setData%10>=7 || setData%10<=-7 ? 55 :
                        setData%10>=6 || setData%10<=-6 ? 54 :
                        setData%10>=5 || setData%10<=-5 ? 53 :
                        setData%10>=4 || setData%10<=-4 ? 52 :
                        setData%10>=3 || setData%10<=-3 ? 51 :
                        setData%10>=2 || setData%10<=-2 ? 50 :
                        setData%10>=1 || setData%10<=-1 ? 49 :
                        48;
                        
    localparam integer MAX_MSGCOUNT = 7;
    reg [($clog2(MAX_MSGCOUNT)-1):0] msgCount = 0;
    reg [7:0] msgBuffer [(MAX_MSGCOUNT-1):0];
    reg [1:0] counter = 0;

    
    // reset test
    integer i;
    initial begin
    
        counter <= 2'b00;
        setType <= 1'b0;
        for ( i=0; i<MAX_MSGCOUNT; i=i+1 ) begin
            msgBuffer[i] <= 0;
        end
        
        setData <= 46;
        
        #30
                
        setData <= 55;
        
        #30
        
        setData <= 46;
        
        #30
                
        setData <= 55;
        
        #30
        
        setData <= 46;        
        #30
                
        setData <= 55;
        
        #30
        
        setData <= 46;
                    
    end
    
    // reset test
    reg state = 1'b0;
    initial begin
    
        setType <= 1'b0;
        state <= 1'b0;
            
    end
    
    always @ ( posedge clk2 ) begin
    
        case ( state )
                        
            0: // clip value
                begin
                    setType <= 1;
                    state <= 1;
                end
                                
            1: // send out value through uart
                begin
                    counter <= counter + 1;
                    msgBuffer[6] <= SET_DATA_TYPE;
                    msgBuffer[5] <= SET_DATA_SIGN;
                    msgBuffer[4] <= counter;//SET_DATA_100;
                    msgBuffer[3] <= setData[7:0];//SET_DATA_10;
                    msgBuffer[2] <= counter;//SET_DATA_1;
                    msgBuffer[1] <= 10;
                    msgBuffer[0] <= 13;
                    msgCount <= 7;
                    state <= 0;
                end
                
        endcase
        
    end

// BUFGCE_DIV  : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (BUFGCE_DIV_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // BUFGCE_DIV: General Clock Buffer with Divide Function
   //             Kintex UltraScale
   // Xilinx HDL Language Template, version 2023.1

   BUFGCE_DIV #(
      .BUFGCE_DIVIDE(8),         // 1-8
      // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
      .IS_CE_INVERTED(1'b0),     // Optional inversion for CE
      .IS_CLR_INVERTED(1'b0),    // Optional inversion for CLR
      .IS_I_INVERTED(1'b0),      // Optional inversion for I
      .SIM_DEVICE("ULTRASCALE")  // ULTRASCALE
   )
   BUFGCE_DIV_inst (
      .O(O),     // 1-bit output: Buffer
      .CE(CE),   // 1-bit input: Buffer enable
      .CLR(CLR), // 1-bit input: Asynchronous clear
      .I(I)      // 1-bit input: Buffer
   );

   // End of BUFGCE_DIV_inst instantiation
					
endmodule
