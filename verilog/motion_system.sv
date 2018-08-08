//
// Top level system file
//
`include  "global_constants.sv"

import types::*;

logic [`NOS_CLOCKS:0] phi_clk;

register_t  reg_in, reg_out;     //logic [31:0] reg_in, reg_out;
logic [7:0]  reg_address;

logic [`NOS_PWM_CHANNELS-1 : 0] pwm_out, PWMs;
   
//
// System structure
//
module motion_system(input logic CLOCK_50, reset, quad_A, quad_B, quad_I);
			

	phase_clocks sys_clocks(
         .clk(CLOCK_50),
         .reset(reset), 
         .phi_clk(phi_clk)
         );
	
	motion_channel #(.MOTION_UNIT(0)) motor_ch0(CLOCK_50, reset, quad_A, quad_B, quad_I, reg_address, reg_out);
	motion_channel #(.MOTION_UNIT(1)) motor_ch1(CLOCK_50, reset, quad_A, quad_B, quad_I, reg_address, reg_out);

	pwm_channel #(.PWM_UNIT(0)) pwm_ch0(
                                       .phase_clk(phi_clk[0]), 
                                       .reset(reset), 
                                       .reg_address(reg_address), 
                                       .reg_in(reg_in), 
                                       .reg_out(reg_out), 
                                       .pwm_out(pwm_out)
                                       );
                                       
	pwm_channel #(.PWM_UNIT(1)) pwm_ch1(
                                       .phase_clk(phi_clk[0]), 
                                       .reset(reset), 
                                       .reg_address(reg_address), 
                                       .reg_in(reg_in), 
                                       .reg_out(reg_out), 
                                       .pwm_out(pwm_out[1])
                                       );

   
endmodule
