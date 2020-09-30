//
// pwm_FSM.sv : 
//
// State machine to run 32-bit interface. Moore machine
//
`include  "global_constants.sv"

module pwm_FSM(clk, reset, pwm_enable, T_on_zero, T_period_zero,
               dec_T_on, dec_T_period, reload_times, pwm_out);
               
input  logic  clk, reset, pwm_enable, T_on_zero, T_period_zero;
output logic   dec_T_on, dec_T_period, reload_times, pwm_out;

//
// Set of states (one-hot encoded)
//
enum bit [8:0] {  IDLE              = 9'b000000001,
                  PWM_OFF           = 9'b000000010,
						CHECK_PULSE_TIME  = 9'b000000100,
						OFF_TIME    		= 9'b000001000,
						ON_TIME        	= 9'b000010000,
						CHECK_COMPLETE    = 9'b000100000,
						RELOAD            = 9'b001000000,
  						TEST_ENABLE       = 9'b010000000,
                  CONFIG            = 9'b100000000
					} state, next_state;
	

always_ff @(posedge clk or negedge reset) begin
		if (!reset)	begin
         state          <= PWM_OFF;
//         dec_T_on       <= 0;
//         dec_T_period   <= 0;
//         pwm_out        <= 0;
		end else           
         state <= next_state;
end
		
always_comb begin: set_next_state
	unique case (state)
		IDLE:
			if (!pwm_enable)
				next_state = PWM_OFF;
         else
            next_state = CONFIG;
      CONFIG :
            next_state = CHECK_PULSE_TIME;
      PWM_OFF:
         next_state = IDLE;
		CHECK_PULSE_TIME:
			if (T_on_zero)
            next_state = OFF_TIME;
         else
            next_state = ON_TIME;
		OFF_TIME:
			next_state = CHECK_COMPLETE;
		ON_TIME:
			next_state = CHECK_COMPLETE;
		CHECK_COMPLETE:
			if (T_period_zero)
            next_state = RELOAD;
         else
            next_state = TEST_ENABLE;
		RELOAD:
			next_state = IDLE;
      TEST_ENABLE:
         if (pwm_enable)
            next_state = CHECK_PULSE_TIME;
         else
            next_state = PWM_OFF;
      default :
         next_state = state;	// default condition - next state is present state
	endcase
end: set_next_state

always_comb  begin: set_outputs
	case (state) 
      PWM_OFF: begin
         dec_T_on       = 0;
         dec_T_period   = 0;
         reload_times   = 0;
         pwm_out        = 0;
      end
      CONFIG: begin
         dec_T_on       = 0;
         dec_T_period   = 0;
         reload_times   = 1;
         pwm_out        = 1;
      end
      CHECK_PULSE_TIME: begin
         dec_T_on       = 0;
         dec_T_period   = 0;
         reload_times   = 0;         
         pwm_out        = 0;
      end      
      OFF_TIME: begin
         dec_T_on       = 0;
         dec_T_period   = 1;
         reload_times   = 0;
         pwm_out        = 0;
      end
      ON_TIME: begin
         dec_T_on       = 1;
         dec_T_period   = 1;
         reload_times   = 0;
         pwm_out        = 1;
      end
      CHECK_COMPLETE: begin
         dec_T_on       = 0;
         dec_T_period   = 0;
         reload_times   = 0;
         pwm_out        = 1;
      end
      RELOAD: begin
         dec_T_on       = 0;
         dec_T_period   = 0;
         reload_times   = 1;
         pwm_out        = 0;
      end
		default: begin
         dec_T_on       = 0;
         dec_T_period   = 0;
         reload_times   = 0;
         pwm_out        = 0;
      end
	endcase	
end: set_outputs

endmodule
