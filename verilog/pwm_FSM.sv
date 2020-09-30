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
// pwm_FSM.sv : control generation of PWM signals
// ==========
//
// Type : Standard three section Moore Finite State Machine structure
//
// Documentation :
//		State machine diagram in system notes folder.
//
// Notes
//		Consists of two timers. One for the PWM period and one for the PWM ON time.
//
// States
//			S_PWM_GEN0  : enable hold state
//			S_PWM_GEN1  : 
//			S_PWM_GEN2  : 
//			S_PWM_GEN3  : 

`include  "global_constants.sv"

module pwm_FSM #(parameter PWM_UNIT = 0) (
    input  logic  clk, reset, 
    input  logic  pwm_enable, 		// ==1 then run PWM machine
    input  logic  T_on_zero, 		// ==1 when ON time complete
    input  logic  T_period_zero,	// ==1 when period complete
    output logic  dec_T_on, 		// decrement the ON time counter
    output logic  dec_T_period, 	// decrement the period time counter
    output logic  reload_times, 	// reload ON and period counters
    output logic  pwm					// PWM output signal
);

//
// Set of FSM states

enum bit [2:0] {  
    S_PWM_GEN0, S_PWM_GEN1, S_PWM_GEN2, S_PWM_GEN3
} state, next_state;
//
// register next state

always_ff @(posedge clk or negedge reset) begin
    if (!reset)   begin
        state <= S_PWM_GEN0;
    end else           
        state <= next_state;
end

//
// next state logic

always_comb begin: set_next_state
    unique case (state)
        S_PWM_GEN0:
            if (pwm_enable == 0)
                next_state = S_PWM_GEN0;
            else
                next_state = S_PWM_GEN1;
        S_PWM_GEN1 :
                next_state = S_PWM_GEN2;
        S_PWM_GEN2:
            if (pwm_enable == 0)
                next_state = S_PWM_GEN0;
            else 
                if (T_on_zero)
                    next_state = S_PWM_GEN3;
                else
                    next_state = S_PWM_GEN2; 
        S_PWM_GEN3:
            if (pwm_enable == 0)
                next_state = S_PWM_GEN0;
            else
                if (T_period_zero)
                    next_state = S_PWM_GEN0; 
                else
                    next_state = S_PWM_GEN3;
        default :
            next_state = state;   // default condition - next state is present state
    endcase
end: set_next_state

//
// set Moore outputs

assign dec_T_on     = (state == S_PWM_GEN2);
assign dec_T_period = (state == S_PWM_GEN2) || (state == S_PWM_GEN3);
assign reload_times = (state == S_PWM_GEN1);
assign pwm          = (state == S_PWM_GEN2);

endmodule



