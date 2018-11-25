//
// RC_servo_sv : 
//
// Implement a set of RC Servo  channels
//
`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;


module RC_servo  ( 
					input  logic clk, reset,
					IO_bus  bus,
					output logic [`NOS_RC_SERVO_CHANNELS:0] RC_servo
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
   
uint32_t  tmp_RC_on_times[`NOS_RC_SERVO_CHANNELS];

// local signals
//


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
//

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

assign RC_servo_enable  = RC_servo_config[`RC_SERVO_ENABLE];

//
// put data onto bus
//
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
//
assign bus.data_in = (subsystem_enable) ? data_in_reg : 'z;

		

endmodule
