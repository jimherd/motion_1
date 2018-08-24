//
// uP_interface.sv : 
//
// Implement an 8-bit interface to control microcontroller
//
`include  "global_constants.sv"
`include  "interfaces.sv"

module uP_interface(
                     input  logic   clk, reset,
                     IO_bus.master  bus,
                     input  logic   uP_start, uP_handshake_1, uP_soft_reset,
                     output logic   uP_ack, uP_handshake_2,
                     input  byte_t  uP_data_out,
                     output byte_t  uP_data_in
                   );
                   

logic counter_zero, set_in_byte_count, set_out_byte_count, increment_count;

logic ack, start, handshake2_1, handshake2_2;

byte_t counter, target_count;

byte_t input_packet[`NOS_READ_BYTES];
byte_t output_packet[`NOS_WRITE_BYTES];


uP_interface_FSM uP_interface_sys(
               .clk(clk), 
               .reset(reset), 
               .RW(bus.RW), 
               .handshake1_1(bus.handshake1_1),
               .handshake1_2(bus.handshake1_2),
               .start(uP_start), 
               .ack(uP_ack),
               .soft_reset(uP_soft_reset),
               .handshake2_1(uP_handshake_1),
               .handshake2_2(uP_handshake_2),
               .counter_zero(counter_zero),
               .set_in_byte_count(set_in_byte_count), 
               .set_out_byte_count(set_out_byte_count), 
               .increment_count(increment_count)
               ); 


always_ff @(posedge clk) begin
   if (!reset) begin
      counter <= 0; 
      target_count <= 0;;
   end else begin
   if (set_in_byte_count == 1'b1) begin
      target_count <= `NOS_READ_BYTES;
      counter <= 0;
   end else 
      if (set_out_byte_count == 1'b1) begin
         target_count <= `NOS_WRITE_BYTES;
         counter <= 0;
      end
      else if (increment_count == 1'b1) begin
            counter <= counter + 1'b1;
            target_count <= target_count - 1'b1;
         end  
   end
end

assign  counter_zero = (counter == 0) ? 1'b1 : 1'b0;

//assign  uP_ack = ack;
              
endmodule
