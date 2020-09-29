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
// SYS_info_sv :
//
// Read only data about system

`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;


module SYS_info  (
    input  logic clk, reset,
    IO_bus  bus
);

logic [31:0] data_in_reg;
logic        nFault;

//
// subsystem registers accessible to external system

//uint32_t  SYS_info_reg_0;
//
// internal registers

// local signals
//


/////////////////////////////////////////////////
//
// Connection to internal system 32-bit bus

logic read_word_from_BUS, write_data_word_to_BUS, write_status_word_to_BUS;
logic subsystem_enable;

//logic register_address_valid;

bus_FSM   bus_FSM_sys(
        .clk(clk),
        .reset(reset),
        .subsystem_enable(subsystem_enable),
        .handshake_2(bus.handshake_2),
        .handshake_1(bus.handshake_1),
        .RW(bus.RW),
        .read_word_from_BUS(read_word_from_BUS),
        .write_data_word_to_BUS(write_data_word_to_BUS),
        .write_status_word_to_BUS(write_status_word_to_BUS),
        .register_address_valid(bus.register_address_valid)
        );


//
// put data onto bus

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        data_in_reg <= 'z;
   end  else begin
        if(write_data_word_to_BUS == 1'b1) begin
            if (bus.reg_address == `SYS_INFO_0 ) begin
                data_in_reg <= `SYS_INFO_0_DATA;
            end
        end else begin
            if(write_status_word_to_BUS == 1'b1) begin
                data_in_reg <= ~`SYS_INFO_0_DATA;
            end else
                data_in_reg <= 'z;
        end
    end
end

//
// assess if registers numbers refer to this subsystem

always_comb begin
    subsystem_enable = 1'b0;
    if (bus.register_address_valid == 1'b1) begin
        if ( (bus.reg_address >= `REGISTER_BASE) && (bus.reg_address < `PWM_BASE))
            subsystem_enable = 1'b1;
    end
end

//
// define 32-bit value to be written to bus

assign bus.data_in = (subsystem_enable) ? data_in_reg : 'z;

//
// TEMP : no error handling so drive "nFault" signal to high impedence state

assign  bus.nFault = 'z;

endmodule