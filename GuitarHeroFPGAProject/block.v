module block(
    input clk,
    input button,
    input reset,
    input StartSwitch,

    input [9:0] hCount, vCount,
    //input[1:0] gamestate, // CURRENTLY UNUSED ?
    input [7:0] horizontal_shift,
    input[49:0] speedshiftIn,

    output reg pointFlag,
    output reg[1:0] colorState,
    output reg blockgoneflag
    
);

    
    reg[2:0] square_state; // square state machine reg <-- WILL NEED TO MAKE BIGGER AS MORE STATS COME IN
    wire debbtn;
    
    reg[9:0] squareY;
    reg[49:0] squareSpeed;

    wire squareZone; // contain 1 or 0 if we are displaying the square
    reg pressflag; // 
    reg missflag;

    ee201_debouncer #(.N_dc(25)) ee201_debouncer_4 
        (.CLK(clk), .RESET(), .PB(button), .DPB(), .SCEN(debbtn), .MCEN( ), .CCEN( ));


    // CASE DEFINITIONS
    localparam 
        TITLE = 3'b001,
        START = 3'b010,
        RESETFLAG = 3'b100;
        
   initial 
   begin
        square_state = TITLE;
        squareY = 10'd320;
        pointFlag = 0;
   end

    // assign statement on wire to control flag that displays the block
    assign squareZone = ((hCount >= 340 + horizontal_shift) && (hCount <= (340 + horizontal_shift + 29)) && (vCount >= squareY) && (vCount <= squareY + 10'd30)) ? 1 : 0;
    

    // Logic to display blue square & give points if button is pressed correctly & update colors etc ITS ALL OF IT IN HERE
    always @ (posedge clk, posedge reset) begin 
         // Reset btn sends state back to title screen and resets all flags
        if(reset) begin
            pointFlag <= 0;  
            square_state <= TITLE;
            missflag <= 0;  
            pressflag <= 0;
            blockgoneflag <= 0;
            
        end
        else begin
        case(square_state)
            TITLE:
            begin
                if(StartSwitch)
                    square_state = START;
            end
            START:
                begin  

                    if(missflag) begin
                        // miss flag triggered, increment block gone array
                        blockgoneflag = 1;
                    end
                    // if button is pressed and the block is in the correct range!
                    if(debbtn && (squareY >= 400 && squareY <= 455)) begin
                        pointFlag <= 1; // give a point
                        square_state <= RESETFLAG; // state-machine stuff to only give one point
                        pressflag <= 1; // turn it green by setting a flag = 2 and the bit file will check for this =2 to make the rgb = green
                    end
                    else if(debbtn) begin
                        //implied: debbtn && !(blueY >= 400 && blueY <= 455) that we pressed the button not in the correct zone
                        missflag <= 1;

                    end

                        // normal coloring of the block
                    if (squareZone && !(squareY >= 400 && squareY <= 455) && !missflag) // cursor in bluebox but outside whitezone
                    begin
                        colorState <= 2'b01; // blue
                        pressflag <= 0; // we are outside the whitezone reset button detection
                    end
                    else if(squareZone && (squareY >= 400 && squareY <= 455) && !missflag) // cursor in bluebox but inside whitezone
                    begin
                        if(pressflag)
                            colorState <= 2'b10; // green
                        else
                            colorState <= 2'b01; // blue
                    end
                    else
                        colorState <= 2'b00; // cursor not in bluebox
                end
            RESETFLAG:
            // state to make sure the point flag resets and only gives one point to the user
                begin
                    square_state <= START;
                    pointFlag <= 0;
                end
            default: square_state <= TITLE;
        endcase
        end
        
    end
    
    // control square speed by counting up and incrementing y value after a certain value has been counted
    always@ (posedge clk, posedge reset) begin
        if(reset) begin
            squareSpeed = 0;
            squareY = 10'd35;
        end
        else begin

            squareSpeed = squareSpeed + 50'd1;
            if (squareSpeed >= (50'd250000-(speedshiftIn))) //250 thousand
            begin
                squareY = squareY + 10'd1; 
                squareSpeed = 50'd0;
                if (squareY == 10'd779) // block reached the end of the screen!
                begin
                    squareY = 10'd0;
                end
            end
        end
    end

    

endmodule