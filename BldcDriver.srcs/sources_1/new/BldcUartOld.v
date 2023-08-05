`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2023 04:31:07 PM
// Design Name: 
// Module Name: BldcUart
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


module BldcUart
#(parameter MAX_AMP = 100, parameter MAX_RPM = 400) (
    input clk,
    input dataAvail,
    input [7:0] inData,
    output reg inReq = 0,
    input inAck,
    output reg [7:0] outData = 0,
    output reg outReq = 0,
    input outAck,
    output reg setReq = 0,
    input setAck,
    output reg setType = 0, // 0=amp, 1=rpm
    output reg signed [9:0] setData = $rtoi(0.5*MAX_AMP)
    );
    
    // Command Handler
    reg firstBuffer = 0;
    reg [($clog2(2+1)-1):0] bufferCount = 0;
    reg [7:0] buffer [3:0];
    wire negative;
    assign negative = buffer[3]==45; // -
    reg [7:0] inDataBuffer = 0;
    reg [($clog2(6+1)-1):0] msg = 0;
    reg [($clog2(2+1)-1):0] mode = 0;
    reg [($clog2(7+1)-1):0] state = 0;
    reg [($clog2(7+1)-1):0] msgState = 0; // logic near bottom
    reg [($clog2(4+1)-1):0] intState = 0; // logic near bottom
    always @ (negedge(clk)) begin
    
        case(state)
        
            0:
                begin
                    msg <= 0;
                    if ( !msgState ) begin // !msgState is no RxTx
                        if ( dataAvail ) begin // uart buffer has character
                            inReq <= 1;
                            if ( mode==0 ) begin // this is the first character
                                state <= 1;
                            end else if ( mode==1 ) begin // this is a value character
                                state <= 4;
                            end
                        end else if ( mode==2 ) begin // this is the last character
                            msg <= 7; // send verification message
                            mode <= 0;
                            state <= 5; // send message to external interface
                        end
                    end
                end
           
            1:
                if ( inAck ) begin
                    if ( inData==65 || inData==97 ) begin // a
                        bufferCount <= 0;
                        buffer[3] = 43; // +
                        buffer[2] = 48; // 0
                        buffer[1] = 48; // 0
                        buffer[0] = 48; // 0
                        setType <= 0;
                        msg <= 1;
                        mode <= 1;
                    end else if ( inData==82 || inData==114 ) begin // r
                        bufferCount <= 0;
                        buffer[3] = 43; // +
                        buffer[2] = 48; // 0
                        buffer[1] = 48; // 0
                        buffer[0] = 48; // 0
                        setType <= 1;
                        msg <= 2;
                        mode <= 1;
                   end else begin // unknown
                        mode <= 0;
                        msg <= 4;
                    end
                    state <= 2;
                end
            
            2:
                begin
                    inReq <= 0;
                    state <= 3;
                end
            
            3:
                if ( !inAck ) begin
                    state <= 0;
                end
            
            4:
                if ( inAck ) begin
                    inDataBuffer <= inData;
                    if ( bufferCount==0 && ( inData==43 || inData==45 ) ) begin // + -
                        buffer[3] = inData;
                        msg <= 3;
                    end else if ( bufferCount<=2 && ( inData>=48 && inData<=57 ) ) begin // 0 - 9
                        buffer[2] <= buffer[1];
                        buffer[1] <= buffer[0];
                        buffer[0] <= inData;
                        if ( bufferCount==2 ) begin // 3 digits entered
                            mode <= 2;
                            msg <= 5;
                        end else begin // data digits entered
                            msg <= 3;
                            bufferCount <= bufferCount + 1;
                        end
                    end else if ( inData==13 ) begin // 13 return, then 10 line feed
                        mode <= 2;
                        msg <= 6;
                    end else begin // unknown
                        mode <= 0;
                        msg <= 4;
                    end
                    state <= 2;
                end
            
            5:
                if ( msgState==3 ) begin
                    setReq <= 1;
                    state <= 6;
                end
                
            6:
                if ( setAck ) begin
                    setReq <= 0;
                    state <= 7;
                end
                
            7:
                if ( !setAck ) begin
                    state <= 0;
                end
                                        
        endcase
    
    end
    
    // Message map
    localparam integer MAX_MSGCOUNT = 7;
    reg [($clog2(MAX_MSGCOUNT)-1):0] msgCount = 0;
    reg [7:0] msgIdx [(MAX_MSGCOUNT-1):0];
    // A 65
    // m 109
    // p 112
    // R 82
    // U 85
    // n 110
    // k 107
    
    // Ascii mapping
    // 0 48
    // 1 49
    // 2 50
    // 3 51
    // 4 52
    // 5 53
    // 6 54
    // 7 55
    // 8 56
    // 9 57
    wire ASCII_SIGN;
    wire [7:0] ASCII_100;
    assign ASCII_100 = setDataTemp%1000>=900 ? 57 :
                       setDataTemp%1000>=800 ? 56 :
                       setDataTemp%1000>=700 ? 55 :
                       setDataTemp%1000>=600 ? 54 :
                       setDataTemp%1000>=500 ? 53 :
                       setDataTemp%1000>=400 ? 52 :
                       setDataTemp%1000>=300 ? 51 :
                       setDataTemp%1000>=200 ? 50 :
                       setDataTemp%1000>=100 ? 49 :
                       48;
    wire [7:0] ASCII_10;
    assign ASCII_10 = setDataTemp%100>=90 ? 57 :
                      setDataTemp%100>=80 ? 56 :
                      setDataTemp%100>=70 ? 55 :
                      setDataTemp%100>=60 ? 54 :
                      setDataTemp%100>=50 ? 53 :
                      setDataTemp%100>=40 ? 52 :
                      setDataTemp%100>=30 ? 51 :
                      setDataTemp%100>=20 ? 50 :
                      setDataTemp%100>=10 ? 49 :
                      48;
    wire [7:0] ASCII_1;
    assign ASCII_1 = setDataTemp%10>=9 ? 57 :
                     setDataTemp%10>=8 ? 56 :
                     setDataTemp%10>=7 ? 55 :
                     setDataTemp%10>=6 ? 54 :
                     setDataTemp%10>=5 ? 53 :
                     setDataTemp%10>=4 ? 52 :
                     setDataTemp%10>=3 ? 51 :
                     setDataTemp%10>=2 ? 50 :
                     setDataTemp%10>=1 ? 49 :
                     48;
                          
    // Message output logic
    reg signed [($clog2((999*2-1)+1)-1):0] setDataTemp = 0;
    reg intMsg = 0;
    always @ (posedge(clk)) begin
        
        case(msgState)

            0:
                if ( msg>0 ) begin
                    msgCount <= 0;
                    if ( msg==1 ) begin
                        msgIdx[2] <= 65;  // A
                        msgIdx[1] <= 109; // m
                        msgIdx[0] <= 112; // p
                        msgCount <= 3;
                    end else if ( msg==2 ) begin
                        msgIdx[2] <= 82;  // R
                        msgIdx[1] <= 112; // p
                        msgIdx[0] <= 109; // m
                        msgCount <= 3;
                    end else if ( msg==3 ) begin
                        msgIdx[0] <= inDataBuffer;
                        msgCount <= 1;
                    end else if ( msg==4 ) begin
                        msgIdx[4] <= 85;  // U
                        msgIdx[3] <= 110; // n
                        msgIdx[2] <= 107; // k
                        msgIdx[1] <= 10;  // lf
                        msgIdx[0] <= 13;  // cr  
                        msgCount <= 5;
                    end else if ( msg==5 ) begin // 3 digits entered
                        msgIdx[2] <= inDataBuffer;
                        msgIdx[1] <= 10; // lf
                        msgIdx[0] <= 13; // cf
                        msgCount <= 3;
                        intMsg <= 1;
                    end else if ( msg==6 ) begin // enter pressed
                        msgIdx[1] <= 10; // lf
                        msgIdx[0] <= 13; // cr
                        msgCount <= 2;
                        intMsg <= 1;
                    end else if ( msg==7 ) begin // show set data
                        if ( setType==0 ) begin
                            msgIdx[6] <= 65; // A
                        end else begin
                            msgIdx[6] <= 82; // R
                        end
                        if ( negative ) begin
                            msgIdx[5] <= 45; // -
                        end else begin
                            msgIdx[5] <= 43; // +
                        end
                        msgIdx[4] <= ASCII_100;
                        msgIdx[3] <= ASCII_10;
                        msgIdx[2] <= ASCII_1;
                        msgIdx[1] <= 10; // lf
                        msgIdx[0] <= 13; // cr
                        msgCount <= 7;
                        intMsg <= 1;
                    end
                    msgState <= 1;
                end

            1:
                begin
                    intMsg <= 0;
                    outData <= msgIdx[msgCount-1];
                    msgState <= 2;
                end

            2:
                begin
                    msgCount <= msgCount - 1;
                    outReq <= 1;
                    msgState <= 3;
                end

            3:
                if ( outAck ) begin
                    outReq <= 0;
                    msgState <= 4;
                end

            4:
                if ( !outAck ) begin
                    if ( msgCount<=0 ) begin
                        msgState <= 0;
                    end else begin
                        msgState <= 1;
                    end
                end        

        endcase
    
    end
    
    // Ascii mapping
    // 0 48
    // 1 49
    // 2 50
    // 3 51
    // 4 52
    // 5 53
    // 6 54
    // 7 55
    // 8 56
    // 9 57
    wire [7:0] HUNDREDS;
    assign HUNDREDS = buffer[2]==48 ? 0 :
                      buffer[2]==49 ? 1 :
                      buffer[2]==50 ? 2 :
                      buffer[2]==51 ? 3 :
                      buffer[2]==52 ? 4 :
                      buffer[2]==53 ? 5 :
                      buffer[2]==54 ? 6 :
                      buffer[2]==55 ? 7 :
                      buffer[2]==56 ? 8 :
                      buffer[2]==57 ? 9 :
                      0;
    wire [7:0] TENS;
    assign TENS = buffer[1]==48 ? 0 :
                  buffer[1]==49 ? 1 :
                  buffer[1]==50 ? 2 :
                  buffer[1]==51 ? 3 :
                  buffer[1]==52 ? 4 :
                  buffer[1]==53 ? 5 :
                  buffer[1]==54 ? 6 :
                  buffer[1]==55 ? 7 :
                  buffer[1]==56 ? 8 :
                  buffer[1]==57 ? 9 :
                  0;
    wire [7:0] ONES;
    assign ONES = buffer[0]==48 ? 0 :
                  buffer[0]==49 ? 1 :
                  buffer[0]==50 ? 2 :
                  buffer[0]==51 ? 3 :
                  buffer[0]==52 ? 4 :
                  buffer[0]==53 ? 5 :
                  buffer[0]==54 ? 6 :
                  buffer[0]==55 ? 7 :
                  buffer[0]==56 ? 8 :
                  buffer[0]==57 ? 9 :
                  0;
                                  
    // Interpret logic
    always @ (negedge(clk)) begin
        
        case(intState)
        
            0:
                if ( intMsg ) begin
                    setDataTemp <= 100*HUNDREDS + 10*TENS + ONES;
                    intState <= 1;
               end
               
            1:
                begin
                    if ( negative ) begin
                        setDataTemp <= -setDataTemp;
                    end
                    intState <= 2;
                end
                
            2:
                begin
                    if ( setType==0 ) begin
                        if ( setDataTemp>MAX_AMP ) begin
                            setDataTemp <= MAX_AMP;
                        end else if ( setDataTemp<0 ) begin
                            setDataTemp <= 0;
                        end
                    end else if ( setType==1 ) begin
                         if ( setDataTemp>MAX_RPM ) begin
                            setDataTemp <= MAX_RPM;
                        end else if ( setDataTemp<-MAX_RPM ) begin
                            setDataTemp <= -MAX_RPM;
                        end
                    end
                   intState <= 3;
                end
                
            3:
                begin
                    setData <= 1*setDataTemp;
                    intState <= 4;
                end
                
            4:
                if ( state==0 ) begin // after external interface received
                    intState <= 0;
                end
              
                
        endcase
    
    end
        
endmodule
