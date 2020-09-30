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
// uP_interface.sv : manage 32-bit bus to 8-bit bus conversions
// ===============
//
// All the hardwork is done in the state machine.

`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;

module uP_interface(
    input  logic  clk, reset,
    IO_bus.master bus,              // internal 32-bit peripheral bus
    input  logic  uP_start,         // ==1 to start transaction with uP
    input  logic  uP_handshake_1,   // first handshake to uP
    input  logic  uP_RW,            // read/write signal from uP
    output logic  uP_ack,           // transaction acknowledge signal to uP
    output logic  uP_handshake_2,   // second handshake to uP
    output logic  uP_nFault,        // fault line to uP
    inout  [7:0]  uP_data           // 8-bit bidirectional bus to uP
);


logic  counter_zero, set_in_uP_byte_count, set_out_uP_byte_count, read_uP_byte, write_uP_byte;
logic  read_bus_word, clear_uP_packet, uP_soft_reset;
logic  set_in_bus_word_count, set_out_bus_word_count;
logic  set_timeout_counter, dec_timeout, timeout_count_zero;
logic  register_address_valid;

byte_t counter, target_count, data_out;
byte_t data_in;

byte_t input_packet[`NOS_READ_BYTES_FROM_UP];
byte_t output_packet[`NOS_READ_BYTES_FROM_SLAVE];

uint16_t timeout_counter;


uP_interface_FSM uP_interface_sys (
    .clk(clk), 
    .reset(reset),  
    .bus_handshake_1(bus.handshake_1),
    .bus_handshake_2(bus.handshake_2),
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
    .clear_uP_packet(clear_uP_packet),
    .set_timeout_counter(set_timeout_counter),
    .dec_timeout(dec_timeout),
    .timeout_count_zero(timeout_count_zero),
    .register_address_valid(register_address_valid)
); 


always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        counter                         <= 1'b0; 
        target_count                    <= 1'b0;
        input_packet[`CMD_REG]          <= 1'b0;
        input_packet[`REGISTER_NUMBER]  <= 1'b0;
    end else begin
        if (set_in_uP_byte_count == 1'b1) begin
            target_count <= byte_t'(`NOS_READ_BYTES_FROM_UP);
            counter <= 1'b0;
        end else begin
            if (set_out_uP_byte_count == 1'b1) begin
                target_count <= byte_t'(`NOS_WRITE_BYTES_TO_UP);
                counter <= 1'b0;
            end else begin
                if (set_in_bus_word_count == 1'b1) begin
                    target_count <= byte_t'(`NOS_READ_BYTES_FROM_SLAVE);
                    counter <= 1'b0;
                end else begin  
                    if (read_uP_byte == 1'b1) begin
                        input_packet[counter] <= uP_data;   // uP_data_out
                        counter <= counter + 1'b1;
                        target_count <= target_count - 1'b1;
                    end else begin
                        if (write_uP_byte == 1'b1) begin
                            data_out <= output_packet[counter];   // uP_data_in
                            counter <= counter + 1'b1;
                            target_count <= target_count - 1'b1;
                            input_packet[`REGISTER_NUMBER] <= 1'b0;  // clear register address
                        end else begin
                            if (read_bus_word == 1'b1) begin
                                output_packet[counter+0] <= bus.data_in[7:0];
                                output_packet[counter+1] <= bus.data_in[15:8];
                                output_packet[counter+2] <= bus.data_in[23:16];
                                output_packet[counter+3] <= bus.data_in[31:24];
                                counter <= byte_t'(counter + 4);
                                target_count <= byte_t'(target_count - 4);
                            end else begin
                                if (clear_uP_packet == 1'b1) begin
                                    output_packet[`UP_STATUS_REG] <= `RESET_CMD_DONE;
                                    target_count <= byte_t'(`NOS_READ_BYTES_FROM_UP);
                                    counter <= 1'b0;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        timeout_counter <= 1'b0;
    end else begin
        if (set_timeout_counter) begin
            timeout_counter <= `TIMEOUT_COUNT;
        end else begin 
            if (dec_timeout) begin
                timeout_counter <= timeout_counter - 1'b1;
            end
        end
    end
end


assign  counter_zero = (target_count == 0) ? 1'b1 : 1'b0;

assign  uP_soft_reset   = input_packet[`CMD_REG][`BIT7];
assign  bus.RW          = input_packet[`CMD_REG][`BIT0];

assign  bus.reg_address = input_packet[1];
assign  bus.data_out    = {input_packet[5],input_packet[4],input_packet[3],input_packet[2]};

assign  uP_data = (uP_RW == 1'b0) ? data_out : 'z;

assign  timeout_count_zero  =  (timeout_counter == 0) ? 1'b1 : 1'b0;

assign  bus.register_address_valid = register_address_valid;

assign  uP_nFault = bus.nFault;


endmodule
