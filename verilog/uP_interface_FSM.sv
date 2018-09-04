 //
// uP_interface_FSM.sv : 
//
// State machine to run 32-bit interface. Moore machine
//
`include  "global_constants.sv"

module uP_interface_FSM(
            input  logic  clk, reset, 
            output logic  bus_RW, bus_handshake_1,
            input  logic  bus_handshake_2,
            input  logic  uP_handshake_1, uP_start, uP_soft_reset, counter_zero,
            output logic  uP_handshake_2, uP_ack,
            output logic  read_uP_byte, write_uP_byte, read_bus_word, clear_uP_packet,             
            output logic  set_in_uP_byte_count, set_out_uP_byte_count,
            output logic  set_in_bus_word_count, set_out_bus_word_count
            );
//
// set of FSM states
//
enum bit [6:0] {	// section #1
                     S_M0, 
                     S_RuP0, S_RuP1, S_RuP2, S_RuP3, S_RuP4, S_RuP5,
                  // section #2
                     S_WB0, S_WB1, S_WB2, S_WB3,
                  // section #3
                     S_RB0, S_RB1, S_RB2, S_RB3, S_RB4, S_RB5, 
                  // section #4 
                     S_WuP0, S_WuP1, S_WuP2, S_WuP3, S_WuP4, S_WuP5, S_WuP6,
                  // section #5 
                     S_M1, S_M2,
                     S_M3, S_M4, S_M5 
					} state, next_state;
	

always_ff @(posedge clk or negedge reset) begin
		if (!reset)
         state <= S_M0;
      else
         state <= next_state;
end
		
always_comb begin: set_next_state
	next_state = state;	// default condition is next state is present state
	unique case (state)
		S_M0:
			next_state = (uP_start) ? S_M1 : S_M2;
      //   
      // read a byte packet from uP and check for "soft_reset" command
      //    
      S_RuP0 :
         next_state = S_RuP1;
      S_RuP1 :
         next_state = (uP_handshake_1 == 1) ? S_RuP2 : S_RuP1; 
      S_RuP2 :
         next_state = S_RuP3;
      S_RuP3 :
         next_state = S_RuP4;
      S_RuP4 : 
         next_state = (uP_handshake_1 == 0) ? S_RuP5 : S_RuP4; 
      S_RuP5 :
         next_state = (counter_zero == 0) ? S_WB0 : S_M1;
      S_M1   :
         next_state = (uP_soft_reset == 0) ? S_WB0 : S_M2;
      S_M2   :
         next_state = S_WuP0;
      //
      // send data onto system 32-bit bus
      //
      S_WB0 :
         next_state = S_WB1;
      S_WB1 :
         next_state = (bus_handshake_1 == 1) ? S_WB2 : S_WB1; 
      S_WB2 :
         next_state = S_WB3;
      S_WB3 : 
         next_state = (bus_handshake_1 == 0) ? S_RB0 : S_WB3; 
      //
      // read data from addressed slave
      //
      S_RB0 :
         next_state = S_RB1;
      S_RB1 :
         next_state = S_RB2;   
      S_RB2 :
         next_state = (bus_handshake_1 == 1) ? S_RB3 : S_RB2; 
      S_RB3 :
         next_state = S_RB4;
      S_RB4 : 
         next_state = (bus_handshake_1 == 0) ? S_RB5 : S_RB4; 
      S_RB5 :
         next_state = (counter_zero == 0) ? S_WuP0 : S_RB1;   
      //
      // send data packet to uP
      //
      S_WuP0:  
         next_state = S_WuP1;
      S_WuP1:
         next_state = S_WuP2;
      S_WuP2:
         next_state = S_WuP3;
      S_WuP3: 
         next_state = (uP_handshake_1 == 1) ? S_WuP4 : S_WuP3; 
      S_WuP4:
         next_state = S_WuP5;
      S_WuP5: 
         next_state = (uP_handshake_1 == 0) ? S_WuP6 : S_WuP5; 
      S_WuP6 :
         next_state = (counter_zero == 0) ? S_M3 : S_WuP1;  
      //
      // complete data transaction with uP
      //
      S_M3:
			next_state = S_M4;
      S_M4:
			next_state = (uP_start == 0) ? S_M5 : S_M4; 
      S_M5:
			next_state = S_M1; 
	endcase
end: set_next_state

always_comb  begin: set_outputs
	case (state)
		S_M0, S_RuP1, S_RuP5, S_WB2, S_WB3, S_RB4, S_RB5, S_WuP4, S_WuP5, S_WuP6, S_M1, S_M5  : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end
		S_RuP0 : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 1;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end
      S_RuP2 : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 1; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end
      S_RuP3, S_RuP4  : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 1;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end
      S_WB0, S_WB1 : begin
            bus_handshake_1         = 1;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end
      S_RB0 : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 1;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end
      S_RB1, S_RB2 : begin
            bus_handshake_1         = 1;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end   
      S_RB3 : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 1;
            clear_uP_packet         = 0;
         end 
      S_WuP0 : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 1;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end 
      S_WuP1,  S_WuP3 : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 1;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end
      S_M2 : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 1;
         end        
      S_M3, S_M4 : begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 1;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end        
		default: begin
            bus_handshake_1         = 0;
            uP_handshake_2          = 0;
            uP_ack                  = 0;
            set_in_uP_byte_count    = 0;
            set_out_uP_byte_count   = 0;
            set_in_bus_word_count   = 0;
            read_uP_byte            = 0; 
            write_uP_byte           = 0;
            read_bus_word           = 0;
            clear_uP_packet         = 0;
         end
	endcase	
end: set_outputs

endmodule
