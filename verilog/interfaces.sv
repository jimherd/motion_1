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
// interfaces.sv : Bus interface definitions
// =============
//

`ifndef   _interfaces_sv_
`define   _interfaces_sv_

`include  "global_constants.sv"

//
// IO_BUS : Bus connection to multiple I/O subsystems
//
// 32-bit bus with individual input and output busses 
//
interface IO_bus (input clk);
    wire  [31:0]  data_in;     // 'in'  wrt master
    logic [31:0]  data_out;    // 'out' wrt master
    logic  [7:0]  reg_address;
    logic         handshake_1, RW, register_address_valid;
    wire          handshake_2; 
    wire          nFault;

    modport master(input  data_in, handshake_2, nFault,
                  output data_out, reg_address, RW, handshake_1, register_address_valid);

    modport slave( input  data_out, reg_address, RW, handshake_1, register_address_valid,
                  output data_in, handshake_2, nFault);

endinterface

`endif    // _global_constants_sv_

