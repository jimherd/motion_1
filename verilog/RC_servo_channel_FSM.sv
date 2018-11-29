//
// RC_servo_channel_FSM.sv : 
//
// Manage single RC servo channel
//
`include  "global_constants.sv"

module RC_servo_channel_FSM( 
               input  logic  clk, reset, 
               input  logic  RC_enable, ON_time_complete, RC_servo_period_0, 
               output logic  RC_servo_ON, RC_servo_OFF, load_RC_servo_ON_timer 
               );
					
enum bit [2:0] {  
                     S_RC_CS0, S_RC_CS1, S_RC_CS2, S_RC_CS3, S_RC_CS4
               } state, next_state;

always_ff @(posedge clk or negedge reset)
      if (!reset)   begin
         state <= S_RC_CS0;
      end
      else
         state <= next_state;
			
always_comb begin: set_next_state
   next_state = state;   // default condition is next state is present state
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
					
assign RC_servo_OFF	               = (state == S_RC_CS0) || (state ==  S_RC_CS4);
assign RC_servo_ON	               = (state == S_RC_CS3);
assign load_RC_servo_ON_timer       = (state == S_RC_CS2); 

endmodule

