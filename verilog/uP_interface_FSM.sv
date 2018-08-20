//
// uP_interface_FSM.sv : 
//
// State machine to run 32-bit interface. Moore machine
//
`include  "global_constants.sv"

module uP_interface_FSM(
               input  logic  clk, reset, 
               output logic  RW, handshake1_1,
               input  logic  handshake1_2,
               input  logic  handshake2_1, start, ack, soft_reset,
               output logic  handshake2_2,
               
               input  logic  counter_zero,
               output logic  set_in_byte_count, set_out_byte_count, decrement_count
               );

enum bit [5:0] {	S_M0, S_M1,
                  S_R0, S_R1, S_R2, S_R3,
                  S_M2, S_M3,
                  S_E0, S_E1, 
                  S_M4, 
                  S_W0, S_W1, S_W2, S_W3, S_W4,
                  S_M5, S_M6, S_M7, S_M8
					} state, next_state;
	

always_ff @(posedge clk or negedge reset)
		if (!reset)	begin
         state <= S_M0;
      end
		else
         state <= next_state;
		
always_comb begin: set_next_state
	next_state = state;	// default condition is next state is present state
	unique case (state)
		S_M0:
			next_state = (start) ? S_M1 : S_M2;   
      S_M1: 
         next_state = S_R0;
         
      S_R0 :  // read a byte from uP 
         next_state = (handshake2_1 == 1) ? S_R1 : S_R0; 
      S_R1 :
         next_state = S_R2;
      S_R2 :
         next_state = S_R3;
      S_R3 : 
         next_state = (handshake2_1 == 0) ? S_M2 : S_R3; 
         
      S_M2:
			next_state = S_M3;
      S_M3:
			next_state = (counter_zero == 0) ? S_E0 : S_R0; 
      S_M4:
			next_state = S_W0; 
         
      S_W0:  // write a byte to uP 
         next_state = S_W1;
      S_W1:
         next_state = S_W2;
      S_W2: 
         next_state = (handshake2_1 == 1) ? S_W3 : S_W2; 
      S_W3:
         next_state = S_W4;
      S_W4: 
         next_state = (handshake2_1 == 0) ? S_M5 : S_W4; 
      
      S_M5:
			next_state = S_M6;
      S_M6:
			next_state = (counter_zero == 0) ? S_M7 : S_W0; 
      S_M7:
			next_state = S_M8; 
		S_M8:
			next_state = (start) ? S_M8 : S_M0;     
		default:
			next_state = S_M0;
	endcase
end: set_next_state

always_comb  begin: set_outputs
	case (state)
		S_M0, S_M3, S_M6, S_M8 : begin
            RW = 0;
            handshake1_1         = 0;
            handshake2_2         = 0;
            set_in_byte_count    = 0;
            set_out_byte_count   = 0;
            decrement_count      = 0;
         end
		S_M1 : begin
            RW = 0;
            handshake1_1         = 0;
            handshake2_2         = 0;
            set_in_byte_count    = 1;
            set_out_byte_count   = 0;
            decrement_count      = 0;
         end
      S_M2, S_M5 : begin
            RW = 0;
            handshake1_1         = 0;
            handshake2_2         = 0;
            set_in_byte_count    = 0;
            set_out_byte_count   = 0;
            decrement_count      = 1;
         end
      S_M4 : begin
            RW = 0;
            handshake1_1         = 0;
            handshake2_2         = 0;
            set_in_byte_count    = 0;
            set_out_byte_count   = 1;
            decrement_count      = 0;
         end
		default: begin
            RW = 0;
            handshake1_1         = 0;
            handshake2_2         = 0;
            set_in_byte_count    = 0;
            set_out_byte_count   = 0;
            decrement_count      = 0;            
         end
	endcase	
end: set_outputs

endmodule
