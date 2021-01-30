/*
MIT License

Copyright (c) 2020 James Herd

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
// error_processing_FSM.sv : manage setting of nFault line
// =======================
//
// Type : Standard three section Moore Finite State Machine structure
//
// Documentation :
//      State machine diagram in system notes folder.
//
// Notes
//
//
// States
//      S_E0 : Initial state - wait for "register_address_valid" signal
//      S_E1 : 20nS delay to allow "subsystem_enable" signal to stabalise
//      S_E2 : check "subsystem_enable"
//      S_E3 : unit not addressed to set "nFault" to 'z
//      S_E4 : wait for "register_address_valid" siganl to go low
//      S_E5 : set "nFault" appropriately

`include  "global_constants.sv"
`include  "interfaces.sv"

module error_processing_FSM (
    input  logic  clk, reset, 

    input  logic  register_address_valid,
    input  logic  subsystem_enable,

    output logic  set_nFault_z,
    output logic  set_nFault_value
);

//
// Set of FSM states and initial state


enum /* bit [3:0] */ {  
    S_E0, S_E1, S_E2, S_E3, S_E4, S_E5
} state, next_state;

`define    S_Ex_INITIAL_STATE    S_E0

//
// register next state

always_ff @(posedge clk or negedge reset) begin
    if (!reset)   begin
        state <= `S_Ex_INITIAL_STATE;
    end else begin         
        state <= next_state;
    end
end

//
// next state logic

always_comb begin: set_next_state
    unique case (state)
        S_E0:
            if (register_address_valid == 1'b0)
                next_state = S_E0;
            else
                next_state = S_E1;
        S_E1:
            next_state = S_E2;
        S_E2:
            if (subsystem_enable == 1'b0)
                next_state = S_E3;
            else
                next_state = S_E4;
        S_E3:
            next_state = `S_Ex_INITIAL_STATE;
        S_E4:
            if (register_address_valid == 1'b1)
                next_state = S_E4;
            else
                next_state = S_E5;
        S_E5:
            next_state = `S_Ex_INITIAL_STATE;
        default :
            next_state = state;   // default condition - next state is present state
    endcase
end: set_next_state

//
// set Moore outputs

assign set_nFault_z      = (state == S_E3);
assign set_nFault_value  = (state == S_E5);

endmodule


