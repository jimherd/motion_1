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
// QE_speed_measure_FSM.sv : state machine to organise speed measurement
//
// Type : Standard three section Moore Finite State Machine structure
//
// Documentation :
//		State machine diagram in system notes folder.
//
// Notes
//			A high speed counter is enabled during the "A" pulse of a quadrature
//       encoder.  Therefore the higher the count, the slower the speed.
//       there is a check on the value getting too large  which implies that
//       the attached motor has stopped.
//
// States
//			S_MV0  : enable hold state
//			S_MV1  : initialise subsystem
//			S_MV2  : wait for rising edge of quadrature encoder A signal
//			S_MV3  : if count has overflowed then restart. Implies motor has stopped
//			S_MV4  : increment temporary speed count register
//			S_MV5  : wait for falling edge of quadrature encoder A signal
//			S_MV6  : check to see if filter mode has been enabled
//			S_MV7  : decrement filter sample count
//			S_MV8  : check for end of set of samples
//			S_MV9  : divide speed count by number of filter samples (2,4,8,16)
//			S_MV10 : load speed register with values in temmporary 
//

`include  "global_constants.sv"

module QE_speed_measure_FSM( 
               input  logic  clk, reset, 
					input  logic  speed_measure_enable,		// enable signal from configuration register
               input  logic  QE_A,		 					// pulse from quadrature encoder
					input  logic  count_overflow,				// counter has reached a set maximum
					input  logic  speed_filter_enable,				// ==1 if filter enabled
					input  logic  samples_complete,        // ==1 when full set of speed samples have been taken
               output logic  clear_all, 					// clear counters
					output logic  inc_temp_speed_counter, 	// increment temporary speed counter
					output logic  dec_sample_count,			// decrement filter sample count
					output logic  do_average,              // take average of sum of speed samples
					output logic  load_speed_buffer  		// record speed
//					output logic  clear_speed_counter		//
               );

//
// set of states
					
enum bit [4:0] {  
                     S_MV0, S_MV1, S_MV2, S_MV3, S_MV4,
							S_MV5, S_MV6, S_MV7, S_MV8, S_MV9, S_MV10
               } state, next_state;

//
// register next state
					
always_ff @(posedge clk or negedge reset)
      if (!reset)   begin
         state <= S_MV0;
      end
      else
         state <= next_state;
//
// next state logic

always_comb begin: set_next_state
   next_state = state;   // default condition is next state is present state
   unique case (state)
	   S_MV0 :
         next_state = (speed_measure_enable == TRUE) ? S_MV1 : S_MV0; 
      S_MV1 :
         next_state = S_MV2; 	
      S_MV2 :
         next_state = (QE_A == 1'b1) ? S_MV3 : S_MV2; 
      S_MV3 :
         next_state = (count_overflow == 1'b1) ? S_MV0 : S_MV4; 
      S_MV4 :
         next_state = S_MV5;  
      S_MV5 :
         next_state = (QE_A == 1'b1) ? S_MV3 : S_MV6; 
      S_MV6 :
         next_state = (speed_filter_enable == 1'b1) ? S_MV7 : S_MV10; 			
		S_MV7 :
         next_state = S_MV8;
		S_MV8 :
         next_state = (samples_complete == 1'b1) ? S_MV9 : S_MV2; 
		S_MV9 :
         next_state = S_MV10;			
		S_MV10 :
         next_state = S_MV0;  
   endcase
end: set_next_state

//
// moore outputs
					
assign clear_all						= (state == S_MV1);
assign inc_temp_speed_counter	   = (state == S_MV4);
assign dec_sample_count		 		= (state == S_MV7);
assign do_average						= (state == S_MV9);
assign load_speed_buffer			= (state == S_MV10);

endmodule

