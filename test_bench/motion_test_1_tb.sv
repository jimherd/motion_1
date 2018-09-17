// 
// motion_test_1_tb.sv :
//
// Test motion system : testbench 1
//
`timescale 1 ns / 100 ps
`include "../verilog/global_constants.sv"
import types::*;


module motion_test_1_tb ();

logic clk, reset;
logic  [`NOS_PWM_CHANNELS-1 : 0] quadrature_A, quadrature_B, quadrature_I;
logic  uP_start, uP_handshake_1;
logic  uP_ack, uP_handshake_2;
byte_t uP_data_out;
byte_t uP_data_in;
logic  [`NOS_PWM_CHANNELS-1 : 0] pwm_out;

byte_t input_packet[8];

motion_system uut(
				.CLOCK_50(clk), 
				.reset(reset), 
                .quadrature_A(quadrature_A), 
				.quadrature_B(quadrature_B), 
				.quadrature_I(quadrature_I),
                .uP_start(uP_start), 
				.uP_handshake_1(uP_handshake_1), 
                .uP_ack(uP_ack), 
				.uP_handshake_2(uP_handshake_2),
                .uP_data_out(uP_data_out),
                .uP_data_in(uP_data_in),
                .pwm_out(pwm_out)
 );
  
initial begin
  // init inputs
  $dumpfile("dump.vcd");
  $dumpvars(1,motion_system);
  
  clk = 0; reset = 1; uP_start = 0;
  uP_handshake_1 = 1'b0;
  #10 reset = 0;
  #20 reset = 1;
  #20 reset = 1;
  #20 uP_start = 1;
 //
 // write command C:/jth/HW_new_robot/Quartus_projects/motion_1/test_bench/motion_test_1_tb.sv
 //
  #100  uP_data_out = 0;	    
  #5   uP_handshake_1 = 1'b1;
  #5   wait(uut.uP_handshake_2 == 1'b1);
  #5   uP_handshake_1 = 1'b0;
  #5   wait(uut.uP_handshake_2 == 1'b0);
//
// Register number 
//  
 #10  uP_data_out = 3;      	// PWM period register of channel 0
  #5   uP_handshake_1 = 1;
  #5   wait(uut.uP_handshake_2 == 1'b1);
  #5   uP_handshake_1 = 0;
  #5   wait(uut.uP_handshake_2 == 1'b0);
//
// data byte 0
//  
 #10   uP_data_out = 42;
  #5   uP_handshake_1 = 1;
  #5   wait(uut.uP_handshake_2 == 1'b1);
  #5   uP_handshake_1 = 0;
  #5   wait(uut.uP_handshake_2 == 1'b0);  
//
// data byte 1
//  
 #10  uP_data_out = 0;
  #5   uP_handshake_1 = 1;
  #5   wait(uut.uP_handshake_2 == 1'b1);
  #5   uP_handshake_1 = 0;
  #5   wait(uut.uP_handshake_2 == 1'b0);    
//
// data byte 2
//  
 #10  uP_data_out = 7;
  #5   uP_handshake_1 = 1;
  #5   wait(uut.uP_handshake_2 == 1'b1);
  #5   uP_handshake_1 = 0;
  #5   wait(uut.uP_handshake_2 == 1'b0);      
//
// data byte 3
//  
 #10  uP_data_out = 5;
  #5   uP_handshake_1 = 1;
  #5   wait(uut.uP_handshake_2 == 1'b1);
  #5   uP_handshake_1 = 0;
  #5   wait(uut.uP_handshake_2 == 1'b0);  
//
// Read returned data
//
  #50   wait(uut.uP_handshake_2 == 1'b1);
  #5   input_packet[0] = uut.uP_data_in;
  #5   uP_handshake_1 = 1;
  #5   wait(uut.uP_handshake_2 == 1'b0);
  #5   uP_handshake_1 = 0;
//
// complete transaction
//
  #5 wait(uut.uP_ack == 1);
  #5 uP_start = 1;

 // #100 $finish;
  
end
always begin 
  #10 clk = ~clk; // 50MHz clock
end

assign uut.uP_data_out = uP_data_out;
assign uut.uP_handshake_1 = uP_handshake_1;
assign uut.uP_start = uP_start;

endmodule