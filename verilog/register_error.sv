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
// register_error_sv : 
//
// Detect access to a register not conected to any subsystem

`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;

/////////////////////////////////////////////////
//
// module interface definition

module register_error  ( 
    input  logic clk, reset,
    IO_bus  bus
);

/////////////////////////////////////////////////
//
// local data

logic [31:0] data_in_reg;
logic reg_nFault;
logic subsystem_enable;

/////////////////////////////////////////////////
//
// instantiate Finite State Machines (FSMs)
//
// 1. FSM to interface to on-FPGA 32-bit bus

logic read_word_from_BUS, write_data_word_to_BUS, write_status_word_to_BUS;

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
// 2. FSM to manage nFault error line (tri-state line)

logic set_nFault_z, set_nFault_value;

error_processing_FSM  sys_error_processing_FSM (
    .clk(clk),
    .reset(reset),
    .register_address_valid(bus.register_address_valid),  
    .subsystem_enable(subsystem_enable),
    .set_nFault_z(set_nFault_z),
    .set_nFault_value(set_nFault_value)
);

/////////////////////////////////////////////////
//
// check if registers address refers to this subsystem

always_comb begin
    subsystem_enable = 1'b0;
    if (bus.register_address_valid == 1'b1) begin
        if ((bus.reg_address >= `FIRST_ILLEGAL_REGISTER) && (bus.reg_address <= `LAST_REGISTER)) begin
            subsystem_enable = 1'b1;
        end
    end
end

/////////////////////////////////////////////////
//
// put data onto bus 

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        data_in_reg <= 'z;
    end  else begin
        if(write_data_word_to_BUS == 1'b1) begin
            data_in_reg <= 32'h55555555;
        end else begin
            if(write_status_word_to_BUS == 1'b1) begin
                data_in_reg <= 32'hAAAAAAAA;
            end else begin
                data_in_reg <= 'z;
            end
        end
    end
end

/////////////////////////////////////////////////
//
// processes error onto nFault bus line

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        reg_nFault <= 'z;
    end  else begin
        if(set_nFault_z == 1'b1) begin
            reg_nFault <= 'z;
        end else begin
            if (set_nFault_value == 1'b1) begin
                reg_nFault <= 1'b0;
            end else begin
                reg_nFault <= 1'b1;
            end
        end
    end
end


/////////////////////////////////////////////////
//
// write data/control to internal 32-bit bus

assign bus.data_in = (subsystem_enable == 1'b1) ? data_in_reg : 'z;
assign bus.nFault  = reg_nFault;


endmodule