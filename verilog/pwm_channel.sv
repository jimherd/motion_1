//
// pwm_channel.sv : 
//
// Implement a PWM generation channel
//
// Timings are in units of 20nS.
//
`include  "global_constants.sv"
`include  "interfaces.sv"

module pwm_channel  #(parameter PWM_UNIT = 0)  (
                     input  logic  clk, reset,
                     IO_bus bus,
                     output logic  pwm_signal,
							output logic  H_bridge_1, H_bridge_2
                     );
//
// PWM subsystem registers
//   
logic [31:0]  T_period;    // in units of 20nS
logic [31:0]  T_on;        // in units of 20nS
logic [31:0]  pwm_config; 
logic [31:0]  pwm_status;

//
// Local registers
//
logic [31:0]  T_period_temp;
logic [31:0]  T_on_temp;

logic         H_bridge_int_enable;
logic         H_bridge_ext_enable;
logic  [2:0]  H_bridge_cmd;
logic  [1:0]  H_bridge_mode;
logic         H_bridge_swap;
logic         H_bridge_dwell_mode;
logic  [1:0]  H_bridge_invert_mode;

logic T_period_zero, T_on_zero;
logic dec_T_on, dec_T_period, reload_times;
logic pwm_enable;
logic data_avail, read_word_from_BUS, write_data_word_to_BUS, write_status_word_to_BUS;
logic pwm;
logic subsystem_enable;

logic [31:0] data_in_reg;


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
   
pwm_FSM   pwm_FSM_sys(
   .clk(clk),
   .reset(reset),
   .pwm_enable(pwm_enable),
   .T_on_zero(T_on_zero), 
   .T_period_zero(T_period_zero),
   .dec_T_on(dec_T_on), 
   .dec_T_period(dec_T_period), 
   .reload_times(reload_times),
   .pwm(pwm) 
   );
	
H_bridge  H_bridge_sys( 
   .PWM_signal(pwm),
	.int_enable(H_bridge_int_enable), 
	.ext_enable(H_bridge_ext_enable), 
	.command(H_bridge_cmd), 
	.mode(H_bridge_mode), 
	.swap(H_bridge_swap),
	.pwm_dwell(H_bridge_dwell_mode),
	.invert(H_bridge_invert_mode),
	.H_bridge_1(H_bridge_1), 
	.H_bridge_2(H_bridge_2)
);
   
//
// Data subsystem to calculate pulse edges
//
always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      T_on_temp = 0;
   end else begin
      if (dec_T_on) begin
         T_on_temp = T_on_temp - 1;
      end else begin 
         if (reload_times) begin
            T_on_temp = T_on;
         end
      end
   end
end
 
always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      T_period_temp = 0;
   end else begin
      if (dec_T_period) begin
         T_period_temp = T_period_temp - 1;
      end else begin 
         if (reload_times) begin
            T_period_temp = T_period;
         end
      end
   end
end 

assign T_period_zero =  (T_period_temp == 0) ? 1'b1 : 1'b0;
assign T_on_zero     =  (T_on_temp == 0)     ? 1'b1 : 1'b0;

//
// data subsystem to talk to bus interface
//
// get data from bus. If read command then ignore data word.
// Clear PWM_enable signal if period or on timings are changed otherwise
// system can get into an infinite loop.
//
always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      T_period   <= 0;
      T_on       <= 0;
      pwm_config <= 0;
   end else begin
      if ((read_word_from_BUS == 1'b1) && (bus.RW == 1)) begin
         if (bus.reg_address == (`PWM_PERIOD + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))) begin
            T_period <= bus.data_out - `T_PERIOD_ADJUSTMENT;   // tweak to meet exact timing
            pwm_config[0] = 1'b0;   // clear enable signal
         end else 
            if (bus.reg_address == (`PWM_ON_TIME + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))) begin
               T_on <= bus.data_out - `T_ON_ADJUSTMENT;    // tweak to meet exact timing
               pwm_config[0] = 1'b0;   // clear enable signal
            end else
               if (bus.reg_address == (`PWM_CONFIG + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))) begin
                  pwm_config <= bus.data_out;
               end
         end
   end
end

assign  pwm_enable           = pwm_config[`PWM_ENABLE];

assign  H_bridge_int_enable  = pwm_config[`H_BRIDGE_INT_ENABLE];
assign  H_bridge_ext_enable  = pwm_config[`H_BRIDGE_EXT_ENABLE];
assign  H_bridge_cmd         = pwm_config[(`H_BRIDGE_COMMAND + 2) : `H_BRIDGE_COMMAND];
assign  H_bridge_mode        = pwm_config[(`H_BRIDGE_MODE + 1) : `H_BRIDGE_MODE];
assign  H_bridge_swap        = pwm_config[`PWM_ENABLE];
assign  H_bridge_dwell_mode  = pwm_config[`H_BRIDGE_DWELL_MODE];
assign  H_bridge_invert_mode = pwm_config[(`H_BRIDGE_INVERT_PINS + 1) : `H_BRIDGE_INVERT_PINS];

//
// put data onto bus
//
always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      data_in_reg <= 'z;
   end  else begin
      if(write_data_word_to_BUS == 1'b1) begin
         case (bus.reg_address)  
            (`PWM_PERIOD  + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))  : data_in_reg <= T_period;
            (`PWM_ON_TIME + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))  : data_in_reg <= T_on;
            (`PWM_CONFIG  + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))  : data_in_reg <= pwm_config;
            (`PWM_STATUS  + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))  : data_in_reg <= pwm_status;
         endcase
      end else begin
         if(write_status_word_to_BUS == 1'b1) begin
            data_in_reg <= pwm_status;
         end else
            data_in_reg <= 'z;
      end
   end
end

assign pwm_signal = pwm;   // set pwm signal value

//
// create status word
//
assign pwm_status = {pwm, {15{1'b0}}, pwm_config[15:0]};


//
// assess if registers numbers refer to this subsystem
//
always_comb begin
      subsystem_enable = 0;
      case (bus.reg_address)  
         (`PWM_PERIOD  + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))  : subsystem_enable = 1;
         (`PWM_ON_TIME + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))  : subsystem_enable = 1;
         (`PWM_CONFIG  + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))  : subsystem_enable = 1;
         (`PWM_STATUS  + (`PWM_BASE + (PWM_UNIT * `NOS_PWM_REGISTERS)))  : subsystem_enable = 1;
         default                                                         : subsystem_enable = 0; 
      endcase
end

//
// define 32-bit value to be written to bus
//
assign bus.data_in = (subsystem_enable) ? data_in_reg : 'z;

//assign motion_system.test_pt1 = subsystem_enable;

endmodule
