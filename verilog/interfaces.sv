//
// interfaces.sv : Bus interface definitions
//
`ifndef   _interfaces_sv_
`define   _interfaces_sv_

//
// IO_BUS : Bus connection to PWM and servo subsystems
//
// 32-bit bus with individual input and output busses
//
interface IO_bus;
   logic  [31:0]  data_in;
   logic  [31:0]  data_out;
   logic  [7:0]   reg_address;
   logic          RW, handshake_1, handshake_2;
   
   modport master(input  data_in, handshake_2,
                  output data_out, RW, handshake_1);
   
   modport slave( input  data_out, reg_address, RW, handshake_1,
                  output data_in, handshake_2);
   
endinterface
   
   
`endif    // _global_constants_sv_

