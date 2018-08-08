// 
// pwm_channel_tb.sv :
//
// Test PWM generation code
//
`timescale 1 ns / 100 ps
`include "../verilog/global_constants.sv"

module pwm_channel_tb ();
  
  logic [(`NOS_CLOCKS-1):0] phase_clk;
  logic reset, register_no, register_in, register_out;
  logic pwm_out;
  
pwm_channel #(.PWM_UNIT(0)) uut (
  .phase_clk(phase_clk),
  .reset(reset),
  .register_no(register_no),
  .register_in(register_in),
  .register_out(register_out),  
  .pwm_out(pwm_out)
);

initial begin
  // init inputs
  $dumpfile("dump.vcd");
  $dumpvars(1,pwm_channel);
  
  phase_clk[0] = 0; reset = 0; pwm_out = 0; uut.pwm_enable = 0;
  
  #5 reset = 1;
   
  #20 uut.T_period = 20; uut.T_on = 10;
  #60 uut.pwm_enable = 1;
  #5000 $finish;
  
end
always begin 
  #10 phase_clk[0] = ~phase_clk[0]; // 50MHz clock
end
endmodule