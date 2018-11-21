//
// 4x decoder : 4 pulses per A/B cycle => 360 pulses/rev.
// Generates a single pulse for each edge of A and B signals.
// Gives 360 pulses for AS5134 encoder
//
// No need to synchronise as this is done on input
//
`include  "global_constants.sv"

module quadrature_decoder(
                     input  logic clk, reset, quadA_in, quadB_in, quadI_in,
                     output logic count_pulse, direction, index
                        );

logic  quadA_delayed, quadB_delayed, index_sync;


logic  count_enable, count_direction;


   always_ff @(posedge clk or negedge reset) begin 
      if (!reset) begin
         quadA_delayed <= 0;
         quadB_delayed <= 0;
			index_sync    <= 0;
      end else begin
         quadA_delayed <=  quadA_in;
         quadB_delayed <=  quadB_in;
         index_sync    <=  quadI_in;
      end
   end

assign index         = index_sync;
assign count_pulse   = quadA_in ^ quadA_delayed ^ quadB_in ^ quadB_delayed;
assign direction     = quadA_in ^ quadB_delayed;

endmodule