//
// QE_speed_measure_FSM.sv : 
//
// State machine to run 32-bit interface. Moore machine
//
`include  "global_constants.sv"

module QE_speed_measure_FSM( 
               input  logic  clk, reset, 
               input  logic  QE_A_sig, max_count,
               output logic  clear_all, increment_speed_counter, load_speed_buffer, clear_speed_counter
               );
					
enum bit [2:0] {  
                     S_QE_MV0, S_QE_MV1, S_QE_MV2, S_QE_MV3, S_QE_MV4,
							S_QE_MV5, S_QE_MV6
               } state, next_state;

always_ff @(posedge clk or negedge reset)
      if (!reset)   begin
         state <= S_QE_MV0;
      end
      else
         state <= next_state;
			
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
					
assign clear_all						= (state ==  S_QE_MV1);
assign increment_speed_counter	= (state ==  S_QE_MV3);
assign load_speed_buffer			= (state ==  S_QE_MV5);
assign clear_speed_counter			= (state ==  S_QE_MV6);

endmodule

