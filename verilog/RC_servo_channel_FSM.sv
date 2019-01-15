/*
MIT License

Copyright (c) 2018 James Herd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//
// RC_servo_channel_FSM.sv : Manage single RC servo channel
// =======================
//
// Type : Standard three section Moore Finite State Machine structure
//
// Documentation :
//		State machine diagram in system notes folder.
//
// Notes
//		State machine driver by two timers - one for the ON time and
//    one for the period time.  
//    Typically, the period will be 20mS and there will be one state
//    machine per servo output.
//
// States
//			S_RC_CS0  : enable hold state
//			S_RC_CS1  : wait until start of T-period
//			S_RC_CS2  : load servo ON timer
//			S_RC_CS3  : wait until end of ON time
//			S_RC_CS4  : set servo OFF
//

`include  "global_constants.sv"

module RC_servo_channel_FSM( 
               input  logic  clk, reset, 
               input  logic  RC_enable,					// 1 = enable servo channel
					input  logic  ON_time_complete,			// 1 = pulse ON time is complete
					input  logic  RC_servo_period_0,			// 1 = specifies start of servo period
               output logic  RC_servo_ON,					// 1 = pulse set to ON
					output logic  RC_servo_OFF,				// 1 = pulse set to OFF
					output logic  load_RC_servo_ON_timer	// 1 = reload pulse details
               );

//
// set of states
					
enum bit [2:0] {  
                     S_RC_CS0, S_RC_CS1, S_RC_CS2, S_RC_CS3, S_RC_CS4
               } state, next_state;

//
// Register next state 

always_ff @(posedge clk or negedge reset)
      if (!reset)   begin
         state <= S_RC_CS0;
      end
      else
         state <= next_state;
			
//
// Next state logic
			
always_comb begin: set_next_state
   next_state = state;
   unique case (state)
      S_RC_CS0 :
         next_state = (RC_enable == 1'b1) ? S_RC_CS1 : S_RC_CS0;  
		S_RC_CS1 :
         next_state = (RC_servo_period_0 == 1'b1) ? S_RC_CS2 : S_RC_CS1;			
      S_RC_CS2 :
         next_state = S_RC_CS3;  
		S_RC_CS3 :
         next_state = (ON_time_complete == 1'b1) ? S_RC_CS4 : S_RC_CS3;
		S_RC_CS4 :
         next_state = S_RC_CS0;  	
   endcase
end: set_next_state

//
// Moore outputs
				
assign RC_servo_OFF	               = (state == S_RC_CS0) || (state ==  S_RC_CS4);
assign RC_servo_ON	               = (state == S_RC_CS3);
assign load_RC_servo_ON_timer       = (state == S_RC_CS2); 

endmodule

