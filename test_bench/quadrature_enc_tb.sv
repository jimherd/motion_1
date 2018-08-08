// Code your testbench here
// or browse Examples
`timescale 1 ns / 100 ps

module quadrature_enc_tb ();
  
  logic clk, reset, quadA_in, quadB_in, quadI_in;
  logic count_pulse, direction, index;
  
quadrature_enc uut (
  .clk(clk),
  .reset(reset),
  .quadA_in(quadA_in),
  .quadB_in(quadB_in),
  .quadI_in(quadI_in),  
  .count_pulse(count_pulse),  
  .direction(direction),  
  .index(index)
);

initial begin
  // init inputs
  $dumpfile("dump.vcd");
  $dumpvars(1,quadrature_enc);
  
  clk = 0; reset = 0;
  #5 reset = 1;
  quadA_in = 0; quadB_in = 0; quadI_in = 0;
  
  for (int i=0 ; i<4 ; i++) begin
  	#100 quadA_in = 1;
    #100 quadB_in = 1;
    #100 quadA_in = 0;
    #100 quadB_in = 0;
  end
  
    for (int i=0 ; i<4 ; i++) begin
  	#100 quadB_in = 1;
    #100 quadA_in = 1;
    #100 quadB_in = 0;
    #100 quadA_in = 0;
  end
  
  $finish;
  
end
always begin 
  #10 clk = ~clk; // 50MHz clock
end
endmodule