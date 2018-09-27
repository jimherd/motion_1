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
logic  async_uP_start, async_uP_handshake_1;
logic  uP_ack, uP_handshake_2;
byte_t uP_data_out;
byte_t uP_data_in;
logic  [`NOS_PWM_CHANNELS-1 : 0] pwm_out;

byte_t input_packet[8];
logic [31:0] status, data;

task do_start;
  begin
      clk = 0; reset = 1; async_uP_start = 0;
      async_uP_handshake_1 = 1'b0;
  #15 reset = 0;
  #62 reset = 1;
  #20 reset = 1;
  #17 async_uP_start = 1;
  end
endtask;

task do_end;
  begin
    #5 wait(uut.uP_ack == 1);
    #5 async_uP_start = 0;
  end
endtask

task write_byte;
  input byte_t data;
  begin
    #50   uP_data_out = data;	    
    #22   async_uP_handshake_1 = 1'b1;
    #20   wait(uut.uP_handshake_2 == 1'b1);
    #23   async_uP_handshake_1 = 1'b0;
    #20   wait(uut.uP_handshake_2 == 1'b0);
  end
endtask;

task read_byte;
  output byte_t data;
  begin
    #50   wait(uut.uP_handshake_2 == 1'b1);
	#20   data = uut.uP_data_in;
    #20   async_uP_handshake_1 = 1;                 // send ack
    #20   wait(uut.uP_handshake_2 == 1'b0);
    #20   async_uP_handshake_1 = 0;
  end;
endtask;

task do_write;
  input [7:0] command;
  input [7:0] reg_address;
  input [31:0] reg_data;
  begin
    write_byte(command);
    write_byte(reg_address);
    write_byte(reg_data[7:0]);
    write_byte(reg_data[15:8]);
    write_byte(reg_data[23:16]);
    write_byte(reg_data[31:24]);
  end;
endtask;

task do_read;
  begin
    for (int i=0; i < `NOS_WRITE_BYTES; i++) begin
		read_byte(input_packet[i]);
	end;
  end;
endtask;

task automatic do_transaction;
  input  [7:0] command;
  input  [7:0] reg_address;
  input  [31:0] reg_data;
  ref [31:0] data;
  ref [31:0] status;
  begin
    do_start();
	do_write(command, reg_address, reg_data);
	do_read();
	do_end();
	data = {input_packet[3], input_packet[2], input_packet[1], input_packet[0]};
	status  = {input_packet[7], input_packet[6], input_packet[5], input_packet[4]};
  end;
endtask;

motion_system uut(
                  .CLOCK_50(clk), 
                  .reset(reset), 
                  .quadrature_A(quadrature_A), 
                  .quadrature_B(quadrature_B), 
                  .quadrature_I(quadrature_I),
                  .async_uP_start(async_uP_start), 
                  .async_uP_handshake_1(async_uP_handshake_1), 
                  .uP_ack(uP_ack), 
                  .uP_handshake_2(uP_handshake_2),
                  .uP_data_out(uP_data_out),
                  .uP_data_in(uP_data_in),
                  .pwm_out(pwm_out)
 );
  
logic [31:0] input_value;
 
initial begin
  // init inputs
  $dumpfile("dump.vcd");
  $dumpvars(1,motion_system);
  
  input_value = $urandom();
  
  do_transaction(1,2,input_value, data, status);
  
  $display("input value = %h", input_value);
  $display("data = %h", data);
  $display("status = %h", status);
  
end
//
// Initiate clock
//
always begin 
  #10 clk = ~clk; // 50MHz clock
end

assign uut.uP_data_out = uP_data_out;
assign uut.async_uP_handshake_1 = async_uP_handshake_1;
assign uut.async_uP_start = async_uP_start;

endmodule