`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:18:00 12/14/2017 
// Design Name: 
// Module Name:    vga_top 
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
module vga_top(
	input ClkPort,
	input BtnC,
	input BtnU,
	input BtnR,
	input BtnL,
	input BtnD,
	input Sw0,
	
	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,
	
	//SSG signal 
	output An0, An1, An2, An3, An4, An5, An6, An7,
	output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	
	output MemOE, MemWR, RamCS, QuadSpiFlashCS
	);
	
	wire bright;
	wire[9:0] hc, vc;
	wire[15:0] score;
	wire [6:0] ssdOut;
	wire [7:0] anode;
	wire [11:0] rgb;
  	wire [11:0] background;

	wire blueblockgoneflag;
	wire yellowblockgoneflag;
	wire redblockgoneflag;
	wire pinkblockgoneflag;

	wire[1:0] blueBoxflag; // flag to tell you if rgb needs to color this box
	wire bluepointflag; // flag to tell you if you need to give a point because the user pressed the button corresponding to this box

	wire[1:0] pinkBoxflag;
	wire pinkpointflag;

	wire[1:0] yellowBoxflag;
	wire yellowpointflag;

	wire[1:0] redBoxflag;
	wire redpointflag;

	wire gameoverflag;
	wire[1:0] gamestate;
	wire[49:0] speedshift;

	wire reset;
	assign reset = BtnC;
	
//------------
	// Our clock is too fast (100MHz) for SSD scanning
	// create a series of slower "divided" clocks
	// each successive bit is 1/2 frequency
	wire sys_clk;
	reg [26:0] DIV_CLK;

	always @ (posedge ClkPort, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			// just incrementing makes our life easier
			DIV_CLK <= DIV_CLK + 1'b1;
	end		
//------------	
	// pick a divided clock bit to assign to system clock
	// your decision should not be "too fast" or you will not see you state machine working
	assign	sys_clk = DIV_CLK[25]; // DIV_CLK[25] (~1.5Hz) = (100MHz / 2**26)

	display_controller dc(.clk(ClkPort), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
	
	// color block modules
	block blue(.clk(ClkPort), .reset(BtnC), .StartSwitch(Sw0), .button(BtnU), .hCount(hc), .vCount(vc), /*.gamestate(),*/ 
	.horizontal_shift(0), .speedshiftIn(speedshift), .pointFlag(bluepointflag), .colorState(blueBoxflag), .blockgoneflag(blueblockgoneflag));
	block pink(.clk(ClkPort), .reset(BtnC), .StartSwitch(Sw0), .button(BtnD), .hCount(hc), .vCount(vc), /*.gamestate(),*/ 
	.horizontal_shift(120), .speedshiftIn(speedshift), .pointFlag(pinkpointflag), .colorState(pinkBoxflag), .blockgoneflag(pinkblockgoneflag));
	block yellow(.clk(ClkPort), .reset(BtnC), .StartSwitch(Sw0), .button(BtnR), .hCount(hc), .vCount(vc), /*.gamestate(),*/ 
	.horizontal_shift(60), .speedshiftIn(speedshift), .pointFlag(yellowpointflag), .colorState(yellowBoxflag), .blockgoneflag(yellowblockgoneflag));
	block red(.clk(ClkPort), .reset(BtnC), .StartSwitch(Sw0), .button(BtnL), .hCount(hc), .vCount(vc), /*.gamestate(), */
	.horizontal_shift(180), .speedshiftIn(speedshift), .pointFlag(redpointflag), .colorState(redBoxflag), .blockgoneflag(redblockgoneflag));

	wire [11:0] titles; // contains the titlescreen rgb info
	title_rom dd(.clk(ClkPort), .color_data(titles), .row(vc-120), .col(hc-160));
	wire[11:0] gover;
	go_rom go(.clk(ClkPort), .color_data(gover), .row(vc-240), .col(hc-320));

	// rgb controlling module
  	vga_bitchange vbc(
		.clk(ClkPort), .bright(bright), .startSwitch(Sw0), 
		.resetbtn(BtnC), .hCount(hc), .vCount(vc), .rgb(rgb), 
		.score(score), .speedshiftOut(speedshift),
		.blueflag(blueBoxflag), .bluepointflag(bluepointflag),
		.pinkflag(pinkBoxflag), .pinkpointflag(pinkpointflag),
		.yellowflag(yellowBoxflag), .yellowpointflag(yellowpointflag),
		.redflag(redBoxflag), .redpointflag(redpointflag), .gameoverflag(gameoverflag), .gamestate(gamestate), 
		.blueblockgoneflag(blueblockgoneflag), .pinkblockgoneflag(pinkblockgoneflag), 
		.yellowblockgoneflag(yellowblockgoneflag), .redblockgoneflag(redblockgoneflag), 
		.titles(titles), .gover(gover));

	counter cnt(.clk(ClkPort), .slowClk(sys_clk), 
	.reset(BtnC), .displayNumber(score), .anode(anode), .ssdOut(ssdOut), .gameStatus(gameoverflag), .gamestate(gamestate));


	assign Dp = 1;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg} = ssdOut[6 : 0];
  	assign {An7, An6, An5, An4, An3, An2, An1, An0} = anode;


	
	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];
	
	// disable mamory ports
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

endmodule
