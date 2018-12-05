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
//

`include  "global_constants.sv"

module QE_speed_measure_FSM( 
               input  logic  clk, reset, 
               input  logic  QE_A_sig, 						// pulse from quadrature encoder
					input  logic  max_count,						// counter has reached a set maximum
               output logic  clear_all, 						// clear counter
					output logic  increment_speed_counter, 	// 
					output logic  load_speed_buffer, 			// record speed
					output logic  clear_speed_counter			//
               );

//
// set of states
					
enum bit [2:0] {  
                     S_QE_MV0, S_QE_MV1, S_QE_MV2, S_QE_MV3, S_QE_MV4,
							S_QE_MV5, S_QE_MV6
               } state, next_state;

//
// register next state
					
always_ff @(posedge clk or negedge reset)
      if (!reset)   begin
         state <= S_QE_MV0;
      end
      else
         state <= next_state;
//
// next state logic

always_comb begin: set_next_state
   next_state = state;   // default condition is next state is present state
   unique case (state)
      S_QE_MV0 :
         next_state = (QE_A_sig == 1'b1) ? S_QE_MV2 : S_QE_MV0;   
      S_QE_MV1 :
         next_state = S_QE_MV0;  
		S_QE_MV2 :
         next_state = (max_count == 1'b1) ? S_QE_MV1 : S_QE_MV3;
		S_QE_MV3 :
         next_state = S_QE_MV4;
		S_QE_MV4 :
         next_state = (QE_A_sig == 1'b0) ? S_QE_MV5 : S_QE_MV2; 
		S_QE_MV5 :
         next_state = S_QE_MV6;			
		S_QE_MV6 :
         next_state = S_QE_MV0;  
   endcase
end: set_next_state

//
// moore outputs
					
assign clear_all						= (state ==  S_QE_MV1);
assign increment_speed_counter	= (state ==  S_QE_MV3);
assign load_speed_buffer			= (state ==  S_QE_MV5);
assign clear_speed_counter			= (state ==  S_QE_MV6);

endmodule

