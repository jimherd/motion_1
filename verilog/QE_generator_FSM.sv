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
// quad_enc_generator_FSM.sv : State machine to generate simulated quadrature signals
// =========================
//
// Type : Standard three section Moore Finite State Machine structure
//
// Documentation :
//		State machine diagram in system notes folder.
//
// Notes
//		State machine to control generation of standard A/B/I quadrature signals for
//  	test purposes.  The A/B signals are a two bit grey code with 4 phases. 
//		

`include  "global_constants.sv"

module QE_generator_FSM( 
               input  logic  clk, reset,
               input  logic  QE_sim_enable, 				// 1 = enable quadrature encoder simulator
					input  logic  phase_cnt_4, 				// 1 = grey code of A/B inputs complete
					input  logic  index_cnt, 					//
					input  logic  timer_cnt_0,					//
               output logic  inc_counters, 				// increment ON and period timers
					output logic  clear_phase_counter, 		// clear 2 bit A/B phase counter
					output logic  clear_pulse_counter, 		//
               output logic  load_phase_timer, 			//
					output logic  decrement_phase_timer		//
               );
//
// set of states

enum bit [4:0] {  
						S_QE_GEN0, S_QE_GEN1, S_QE_GEN2, S_QE_GEN3, S_QE_GEN4,
						S_QE_GEN5, S_QE_GEN6, S_QE_GEN7, S_QE_GEN8
               } state, next_state;

//
// register next state

always_ff @(posedge clk or negedge reset)
      if (!reset)   begin
         state <= S_QE_GEN0;
      end
      else
         state <= next_state;
 
//
// next state logic
 
always_comb begin: set_next_state
   next_state = state;   // default condition is next state is present state
   unique case (state)
      S_QE_GEN0 :
         next_state = (QE_sim_enable == 1'b1) ? S_QE_GEN1 : S_QE_GEN0;  
		S_QE_GEN1 :
         next_state = S_QE_GEN2;   
      S_QE_GEN2 :
         next_state = (phase_cnt_4 == 1'b1) ? S_QE_GEN3 : S_QE_GEN4;  
		S_QE_GEN3 :
         next_state = S_QE_GEN4;
		S_QE_GEN4 :
         next_state = (index_cnt == 1'b1) ? S_QE_GEN5 : S_QE_GEN6;  
		S_QE_GEN5 :
         next_state = S_QE_GEN6;
		S_QE_GEN6 :
         next_state = S_QE_GEN7;
		S_QE_GEN7 :
         next_state = S_QE_GEN8;			
		S_QE_GEN8 :
         next_state = (timer_cnt_0 == 1'b1) ? S_QE_GEN0 : S_QE_GEN7;  
   endcase
end: set_next_state

//
// Moore outputs

assign inc_counters				= (state == S_QE_GEN1);
assign clear_phase_counter		= (state == S_QE_GEN3); 
assign clear_pulse_counter		= (state == S_QE_GEN5);
assign load_phase_timer			= (state == S_QE_GEN6);
assign decrement_phase_timer	= (state == S_QE_GEN7);

endmodule
