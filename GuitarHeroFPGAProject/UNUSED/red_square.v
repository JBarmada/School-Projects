module redSquare(
    input clk,
    output reg[1:0] color,
    input buttonRed,
    input [9:0] hCount, vCount,
    output reg btnflag,
    input resetbtn,
    input[1:0] gamestate
);

    reg[2:0] red_state;
    wire debbtn;
    ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(clk), .RESET(resetbtn), .PB(buttonRed), .DPB(), .SCEN(debbtn), .MCEN( ), .CCEN( ));

    reg[9:0] redY;
    reg[49:0] redSpeed;

    // Define parameters for square position
    parameter SQUARE_X_START = 520;
    parameter SQUARE_X_END = 549;
    // SQUARE_WIDTH = 30;
    wire redzone;

    localparam 
        TITLE = 3'b001,
        START = 3'b010,
        RESETFLAG = 3'b100;
        
   initial 
   begin
        red_state = TITLE;
        redY = 10'd320;
        btnflag = 0;
   end

    // assign statement on wire to control flag that displays the block
    assign redzone = ((hCount >= SQUARE_X_START) && (hCount <= SQUARE_X_END) && (vCount >= redY) && (vCount <= redY + 10'd30)) ? 1 : 0;
    reg pressflag;
    reg missflag;

    // Logic to display blue square & give points if button is pressed correctly & update colors etc ITS ALL OF IT IN HERE
    always @ (posedge clk, posedge resetbtn) begin 
        if(gamestate == 2'b01) begin
            // if state is title keep this module in title state
            red_state <= gamestate;
        end
        else if(gamestate == 2'b10 && red_state == TITLE) // if we havent started and game state is no longer in title, update the state machine
            red_state <= START; 
        case(red_state)
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
                        red_state <= TITLE;
                        missflag <= 0;  
                    end
                    else begin        
                        // if button is pressed and the block is in the correct range!
                        if(debbtn && (redY >= 400 && redY <= 455)) begin
                            btnflag <= 1; // give a point
                            red_state <= RESETFLAG; // state-machine stuff to only give one point
                            pressflag <= 1; // turn it green by setting a flag = 2 and the bit file will check for this =2 to make the rgb = green
                        end
                        else if(debbtn) begin
                            //implied: debbtn && !(blueY >= 400 && blueY <= 455) that we pressed the button not in the correct zone
                            missflag <= 1;

                        end

                         // normal coloring of the block
                        if (redzone && !(redY >= 400 && redY <= 455) && !missflag) // cursor in bluebox but outside whitezone
                        begin
                            color <= 2'b01; // blue
                            pressflag <= 0; // we are outside the whitezone reset button detection
                        end
                        else if(redzone && (redY >= 400 && redY <= 455) && !missflag) // cursor in bluebox but inside whitezone
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
                    red_state <= START;
                    btnflag <= 0;
                end

        endcase
        
    end
    
    // control square speed by counting up and incrementing y value after a certain value has been counted
    always@ (posedge clk) begin
        case(red_state)
            TITLE:
            begin
                redY = 10'd0;
                redSpeed = 50'd0;
            end
            START:
                begin
                    redSpeed = redSpeed + 50'd1;
                    if (redSpeed >= (50'd250000) ) //250 thousand
                    begin
                        redY = redY + 10'd1; 
                        redSpeed = 50'd0;
                        if (redY == 10'd779) // block reached the end of the screen!
                        begin
                            redY = 10'd0;
                        end
                    end
                end

        endcase
        
    end

    

endmodule