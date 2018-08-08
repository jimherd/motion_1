//
// pwm_channel.sv : 
//
// Implement a PWM generation channel
//
`include  "global_constants.sv"

module pwm_channel #(parameter [`NOS_PWM_CHANNELS-1 : 0] PWM_UNIT = 0) (phase_clk, reset, reg_address, reg_in, reg_out, pwm_out);
	input  logic [`NOS_CLOCKS-1:0] phase_clk;
	input  logic reset;
	input  logic [7:0]  reg_address;
	input  logic [31:0] reg_in;
   output logic [31:0] reg_out;
	output  pwm_out;
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
logic pwm_enable, bus_data_avail, ack, RW;
logic data_avail, read_word, write_word;

assign pwm_enable = pwm_config[0];   // bit 0 is PWM enable bit

bus_FSM   bus_FSM_sys(
	.clk(phase_clk[0]),
	.reset(reset),
   .ack(ack),
   .bus_data_avail(bus_data_avail),
   .RW(RW),
   .data_avail(data_avail), 
   .read_word(read_word), 
   .write_word(write_word)
	);
   
pwm_FSM   pwm_FSM_sys(
   .clk(phase_clk[0]),
   .reset(reset),
   .pwm_enable(pwm_enable),
   .T_on_zero(T_on_zero), 
   .T_period_zero(T_period_zero),
   .dec_T_on(dec_T_on), 
   .dec_T_period(dec_T_period), 
   .reload_times(reload_times),
   .pwm_out(pwm_out) 
   );

//
// Data subsystem to calculate pulse edges
//
always_ff @(posedge phase_clk[0] or negedge reset) begin
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
 
always_ff @(posedge phase_clk[0] or negedge reset) begin
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
always_ff @(posedge phase_clk[0] or negedge reset) begin
   if (!reset) begin
      T_period   <= 0;
      T_on       <= 0;
      pwm_config <= 0;
      pwm_status <= 0;
   end else begin
      if (read_word) begin
         if (reg_address == (`PWM_PERIOD + PWM_UNIT)) begin
            T_period <= reg_in;
         end else 
            if (reg_address == (`PWM_ON_TIME + PWM_UNIT)) begin
               T_on <= reg_in;
            end else
               if (reg_address == (`PWM_CONFIG + PWM_UNIT)) begin
                  pwm_config <= reg_in;
               end
      end 
         
   end
end

//
// put data onto bus
//
always_latch begin
   if(write_word === 1'b1) begin
      reg_out <= 32'hzzzzzzzz;
      case (reg_address)
         (`PWM_PERIOD  + PWM_UNIT)  : reg_out <= T_period;
         (`PWM_ON_TIME + PWM_UNIT)  : reg_out <= T_on;
         (`PWM_CONFIG  + PWM_UNIT)  : reg_out <= pwm_config;
         (`PWM_STATUS  + PWM_UNIT)  : reg_out <= pwm_status;
         default                    : reg_out <= 32'hzzzzzzzz;
      endcase
   end
end

//assign register_out  =  (register_no == (`PWM_PERIOD + PWM_UNIT)) ? T_period : 32'hzzzzzzzz;
//assign register_out  =  (register_no == (`PWM_ON_TIME + PWM_UNIT)) ? T_on : 32'hzzzzzzzz;


endmodule
