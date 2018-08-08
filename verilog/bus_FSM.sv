//
// bus_FSM.sv : 
//
// State machine to run 32-bit interface. Moore machine
//
`include  "global_constants.sv"

module bus_FSM(clk, reset, ack, bus_data_avail, RW, data_avail, read_word, write_word);
input  logic  clk, reset, RW, bus_data_avail;
output logic  ack;
output logic  data_avail, read_word, write_word;

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
//         address_avail <= 0;
      end
		else
         state <= next_state;
		
always_comb begin: set_next_state
	next_state = state;	// default condition is next state is present state
	unique case (state)
		IDLE:
			next_state = (bus_data_avail) ? READ_ADDRESS : IDLE;         
		READ_ADDRESS:
			next_state = (RW) ? SEND_DATA : GET_DATA;
		SEND_DATA:
			next_state = SEND_ACK;
		GET_DATA:
			next_state = SEND_ACK;
		SEND_ACK:
			next_state = WAIT_NAVAIL;
		WAIT_NAVAIL:
         next_state = (bus_data_avail) ? WAIT_NAVAIL : SEND_NACK;
		SEND_NACK:
			next_state = IDLE;
	endcase
end: set_next_state

always_comb  begin: set_outputs
	case (state)
		IDLE: begin
            ack = 0;
            data_avail = 0;
            read_word = 0;
            write_word = 0;
         end
      READ_ADDRESS : begin
            ack = 0;
            data_avail = 1;
            read_word = 0;
            write_word = 0;
         end
      SEND_ACK: begin
            ack = 1;
            data_avail = 0;
            read_word = 0;
            write_word = 0;
         end
		SEND_DATA: begin
            ack = 1;
            data_avail = 0;
            read_word = 0;
            write_word = 1;
         end
      GET_DATA: begin
            ack = 1;
            data_avail = 0;
            read_word = 1;
            write_word = 0;
         end
		SEND_NACK: begin
            ack = 0;
            data_avail = 0;
            read_word = 0;
            write_word = 0;
         end
		default: begin
            ack = 0;
            data_avail = 0;
            read_word = 0;
            write_word = 0;
         end
	endcase	
end: set_outputs

endmodule
