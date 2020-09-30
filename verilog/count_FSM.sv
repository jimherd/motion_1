/*
MIT License

Copyright (c) 2019 James Herd

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
// count_FSM.sv : up/down counter for slow pulses
// ============
//
// Type : Standard three section Moore Finite State Machine structure
//
// Documentation :
//		State machine diagram in system notes folder.
//
// Notes
//		Consists of two timers. One for the PWM period and one for the PWM ON time.
//
// States
//          S_COUNT0  : count hold state and wait for rising edge of pulse being counted
//          S_COUNT1  : check direction signal
//          S_COUNT2  : increment by 1
//          S_COUNT3  : decrement by 1
//          S_COUNT4  : wait for falling edge of pulse being counted

`include  "global_constants.sv"
`include  "interfaces.sv"

module count_FSM (
    input  logic  clk, reset, 

    input  logic  count_sig,        //
    input  logic  direction,        // signal to define direction of count

    output logic  inc_counter,      // decrement the ON time counter
    output logic  dec_counter       // decrement the period time counter
);

//
// Set of FSM states

enum bit [3:0] {  
    S_COUNT0, S_COUNT1, S_COUNT2, S_COUNT3, S_COUNT4
} state, next_state;
//
// register next state

always_ff @(posedge clk or negedge reset) begin
    if (!reset)   begin
        state <= S_COUNT0;
    end else begin       
        state <= next_state;
    end
end

//
// next state logic

always_comb begin: set_next_state
    unique case (state)
        S_COUNT0:
            if (count_sig == 0)
                next_state = S_COUNT0;
            else
                next_state = S_COUNT1;
        S_COUNT1:
            if (direction == 0)
                next_state = S_COUNT2;
            else
                next_state = S_COUNT3;
        S_COUNT2:
            next_state = S_COUNT4;
        S_COUNT3:
            next_state = S_COUNT4;
        S_COUNT4:
            if (count_sig == 0)
                next_state = S_COUNT0;
            else
                next_state = S_COUNT4;
        default :
            next_state = state;   // default condition - next state is present state
    endcase
end: set_next_state

//
// set Moore outputs

assign inc_counter  = (state == S_COUNT2);
assign dec_counter  = (state == S_COUNT3);

endmodule


