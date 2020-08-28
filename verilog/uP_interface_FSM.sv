/*
MIT License

Copyright (c) 2018 James Herd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//
// uP_interface_FSM.sv : State machine to run 32-bit interface
// ===================
//
// Type : Standard three section Moore Finite State Machine structure
//
// Documentation :
//		State machine diagram in system notes folder.
//
// Notes
//		State machine to control data transfer over the internal 32-bit data bus.
//    Bus consists of four parts
//			1. 32-bit bus from uP interface to peripheral subsystems
//			2. 32-bit bus from peripheral subsystems to uP interface
//			3. 8-bit register address bus from uP interface to peripheraal subsystems
//			4. set of handshake signals 
//
//		The state machine is split into 6 sections as follows
//			1. read bytes from uP
//			2. send data onto internal 32-bit bus
//			3  read TWO 32-bit values from addresses subsystem
//			4. send data to uP
//			5. complete transaction
//			6. handle soft reset signal
//
`include  "global_constants.sv"

module uP_interface_FSM(
            input  logic  clk, reset, 
				input  logic  uP_soft_reset, 				// allow uP to initiate FPGA reset
				
				input  logic  uP_start, 					// signal from uP to initiate start of transaction
				output logic  uP_ack,						//

            output logic  bus_handshake_1,			// first handshake line for internal 32-bit bus
            input  logic  bus_handshake_2,			// second handshake line for internal 32-bit bus
            input  logic  uP_handshake_1, 			// first handshake line for external 8-bit bus to uP
				output logic  uP_handshake_2, 			// second handshake line for external 8-bit bus to uP

            output logic  read_uP_byte, 				// read byte from uP
				output logic  write_uP_byte, 				//	write byte to uP
				
				output logic  read_bus_word, 				// read word from internal 32-bit bus
				output logic  clear_uP_packet,  			//           
            output logic  set_in_uP_byte_count, 	//
				output logic  set_out_uP_byte_count,	//
            output logic  set_in_bus_word_count,	//
				input  logic  counter_zero,				// == 1 when byte counter is zero

				output logic  set_timeout_counter,
				output logic  dec_timeout,
				input  logic  timeout_count_zero,
									
				output logic  register_address_valid	// defines time when subunits can decode register address
            );
//
// set of FSM states (refer to state diagram for different sections)

enum logic [6:0] {   // section #1    // bit
                     S_M0, 
                     S_RuP0, S_RuP1, S_RuP2, S_RuP3, S_RuP4, S_RuP5,
                  // section #2
                     S_WB0, S_WB1, S_WB2, S_WB3,
                  // section #3
                     S_RB0, S_RB1, S_RB2, S_RB3, S_RB4, S_RB5, 
                  // section #4 
                     S_WuP0, S_WuP1, S_WuP2, S_WuP3, S_WuP4, S_WuP5, S_WuP6,
                  // section #5 
                     S_M1, S_M2, S_M3, S_M4, S_M5 ,
						// section #6 - soft PING test (no reset required)
						   S_TST0, S_TST1, S_TST2, S_TST3, S_TST4
               } state, next_state;

//
// register next state		

always_ff @(posedge clk or negedge reset) begin
      if (!reset)
         state <= S_M0;
      else
         state <= next_state;
end

//
// next state logic
    
always_comb begin: set_next_state
   next_state = state;   // default condition is next state is present state
   unique case (state)
      S_M0:
			if (uP_start == 1) begin
				next_state = S_RuP0;
			end else begin
				if (uP_handshake_1 == 1) begin
					next_state = S_TST1;
				end else begin
					next_state = S_M0;
				end
			end
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
         next_state = (counter_zero) ? S_M1 : S_RuP1;
      S_M1   :
         next_state = (uP_soft_reset == 1) ? S_M2 : S_WB0;
      S_M2   :
         next_state = S_WuP0;
      //
      // send data onto system 32-bit bus
      //
      S_WB0 :
         next_state = S_WB1;
      S_WB1 :
         next_state = (bus_handshake_2 == 1) ? S_WB2 : S_WB1; 
      S_WB2 :
         next_state = S_WB3;
      S_WB3 : 
         next_state = (bus_handshake_2 == 0) ? S_RB0 : S_WB3; 
      //
      // read data from addressed slave
      //
      S_RB0 :
         next_state = S_RB1;
      S_RB1 :
         next_state = S_RB2;   
      S_RB2 :
         next_state = (bus_handshake_2 == 1) ? S_RB3 : S_RB2; 
      S_RB3 :
         next_state = S_RB4;
      S_RB4 : 
         next_state = (bus_handshake_2 == 0) ? S_RB5 : S_RB4; 
      S_RB5 :
         next_state = (counter_zero) ? S_WuP0 : S_RB1;   
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
         next_state = (counter_zero) ? S_M3 : S_WuP1;  
      //
      // complete data transaction with uP
      //
      S_M3:
         next_state = S_M4;
      S_M4:
         next_state = (uP_start == 0) ? S_M5 : S_M4; 
      S_M5:
         next_state = S_M0; 
		//
		// Handshake only to implement PING to check that FPGA is active
		// Includes timeout to ensure that system does not hang
		//
		S_TST0:
			next_state = S_TST1;
		S_TST1:
			next_state = (uP_handshake_1 == 0) ? S_TST2 : S_TST3; 
		S_TST2:
			next_state = S_M0;
		S_TST3:
			next_state = S_TST4;
		S_TST4:
			next_state = (timeout_count_zero == 0) ? S_TST2 : S_TST1;
			
   endcase
end: set_next_state

//
// Moore outputs

assign set_in_uP_byte_count  =  (state == S_RuP0);  //   //state[S_RuP0];
assign read_uP_byte          =  (state == S_RuP2);
assign uP_handshake_2        = ((state == S_RuP3) || (state == S_RuP4) || 
 										  (state == S_WuP2) || (state == S_WuP3) ||
										  (state == S_TST0) || (state == S_TST1) || (state == S_TST3) || (state == S_TST4));
assign bus_handshake_1       = ((state == S_WB0)  || (state == S_WB1)  || (state == S_RB1)  ||
                                (state == S_RB2)  || (state == S_RB3));
assign set_out_uP_byte_count =  (state == S_WuP0);
assign write_uP_byte         =  (state == S_WuP1);
assign uP_ack                = ((state == S_M3)   || (state == S_M4));
assign clear_uP_packet       =  (state == S_M2);                           
assign set_in_bus_word_count =  (state == S_RB0);
assign read_bus_word         =  (state == S_RB3);

assign set_timeout_counter   =  (state == S_TST0);
assign dec_timeout           =  (state == S_TST3);


always_comb
begin
	if ((state >= S_WB0) && (state <= S_WuP0)) 
		register_address_valid = 1'b1;
	else
		register_address_valid = 1'b0;
end

endmodule
