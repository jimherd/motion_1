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
// supervisor.sv : Check operation of system
// =============
//
// Notes
//	

`include  "global_constants.sv"

import types::*;

module supervisor( 
               input  logic  clk, reset,
					
					input logic   uP_handshake_1, uP_handshake_2,
					input logic   bus_handshake_1, bus_handshake_2,
					
					output logic  led_2, led_3, led_4, led_5
               );


//
// Code here to check system

// show handshake signals on LEDs
//		- "bus_handshake_2" is a tri-state to will show ON
					
assign led_2 = ~uP_handshake_1;
assign led_3 = ~uP_handshake_2;
assign led_4 = ~bus_handshake_1;
assign led_5 = ~bus_handshake_2;

endmodule