//
// H-bridge.sv : 
//
// Implement various forms of H-bridge logic
//
//
`include  "global_constants.sv"


module H_bridge ( 
                  input  logic PWM_signal,
						input  logic int_enable, ext_enable, pwm_dwell, swap,
						input  [1:0] mode, invert,
						input  [2:0] command,
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
//
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