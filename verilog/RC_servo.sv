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
// RC_servo_sv : 
//
// Implement a set of RC Servo  channels

`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;


module RC_servo  ( 
					input  logic clk, reset,
					IO_bus  bus,
					output logic [(`NOS_RC_SERVO_CHANNELS-1):0] RC_servo
					);
					
logic [31:0] data_in_reg;

//
// subsystem registers accessible to external system
  
uint32_t  RC_servo_period;
uint32_t  RC_servo_config;
uint32_t  RC_servo_status;
uint32_t  RC_on_times[`NOS_RC_SERVO_CHANNELS];

//
// internal registers
   
uint32_t  tmp_RC_on_time_counter[`NOS_RC_SERVO_CHANNELS];
uint32_t  tmp_period_counter;

// local signals
//
logic RC_servo_global_enable;

/////////////////////////////////////////////////
//
// Connection to internal system 32-bit bus

logic data_avail, read_word_from_BUS, write_data_word_to_BUS, write_status_word_to_BUS;
logic subsystem_enable;

bus_FSM   bus_FSM_sys(
		.clk(clk),
		.reset(reset),
		.subsystem_enable(subsystem_enable),
		.handshake_2(bus.handshake_2),
		.handshake_1(bus.handshake_1),
		.RW(bus.RW),
		.read_word_from_BUS(read_word_from_BUS), 
		.write_data_word_to_BUS(write_data_word_to_BUS),
		.write_status_word_to_BUS(write_status_word_to_BUS)
		);

//
// data subsystem to talk to bus interface
//
// get data from bus. If read command then ignore data word.
// Clear PWM_enable signal if period or on timings are changed otherwise
// system can get into an infinite loop.

always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
		RC_servo_period		<= 0;
		RC_servo_config		<= 0;
		RC_servo_status		<= 0;
		for (int i=0; i < `NOS_RC_SERVO_CHANNELS; i=i+1) 
			RC_on_times[i] = 0;
   end else begin
      if ((read_word_from_BUS == 1'b1) && (bus.RW == 1)) begin
         if (bus.reg_address == (`RC_SERVO_PERIOD + `RC_BASE)) begin
            RC_servo_period <= bus.data_out;
         end else 
            if (bus.reg_address == (`RC_SERVO_CONFIG + `RC_BASE)) begin
               RC_servo_config <= bus.data_out;
            end else
               if (bus.reg_address == (`RC_SERVO_STATUS + `RC_BASE)) begin
                  RC_servo_status <= bus.data_out;
               end else
						if ((bus.reg_address >= `RC_ON_TIME_BASE) && (bus.reg_address < (`RC_ON_TIME_BASE + `NOS_RC_SERVO_CHANNELS))) begin
							RC_on_times[bus.reg_address - `RC_ON_TIME_BASE] <= bus.data_out;
						end
         end
   end
end

//
// put data onto bus

always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      data_in_reg <= 'z;
   end  else begin
      if(write_data_word_to_BUS == 1'b1) begin
			if (bus.reg_address == (`RC_SERVO_PERIOD + `RC_BASE)) begin
            data_in_reg <= RC_servo_period;
         end else begin
            if (bus.reg_address == (`RC_SERVO_CONFIG + `RC_BASE)) begin
               data_in_reg <= RC_servo_config;
            end else begin
               if (bus.reg_address == (`RC_SERVO_STATUS + `RC_BASE)) begin
                  data_in_reg <= RC_servo_status;
               end else begin
						if ((bus.reg_address >= `RC_ON_TIME_BASE) && (bus.reg_address < (`RC_ON_TIME_BASE + `NOS_RC_SERVO_CHANNELS))) begin
							data_in_reg <= RC_on_times[bus.reg_address - `RC_ON_TIME_BASE];
						end
					end
				end
         end
		end else begin
         if(write_status_word_to_BUS == 1'b1) begin
            data_in_reg <= RC_servo_status;
         end else
            data_in_reg <= 'z;
      end
   end
end

//
// assess if registers numbers refer to this subsystem

always_comb begin
      subsystem_enable = 0;
		if ( (bus.reg_address >= `RC_BASE) && (bus.reg_address < (3 + `NOS_RC_SERVO_CHANNELS) + `RC_BASE))  begin
			subsystem_enable = 1;
		end
end

//
// define 32-bit value to be written to bus

assign bus.data_in = (subsystem_enable) ? data_in_reg : 'z;

/////////////////////////////////////////////////
//
// Code to run individual servo channels

assign RC_servo_global_enable = RC_servo_config[`RC_SERVO_GLOBAL_ENABLE];

logic RC_servo_period_0;

genvar Servo_channel;
generate
	for (Servo_channel = 0; Servo_channel < `NOS_RC_SERVO_CHANNELS; Servo_channel = Servo_channel+1) begin : Servos
	
		logic ON_time_complete, RC_servo_ON, RC_servo_OFF;
		logic load_RC_servo_ON_timer;
		
		RC_servo_channel_FSM RC_servo_channel_FSM_sys( 
					.clk(clk),
					.reset(reset),
					.RC_enable(RC_servo_config[Servo_channel]),
					.RC_servo_period_0(RC_servo_period_0),
					.ON_time_complete(ON_time_complete),
					.RC_servo_ON(RC_servo_ON),
					.RC_servo_OFF(RC_servo_OFF),
					.load_RC_servo_ON_timer(load_RC_servo_ON_timer)
        );
		 
		 assign ON_time_complete = (tmp_RC_on_time_counter[Servo_channel] == 0) ? 1'b1 : 1'b0;	 
		 
		 always_ff @(posedge clk or negedge reset) begin
			if (!reset) begin
				tmp_RC_on_time_counter[Servo_channel] <= 0;
				RC_servo[Servo_channel]               <= 0;
			end  else begin
				if(load_RC_servo_ON_timer == 1'b1) begin
					tmp_RC_on_time_counter[Servo_channel] <= RC_on_times[Servo_channel];
				end else begin
					if(RC_servo_ON == 1'b1) begin
						tmp_RC_on_time_counter[Servo_channel] <= tmp_RC_on_time_counter[Servo_channel] - 1;
						RC_servo[Servo_channel] <= 1;
					end else begin
						if (RC_servo_OFF == 1'b1) begin
							RC_servo[Servo_channel] <= 0;
						end
					end
				end			
			end
		end
		 
	end // generate for loop
	
endgenerate

//
// update global servo period 20mS counter

 always_ff @(posedge clk) begin
	if (RC_servo_global_enable == 1'b1) begin
		if (tmp_period_counter > 0) begin
			tmp_period_counter <= tmp_period_counter - 1;
		end else begin
			tmp_period_counter <= RC_servo_period;
		end
	end
 end	

assign RC_servo_period_0 = (tmp_period_counter == 0) ? 1'b1 : 1'b0;

endmodule
