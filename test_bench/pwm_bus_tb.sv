// 
// pwm_bus_tb.sv :
//
// Test PWM generation code
//
`timescale 1 ns / 100 ps
`include "../verilog/global_constants.sv"

module pwm_bus_tb ();
  
  logic [(`NOS_CLOCKS-1):0] phase_clk;
  logic reset;
  logic [31:0] reg_in, reg_out;
  logic [7:0] reg_address;
  logic pwm_out;
  
pwm_channel #(.PWM_UNIT(0)) uut (
  .phase_clk(phase_clk),
  .reset(reset),
  .reg_address(reg_address),
  .reg_in(reg_in),
  .reg_out(reg_out),  
  .pwm_out(pwm_out)
);

initial begin
  // init inputs
  $dumpfile("dump.vcd");
  $dumpvars(1,pwm_channel);
  
  phase_clk[0] = 0; reset = 0; 
  uut.bus_data_avail = 0;
  #5 reset = 1;
  
  #100 reg_address = `PWM_PERIOD; reg_in = 38;
  #25 uut.RW = 0;                // load an internal register
  #25 uut.bus_data_avail = 1;
  #1  wait(uut.ack == 1'b1);
  #25 uut.bus_data_avail = 0;
  #1  wait(uut.ack == 1'b0);
   
  #100 reg_address = `PWM_ON_TIME; reg_in = 12; 
  #25 uut.RW = 0;                // load an internal register
  #25 uut.bus_data_avail = 1;
  #1  wait(uut.ack == 1'b1);
  #25 uut.bus_data_avail = 0;
  #1  wait(uut.ack == 1'b0);
 
  #100 reg_address = `PWM_PERIOD; 
  #25 uut.RW = 1;                // load an internal register
  #25 uut.bus_data_avail = 1;
  #1  wait(uut.ack == 1'b1);
  #25 uut.bus_data_avail = 0;
  #1  wait(uut.ack == 1'b0);
 
 // #100 $finish;
  
end
always begin 
  #10 phase_clk[0] = ~phase_clk[0]; // 50MHz clock
end
endmodule