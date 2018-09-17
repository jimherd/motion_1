//
// uP_interface.sv : 
//
// Implement an 8-bit interface to control microcontroller to the internal
// 32-bit bus to slave subsystems.
//
`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;

module uP_interface(
                     input  logic   clk, reset,
                     IO_bus.master  bus,
                     input  logic   uP_start, uP_handshake_1,
                     output logic   uP_ack, uP_handshake_2,
                     input  byte_t  uP_data_out,
                     output byte_t  uP_data_in
                   );
                   

logic counter_zero, set_in_uP_byte_count, set_out_uP_byte_count, read_uP_byte, write_uP_byte;
logic  read_bus_word, clear_uP_packet, uP_soft_reset;
logic  set_in_bus_word_count, set_out_bus_word_count;

byte_t counter, target_count, data_out, data_in_reg;

byte_t input_packet[`NOS_READ_BYTES];
byte_t output_packet[`NOS_WRITE_BYTES];


uP_interface_FSM uP_interface_sys(
               .clk(clk), 
               .reset(reset),  
               .bus_handshake_1(bus.handshake1_1),
               .bus_handshake_2(bus.handshake1_2),
               .uP_start(uP_start), 
               .uP_ack(uP_ack),
               .uP_handshake_1(uP_handshake_1),
               .uP_handshake_2(uP_handshake_2),
               .uP_soft_reset(uP_soft_reset),
               .counter_zero(counter_zero),
               .set_in_uP_byte_count(set_in_uP_byte_count), 
               .set_out_uP_byte_count(set_out_uP_byte_count),
               .set_in_bus_word_count(set_in_bus_word_count),
               .read_uP_byte(read_uP_byte), 
               .write_uP_byte(write_uP_byte),
               .read_bus_word(read_bus_word),
               .clear_uP_packet(clear_uP_packet)
               ); 


always_ff @(posedge clk) begin
   if (!reset) begin
      counter <= 0; 
      target_count <= 0;
      input_packet[`CMD_REG] <= 0;
      input_packet[`REGISTER_NUMBER] <= 0;
   end 
   else begin
      if (set_in_uP_byte_count == 1'b1) begin
         target_count <= byte_t'(`NOS_READ_BYTES);
         counter <= 0;
      end else begin
         if (set_out_uP_byte_count == 1'b1) begin
            target_count <= byte_t'(`NOS_WRITE_BYTES);
            counter <= 0;
         end
         else begin  
            if (read_uP_byte == 1'b1) begin
               input_packet[counter] <= data_out;   // uP_data_out
               counter <= counter + 1'b1;
               target_count <= target_count - 1'b1;
            end
            else begin
               if (write_uP_byte == 1'b1) begin
                  data_in_reg <= output_packet[counter];   // uP_data_in
                  counter <= counter + 1'b1;
                  target_count <= target_count - 1'b1;
               end
               else begin
                  if (read_bus_word == 1'b1) begin
                     output_packet[counter+0] <= bus.data_in[7:0];
                     output_packet[counter+1] <= bus.data_in[15:8];
                     output_packet[counter+2] <= bus.data_in[23:16];
                     output_packet[counter+3] <= bus.data_in[31:24];
                     counter <= byte_t'(counter + 4);
                     target_count <= byte_t'(target_count - 4);
                  end
                  else begin
                     if (clear_uP_packet == 1'b1) begin
                        output_packet[`UP_STATUS_REG] <= `RESET_CMD_DONE;
                        target_count <= byte_t'(`NOS_READ_BYTES);
                        counter <= 0;
                     end
                  end
               end
            end
         end
      end
   end
end


assign  counter_zero = (target_count == 0) ? 1'b1 : 1'b0;

assign  uP_soft_reset   = input_packet[`CMD_REG][`BIT7];

assign  bus.RW          = input_packet[`CMD_REG][`BIT0];
assign  bus.reg_address = input_packet[1];
assign  bus.data_out    = {input_packet[5],input_packet[4],input_packet[3],input_packet[2]};

assign  data_out = uP_data_out;
assign  uP_data_in = data_in_reg;

              
endmodule
