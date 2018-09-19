//
// interfaces.sv : Bus interface definitions
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
   logic  [31:0]  data_in;     // 'in'  wrt master
   logic  [31:0]  data_out;    // 'out' wrt master
   logic  [7:0]   reg_address;
   logic          RW, handshake_1, handshake_2; 
   
   modport master(input  data_in, handshake_2,
                  output data_out, reg_address, RW, handshake_1);
   
   modport slave( input  data_out, reg_address, RW, handshake_1,
                  output data_in, handshake_2);
   
endinterface
   
   
`endif    // _global_constants_sv_

