//
// uP_interface.sv : 
//
// Implement an 8-bit interface to control microcontroller
//
`include  "global_constants.sv"
`include  "interfaces.sv"

module uP_interface(
                     input  logic clk, reset,
                     IO_bus.master bus
                   );
                   
logic start, ack, soft_reset;
logic handshake2_1, handshake2_2;
logic counter_zero, set_in_byte_count, set_out_byte_count, decrement_count;

//logic [7:0] reg_add;

uP_interface_FSM uP_interface_sys(
               .clk(clk), 
               .reset(reset), 
               .RW(bus.RW), 
               .handshake1_1(bus.handshake1_1),
               .handshake1_2(bus.handshake1_2),
               .start(start), 
               .ack(ack),
               .soft_reset(soft_reset),
               .handshake2_1(handshake2_1),
               .handshake2_2(handshake2_2),
               .counter_zero(counter_zero),
               .set_in_byte_count(set_in_byte_count), 
               .set_out_byte_count(set_out_byte_count), 
               .decrement_count(decrement_count)
               ); 

always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      bus.reg_address = 0;
   end else begin
      bus.reg_address = 1;
   end
end 
              
endmodule
