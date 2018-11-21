//
// quad_enc_generator_FSM.sv : 
//
// State machine to run 32-bit interface. Moore machine
//
`include  "global_constants.sv"

module QE_generator_FSM( 
               input  logic  clk, reset, 
               input  logic  QE_sim_enable, phase_cnt_4, index_cnt, timer_cnt_0,
               output logic  inc_counters, clear_phase_counter, clear_pulse_counter, 
               output logic  load_phase_timer, decrement_phase_timer
               );

enum bit [4:0] {  
						S_QE_GEN0, S_QE_GEN1, S_QE_GEN2, S_QE_GEN3, S_QE_GEN4,
						S_QE_GEN5, S_QE_GEN6, S_QE_GEN7, S_QE_GEN8
               } state, next_state;


always_ff @(posedge clk or negedge reset)
      if (!reset)   begin
         state <= S_QE_GEN0;
      end
      else
         state <= next_state;
      
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
//

assign inc_counters				= (state == S_QE_GEN1);
assign clear_phase_counter		= (state == S_QE_GEN3); 
assign clear_pulse_counter		= (state == S_QE_GEN5);
assign load_phase_timer			= (state == S_QE_GEN6);
assign decrement_phase_timer	= (state == S_QE_GEN7);

endmodule
