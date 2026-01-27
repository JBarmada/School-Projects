module blueSquare(
    input clk,
    output reg[1:0] color,
    input button,
    input [9:0] hCount, vCount,
    output reg btnflag,
    input resetbtn,
    input[1:0] gamestate,
    input [7:0] shift,
    input[31:0] speedshift,
    input Sw0
);

    wire SCreset;
    assign SCreset = resetbtn;

    reg[2:0] blue_state;
    wire debbtn;
    
    ee201_debouncer #(.N_dc(25)) ee201_debouncer_4 
        (.CLK(clk), .RESET(), .PB(button), .DPB(), .SCEN(debbtn), .MCEN( ), .CCEN( ));

    reg[9:0] blueY;
    reg[49:0] blueSpeed;

    // Define parameters for square position
    // parameter SQUARE_X_START = 340;
    // parameter SQUARE_X_END = 369;
    // SQUARE_WIDTH = 30;
    wire bluezone;
    
    // // Define parameters for square position
    // parameter  = 320;
    // parameter SQUARE_Y_END = 349;

    localparam 
        TITLE = 3'b001,
        START = 3'b010,
        RESETFLAG = 3'b100;
        
   initial 
   begin
        blue_state = TITLE;
        blueY = 10'd320;
        btnflag = 0;
   end

    // assign statement on wire to control flag that displays the block
    assign bluezone = ((hCount >= 340 + shift) && (hCount <= (340 + shift + 29)) && (vCount >= blueY) && (vCount <= blueY + 10'd30)) ? 1 : 0;
    reg pressflag;
    reg missflag;

    // Logic to display blue square & give points if button is pressed correctly & update colors etc ITS ALL OF IT IN HERE
    always @ (posedge clk, posedge SCreset) begin 
        case(blue_state)
            TITLE:
            begin
                if(Sw0)
                 blue_state = START;
            end
            START:
                begin
                    // Reset btn sends state back to title screen and resets all flags
                    if(SCreset) begin
                        btnflag <= 0;  
                        blue_state <= TITLE;
                        missflag <= 0;  
                    end
                    else begin        
                        // if button is pressed and the block is in the correct range!
                        if(debbtn && (blueY >= 400 && blueY <= 455)) begin
                            btnflag <= 1; // give a point
                            blue_state <= RESETFLAG; // state-machine stuff to only give one point
                            pressflag <= 1; // turn it green by setting a flag = 2 and the bit file will check for this =2 to make the rgb = green
                        end
                        else if(debbtn) begin
                            //implied: debbtn && !(blueY >= 400 && blueY <= 455) that we pressed the button not in the correct zone
                            missflag <= 1;

                        end

                         // normal coloring of the block
                        if (bluezone && !(blueY >= 400 && blueY <= 455) && !missflag) // cursor in bluebox but outside whitezone
                        begin
                            color <= 2'b01; // blue
                            pressflag <= 0; // we are outside the whitezone reset button detection
                        end
                        else if(bluezone && (blueY >= 400 && blueY <= 455) && !missflag) // cursor in bluebox but inside whitezone
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
                    blue_state <= START;
                    btnflag <= 0;
                end

        endcase
        
    end
    
    // control square speed by counting up and incrementing y value after a certain value has been counted
    always@ (posedge clk) begin

                    blueSpeed = blueSpeed + 50'd1;
                    if (blueSpeed >= (50'd250000-(speedshift))) //250 thousand
                    begin
                        blueY = blueY + 10'd1; 
                        blueSpeed = 50'd0;
                        if (blueY == 10'd779) // block reached the end of the screen!
                        begin
                            blueY = 10'd0;
                        end
                    end


    end

    

endmodule