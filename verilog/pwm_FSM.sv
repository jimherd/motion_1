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
//
// If PWM_enable signal goes low during pulse generation then
// abort generation.  
//
always_comb begin: set_next_state
   unique case (state)
      IDLE:
         if (pwm_enable == 0)
            next_state = IDLE;
         else
            next_state = CONFIG;
      CONFIG :
            next_state = CHECK_ON_TIME;
      CHECK_ON_TIME:
         if (pwm_enable == 0)
            next_state = IDLE;
         else 
            if (T_on_zero)
               next_state = CHECK_OFF_TIME;
            else
               next_state = CHECK_ON_TIME; 
      CHECK_OFF_TIME:
         if (pwm_enable == 0)
            next_state = IDLE;
         else
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



