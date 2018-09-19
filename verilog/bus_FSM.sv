//
// bus_FSM.sv : 
//
// State machine to run 32-bit interface. Moore machine
//
`include  "global_constants.sv"

module bus_FSM( 
               input  logic  clk, reset, 
               input  logic  RW, subsystem_enable, handshake_1,
               output logic  handshake_2,
               output logic  data_avail, 
               output logic  read_word_from_BUS, write_data_word_to_BUS, write_status_word_to_BUS
               );

enum bit [4:0] {
                  // section #1	
                     S_RW0, S_RW1, S_RW2, S_RW3, S_RW4, S_RW5, S_RW6, 
                  // section #2
                     S_WWD0, S_WWD1, S_WWD2, S_WWD3, S_WWD4, 
                  // section #3
                     S_WWS0, S_WWS1, S_WWS2, S_WWS3, S_WWS4 
					} state, next_state;
	

always_ff @(posedge clk or negedge reset)
		if (!reset)	begin
         state <= S_RW0;
      end
		else
         state <= next_state;
		
always_comb begin: set_next_state
	next_state = state;	// default condition is next state is present state
	unique case (state)
      //
      // Read 32-bit data word from bus and load into addressed register
      //
      S_RW0 :
         next_state = (subsystem_enable == 1'b1) ? S_RW1 : S_RW0;   
		S_RW1 :
			next_state = (handshake_1 == 1'b1) ? S_RW2 : S_RW1;         
		S_RW2 :
			next_state = (RW) ? S_RW3 : S_RW4;
		S_RW3 :
			next_state = S_RW4;
		S_RW4 :
			next_state = S_RW5;
		S_RW5 :
         next_state = (handshake_1 == 1'b1) ? S_RW5 : S_RW6;
		S_RW6 :
			next_state = S_WWD0;
      //
      // Write 32-bit data word onto BUS
      //
      S_WWD0 :
			next_state = S_WWD1;
      S_WWD1 :
			next_state = S_WWD2;   
		S_WWD2 :
         next_state = (handshake_1 == 1'b1) ? S_WWD3 : S_WWD2;
		S_WWD3 :
			next_state = S_WWD4; 
      S_WWD4 :
         next_state = (handshake_1 == 1'b1) ? S_WWD4 : S_WWS0;
      //
      // Write 32-bit status word onto BUS
      // 
      S_WWS0 :
			next_state = S_WWS1;
      S_WWS1 :
			next_state = S_WWS2;   
		S_WWS2 :
         next_state = (handshake_1 == 1'b1) ? S_WWS3 : S_WWS2;
		S_WWS3 :
			next_state = S_WWS4; 
      S_WWS4 :
         next_state = (handshake_1 == 1'b1) ? S_WWS4 : S_RW0; 
	endcase
end: set_next_state

//
// Moore outputs
//
assign read_word_from_BUS       =  (state == S_RW2);
assign write_data_word_to_BUS   =  (state == S_WWD0);
assign write_status_word_to_BUS =  (state == S_WWS0);
assign handshake_2              = ((state == S_RW3)  || (state == S_RW4)  ||
                                   (state == S_WWD1) || (state == S_WWD2) ||
                                   (state == S_WWS1) || (state == S_WWS2));
                                  

endmodule
