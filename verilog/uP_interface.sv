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
                   

logic counter_zero, set_in_byte_count, set_out_byte_count, increment_count, read_byte, write_byte;

logic ack, start, handshake2_1, handshake2_2;

byte_t counter, target_count;

byte_t input_packet[`NOS_READ_BYTES];
byte_t output_packet[`NOS_WRITE_BYTES];


uP_interface_FSM uP_interface_sys(
               .clk(clk), 
               .reset(reset), 
               .word_RW(bus.RW), 
               .word_handshake_1(bus.handshake1_1),
               .word_handshake_2(bus.handshake1_2),
               .packet_start(uP_start), 
               .packet_ack(uP_ack),
               .soft_reset(uP_soft_reset),
               .byte_handshake_1(uP_handshake_1),
               .byte_handshake_2(uP_handshake_2),
               .counter_zero(counter_zero),
               .set_in_byte_count(set_in_byte_count), 
               .set_out_byte_count(set_out_byte_count), 
               .read_byte(read_byte), 
               .write_byte(write_byte)
               ); 


always_ff @(posedge clk) begin
   if (!reset) begin
      counter <= 0; 
      target_count <= 0;;
   end 
   else begin
      if (set_in_byte_count == 1'b1) begin
         target_count <= `NOS_READ_BYTES;
         counter <= 0;
      end else begin
         if (set_out_byte_count == 1'b1) begin
            target_count <= `NOS_WRITE_BYTES;
            counter <= 0;
         end
         else begin  
            if (read_byte == 1'b1) begin
               input_packet[counter] <= uP_data_out;
               counter <= counter + 1'b1;
               target_count <= target_count - 1'b1;
            end
            else begin
               if (write_byte == 1'b1) begin
                  uP_data_in <= output_packet[0];
                  counter <= counter + 1'b1;
                  target_count <= target_count - 1'b1;
               end
            end
         end
      end
   end
end



assign  counter_zero = (counter == 0) ? 1'b1 : 1'b0;

assign  bus.reg_address = input_packet[1];
assign  bus.data_out = {input_packet[5],input_packet[4],input_packet[3],input_packet[2]};

assign 
              
endmodule
