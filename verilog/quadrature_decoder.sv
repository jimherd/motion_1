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
// quadrature_decoder.sv : decode encoder signals
// =====================
//
// 4x decoder : 4 pulses per A/B cycle.
// Generates a single pulse for each edge of A and B signals.
//
// No need to synchronise as this is done on input
//
// Notes
//		The output 'index' is used as a 'clock' edge in later logic.  This will show up
//    as a warning in Quartus.  

`include  "global_constants.sv"

module quadrature_decoder(
    input  logic clk, reset,

    input  logic quadA_in,      // Synchronised quadrature input A
    input  logic quadB_in,      // Synchronised quadrature input B
    input  logic quadI_in,      // Synchronised quadrature input I

    output logic count_pulse,   // decoded pulse (X4 decoder)
    output logic direction,     // decoded direction signal
    output logic index          // index pulse (used as clock in logic)
);

//
// local variables

logic  quadA_delayed, quadB_delayed, index_sync;
logic  count_enable, count_direction;

//
// get raw encoder signals

always_ff @(posedge clk or negedge reset) begin 
    if (!reset) begin
        quadA_delayed <= 1'b0;
        quadB_delayed <= 1'b0;
        index_sync    <= 1'b0;
    end else begin
        quadA_delayed <=  quadA_in;
        quadB_delayed <=  quadB_in;
        index_sync    <=  quadI_in;
    end
end

//
// generate decoded signals

assign index         = index_sync;
assign count_pulse   = quadA_in ^ quadA_delayed ^ quadB_in ^ quadB_delayed;
assign direction     = quadA_in ^ quadB_delayed;

endmodule