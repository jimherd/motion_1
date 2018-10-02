//
// pwm_FSM.sv : 
//
// State machine to generate PWM signal. Moore machine
//
`include  "global_constants.sv"

module pwm_FSM #(parameter PWM_UNIT = 0) (
                     input  logic  clk, reset, 
                     input  logic  pwm_enable, T_on_zero, T_period_zero,
                     output logic  dec_T_on, dec_T_period, reload_times, 
                     output logic  pwm
                  );
               
//
// Set of FSM states
//
enum bit [1:0] {  IDLE,
                  CONFIG,
                  CHECK_ON_TIME,
                  CHECK_OFF_TIME
               } state, next_state;
 

always_ff @(posedge clk or negedge reset) begin
      if (!reset)   begin
         state <= IDLE;
      end else           
         state <= next_state;
end

always_comb begin: set_next_state
   unique case (state)
      IDLE:
         if (!pwm_enable)
            next_state = IDLE;
         else
            next_state = CONFIG;
      CONFIG :
            next_state = CHECK_ON_TIME;
      CHECK_ON_TIME:
         if (T_on_zero)
            next_state = CHECK_OFF_TIME;
         else
            next_state = CHECK_ON_TIME; 
      CHECK_OFF_TIME:
         if (T_period_zero)
            next_state = IDLE; 
         else
            next_state = CHECK_OFF_TIME;
      default :
         next_state = state;   // default condition - next state is present state
   endcase
end: set_next_state

//
// set Moore outputs
//
assign dec_T_on     = (state == CHECK_ON_TIME);
assign dec_T_period = (state == CHECK_ON_TIME) || (state == CHECK_OFF_TIME);
assign reload_times = (state == CONFIG);
assign pwm          = (state == CHECK_ON_TIME);

endmodule



