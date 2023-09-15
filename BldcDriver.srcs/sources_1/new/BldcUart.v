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
    input clk_48mhz,
    input [4:0] btns, // {btnC,btnU,btnL,btnR,btnD}
    input dataAvail,
    input [7:0] inData,
    output reg inReq = 0,
    input inAck,
    //output reg [7:0] outData = 0,
    output [7:0] outData,
    output reg outReq = 0,
    input outAck,
    output reg setReq = 0,
    input setAck,
    output reg setType = 0, // 0=amp, 1=rpm
    output reg signed [9:0] setData = $rtoi(0.5*MAX_AMP)
    );

    // Ascii to int
    reg [7:0] asciiVal = 0;
    wire signed [9:0] ASCII2INT;
    assign ASCII2INT = asciiVal==48 ? 0 :
                       asciiVal==49 ? 1 :
                       asciiVal==50 ? 2 :
                       asciiVal==51 ? 3 :
                       asciiVal==52 ? 4 :
                       asciiVal==53 ? 5 :
                       asciiVal==54 ? 6 :
                       asciiVal==55 ? 7 :
                       asciiVal==56 ? 8 :
                       asciiVal==57 ? 9 :
                       0;

    // setData in ascii
    reg signed [10:0] setData1024 = 0;
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
    
    // Input ascii buffer
    reg [($clog2(7+1)-1):0] bufferCount = 0;
    reg [7:0] buffer [4:0];
    initial begin
        buffer[4] = 64; // A
        buffer[3] = 43; // +
        buffer[2] = 48; // 0
        buffer[1] = 48; // 0
        buffer[0] = 48; // 0
    end 
    
    // Output message buffer
    localparam integer MAX_DIGITS = 3;
    localparam integer MAX_MSGCOUNT = 7;
    reg msgSign = 0;
    reg [($clog2(MAX_MSGCOUNT)-1):0] msgCount = 0;
    reg [7:0] msgBuffer [(MAX_MSGCOUNT-1):0];
    assign outData = msgBuffer[msgCount-1];
    reg [4:0] btnsReg = 5'b00000;
    
    // Old values
    reg signed [9:0] ampData = $rtoi(0.5*MAX_AMP);
    reg signed [9:0] rpmData = 0;

    reg [($clog2(19+1)-1):0] state = 0;
    //always @ (negedge(clk)) begin
    always @ ( posedge(clk_48mhz) ) begin
    
        case ( state )
        
            // Wait for and process keypress from uart
            0:
                begin
                    if ( dataAvail ) begin
                        inReq <= 1;
                        state <= 1;
                    end else if ( bufferCount==0 && btns>0 ) begin
                        btnsReg <= btns;
                        state <= 10;
                    end
                end
                
            1: // ascii value vailable in buffer
                if ( inAck ) begin
                    if ( bufferCount==0 ) begin // initial key press aA or rR
                        if ( inData == 65 || inData == 97 ) begin // A a
                            setType <= 0;
                            buffer[4] <= 65;
                            bufferCount <= 1;
                        end else if ( inData == 82 || inData == 114 ) begin // R r
                            setType <= 1;
                            buffer[4] <= 82;
                            bufferCount <= 1;
                        end
                        buffer[3] <= 43; // +
                        buffer[2] <= 48; // 0
                        buffer[1] <= 48; // 0
                        buffer[0] <= 48; // 0
                    end else if ( bufferCount==1 ) begin // second key press +- or 0-9
                        if ( inData == 43 || inData == 45 ) begin // + -
                            buffer[3] <= inData;
                            bufferCount <= 2;
                            msgSign <= 0;
                        end else if ( inData>=48 && inData<=57 ) begin // 0 - 9
                            buffer[0] <= inData;
                            bufferCount <= 3;
                            msgSign <= 1;
                        end else if ( inData == 65 || inData == 97 ) begin // A a
                            setType <= 0;
                            buffer[4] <= 97;
                        end else if ( inData == 82 || inData == 114 ) begin // R r
                            setType <= 1;
                            buffer[4] <= 114;
                        end else begin // unknown key press
                            bufferCount <= 7;
                        end
                    end else if ( bufferCount<=4 ) begin // second number key press 0-9
                        if ( inData>=48 && inData<=57 ) begin // 0 - 9
                            buffer[2] <= buffer[1];
                            buffer[1] <= buffer[0];
                            buffer[0] <= inData;
                            bufferCount <= bufferCount+1;
                        end else if ( inData==13 ) begin // cr
                            bufferCount <= 6;
                        end else begin // unknown key press
                            bufferCount <= 7;
                        end
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
                    state <= 4;
                end
                
            4: // key press placed in buffer, create uart out message
                begin
                    if ( bufferCount==1 ) begin
                        if ( buffer[4]==65 ) begin
                            msgBuffer[2] <= 65;  // A
                            msgBuffer[1] <= 109; // m
                            msgBuffer[0] <= 112; // p
                            msgCount <= 3;
                        end else if ( buffer[4]==82 ) begin
                            msgBuffer[2] <= 82;  // R
                            msgBuffer[1] <= 112; // p
                            msgBuffer[0] <= 109; // m
                            msgCount <= 3;
                        end else if ( buffer[4]==97 ) begin // if on second key press then add cr
                            msgBuffer[4] <= 10;  // lf
                            msgBuffer[3] <= 13;  // cr
                            msgBuffer[2] <= 65;  // A
                            msgBuffer[1] <= 109; // m
                            msgBuffer[0] <= 112; // p
                            msgCount <= 5;
                        end else if ( buffer[4]==114 ) begin // if on second key press then add cr
                            msgBuffer[4] <= 10;  // lf
                            msgBuffer[3] <= 13;  // cr
                            msgBuffer[2] <= 82;  // R
                            msgBuffer[1] <= 112; // p
                            msgBuffer[0] <= 109; // m
                            msgCount <= 5;
                        end
                    end else if ( bufferCount==2 ) begin
                        msgBuffer[0] <= buffer[3]; // + -
                        msgCount <= 1;
                    end else if ( bufferCount==3 ) begin
                        if ( msgSign ) begin
                            msgBuffer[1] <= buffer[3]; // + -
                            msgBuffer[0] <= buffer[0]; // 0 - 9
                            msgCount <= 2;
                        end else begin
                            msgBuffer[0] <= buffer[0]; // 0 - 9
                            msgCount <= 1;
                        end
                    end else if ( bufferCount==4 ) begin
                        msgBuffer[0] <= buffer[0]; // 0 - 9
                        msgCount <= 1;
                    end else if ( bufferCount==5 ) begin
                        msgBuffer[2] <= buffer[0]; // 0 - 9
                        msgBuffer[1] <= 10;        // lf
                        msgBuffer[0] <= 13;        // cr
                        msgCount <= 3;
                    end else if ( bufferCount==6 ) begin
                        msgBuffer[1] <= 10;        // lf
                        msgBuffer[0] <= 13;        // cr
                        msgCount <= 2;
                    end else if ( bufferCount==7 ) begin
                        bufferCount <= 0;
                        msgBuffer[6] <= 10;  // lf
                        msgBuffer[5] <= 13;  // cr
                        msgBuffer[4] <= 85;  // U
                        msgBuffer[3] <= 110; // n
                        msgBuffer[2] <= 107; // k
                        msgBuffer[1] <= 10;  // lf
                        msgBuffer[0] <= 13;  // cr
                        msgCount <= 7;
                    end else begin
                        msgBuffer[4] <= 85;  // U
                        msgBuffer[3] <= 110; // n
                        msgBuffer[2] <= 107; // k
                        msgBuffer[1] <= 10;  // lf
                        msgBuffer[0] <= 13;  // cr
                        msgCount <= 5;
                    end
                    state <= 5;
                end
                
            5:
                if ( msgCount>0 ) begin
                    outReq <= 1;
                    state <= 6;
                end else begin
                    state <= 7;
                end
                
            6:
                if ( outAck ) begin
                    msgCount <= msgCount - 1;
                    outReq <= 0;
                    state <= 5;
                end
                
            7:
                if ( !outAck ) begin
                    if ( bufferCount >= 5 ) begin
                        bufferCount <= 3;
                        state <= 8;
                    end else begin
                        state <= 0;
                    end
                end
                
            8: // buffer is full, turn into value
                if ( bufferCount>0 ) begin
                    asciiVal <= buffer[bufferCount-1];
                    state <= 9;
                end else begin
                    if ( buffer[3]==45 ) begin // -
                        setData1024 <= -setData1024;
                    end
                    state <= 12;
                end
                
            9:
                begin
                    if ( bufferCount==3 ) begin
                        setData1024 <= 100 * ASCII2INT;
                    end else if ( bufferCount == 2 ) begin
                        setData1024 <= setData1024 + 10 * ASCII2INT;
                    end else if ( bufferCount == 1 ) begin
                        setData1024 <= setData1024 + ASCII2INT;
                    end
                    bufferCount <= bufferCount - 1;
                    state <= 8;
                end
                
            10: // {btnC,btnU,btnL,btnR,btnD} handle button press
                begin
                    if ( btnsReg[3] ) begin
                        if ( setType==0 ) begin
                            setData1024 <= ampData + 1;
                        end else begin
                            setData1024 <= ampData;
                        end
                        setType <= 0;
                    end else if ( btnsReg[2] ) begin
                        if ( setType==1 ) begin
                            setData1024 <= rpmData - 1;
                        end else begin
                            setData1024 <= rpmData;
                        end
                        setType <= 1;
                    end else if ( btnsReg[1] ) begin
                        if ( setType==1 ) begin
                            setData1024 <= rpmData + 1;
                        end else begin
                            setData1024 <= rpmData;
                        end
                        setType <= 1;
                   end else if ( btnsReg[0] ) begin
                        if ( setType==0 ) begin
                            setData1024 <= ampData - 1;
                        end else begin
                            setData1024 <= ampData;
                        end
                        setType <= 0;
                    end else if ( btnsReg[4] ) begin // reset amp
                        setType <= 0;
                        setData1024 <= $rtoi(0.5*MAX_AMP);
                    end
                    state <= 11;
                end
                
            11:
                if ( btns==0 ) begin
                    state <= 12;
                end
                
            12: // clip value
                begin
                    if ( setType==0 ) begin
                        if ( setData1024<0 ) begin
                            setData <= 0;
                        end else if ( setData1024>MAX_AMP ) begin
                            setData <= MAX_AMP;
                        end else begin
                            setData <= setData1024;
                        end
                    end else if ( setType==1 ) begin
                        if ( setData1024<-MAX_RPM ) begin
                            setData <= -MAX_RPM;
                        end else if ( setData1024>MAX_RPM ) begin
                            setData <= MAX_RPM;
                        end else begin
                            setData <= setData1024;
                        end
                    end
                    state <= 13;
                end
                                
            13: // send out value through uart
                begin
                    msgBuffer[6] <= SET_DATA_TYPE;
                    msgBuffer[5] <= SET_DATA_SIGN;
                    msgBuffer[4] <= SET_DATA_100;
                    msgBuffer[3] <= SET_DATA_10;
                    msgBuffer[2] <= SET_DATA_1;
                    msgBuffer[1] <= 10;
                    msgBuffer[0] <= 13;
                    msgCount <= 7;
                    state <= 14;
                end
            
            
            14:
                if ( msgCount>0 ) begin
                    outReq <= 1;
                    state <= 15;
                end else begin
                    state <= 17;
                end
                
            15:
                if ( outAck ) begin
                    msgCount <= msgCount - 1;
                    outReq <= 0;
                    state <= 16;
                end
             
            16:
                if ( !outAck ) begin
                    state <= 14;
                end
                
            17: // Send the external set value
                begin
                    // Save old values
                    if ( setType==1 ) begin
                        rpmData <= setData;
                    end else begin
                        ampData <= setData;
                    end
                    setReq <= 1;
                    state <= 18;
                end
                
            18:
                if ( setAck ) begin
                    setReq <= 0;
                    state <= 19;
                end
                
            19:
                if ( !setAck ) begin
                    state <= 0;
                end

        endcase
        
    end
        
endmodule
