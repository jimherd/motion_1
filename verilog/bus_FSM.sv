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
// bus_FSM.sv : State machine to run 32-bit interface in a peripheral subsystem
//
// Type : Standard three section Moore Finite State Machine structure
//
// Documentation :
//		State machine diagram in system notes folder.
//

`include  "global_constants.sv"

module bus_FSM( 
               input  logic  clk, reset, 
               input  logic  RW, subsystem_enable, handshake_1,
               output wire   handshake_2,
               output logic  read_word_from_BUS, write_data_word_to_BUS, write_status_word_to_BUS
               );

//
// set of states

enum bit [4:0] {
                  // section #1   
                     S_RW0, S_RW1, S_RW2, S_RW3, S_RW4, S_RW5, S_RW6, 
                  // section #2
                     S_WWD0, S_WWD1, S_WWD2, S_WWD3, S_WWD4, 
                  // section #3
                     S_WWS0, S_WWS1, S_WWS2, S_WWS3, S_WWS4, S_WWS5 
               } state, next_state;
   
//
// register next state

always_ff @(posedge clk or negedge reset)
      if (!reset)   begin
         state <= S_RW0;
      end
      else
         state <= next_state;

//
// next state logic
			
always_comb begin: set_next_state
   next_state = state;   // default condition is next state is present state
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
			`ifdef INCLUDE_32_BIT_STATUS_RETURN
					next_state = (handshake_1 == 1'b1) ? S_WWD4 : S_WWS0;
			`else
					next_state = (handshake_1 == 1'b1) ? S_WWD4 : S_WWS5;
			`endif
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
         next_state = (handshake_1 == 1'b1) ? S_WWS4 : S_WWS5;
      S_WWS5 :
         next_state = (subsystem_enable == 0) ? S_RW0 : S_WWS5;
   endcase
end: set_next_state

//
// Moore outputs

assign read_word_from_BUS       =  (state == S_RW2);
assign write_data_word_to_BUS   =  (state == S_WWD0) || (state == S_WWD1) || (state == S_WWD2);
assign write_status_word_to_BUS =  (state == S_WWS0) || (state == S_WWS1) || (state == S_WWS2);

logic handshake_2_reg; 

always_comb
begin
   if ((state == S_RW3) || (state == S_RW4) || (state == S_WWD1) || (state == S_WWD2) ||
                           (state == S_WWS1) || (state == S_WWS2)) 
      handshake_2_reg = 1'b1;
   else
      if (subsystem_enable == 1'b1)
         handshake_2_reg = 1'b0;
      else
         handshake_2_reg = 1'bz;
end

assign handshake_2 = handshake_2_reg;

endmodule
