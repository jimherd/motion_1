//
// Top level system file
//
`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;

logic [`NOS_PWM_CHANNELS-1 : 0] pwm_out;
logic [`NOS_PWM_CHANNELS-1 : 0] quadrature_A;
logic [`NOS_PWM_CHANNELS-1 : 0] quadrature_B;
logic [`NOS_PWM_CHANNELS-1 : 0] quadrature_I;

//
// System structure
//
module motion_system(input logic CLOCK_50, reset, quad_A, quad_B, quad_I);

IO_bus  intf();

   uP_interface uP_interface_sys(
                                 .clk(CLOCK_50),
                                 .reset(reset),
                                 .bus(intf)
                                 );
         	
   motion_channel #(.MOTION_UNIT(0)) motor_ch0 (
                                       .clk(CLOCK_50),
                                       .reset(reset),
                                       .bus(intf),
                                       .quad_A(quadrature_A[0]), 
                                       .quad_B(quadrature_B[0]), 
                                       .quad_I(quadrature_I[0])
                                       );

   motion_channel #(.MOTION_UNIT(1)) motor_ch1 (
                                       .clk(CLOCK_50),
                                       .reset(reset),
                                       .bus(intf),
                                       .quad_A(quadrature_A[1]), 
                                       .quad_B(quadrature_B[1]), 
                                       .quad_I(quadrature_I[1])
);

	pwm_channel #(.PWM_UNIT(0)) pwm_ch0(
                                       .clk(CLOCK_50),
                                       .reset(reset),
                                       .bus(intf),
                                       .pwm_out(pwm_out[0])
                                       );
                                       
	pwm_channel #(.PWM_UNIT(1)) pwm_ch1(
                                       .clk(CLOCK_50), 
                                       .reset(reset),
                                       .bus(intf), 
                                       .pwm_out(pwm_out[1])
                                       );

   
endmodule
