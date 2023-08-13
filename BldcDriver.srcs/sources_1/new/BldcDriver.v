`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2023 08:06:27 PM
// Design Name: 
// Module Name: BldcDriver
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


module BldcDriver(
input clk,
output [6:0] seg,
output dp,
output [3:0] an,
output RsTx,
input btnC,
input btnU,
input btnL,
input btnR,
input btnD,
input RsRx,
output [15:0] led,
output [5:0] JA
);

    // User interface implementation
        
    wire [3:0] decimals;
    wire [9:0] digits;
    SegmentDisplay segDisp( .clk(clk), .digits(digits), .decimals(decimals), .seg(seg), .dp(dp), .an(an) );
    
    wire [4:0] btns;
    assign btns = {btnC,btnU,btnL,btnR,btnD};
    wire [4:0] btnsDbc;
    Debouncer #( .LATCH_RATE(1000), .LATCH_COUNT(3), .INPUT_WIDTH(5) ) dbc( .clk(clk), .raw(btns), .debounced(btnsDbc) );
    
    wire uinDatAvail;
    wire uinReq;
    wire uinAck;
    wire [7:0] uinDataOut;
    UartIn uin( .clk(clk), .RsRx(RsRx), .dataAvail(uinDatAvail), .req(uinReq),
        .ack(uinAck), .dataOut(uinDataOut) );
    
    wire uoutDataFull;
    wire uoutReq;
    wire uoutAck;
    wire [7:0] uoutDataIn;
    UartOut uout( .clk(clk), .RsTx(RsTx), .dataFull(uoutDataFull), .req(uoutReq),
        .ack(uoutAck), .dataIn(uoutDataIn) );    

    wire setReq;
    reg setAck = 0;
    wire setType;
    wire [9:0] setData;
    BldcUart bldcUart( .clk(clk), .btns(btnsDbc),
        .dataAvail(uinDatAvail), .inData(uinDataOut), .inReq(uinReq), .inAck(uinAck),
        .outData(uoutDataIn), .outReq(uoutReq), .outAck(uoutAck),
        .setReq(setReq), .setAck(setAck), .setType(setType), .setData(setData) );
    
    reg signed [9:0] ampData = 50;
    reg signed [9:0] rpmData = 0;
    reg [($clog2(2+1)-1):0] state = 0;
    always @ (posedge(clk)) begin
    
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
    
    // Output implementation
    
    wire clk1Ghz;
    GhzPll ghzPll( .clk(clk), .clk1Ghz(clk1Ghz) );
    
    wire D;
    ModulatePwm #(.CLK_RATE(1000000000),.FREQUENCY(20000),.MAXAMP(100)) modPwm( .clk(clk1Ghz), .amp(ampData), .D(D) );
    
    wire [$clog2(6):0] seq;
    ModulateBldc #(.CLK_RATE(100000000),.MAXRPM(400)) modBldc( .clk(clk), .rpm(rpmData), .seq(seq) );
    
    // 2 L298N H-Bridge drivers 
    reg [5:0] hBus = 9'b00000;
    always @ ( posedge( clk ) ) begin
    
        case(seq)
        
            0:
                hBus = {D   ,1'b1,!D  ,1'b1,1'b0,1'b0};
            1:
                hBus = {D   ,1'b1,1'b0,1'b0,!D  ,1'b1};
            2:
                hBus = {1'b0,1'b0,D   ,1'b1,!D  ,1'b1};
            3:
                hBus = {!D  ,1'b1,D   ,1'b1,1'b0,1'b0};
            4:
                hBus = {!D  ,1'b1,1'b0,1'b0,D   ,1'b1};
            5:
                hBus = {1'b0,1'b0,!D  ,1'b1,D   ,1'b1};
                
        endcase
    end
    assign JA = hBus;
    
    assign led[15-:8] = {8{D}};
    assign led[0+:6] = hBus;
    
endmodule
