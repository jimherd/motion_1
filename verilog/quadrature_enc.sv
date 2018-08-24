//
// 4x decoder : 4 pulses per A/B cycle => 360 pulses/rev.
// Generates a single pulse for each edge of A and B signals.
// Gives 360 pulses for AS5134 encoder
//
`include  "global_constants.sv"

module quadrature_enc(
                     input  logic clk, reset, quadA_in, quadB_in, quadI_in,
                     output logic count_pulse, direction, index
                        );

logic [2:0] quadA_delayed, quadB_delayed;
logic [1:0] index_sync;

logic  count_enable, count_direction;


  always_ff @(posedge clk or negedge reset) begin 
    if (!reset) begin
      	quadA_delayed <= 0;
      	quadB_delayed <= 0;
      index_sync <= 0;
    end else begin
		quadA_delayed <= {quadA_delayed[1:0], quadA_in};
		quadB_delayed <= {quadB_delayed[1:0], quadB_in};

		index_sync[0] <= quadI_in;
		index_sync[1] <= index_sync[0];
    end
  end

assign index         = index_sync[1];

assign count_enable = quadA_delayed[1] ^ quadA_delayed[2] ^ quadB_delayed[1] ^ quadB_delayed[2];
assign count_direction = quadA_delayed[1] ^ quadB_delayed[2];

assign count_pulse = count_enable;
assign direction   = count_direction;

endmodule