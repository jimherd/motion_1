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
// motion_system.sv : Top level system file
// ================
//
// Notes
//    * Connection to uP changed to shared 8-bit bus

`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;

//
// System structure
//
module motion_system( input  logic      CLOCK_50,
							 input  logic      async_uP_reset, 				// async reset from uP

                      input  logic      async_uP_start, 				// start command transaction
							 input  logic      async_uP_RW, 					// read or write command
							 input  logic      async_uP_handshake_1, 		// first handshake
                      output logic      uP_ack, uP_handshake_2, 	// second handshake							 
                      inout  wire [7:0] uP_data,						// 8-bit bidirectional data bus to uP
					//
					// system hardware signals
					
                      input  logic  [`NOS_QE_CHANNELS-1 : 0]  quadrature_A, quadrature_B, quadrature_I,
                      output wire   [`NOS_PWM_CHANNELS-1 : 0] pwm_out, H_bridge_1, H_bridge_2,
							 output wire   [`NOS_RC_SERVO_CHANNELS-1 : 0] RC_servo,
                      output        led1, led2, led3, led4, led5,
                      output        test_pt1, test_pt2, test_pt3, test_pt4
                      );

//
// declare on chip 32-bit bus

IO_bus  intf(
		.clk(CLOCK_50)
		);
		
logic   uP_start, uP_handshake_1, uP_RW, uP_reset, reset;

assign reset = async_uP_reset;
//assign led2 = !reset;
//assign led3 = !reset;
//assign led4 = !reset;
//assign led5 = !reset;

//assign test_pt1 = !reset;
//assign test_pt2 = !reset;
//assign test_pt3 = !reset;
//assign test_pt4 = !reset;

//
// initiate LED flash activity

   I_am_alive flash(
                  .clk(CLOCK_50),
                  .reset(reset),
                  .led(led1)
                  );

//
// System check feature
						
	supervisor supervisor_sys(
                  .clk(CLOCK_50),
                  .reset(reset),
					//	
					//inputs
					
						.uP_handshake_1(uP_handshake_1), 
						.uP_handshake_2(uP_handshake_2),
						.bus_handshake_1(intf.handshake_1), 
						.bus_handshake_2(intf.handshake_2),
					//
					// outputs
					
						.led_2(led2), 
						.led_3(led3), 
						.led_4(led4), 
						.led_5(led5),
						.test_pt1(test_pt1), 
						.test_pt2(test_pt2), 
						.test_pt3(test_pt3), 
						.test_pt4(test_pt4)
					);

//
// initiate signal synchtonizers
						
   synchronizer sync_handshake_1(
                  .clk(CLOCK_50),
                  .reset(reset),
                  .async_in(async_uP_handshake_1),
                  .sync_out(uP_handshake_1)
                  );
                  
   synchronizer RW_sync(
                  .clk(CLOCK_50),
                  .reset(reset),
                  .async_in(async_uP_RW),
                  .sync_out(uP_RW)
                  );

   synchronizer sync_uP_start(
                  .clk(CLOCK_50),
                  .reset(reset),
                  .async_in(async_uP_start),
                  .sync_out(uP_start)
                  );
                   

//
// initiate 32-bit internal bus master subsystems
                  
   uP_interface uP_interface_sys(
                                 .clk(CLOCK_50),
                                 .reset(reset),
                                 .bus(intf.master),
                                 .uP_start(uP_start), 
                                 .uP_handshake_1(uP_handshake_1), 
                                 .uP_RW(uP_RW),
                                 .uP_ack(uP_ack), 
                                 .uP_handshake_2(uP_handshake_2),
                                 .uP_data(uP_data)
										);
//
// initiate set of quadrature encoder (QE) subsystems
   
   QE_channel #(.QE_UNIT(0)) QE_ch0 (
                                 .clk(CLOCK_50),
                                 .reset(reset),
                                 .bus(intf.slave),
                                 .async_ext_QE_A(quadrature_A[0]), 
                                 .async_ext_QE_B(quadrature_B[0]), 
                                 .async_ext_QE_I(quadrature_I[0])
                                 );

	QE_channel #(.QE_UNIT(1)) QE_ch1 (
                                 .clk(CLOCK_50),
                                 .reset(reset),
                                 .bus(intf.slave),
                                 .async_ext_QE_A(quadrature_A[1]), 
                                 .async_ext_QE_B(quadrature_B[1]), 
                                 .async_ext_QE_I(quadrature_I[1])
                                 );

	QE_channel #(.QE_UNIT(2)) QE_ch2 (
                                 .clk(CLOCK_50),
                                 .reset(reset),
                                 .bus(intf.slave),
                                 .async_ext_QE_A(quadrature_A[2]), 
                                 .async_ext_QE_B(quadrature_B[2]), 
                                 .async_ext_QE_I(quadrature_I[2])
                                 );											

   QE_channel #(.QE_UNIT(3)) QE_ch3 (
                                 .clk(CLOCK_50),
                                 .reset(reset),
                                 .bus(intf.slave),
                                 .async_ext_QE_A(quadrature_A[3]), 
                                 .async_ext_QE_B(quadrature_B[3]), 
                                 .async_ext_QE_I(quadrature_I[3])
                                 );

											
`ifdef USE_PWM_GENERATE

	genvar PWM_unit;
	generate
		for (PWM_unit=0; PWM_unit < `NOS_PWM_CHANNELS; PWM_unit=PWM_unit+1) begin : PWM_H_bridge
			pwm_channel #(.PWM_UNIT(PWM_unit)) pwm_ch(
					.clk(CLOCK_50),
					.reset(reset),
					.bus(intf.slave),
					.pwm_signal(pwm_out[PWM_unit]),
					.H_bridge_1(H_bridge_1[PWM_unit]),
					.H_bridge_2(H_bridge_2[PWM_unit])
			);
		end
	endgenerate

`else

//
// initiate set of PWM subsystems

   pwm_channel #(.PWM_UNIT(0)) pwm_ch0(
                                       .clk(CLOCK_50),
                                       .reset(reset),
                                       .bus(intf.slave),
                                       .pwm_signal(pwm_out[0]),
													.H_bridge_1(H_bridge_1[0]),
													.H_bridge_2(H_bridge_2[0])
                                       );
                                       
   pwm_channel #(.PWM_UNIT(1)) pwm_ch1(
                                       .clk(CLOCK_50), 
                                       .reset(reset),
                                       .bus(intf.slave), 
                                       .pwm_signal(pwm_out[1]),
													.H_bridge_1(H_bridge_1[1]),
													.H_bridge_2(H_bridge_2[1])
                                       );

   pwm_channel #(.PWM_UNIT(2)) pwm_ch2(
                                       .clk(CLOCK_50), 
                                       .reset(reset),
                                       .bus(intf.slave), 
                                       .pwm_signal(pwm_out[2]),
													.H_bridge_1(H_bridge_1[2]),
													.H_bridge_2(H_bridge_2[2])
													);

   pwm_channel #(.PWM_UNIT(3)) pwm_ch3(
                                       .clk(CLOCK_50), 
                                       .reset(reset),
                                       .bus(intf.slave), 
                                       .pwm_signal(pwm_out[3]),
													.H_bridge_1(H_bridge_1[3]),
													.H_bridge_2(H_bridge_2[3])
                                       );							

`endif

//
// initiate RC servo subsystem

	RC_servo  RC_servo_sys( 
					.clk(CLOCK_50), 
					.reset(reset),
					.bus(intf.slave),
					.RC_servo(RC_servo)
					);
   
endmodule
