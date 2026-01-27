`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:15:38 12/14/2017 
// Design Name: 
// Module Name:    vgaBitChange 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
// Date: 04/04/2020
// Author: Yue (Julien) Niu
// Description: Port from NEXYS3 to NEXYS4
//////////////////////////////////////////////////////////////////////////////////

module vga_bitchange(
	input clk,
	input bright,
  input startSwitch,
  input resetbtn,
	input [9:0] hCount, 
	input [9:0] vCount,

  input[1:0] blueflag,
  input bluepointflag,

  input[1:0] pinkflag,
  input pinkpointflag,

  input[1:0] yellowflag,
  input yellowpointflag,

  input[1:0] redflag,
  input redpointflag,

  input gameoverflag,

  input blueblockgoneflag,
  input redblockgoneflag,
  input yellowblockgoneflag,
  input pinkblockgoneflag,


  input[11:0] titles,
  input[11:0] gover,

	output reg [11:0] rgb,
	output reg [15:0] score,
  output reg [49:0] speedshiftOut,
  output reg[1:0] gamestate // contains and tells you the game state
   //, output [11:0] backgrounds
   );
  
  wire whiteZone; // boolean expression to display a white band
  reg[3:0] blockgoneflag; // to detect what blocks went missing

  parameter
    TITLESCREEN  = 2'b01,
    STARTGAME  = 2'b10,
    GAMEOVER = 2'b11;
  
  parameter BLACK = 12'b0000_0000_0000;
  parameter WHITE = 12'b1111_1111_1111;
  parameter RED   = 12'b1111_0010_0000;
  parameter GREEN = 12'b0000_1111_0000;
  parameter BLUE = 12'b0000_0000_1111;
  parameter YELLOW = 12'b1111_1111_0000;
  parameter PINK = 12'b1111_1001_1010;

  
	//bg_rom bg(.clk(clk), .row(vCount-160), .col(hCount-320), .color_data(background));
 
       

  initial begin
    score = 16'd0;
    gamestate = TITLESCREEN;
  end



  // ee201_debouncer #(.N_dc(25)) ee201_debouncer_5 
  //   (.CLK(clk), .RESET(), .PB(resetbtn), .DPB(), .SCEN(SCreset), .MCEN( ), .CCEN( ));

  always@ (*) // always block containing the RGB control
  begin
    if(startSwitch) gamestate <= STARTGAME;
    else if(resetbtn) begin
          gamestate <= TITLESCREEN;
        end
    else begin
    case(gamestate)
      TITLESCREEN:
      begin
        if(startSwitch) gamestate <= STARTGAME;
        
        if(~bright) rgb = BLACK;
        else rgb = titles;
      end
      STARTGAME:
      begin
        blockgoneflag = {redblockgoneflag, blueblockgoneflag, yellowblockgoneflag, pinkblockgoneflag};
        if (gameoverflag || (blockgoneflag == 4'b1111))
        begin
          gamestate <= GAMEOVER;
        end
        // contains the rgb if else trees to determine what color we should be using at the moment
        else begin
          
        if (~bright)
          rgb = BLACK; // force black if not bright
        else if(blueflag > 0) begin // to make blue box appear
           if(blueflag == 2'b01) 
             rgb = BLUE;
           else // blueflag == 2'b10
             rgb = GREEN;
         end 
         else if (pinkflag > 0) begin 
           if(pinkflag == 2'b01) 
             rgb = PINK;
           else
             rgb = GREEN;
         end
         else if (yellowflag > 0) begin 
           if(yellowflag == 2'b01) 
             rgb = YELLOW;
           else
             rgb = GREEN;
         end
         else if (redflag > 0) begin 
           if(redflag == 2'b01) 
             rgb = RED;
           else
             rgb = GREEN;
         end	
          else if (whiteZone == 1) 
            rgb = WHITE;
          else
            rgb = BLACK; // background color
        end
      end
      GAMEOVER:
        begin
             if (~bright)
              rgb = BLACK;
            else
              rgb = gover;
        end
      default: rgb = BLACK;
      // IMPLEMENT A NEW CASE FOR RGB TO DISPLAY OUR CHOSEN GAMEOVER COLOR
      // tip : create new output flags in block and input them here
    endcase
    end
  end

  // always block to update score when a flag is set to true
  always@ (posedge clk, posedge resetbtn)
  begin
      if(resetbtn) begin
        score <= 0;
      end
     else begin
       if (bluepointflag)
       begin
         score = score + 16'd1;
       end
       if (pinkpointflag)
       begin
         score = score + 16'd1;
       end
       if (yellowpointflag)
       begin
         score = score + 16'd1;
       end
       if (redpointflag)
       begin
         score = score + 16'd1;
       end
     end
  end

  // determines where the zone is 
  assign whiteZone = ((hCount >= 10'd144) && (hCount <= 10'd784)) 
                  && ((vCount >= 10'd400) && (vCount <= 10'd455)) ? 1 : 0;

  // multiplication table for timing design criteria
  always@(posedge clk) begin
    if(score == 0) speedshiftOut <= 50'd0;
    else if (score == 1) speedshiftOut <= 50'd1000;
    else if (score == 2) speedshiftOut <= 50'd2000;
    else if (score == 3) speedshiftOut <= 50'd3000;
    else if (score == 4) speedshiftOut <= 50'd4000;
    else if (score == 5) speedshiftOut <= 50'd5000;
    else if (score == 6) speedshiftOut <= 50'd6000;
    else if (score == 7) speedshiftOut <= 50'd7000;
    else if (score == 8) speedshiftOut <= 50'd8000;
    else if (score == 9) speedshiftOut <= 50'd9000;
    else if (score == 10) speedshiftOut <= 50'd10000;
    else if (score == 11) speedshiftOut <= 50'd11000;
    else if (score == 12) speedshiftOut <= 50'd12000;
    else if (score == 13) speedshiftOut <= 50'd13000;
    else if (score == 14) speedshiftOut <= 50'd14000;
    else if (score == 15) speedshiftOut <= 50'd15000;
    else if (score == 16) speedshiftOut <= 50'd16000;
    else if (score == 17) speedshiftOut <= 50'd17000;
    else if (score == 18) speedshiftOut <= 50'd18000;
    else if (score == 19) speedshiftOut <= 50'd19000;
    else if (score == 20) speedshiftOut <= 50'd20000;
    else if (score == 21) speedshiftOut <= 50'd21000;
    else if (score == 22) speedshiftOut <= 50'd22000;
    else if (score == 23) speedshiftOut <= 50'd23000;
    else if (score == 24) speedshiftOut <= 50'd24000;
    else if (score == 25) speedshiftOut <= 50'd25000;
    else if (score == 26) speedshiftOut <= 50'd26000;
    else if (score == 27) speedshiftOut <= 50'd27000;
    else if (score == 28) speedshiftOut <= 50'd28000;
    else if (score == 29) speedshiftOut <= 50'd29000;
    else if (score == 30) speedshiftOut <= 50'd30000;
    else if (score == 31) speedshiftOut <= 50'd31000;
    else if (score == 32) speedshiftOut <= 50'd32000;
    else if (score == 33) speedshiftOut <= 50'd33000;
    else if (score == 34) speedshiftOut <= 50'd34000;
    else if (score == 35) speedshiftOut <= 50'd35000;
    else if (score == 36) speedshiftOut <= 50'd36000;
    else if (score == 37) speedshiftOut <= 50'd37000;
    else if (score == 38) speedshiftOut <= 50'd38000;
    else if (score == 39) speedshiftOut <= 50'd39000;
    else if (score == 40) speedshiftOut <= 50'd40000;
    else if (score == 41) speedshiftOut <= 50'd41000;
    else if (score == 42) speedshiftOut <= 50'd42000;
    else if (score == 43) speedshiftOut <= 50'd43000;
    else if (score == 44) speedshiftOut <= 50'd44000;
    else if (score == 45) speedshiftOut <= 50'd45000;
    else if (score == 46) speedshiftOut <= 50'd46000;
    else if (score == 47) speedshiftOut <= 50'd47000;
    else if (score == 48) speedshiftOut <= 50'd48000;
    else if (score == 49) speedshiftOut <= 50'd49000;
    else if (score == 50) speedshiftOut <= 50'd50000;
    else if (score == 51) speedshiftOut <= 50'd51000;
    else if (score == 52) speedshiftOut <= 50'd52000;
    else if (score == 53) speedshiftOut <= 50'd53000;
    else if (score == 54) speedshiftOut <= 50'd54000;
    else if (score == 55) speedshiftOut <= 50'd55000;
    else if (score == 56) speedshiftOut <= 50'd56000;
    else if (score == 57) speedshiftOut <= 50'd57000;
    else if (score == 58) speedshiftOut <= 50'd58000;
    else if (score == 59) speedshiftOut <= 50'd59000;
    else if (score == 60) speedshiftOut <= 50'd60000;
    else if (score == 61) speedshiftOut <= 50'd61000;
    else if (score == 62) speedshiftOut <= 50'd62000;
    else if (score == 63) speedshiftOut <= 50'd63000;
    else if (score == 64) speedshiftOut <= 50'd64000;
    else if (score == 65) speedshiftOut <= 50'd65000;
    else if (score == 66) speedshiftOut <= 50'd66000;
    else if (score == 67) speedshiftOut <= 50'd67000;
    else if (score == 68) speedshiftOut <= 50'd68000;
    else if (score == 69) speedshiftOut <= 50'd69000;
    else if (score == 70) speedshiftOut <= 50'd70000;
    else if (score == 71) speedshiftOut <= 50'd71000;
    else if (score == 72) speedshiftOut <= 50'd72000;
    else if (score == 73) speedshiftOut <= 50'd73000;
    else if (score == 74) speedshiftOut <= 50'd74000;
    else if (score == 75) speedshiftOut <= 50'd75000;
    else if (score == 76) speedshiftOut <= 50'd76000;
    else if (score == 77) speedshiftOut <= 50'd77000;
    else if (score == 78) speedshiftOut <= 50'd78000;
    else if (score == 79) speedshiftOut <= 50'd79000;
    else if (score == 80) speedshiftOut <= 50'd80000;
    else if (score == 81) speedshiftOut <= 50'd81000;
    else if (score == 82) speedshiftOut <= 50'd82000;
    else if (score == 83) speedshiftOut <= 50'd83000;
    else if (score == 84) speedshiftOut <= 50'd84000;
    else if (score == 85) speedshiftOut <= 50'd85000;
    else if (score == 86) speedshiftOut <= 50'd86000;
    else if (score == 87) speedshiftOut <= 50'd87000;
    else if (score == 88) speedshiftOut <= 50'd88000;
    else if (score == 89) speedshiftOut <= 50'd89000;
    else if (score == 90) speedshiftOut <= 50'd90000;
    else if (score == 91) speedshiftOut <= 50'd91000;
    else if (score == 92) speedshiftOut <= 50'd92000;
    else if (score == 93) speedshiftOut <= 50'd93000;
    else if (score == 94) speedshiftOut <= 50'd94000;
    else if (score == 95) speedshiftOut <= 50'd95000;
    else if (score == 96) speedshiftOut <= 50'd96000;
    else if (score == 97) speedshiftOut <= 50'd97000;
    else if (score == 98) speedshiftOut <= 50'd98000;
    else if (score == 99) speedshiftOut <= 50'd99000;
    else if (score == 100) speedshiftOut <= 50'd200000;
  end
endmodule