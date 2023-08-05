`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2023 06:13:24 PM
// Design Name: 
// Module Name: TestDebounce
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


module TestDebounce();

// generate clock
localparam CLK_PERIOD = 10; //ns, 100MHz
reg clk = 0;
initial clk = 1'b0;
always #( CLK_PERIOD/2.0 )
    clk = ~clk;

// test input register
reg [4:0] raw = 4'b01010;
wire [4:0] debounced;

// generate 1 byte serial
initial begin

    #100;
    raw <= 5'b00001;
    
    #100;
    raw <= 5'b00010;

    #100;
    raw <= 5'b00101;
    
    #100;
    raw <= 5'b01100;

    #100;
    raw <= 5'b10001;
        
end

// module to test
Debouncer #( .LATCH_RATE(10000000), .LATCH_COUNT(3) ) dbc( .clk(clk), .raw(raw), .debounced(debounced) );

endmodule
