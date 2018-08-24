package types;

   parameter TEST = 0;

   typedef logic [31:0] register_t;
   typedef logic [7:0]  byte_t;
   typedef struct packed {logic [3:0] data_h;
                          logic [3:0] data_l;
                         } wdata_struct_t;
endpackage: types
