//
// bus_FSM.sv : 
//
// State machine to run 32-bit interface. Moore machine
//
`include  "global_constants.sv"

module bus_FSM( 
               input  logic  clk, reset, 
               input  logic  RW, handshake1_1,
               output logic  handshake1_2,
               output logic  data_avail, 
               output logic  read_word_from_BUS, write_word_to_BUS
               );

enum bit [2:0] {	IDLE,
                  READ_ADDRESS,
						GET_DATA,
						SEND_DATA,
						SEND_ACK,
						WAIT_NAVAIL,
						SEND_NACK
					} state, next_state;
	

always_ff @(posedge clk or negedge reset)
		if (!reset)	begin
         state <= IDLE;
      end
		else
         state <= next_state;
		
always_comb begin: set_next_state
	next_state = state;	// default condition is next state is present state
	unique case (state)
		IDLE:
			next_state = (handshake1_1) ? READ_ADDRESS : IDLE;         
		READ_ADDRESS:
			next_state = (RW) ? SEND_DATA : GET_DATA;
		SEND_DATA:
			next_state = SEND_ACK;
		GET_DATA:
			next_state = SEND_ACK;
		SEND_ACK:
			next_state = WAIT_NAVAIL;
		WAIT_NAVAIL:
         next_state = (handshake1_1) ? WAIT_NAVAIL : SEND_NACK;
		SEND_NACK:
			next_state = IDLE;
	endcase
end: set_next_state

always_comb  begin: set_outputs
	case (state)
		IDLE: begin
            handshake1_2 = 0;
            data_avail = 0;
            read_word_from_BUS = 0;
            write_word_to_BUS = 0;
         end
      READ_ADDRESS : begin
            handshake1_2 = 0;
            data_avail = 1;
            read_word_from_BUS = 0;
            write_word_to_BUS = 0;
         end
      SEND_ACK: begin
            handshake1_2 = 1;
            data_avail = 0;
            read_word_from_BUS = 0;
            write_word_to_BUS = 0;
         end
		SEND_DATA: begin
            handshake1_2 = 1;
            data_avail = 0;
            read_word_from_BUS = 0;
            write_word_to_BUS = 1;
         end
      GET_DATA: begin
            handshake1_2 = 1;
            data_avail = 0;
            read_word_from_BUS = 1;
            write_word_to_BUS = 0;
         end
		SEND_NACK: begin
            handshake1_2 = 0;
            data_avail = 0;
            read_word_from_BUS = 0;
            write_word_to_BUS = 0;
         end
		default: begin
            handshake1_2 = 0;
            data_avail = 0;
            read_word_from_BUS = 0;
            write_word_to_BUS = 0;
         end
	endcase	
end: set_outputs

endmodule
