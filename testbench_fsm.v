`timescale 1ns / 1ps
module testbench_fsm();
    // variables
    reg clk;
    reg pbin;
    reg [15:0] physical_sw;
    wire [15:0]physical_leds;
    top_fsm_system uut (
        .clk(clk),
        .pbin(pbin),//reset
        .physical_sw(physical_sw),
        .physical_leds(physical_leds)
    );
    // initialise 100 MHz clock (10ns period)
    always #5 clk = ~clk;
    initial begin
        // initialize signals and apply reset
        clk = 0;
        pbin = 1;          // reset (button press)
        physical_sw = 16'd0;
        #30;
        pbin = 0;          // reset goes to WAIT state
        #40;
        // starting countdown with a switch value of 3
        physical_sw = 16'd3; 
        #30;
        physical_sw = 16'd0;
        #250;             // wait for countdown from 3 to 0 to end
        //testing another value
        physical_sw = 16'd5; // set switches to 5
        #30;
        physical_sw = 16'd0;
        #400;              // wait for second countdown to finish
        // testing emergency reset button mid countdown
        physical_sw = 16'd7; // start countdown from 7
        #30;
        physical_sw = 16'd0;
        #50;
        pbin = 1;          // press reset button while counting down!
        #30;
        pbin = 0;          // release reset button then it should jump back to WAIT
        #100;
        $finish;           // end
    end
endmodule
