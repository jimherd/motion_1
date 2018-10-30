//
// H-bridge.sv : 
//
// Implement various forms of H-bridge logic
//
//
`include  "global_constants.sv"


module H_bridge ( 
                  input  logic PWM_signal,
						input  logic enable, mode, pwm_dwell,
						input  [1:0] command,
						output logic H_bridge_1, H_bridge_2
						);
						
always_comb
begin
	H_bridge_1 = 0;   // required to prevent inferred latch error
	H_bridge_2 = 0;
	if (enable == 1) begin
		if (mode == MODE_PWM_CONTROL) begin  // swap PWM signal to give forward/backward 
			unique case (command)
				MOTOR_COAST : begin
					H_bridge_1 = 1'b0;
					H_bridge_2 = 1'b0;
				end
				MOTOR_FORWARD : begin
					H_bridge_1 = (pwm_dwell == PWM_BRAKE_DWELL) ? 1'b1 : PWM_signal;
					H_bridge_2 = (pwm_dwell == PWM_BRAKE_DWELL) ? !PWM_signal : 1'b0;			
				end
				MOTOR_BACKWARD : begin
					H_bridge_1 = (pwm_dwell == PWM_BRAKE_DWELL) ? !PWM_signal : 1'b1;
					H_bridge_2 = (pwm_dwell == PWM_BRAKE_DWELL) ? 1'b1 : PWM_signal;					
				end
				MOTOR_BRAKE : begin
					H_bridge_1 = 1'b1;
					H_bridge_2 = 1'b1;			
				end
				default : begin
					H_bridge_1 = 1'b0;
					H_bridge_2 = 1'b0;
				end
			endcase
		end
		else if (mode == MODE_PWM_DIR_CONTROL) begin  // uses pwm and direction signals 
			case (command)
				MOTOR_COAST : begin
					H_bridge_1 = 0;
					H_bridge_2 = 0;
				end
				MOTOR_FORWARD : begin
					H_bridge_1 = PWM_signal;
					H_bridge_2 = FORWARD;			
				end
				MOTOR_BACKWARD : begin
					H_bridge_1 = PWM_signal;
					H_bridge_2 = BACKWARD;					
				end
				MOTOR_BRAKE : begin
					H_bridge_1 = 1;
					H_bridge_2 = 1;			
				end
				default : begin
					H_bridge_1 = 0;
					H_bridge_2 = 0;
				end
			endcase
		end
	end
end

endmodule

//