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

task do_start;
  begin
      clk = 0; reset = 1; uP_start = 0;
      uP_handshake_1 = 1'b0;
  #10 reset = 0;
  #20 reset = 1;
  #20 reset = 1;
  #20 uP_start = 1;
  end
endtask;

task do_end;
  begin
    #5 wait(uut.uP_ack == 1);
    #5 uP_start = 0;
  end
endtask

task write_byte;
  input byte_t data;
  begin
     #50   uP_data_out = data;	    
     #20   uP_handshake_1 = 1'b1;
     #20   wait(uut.uP_handshake_2 == 1'b1);
     #20   uP_handshake_1 = 1'b0;
     #20   wait(uut.uP_handshake_2 == 1'b0);
  end
endtask;

task do_write;
  input [7:0] reg_address;
  input [31:0] reg_data;
  begin
    write_byte(1);
    write_byte(reg_address);
    write_byte(reg_data[7:0]);
    write_byte(reg_data[15:8]);
    write_byte(reg_data[23:16]);
    write_byte(reg_data[31:24]);
  end;
endtask;

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
  
  do_start();
  do_write(2, 32'h0506080B);
//
// Read returned data
//
//  do_read(0);
  #50   wait(uut.uP_handshake_2 == 1'b1);
  #5   input_packet[0] = uut.uP_data_in;
  #5   uP_handshake_1 = 1;
  #5   wait(uut.uP_handshake_2 == 1'b0);
  #5   uP_handshake_1 = 0;
  
  do_end();

 // #100 $finish;
  
end
//
// Initiate clock
//
always begin 
  #10 clk = ~clk; // 50MHz clock
end

assign uut.uP_data_out = uP_data_out;
assign uut.uP_handshake_1 = uP_handshake_1;
assign uut.uP_start = uP_start;

endmodule