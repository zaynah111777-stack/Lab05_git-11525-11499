`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali

// Module Name: top_fsm_system
// Project Name: Counter
// Target Devices: Basys 3
// 
//////////////////////////////////////////////////////////////////////////////////

module top_fsm_system (
    input wire clk,
    input wire pbin,
    input wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

    // DEBOUNCER (Cleans up the physical reset button signal)
    wire rst_clean;
  	wire [31:0] switch_data; // hold the value read from the switches
  	reg [31:0] led_write_data = 32'd0; // counter value here
  	wire slow_clk;
  
    debouncer rst_db (
      			.clk(clk),
        		.pbin(pbin), 
      				.pbout(rst_clean)	//generated a clean signal
    ); 
    
    leds switch_reader (
      			.clk(clk), .rst(rst_clean),
                    .btns(16'd0),			// Not used for this FSM
                    .writeData(32'd0),			// We don't write to switches
                    .writeEnable(1'b0),			// Disabled
                    .readEnable(1'b1),			// Always ON so we can monitor switches
                    .memAddress(30'd0),       
                    .switches(physical_sw),		// Plug in the physical switches
                    .readData(switch_data)		// output data 
    );
    
    switches led_writer (
                    .clk(clk), .rst(rst_clean),
                    .writeData(led_write_data),
                    .writeEnable(1'b1),         	// Always ON so LEDs update instantly
                    .readEnable(1'b0), .memAddress(30'd0),
                    .readData(),                	// Ignored
                    .leds(physical_leds)      
    );
    
    clock_divider ticker (
                    .clk_in(clk),          		// Feed it the 100MHz fast clock
                    .rst(rst_clean),       		// Feed it the clean reset signal
                    .clk_out(slow_clk)     		// It spits out the 1Hz slow clock!
    );
    // FSM states
    localparam WAIT = 1'b0;//state 0 our input waiting state
    localparam COUNT = 1'b1;//state 1 counter state 

    reg state = WAIT;
    reg [15:0] counter = 16'd0;

    always @(posedge slow_clk or posedge rst_clean) begin //starting loop
        if (rst_clean) begin //if reset = 1 then back to wait
            state <= WAIT; //waiting state
            counter <= 16'd0;//counter is cleared
            led_write_data <= 32'd0;//LED cleared 
        end else begin// else statement
            case (state)
                // state 0: wait for a switch input thats not 0
                WAIT: begin//defining wait
                    if (switch_data[15:0] != 16'd0) begin//if switches==0 
                        counter <= switch_data[15:0];//count = 0
                        led_write_data <= {16'd0, switch_data[15:0]};//putting the value of switches to LEDs
                        state <= COUNT;//state = count
                    end else begin
                        led_write_data <= 32'd0;//else LEDs offf
                    end
                end
                
                // state 1: counting down from the value to 0
                COUNT: begin//Defining count
                    if (counter > 16'd0) begin// if counter > 0
                        counter <= counter - 16'd1;// then decrement 
                        led_write_data <= {16'd0, counter - 16'd1};// update LEDs
                    end else begin
                        state <= WAIT;// going back to waiting state
                    end
                end
            endcase
        end
    end
    
    endmodule