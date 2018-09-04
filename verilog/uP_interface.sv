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
                   

logic counter_zero, set_in_uP_byte_count, set_out_uP_byte_count, read_uP_byte, write_uP_byte;

logic handshake2_1, handshake2_2;
logic  read_bus_word, clear_uP_packet;
logic  set_in_bus_word_count, set_out_bus_word_count;


//logic  uP_handshake_1, uP_start, uP_soft_reset;
//logic  uP_handshake_2, uP_ack;



byte_t counter, target_count;

byte_t input_packet[`NOS_READ_BYTES];
byte_t output_packet[`NOS_WRITE_BYTES];


uP_interface_FSM uP_interface_sys(
               .clk(clk), 
               .reset(reset), 
               .bus_RW(bus.RW), 
               .bus_handshake_1(bus.handshake1_1),
               .bus_handshake_2(bus.handshake1_2),
               .uP_start(uP_start), 
               .uP_ack(uP_ack),
               .uP_soft_reset(uP_soft_reset),
               .uP_handshake_1(uP_handshake_1),
               .uP_handshake_2(uP_handshake_2),
               .counter_zero(counter_zero),
               .set_in_uP_byte_count(set_in_uP_byte_count), 
               .set_out_uP_byte_count(set_out_uP_byte_count),
               .set_out_bus_word_count(set_out_bus_word_count),
               .read_uP_byte(read_uP_byte), 
               .write_uP_byte(write_uP_byte),
               .clear_uP_packet(clear_uP_packet)
               ); 


always_ff @(posedge clk) begin
   if (!reset) begin
      counter <= 0; 
      target_count <= 0;;
   end 
   else begin
      if (set_in_uP_byte_count == 1'b1) begin
         target_count <= `NOS_READ_BYTES;
         counter <= 0;
      end else begin
         if (set_out_uP_byte_count == 1'b1) begin
            target_count <= `NOS_WRITE_BYTES;
            counter <= 0;
         end
         else begin  
            if (read_uP_byte == 1'b1) begin
               input_packet[counter] <= uP_data_out;
               counter <= counter + 1'b1;
               target_count <= target_count - 1'b1;
            end
            else begin
               if (write_uP_byte == 1'b1) begin
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

              
endmodule
