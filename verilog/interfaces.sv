//
// interfaces.sv : Bus interface definitions
//
`ifndef   _interfaces_sv_
`define   _interfaces_sv_

interface IO_bus;
   logic  [31:0]  data_to_uP;
   logic  [31:0]  data_from_uP;
   logic  [7:0]   reg_address;
   logic          RW, handshake_1, handshake_2;
   
   modport slave( input  data_from_uP, reg_address, RW, handshake_1,
                  output data_to_uP, handshake_2);
   
endinterface
   
   
`endif    // _global_constants_sv_

