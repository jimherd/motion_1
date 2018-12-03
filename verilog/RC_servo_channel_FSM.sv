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

