//
// phase_clocks.sv : generate 5 phase clock (10MHz)
//

`include  "global_constants.sv"

module phase_clocks (clk, reset, phi_clk);
	
input logic clk, reset;
output logic [`NOS_CLOCKS-1:0] phi_clk;

logic [`NOS_CLOCKS-1:0] counter;

	always_ff @(posedge clk)
		if(reset)
			counter <= 'b1;
		else begin
			counter    <= counter<<1;
			counter[0] <= counter[`NOS_CLOCKS-1];
		end
	
	assign phi_clk = counter;

endmodule