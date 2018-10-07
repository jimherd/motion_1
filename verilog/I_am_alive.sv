//
// Generate "I'm alive" LED signal
//
`include  "global_constants.sv"

module I_am_alive(
                  input  logic clk, reset, 
                  output logic led
                  );

logic [26:0] counter;

always_ff @(posedge clk or negedge reset) begin 
   if (!reset) begin
      counter <= 0;
   end else begin
      counter <= counter + 1'b1;
   end
end

assign led = (counter > 50000000) ? 1'b1 : 1'b0;

endmodule
