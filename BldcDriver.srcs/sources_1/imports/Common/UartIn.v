`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2023 04:55:28 PM
// Design Name: 
// Module Name: UartIn
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


module UartIn
#(parameter BAUD = 9600) (
    input clk,
    input RsRx,
    output dataAvail,
    input req,
    output reg ack = 0,
    output [7:0] dataOut
    );
    
    // Creat 1 cycle counter
    localparam integer CLK_RATE = 100000000; // 100 MHz Artix7
    localparam real PERIOD = CLK_RATE/BAUD;
    localparam integer BITS_NEEDED = $clog2($rtoi(PERIOD+1));
    localparam integer HALF_COUNT = $rtoi(0.5*PERIOD);
    localparam integer RESET_COUNT = $rtoi(PERIOD);
    reg [(BITS_NEEDED-1):0] counter = 0;
    
    // Fifo connections
    wire ALMOSTEMPTY;
    wire ALMOSTFULL;
    wire [7:0] DO;
    wire EMPTY;
    wire FULL;
    wire [10:0] RDCOUNT;
    wire RDERR;
    wire [10:0] WRCOUNT;
    wire WRERR;
    wire CLK;
    reg [7:0] DI;
    reg RDEN = 0;
    reg RST = 1;
    reg WREN = 0;
    
    // Wire assignment
    assign CLK = clk;
    reg [($clog2(10+1)-1):0] fifoResetCount = 10;
    assign dataAvail = !EMPTY && (fifoResetCount==0);
    assign dataOut = DO;
    
    // Reset fifo
    always @ (posedge(CLK)) begin
        RST <= (fifoResetCount>=4);
        if ( fifoResetCount>0 ) begin
            fifoResetCount <= fifoResetCount - 1;
        end
    end
    
    // Byte reader
    reg [($clog2(11+1)-1):0] state = 0; // 11 is max state
    always @ (posedge(CLK)) begin
    
        case(state)
        
            0:
                if (!RsRx && (fifoResetCount==0)) begin
                    state <= 1;
                end
                
            1:
                if (counter==HALF_COUNT) begin
                    state <= state + 1;
                end
                
            2,3,4,5,6,7,8,9:
                begin
                    if (counter==HALF_COUNT) begin
                        DI[state-2] <= RsRx;
                        state <= state + 1;
                    end
                end
                
            10:
                if (counter==HALF_COUNT) begin
                    state <= 11;
                end
                
            11:
                state <= 0;
                
        endcase
    
    end
    
    // Increment counter
    always @ (negedge(CLK)) begin
    
        if ( state!=0 && counter<RESET_COUNT ) begin
            counter <= counter+1;
        end else begin
            counter <= 0;
        end
        
        if ( state==11 ) begin
            if (!FULL) begin
                WREN <= 1;
            end
        end else begin
            WREN <= 0;
        end
    
    end
    
    // Request Handler
    reg [($clog2(2+1)-1):0] reqState = 0;
    always @ (negedge(CLK)) begin
     
        case(reqState)
        
            0:
                if ( !req ) begin
                    // Prevent lockup
                    if ( RDEN ) begin
                        RDEN <= 0;
                    end
                    if ( ack ) begin
                        ack <= 0;
                    end
                end else if ( req && dataAvail ) begin
                    RDEN <= 1;
                    reqState <= 1;
                end
           
            1:
                begin
                    RDEN <= 0;
                    ack <= 1;
                    reqState <= 2;
                end

            2:
                if ( !req ) begin
                    ack <= 0;
                    reqState <= 0;
                end
            
            default:
                // Prevent lockup
                reqState <= 3'b010;
               
        endcase
        
    end
    
// FIFO_SYNC_MACRO : In order to incorporate this function into the design,
//     Verilog      : the following instance declaration needs to be placed
//    instance      : in the body of the design code.  The instance name
//   declaration    : (FIFO_SYNC_MACRO_inst) and/or the port declarations within the
//      code        : parenthesis may be changed to properly reference and
//                  : connect this function to the design.  All inputs
//                  : and outputs must be connected.

//  <-----Cut code below this line---->

   // FIFO_SYNC_MACRO: Synchronous First-In, First-Out (FIFO) RAM Buffer
   //                  Artix-7
   // Xilinx HDL Language Template, version 2022.2

   /////////////////////////////////////////////////////////////////
   // DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width //
   // ===========|===========|============|=======================//
   //   37-72    |  "36Kb"   |     512    |         9-bit         //
   //   19-36    |  "36Kb"   |    1024    |        10-bit         //
   //   19-36    |  "18Kb"   |     512    |         9-bit         //
   //   10-18    |  "36Kb"   |    2048    |        11-bit         //
   //   10-18    |  "18Kb"   |    1024    |        10-bit         //
   //    5-9     |  "36Kb"   |    4096    |        12-bit         //
   //    5-9     |  "18Kb"   |    2048    |        11-bit         //
   //    1-4     |  "36Kb"   |    8192    |        13-bit         //
   //    1-4     |  "18Kb"   |    4096    |        12-bit         //
   /////////////////////////////////////////////////////////////////

   FIFO_SYNC_MACRO  #(
      .DEVICE("7SERIES"), // Target Device: "7SERIES" 
      .ALMOST_EMPTY_OFFSET(9'h080), // Sets the almost empty threshold
      .ALMOST_FULL_OFFSET(9'h080),  // Sets almost full threshold
      .DATA_WIDTH(8), // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
      .DO_REG(0),     // Optional output register (0 or 1)
      .FIFO_SIZE ("18Kb")  // Target BRAM: "18Kb" or "36Kb" 
   ) FIFO_SYNC_MACRO_inst (
      .ALMOSTEMPTY(ALMOSTEMPTY), // 1-bit output almost empty
      .ALMOSTFULL(ALMOSTFULL),   // 1-bit output almost full
      .DO(DO),                   // Output data, width defined by DATA_WIDTH parameter
      .EMPTY(EMPTY),             // 1-bit output empty
      .FULL(FULL),               // 1-bit output full
      .RDCOUNT(RDCOUNT),         // Output read count, width determined by FIFO depth
      .RDERR(RDERR),             // 1-bit output read error
      .WRCOUNT(WRCOUNT),         // Output write count, width determined by FIFO depth
      .WRERR(WRERR),             // 1-bit output write error
      .CLK(CLK),                 // 1-bit input clock
      .DI(DI),                   // Input data, width defined by DATA_WIDTH parameter
      .RDEN(RDEN),               // 1-bit input read enable
      .RST(RST),                 // 1-bit input reset
      .WREN(WREN)                // 1-bit input write enable
    );

   // End of FIFO_SYNC_MACRO_inst instantiation
				
endmodule
