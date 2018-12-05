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
// H-bridge.sv : Implement various forms of H-bridge logic
// ===========
//
// Options to generate different formats of H-bridge control signals.
// The two formats are
//		1. PWM + direction
//		2. IN1 + IN2

`include  "global_constants.sv"

module H_bridge ( 
                  input  logic PWM_signal,	// source of basic PWM signal
						input  [2:0] command,		// commands - forward, backward, brake, etc
						input  [1:0] mode, 			// format of H-bridge control signals
						input  logic int_enable, 	//
						input  logic ext_enable, 	//
						input  logic pwm_dwell, 	// set of time of PWM to BRAKE or COAST
						input  logic swap,			//
						input  [1:0] invert,			//
						
						output logic H_bridge_1, H_bridge_2
						);
						
logic H_bridge_1_tmp, H_bridge_2_tmp;
						
always_comb
begin
	H_bridge_1_tmp = 0;   // required to prevent inferred latch error
	H_bridge_2_tmp = 0;
	if (mode == MODE_PWM_CONTROL) begin  // swap PWM signal to give forward/backward 
		unique case (command)
			MOTOR_COAST : begin
				H_bridge_1_tmp = 1'b0;
				H_bridge_2_tmp = 1'b0;
			end
			MOTOR_FORWARD : begin
				H_bridge_1_tmp = (pwm_dwell == PWM_BRAKE_DWELL) ? 1'b1 : PWM_signal;
				H_bridge_2_tmp = (pwm_dwell == PWM_BRAKE_DWELL) ? !PWM_signal : 1'b0;			
			end
			MOTOR_BACKWARD : begin
				H_bridge_1_tmp = (pwm_dwell == PWM_BRAKE_DWELL) ? !PWM_signal : 1'b1;
				H_bridge_2_tmp = (pwm_dwell == PWM_BRAKE_DWELL) ? 1'b1 : PWM_signal;					
			end
			MOTOR_BRAKE : begin
				H_bridge_1_tmp = 1'b1;
				H_bridge_2_tmp = 1'b1;			
			end
			default : begin
				H_bridge_1_tmp = 1'b0;
				H_bridge_2_tmp = 1'b0;
			end
		endcase
	end
	else if (mode == MODE_PWM_DIR_CONTROL) begin  // uses pwm and direction signals 
		case (command)
			MOTOR_COAST : begin
				H_bridge_1_tmp = 0;
				H_bridge_2_tmp = 0;
			end
			MOTOR_FORWARD : begin
				H_bridge_1_tmp = PWM_signal;
				H_bridge_2_tmp = FORWARD;			
			end
			MOTOR_BACKWARD : begin
				H_bridge_1_tmp = PWM_signal;
				H_bridge_2_tmp = BACKWARD;					
			end
			MOTOR_BRAKE : begin
				H_bridge_1_tmp = 1;
				H_bridge_2_tmp = 1;			
			end
			default : begin
				H_bridge_1_tmp = 0;
				H_bridge_2_tmp = 0;
			end
		endcase
	end
end

//
// Post processing of H-bridge signals to provide INVERT, SWAP and ENABLE
// features.

always_comb
begin
	H_bridge_1 = 0;
	if (int_enable == 1'b1)
		if (swap == 1'b0) 
			H_bridge_1 = (invert[0] == 1'b0) ? H_bridge_1_tmp : !H_bridge_1_tmp;
		else 
			H_bridge_1 = (invert[0] == 1'b0) ? H_bridge_2_tmp : !H_bridge_2_tmp;
end

always_comb
begin
	H_bridge_2 = 0;
	if (int_enable == 1'b1)
		if (swap == 1'b0) 
			H_bridge_2 = (invert[1] == 1'b0) ? H_bridge_2_tmp : !H_bridge_2_tmp;
		else 
			H_bridge_2 = (invert[1] == 1'b0) ? H_bridge_1_tmp : !H_bridge_1_tmp;
end

endmodule

//