//
// pwm_channel.sv : 
//
// Implement a PWM generation channel
//
`include  "global_constants.sv"
`include  "interfaces.sv"

module pwm_channel #(parameter PWM_UNIT = 0) (
                     input  logic  clk, reset,
                     IO_bus.slave  bus,
                     output logic  pwm_signal
                     );
//
// PWM subsystem registers
//	
int unsigned  T_period;    // in units of 100nS
int unsigned  T_on;        // in units of 100nS
logic [31:0]  pwm_config; 
logic [31:0]  pwm_status;

//
// Local registers
//
int unsigned  T_period_temp;
int unsigned  T_on_temp;

logic T_period_zero, T_on_zero;
logic dec_T_on, dec_T_period, reload_times;
logic pwm_enable;
logic data_avail, read_word_from_BUS, write_word_to_BUS;
logic pwm;


bus_FSM   bus_FSM_sys(
	.clk(clk),
	.reset(reset),
   .handshake1_2(bus.handshake1_2),
   .handshake1_1(bus.handshake1_1),
   .RW(bus.RW),
   .data_avail(data_avail), 
   .read_word_from_BUS(read_word_from_BUS), 
   .write_word_to_BUS(write_word_to_BUS)
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
   
assign pwm_signal = pwm;

//
// Data subsystem to calculate pulse edges
//
always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      T_on_temp = 0;
   end else begin
      if (dec_T_on) begin
         T_on_temp = T_on_temp -1;
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
         T_period_temp = T_period_temp -1;
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
// get data from bus
//
always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      T_period   <= 0;
      T_on       <= 0;
      pwm_config <= 0;
   end else begin
      if (read_word_from_BUS == 1'b1) begin
         if (bus.reg_address == (`PWM_PERIOD + (PWM_UNIT * `NOS_PWM_REGISTERS))) begin
            T_period <= bus.data_out;
         end else 
            if (bus.reg_address == (`PWM_ON_TIME + (PWM_UNIT * `NOS_PWM_REGISTERS))) begin
               T_on <= bus.data_out;
            end else
               if (bus.reg_address == (`PWM_CONFIG + (PWM_UNIT * `NOS_PWM_REGISTERS))) begin
                  pwm_config <= bus.data_out;
               end
         end
   end
end

//
// put data onto bus
//
always_ff @(posedge clk) begin
   if(write_word_to_BUS == 1'b1) begin
      case (bus.reg_address)  
         (`PWM_PERIOD  + (PWM_UNIT * `NOS_PWM_REGISTERS))  : bus.data_in <= T_period;
         (`PWM_ON_TIME + (PWM_UNIT * `NOS_PWM_REGISTERS))  : bus.data_in <= T_on;
         (`PWM_CONFIG  + (PWM_UNIT * `NOS_PWM_REGISTERS))  : bus.data_in <= pwm_config;
         (`PWM_STATUS  + (PWM_UNIT * `NOS_PWM_REGISTERS))  : bus.data_in <= pwm_status;
      endcase
   end else
      bus.data_in <= 32'hzzzzzzzz;
end

assign pwm_status = pwm_config;
assign pwm_enable = pwm_config[0];   // bit 0 is PWM enable bit


endmodule
