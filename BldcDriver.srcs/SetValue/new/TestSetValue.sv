`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2023 04:57:10 AM
// Design Name: 
// Module Name: TestSetValue
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


module TestSetValue();

// generate clock
localparam CLK_PERIOD = 10; //ns, 100MHz
reg clk = 0;
initial clk = 1'b0;
always #( CLK_PERIOD/2.0 )
clk = ~clk;

// test input register
reg [4:0] btnsDbc = 4'b00000;
wire [9:0] rpm;
wire [9:0] amp;
    
// assign btns = {btnC,btnU,btnL,btnR,btnD};
integer idx;
initial begin

    for ( idx=0; idx<600; idx = idx+1 ) begin
        #20;
        btnsDbc <= 5'b00001;
        #40;
        btnsDbc <= 5'b00000;
    end


    for ( idx=0; idx<2000; idx = idx+1 ) begin
        #20;
        btnsDbc <= 5'b01000;
        #40;
        btnsDbc <= 5'b00000;
    end
    
end

SetValue sv( .clk(clk), .btns(btnsDbc), .rpm(rpm), .amp(amp) );

endmodule
