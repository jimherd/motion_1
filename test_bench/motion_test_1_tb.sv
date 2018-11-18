// 
// motion_test_1_tb.sv :
//
// Test motion system : testbench 1
//
`timescale 1 ns / 100 ps
`include "../verilog/global_constants.sv"
import types::*;

enum {PWM_TEST_0, PWM_TEST_1, QE_TEST_0} test_set;

`define TEST        PWM_TEST_1

`define READ_REGISTER_CMD   0
`define WRITE_REGISTER_CMD  1

module motion_test_1_tb ();

logic clk;  //  reset; 
logic  [`NOS_PWM_CHANNELS-1 : 0] quadrature_A, quadrature_B, quadrature_I;
logic  async_uP_start, async_uP_handshake_1, async_uP_RW, async_uP_reset;
logic  uP_ack, uP_handshake_2;
logic  [7:0] uP_data_out;
wire   [7:0] uP_data;
logic  [`NOS_PWM_CHANNELS-1 : 0] pwm_out, H_bridge_1, H_bridge_2;
logic  led1, led2, led3, led4, led5;
logic  test_pt1, test_pt2, test_pt3, test_pt4;

byte_t input_packet[`NOS_WRITE_BYTES];
logic [31:0] status, data;

task do_init();
  begin
        clk = 0; async_uP_reset = 1; async_uP_start = 0; async_uP_handshake_1 = 1'b0; async_uP_RW = 0;
    #50 async_uP_reset = 0;
    #62 async_uP_reset = 1;
    #50 async_uP_reset = 1;
  end
endtask;

task do_start;
  begin
    #17 async_uP_start = 1;
    #50 async_uP_handshake_1 = 1'b0;
    #50 async_uP_start = 0;
  end
endtask;

task do_end;
  begin
    #50 wait(uut.uP_ack == 1);
    #50 async_uP_start = 0;
  end
endtask

task write_byte;
  input [7:0] data;
  begin
    #50   uP_data_out = data;	
        #50 async_uP_RW = 1;    
    #52   async_uP_handshake_1 = 1'b1;
    #50   wait(uut.uP_handshake_2 == 1'b1);
    #53   async_uP_handshake_1 = 1'b0;
        #50 async_uP_RW = 0;        
    #50   wait(uut.uP_handshake_2 == 1'b0);
  end
endtask;

task read_byte;
  output [7:0] data;
  begin
    #50   wait(uut.uP_handshake_2 == 1'b1);
        #50 async_uP_RW = 0;      
	#50   data = uut.uP_data;
    #50   async_uP_handshake_1 = 1;                 // send ack
    #20   wait(uut.uP_handshake_2 == 1'b0);
        #50 async_uP_RW = 0;  
    #50   async_uP_handshake_1 = 0;
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
  output byte_t packet[`NOS_WRITE_BYTES];
  begin
    for (int i=0; i < `NOS_WRITE_BYTES; i++) begin
		read_byte(packet[i]);
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
	do_read(input_packet);
	do_end();
	data = {input_packet[3], input_packet[2], input_packet[1], input_packet[0]};
	status  = {input_packet[7], input_packet[6], input_packet[5], input_packet[4]};
  end;
endtask;

motion_system uut(
                  .CLOCK_50(clk), 
                  .async_uP_reset(async_uP_reset), 
                  .quadrature_A(quadrature_A), 
                  .quadrature_B(quadrature_B), 
                  .quadrature_I(quadrature_I),
                  .async_uP_start(async_uP_start), 
                  .async_uP_handshake_1(async_uP_handshake_1), 
                  .async_uP_RW(async_uP_RW),
                  .uP_ack(uP_ack), 
                  .uP_handshake_2(uP_handshake_2),
                  .uP_data(uP_data),
                  .pwm_out(pwm_out),
                  .H_bridge_1(H_bridge_1),
                  .H_bridge_2(H_bridge_2),
                  .led1(led1),
                  .led2(led2),
                  .led3(led3),
                  .led4(led4),
                  .led5(led5),
                  .test_pt1(test_pt1),
                  .test_pt2(test_pt2),
                  .test_pt3(test_pt3),
                  .test_pt4(test_pt4)
 );
  
logic [31:0] input_value;
 
initial begin
  // init inputs
  $dumpfile("dump.vcd");
  $dumpvars(1,motion_system);
  do_init();
  // select test sequence
  case(`TEST)
    PWM_TEST_0 : begin   // simple single transaction test
            input_value = $urandom();
            do_transaction(`WRITE_REGISTER_CMD, (`PWM_0 + `PWM_PERIOD), input_value, data, status);
            $display("input value = %h", input_value);
            $display("data = %h", data);
            $display("status = %h", status);
        end
    PWM_TEST_1 : begin    // simple PWM test
          #50 do_transaction(`WRITE_REGISTER_CMD, (`PWM_0 + `PWM_PERIOD), 100, data, status);
          #50 do_transaction(`WRITE_REGISTER_CMD, (`PWM_0 + `PWM_ON_TIME), 25, data, status);
          #50 do_transaction(`WRITE_REGISTER_CMD, (`PWM_0 + `PWM_CONFIG), 1, data, status);
          #50 do_transaction(`READ_REGISTER_CMD,  (`PWM_0 + `PWM_PERIOD), 101, data, status);
          $display("PWM period = %d", data);
        end
    QE_TEST_0 : begin    // simple Quadrature Encoder test
          #50 do_transaction(`WRITE_REGISTER_CMD, (`QE_0 + `QE_COUNTS_PER_REV), 100, data, status);
          #50 do_transaction(`WRITE_REGISTER_CMD, (`QE_0 + `QE_CONFIG), 25, data, status);
          $display("PWM period = %d", data);
        end
    default :
        $display("Test select number %d is  unknown", `TEST);
   endcase;
     
end
//
// Initiate clock
//
always begin 
  #10 clk = ~clk; // 50MHz clock
end

assign uut.uP_data = (async_uP_RW == 1) ? uP_data_out : 'z;
assign uut.async_uP_RW = async_uP_RW;
assign uut.async_uP_handshake_1 = async_uP_handshake_1;
assign uut.async_uP_start = async_uP_start;

endmodule