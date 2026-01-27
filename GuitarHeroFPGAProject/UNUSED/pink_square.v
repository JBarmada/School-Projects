module pinkSquare(
    input clk,
    output reg[1:0] color,
    input buttonPink,
    input [9:0] hCount, vCount,
    output reg btnflag,
    input resetbtn,
    input [1:0] gamestate
);

    reg[2:0] pink_state;
    wire debbtn;
    ee201_debouncer #(.N_dc(25)) ee201_debouncer_3 
        (.CLK(clk), .RESET(resetbtn), .PB(buttonPink), .DPB(), .SCEN(debbtn), .MCEN( ), .CCEN( ));

    reg[9:0] pinkY;
    reg[49:0] pinkSpeed;

   
    // Define parameters for square position
    parameter SQUARE_X_START = 460;
    parameter SQUARE_X_END = 489;
    wire pinkzone;
    
    // // Define parameters for square position
    // parameter  = 320;
    // parameter SQUARE_Y_END = 349;
    localparam 
        TITLE = 3'b001,
        START = 3'b010,
        RESETFLAG = 3'b100;
        
   initial 
   begin
        pink_state = TITLE;
        pinkY = 10'd320;
        btnflag = 0;
   end

    assign pinkzone = ((hCount >= SQUARE_X_START) && (hCount <= SQUARE_X_END) && (vCount >= pinkY) && (vCount <= pinkY + 10'd30)) ? 1 : 0;
    reg pressflag;
    reg missflag;

   // Logic to display pink square & give points if button is pressed correctly & update colors etc ITS ALL OF IT IN HERE
    // Logic to display blue square & give points if button is pressed correctly & update colors etc ITS ALL OF IT IN HERE
    always @ (posedge clk, posedge resetbtn) begin 
        if(gamestate == 2'b01) begin
            // if state is title keep this module in title state
            pink_state <= gamestate;
        end
        else if(gamestate == 2'b10 && pink_state == TITLE) // if we havent started and game state is no longer in title, update the state machine
            pink_state <= START; 
        case(pink_state)
            TITLE:
            begin
                missflag <= 0;
                btnflag <= 0;
                color <= 2'b00;
            end
            START:
                begin
                    // Reset btn sends state back to title screen and resets all flags
                    if(resetbtn) begin
                        btnflag <= 0;  
                        pink_state <= TITLE;
                        missflag <= 0;  
                    end
                    else begin        
                        // if button is pressed and the block is in the correct range!
                        if(debbtn && (pinkY >= 400 && pinkY <= 455)) begin
                            btnflag <= 1; // give a point
                            pink_state <= RESETFLAG; // state-machine stuff to only give one point
                            pressflag <= 1; // turn it green by setting a flag = 2 and the bit file will check for this =2 to make the rgb = green
                        end
                        else if(debbtn) begin
                            //implied: debbtn && !(blueY >= 400 && blueY <= 455) that we pressed the button not in the correct zone
                            missflag <= 1;

                        end

                         // normal coloring of the block
                        if (pinkzone && !(pinkY >= 400 && pinkY <= 455) && !missflag) // cursor in bluebox but outside whitezone
                        begin
                            color <= 2'b01; // blue
                            pressflag <= 0; // we are outside the whitezone reset button detection
                        end
                        else if(pinkzone && (pinkY >= 400 && pinkY <= 455) && !missflag) // cursor in bluebox but inside whitezone
                        begin
                            if(pressflag)
                                color <= 2'b10; // green
                            else
                                color <= 2'b01; // blue
                        end
                        else
                            color <= 2'b00; // cursor not in bluebox
                    end
                end
            RESETFLAG:
                begin
                    pink_state <= START;
                    btnflag <= 0;
                end

        endcase
        
    end


    
// control square speed by counting up and incrementing y value after a certain value has been counted
always@ (posedge clk) begin
    case(pink_state)
        TITLE:
        begin
            pinkY = 10'd0;
            pinkSpeed = 50'd0;
        end
        START:
            begin
                if(resetbtn) begin
                    pinkY = 10'd0;
                end
                else begin
                pinkSpeed = pinkSpeed + 50'd1;
                if (pinkSpeed >= (50'd250000) ) //250 thousand
                begin
                    pinkY = pinkY + 10'd1; 
                    pinkSpeed = 50'd0;
                    if (pinkY == 10'd779) // block reached the end of the screen!
                    begin
                        pinkY = 10'd0;
                    end
                end
                end
            end

    endcase
    
end

    

endmodule