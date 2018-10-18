//
// Top level system file
//
//
// Notes
//    * Connection to uP changed to shared 8-bit bus

`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;

//
// System structure
//
module motion_system( input  logic  CLOCK_50,
                      input  logic  [`NOS_PWM_CHANNELS-1 : 0] quadrature_A, quadrature_B, quadrature_I,
                      input  logic  async_uP_start, async_uP_handshake_1, async_uP_RW, async_uP_reset, 
                      output logic  uP_ack, uP_handshake_2,
                      inout  wire [7:0] uP_data,
                      output wire   [`NOS_PWM_CHANNELS-1 : 0] pwm_out,
                      output        led1, led2
                      );

IO_bus  intf(.clk(CLOCK_50));
logic   uP_start, uP_handshake_1, uP_RW, uP_reset, reset;

assign reset = async_uP_reset;
assign led2 = !reset;

   I_am_alive flash(
                  .clk(CLOCK_50),
                  .reset(reset),
                  .led(led1)
                  );
                      
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

//   synchronizer sync_uP_reset(
//                  .clk(CLOCK_50),
//                  .reset(reset),
//                  .async_in(async_uP_reset),
//                  .sync_out(uP_reset)
//                  );                     
                  
                  
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
