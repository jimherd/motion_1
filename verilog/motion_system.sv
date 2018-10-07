//
// Top level system file
//
`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;

//
// System structure
//
module motion_system( input  logic  CLOCK_50, reset, 
                      input  logic  [`NOS_PWM_CHANNELS-1 : 0] quadrature_A, quadrature_B, quadrature_I,
                      input  logic  async_uP_start, async_uP_handshake_1, 
                      output logic  uP_ack, uP_handshake_2,
                      input  byte_t uP_data_out,
                      output byte_t uP_data_in,
                      output wire  [`NOS_PWM_CHANNELS-1 : 0] pwm_out,
                      output        led
                      );

IO_bus  intf(.clk(CLOCK_50));
logic   uP_start, uP_handshake_1;

   I_am_alive flash(
                  .clk(CLOCK_50),
                  .reset(reset),
                  .led(led)
                  );
                      
   synchronizer sync1(
                  .clk(CLOCK_50),
                  .reset(reset),
                  .async_in(async_uP_handshake_1),
                  .sync_out(uP_handshake_1)
                  );

   synchronizer sync2(
                  .clk(CLOCK_50),
                  .reset(reset),
                  .async_in(async_uP_start),
                  .sync_out(uP_start)
                  );                      

                  
   uP_interface uP_interface_sys(
                                 .clk(CLOCK_50),
                                 .reset(reset),
                                 .bus(intf.master),
                                 .uP_start(uP_start), 
                                 .uP_handshake_1(uP_handshake_1), 
                                 .uP_ack(uP_ack), 
                                 .uP_handshake_2(uP_handshake_2),
                                 .uP_data_out(uP_data_out),
                                 .uP_data_in(uP_data_in)                              
                                 );
   
 /*  motion_channel #(.MOTION_UNIT(0)) motor_ch0 (
                                 .clk(CLOCK_50),
                                 .reset(reset),
                                 .bus(intf.slave),
                                 .quad_A(quadrature_A[0]), 
                                 .quad_B(quadrature_B[0]), 
                                 .quad_I(quadrature_I[0])
                                 );

   motion_channel #(.MOTION_UNIT(1)) motor_ch1 (
                                       .clk(CLOCK_50),
                                       .reset(reset),
                                       .bus(intf.slave),
                                       .quad_A(quadrature_A[1]), 
                                       .quad_B(quadrature_B[1]), 
                                       .quad_I(quadrature_I[1])
);
*/
   pwm_channel #(.PWM_UNIT(0)) pwm_ch0(
                                       .clk(CLOCK_50),
                                       .reset(reset),
                                       .bus(intf.slave),
                                       .pwm_signal(pwm_out[0])
                                       );
                                       
   pwm_channel #(.PWM_UNIT(1)) pwm_ch1(
                                       .clk(CLOCK_50), 
                                       .reset(reset),
                                       .bus(intf.slave), 
                                       .pwm_signal(pwm_out[1])
                                       );

   
endmodule
