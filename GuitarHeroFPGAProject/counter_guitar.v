`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:08:25 12/01/2017 
// Design Name: 
// Module Name:    counterVerilog 
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
//////////////////////////////////////////////////////////////////////////////////
module counter(
	input clk,
	input slowClk,
	input reset,
	input[1:0] gamestate,
	output reg gameStatus,
	input[15:0] displayNumber,
	output reg [7:0] anode,
	output reg [6:0] ssdOut	
    );
	 
	reg [20:0] refresh;
	reg [3:0] LEDNumber;
	wire [2:0] LEDCounter;
	
	reg[15:0] timecnt;
    reg[49:0] count;

	initial begin
		timecnt = 16'd99;
	end

	always @ (posedge clk)
	begin
		refresh <= refresh + 21'd1;
	end
	assign LEDCounter = refresh[20:18];
	
	// always to convert number into just the integer of the current anode being activated
	always @ (*)
	 begin
		case (LEDCounter)
		3'b000: begin
			anode = 8'b11110111;
			LEDNumber = displayNumber/1000;
				end
		3'b001: begin
			anode = 8'b11111011;
			LEDNumber = (displayNumber % 1000)/100;
				end
		3'b010: begin
			anode = 8'b11111101;
			LEDNumber = ((displayNumber % 1000)%100)/10;
				end
		3'b011: begin
			anode = 8'b11111110;
			LEDNumber = ((displayNumber % 1000)%100)%10;
				end	
		3'b100:
			begin
				anode = 8'b0111_1111;
				LEDNumber = timecnt/1000;
			end
		3'b101:
			begin
				anode = 8'b10111111;
				LEDNumber = (timecnt % 1000)/100;
			end
		3'b110:
			begin
				anode = 8'b11011111;
				LEDNumber = ((timecnt % 1000)%100)/10;
			end
		3'b111:
			begin
				anode = 8'b11101111;
				LEDNumber = ((timecnt % 1000)%100)%10;
			end

		endcase
	end

	always @(posedge slowClk, posedge reset)begin
		if(reset) begin
			timecnt <= 16'd99;
			gameStatus <= 0;
		end
		else begin
			if (gamestate == 2'b10) begin
			 timecnt <= timecnt - 16'd1;
			 if(timecnt == 0) begin
				timecnt <= 0;
				// ADD FLAG TO TELL TOP GAMEOVER AND STOP THE TIMER!
				gameStatus <= 1;
			 end
			end
		end

	end


	// converts integer into SSD
	always @ (*)
    begin
        case (LEDNumber)
        4'b0000: ssdOut = 7'b0000001;     
        4'b0001: ssdOut = 7'b1001111; 
        4'b0010: ssdOut = 7'b0010010; 
        4'b0011: ssdOut = 7'b0000110;  
        4'b0100: ssdOut = 7'b1001100;  
        4'b0101: ssdOut = 7'b0100100; 
        4'b0110: ssdOut = 7'b0100000;  
        4'b0111: ssdOut = 7'b0001111;  
        4'b1000: ssdOut = 7'b0000000;     
        4'b1001: ssdOut = 7'b0000100; 
        default: ssdOut = 7'b0000001; 
        endcase
    end
endmodule
