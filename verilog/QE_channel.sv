//
// QE_channel_sv : 
//
// Implement a single encoder channel
//
`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;


module QE_channel #(QE_UNIT = 0) ( 
									input  logic clk, reset,
									IO_bus  bus,
									input  logic async_ext_QE_A, async_ext_QE_B, async_ext_QE_I
									);

//
// subsystem registers accessible to external system
//   
uint32_t  QE_count_buffer;
uint32_t  QE_turns_buffer;
uint32_t  QE_speed_buffer;
uint32_t  QE_sim_phase_time;
uint32_t  QE_counts_per_rev;
uint32_t  QE_config;
uint32_t  QE_status;
//


// internal registers
//   
uint32_t  turns, count, speed;

// local signals
//
logic direction, pulse, index;
logic QE_A, QE_B, QE_I;

logic [31:0] data_in_reg;

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
		QE_sim_phase_time		<= 0;
		QE_counts_per_rev		<= 0;
		QE_config				<= 0;
   end else begin
      if ((read_word_from_BUS == 1'b1) && (bus.RW == 1)) begin
         if (bus.reg_address == (`QE_SIM_PHASE_TIME + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))) begin
            QE_sim_phase_time <= bus.data_out;
         end else 
            if (bus.reg_address == (`QE_COUNTS_PER_REV + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))) begin
               QE_counts_per_rev <= bus.data_out;
            end else
               if (bus.reg_address == (`QE_CONFIG + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))) begin
                  QE_config <= bus.data_out;
               end
         end
   end
end

logic  QE_source, QE_sim_enable;

assign QE_source     = QE_config[`QE_SOURCE];
assign QE_sim_enable = QE_config[`QE_SIM_ENABLE];

//
// put data onto bus
//
always_ff @(posedge clk or negedge reset) begin
   if (!reset) begin
      data_in_reg <= 'z;
   end  else begin
      if(write_data_word_to_BUS == 1'b1) begin
         case (bus.reg_address)  
            (`QE_COUNT_BUFFER  	+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: data_in_reg <= QE_count_buffer;
            (`QE_TURN_BUFFER 		+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: data_in_reg <= QE_turns_buffer;
            (`QE_SPEED_BUFFER    + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: data_in_reg <= QE_speed_buffer;
            (`QE_SIM_PHASE_TIME  + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: data_in_reg <= QE_sim_phase_time;
            (`QE_COUNTS_PER_REV 	+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: data_in_reg <= QE_counts_per_rev;
            (`QE_CONFIG  			+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: data_in_reg <= QE_config;
            (`QE_STATUS  			+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: data_in_reg <= QE_status;				
				
         endcase
      end else begin
         if(write_status_word_to_BUS == 1'b1) begin
            data_in_reg <= QE_status;
         end else
            data_in_reg <= 'z;
      end
   end
end

//
// assess if registers numbers refer to this subsystem
//

always_comb begin
      subsystem_enable = 0;
      case (bus.reg_address)  
         (`QE_COUNT_BUFFER  	+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: subsystem_enable = 1;
         (`QE_TURN_BUFFER 		+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS))) 	: subsystem_enable = 1;
         (`QE_SPEED_BUFFER    + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: subsystem_enable = 1;
         (`QE_SIM_PHASE_TIME  + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS))) 	: subsystem_enable = 1;
         (`QE_COUNTS_PER_REV 	+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))	: subsystem_enable = 1;
         (`QE_CONFIG  			+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: subsystem_enable = 1;
         (`QE_STATUS  			+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: subsystem_enable = 1;			
         default                                                         		: subsystem_enable = 0; 
      endcase
end


//
// define 32-bit value to be written to bus
//
assign bus.data_in = (subsystem_enable) ? data_in_reg : 'z;

		
/////////////////////////////////////////////////
//
// Subsystem to organise generation of simulated quadrature encoder signals
	
logic inc_counters, clear_phase_counter, clear_pulse_counter, load_phase_timer , decrement_phase_timer;
logic  phase_cnt_4, index_cnt, timer_cnt_0;
	
QE_generator_FSM  QE_generator_FSM_sys( 
			.clk(clk),
			.reset(reset),
			.QE_sim_enable(QE_sim_enable),
			.phase_cnt_4(phase_cnt_4), 
			.index_cnt(index_cnt), 
			.timer_cnt_0(timer_cnt_0),
			.inc_counters(inc_counters), 
			.clear_phase_counter(clear_phase_counter), 
			.clear_pulse_counter(clear_pulse_counter), 
			.load_phase_timer(load_phase_timer), 
			.decrement_phase_timer(decrement_phase_timer)
      );
//

logic int_QE_A, int_QE_B, int_QE_I;
logic ext_QE_A, ext_QE_B, ext_QE_I;

logic [2:0] QE_sim_phase_counter;
uint32_t    QE_sim_pulse_counter;
uint32_t    QE_sim_phase_timer;

always_ff @(posedge clk or negedge reset)
begin
   if (!reset) begin
      QE_sim_phase_counter <= 0;
		QE_sim_pulse_counter <= 0;
		QE_sim_phase_timer   <= 10;
   end  else begin
		if (inc_counters == 1'b1) begin
			QE_sim_phase_counter <= QE_sim_phase_counter + 1'b1;
			QE_sim_pulse_counter <= QE_sim_pulse_counter + 1;
		end else begin
			if (clear_phase_counter == 1'b1) begin
				QE_sim_phase_counter <= 0;
				int_QE_I <= 1;
			end else begin
				if (clear_pulse_counter == 1'b1) begin
					QE_sim_pulse_counter <= 0;
					int_QE_I <= 1;
				end else begin
					if (load_phase_timer == 1'b1) begin
						QE_sim_phase_timer <= QE_sim_phase_time;
					end else begin
						if (decrement_phase_timer == 1'b1) begin
							QE_sim_phase_timer <= QE_sim_phase_timer - 1;
						end
					end
				end
			end
		end
	end	
end

assign phase_cnt_4 = (QE_sim_phase_counter == 4) ? 1'b1 : 1'b0;
assign index_cnt   = (QE_sim_pulse_counter == QE_counts_per_rev) ? 1'b1 : 1'b0;
assign timer_cnt_0 = (QE_sim_phase_timer == 0) ? 1'b1 : 1'b0;



always_comb
begin
	int_QE_A = 1'b0;
	int_QE_B = 1'b0;
	if (QE_config[2] == QE_CW) begin
		case (QE_sim_phase_counter)
			2'b00 : 	begin
							int_QE_A = 1'b0;
							int_QE_B = 1'b0;
						end
			2'b01 : 	begin
							int_QE_A = 1'b1;
							int_QE_B = 1'b0;
						end
			2'b10 : 	begin
							int_QE_A = 1'b1;
							int_QE_B = 1'b1;
						end
			2'b11 : 	begin
							int_QE_A = 1'b0;
							int_QE_B = 1'b1;
						end
			default 	begin
							int_QE_A = 1'b0;
							int_QE_B = 1'b0;
						end
		endcase
	end else begin
		case (QE_sim_phase_counter)
			2'b00 : 	begin
							int_QE_A = 1'b0;
							int_QE_B = 1'b0;
						end
			2'b01 : 	begin
							int_QE_A = 1'b0;
							int_QE_B = 1'b1;
						end
			2'b10 : 	begin
							int_QE_A = 1'b1;
							int_QE_B = 1'b1;
						end
			2'b11 : 	begin
							int_QE_A = 1'b1;
							int_QE_B = 1'b0;
						end
			default 	begin
							int_QE_A = 1'b0;
							int_QE_B = 1'b0;
						end
		endcase
	end	
end


always_comb
begin
	QE_A = 1'b0;
	QE_B = 1'b0;
	QE_I = 1'b0;
	if (QE_source == QE_INTERNAL) begin
		QE_A = int_QE_A;
		QE_B = int_QE_B;
		QE_I = int_QE_I;
	end else begin
		QE_A = ext_QE_A;
		QE_B = ext_QE_B;
		QE_I = ext_QE_I;	
	end
end

/////////////////////////////////////////////////
//
// synchronise external quadrature signals

synchronizer sync_QE_A(
                  .clk(clk),
                  .reset(reset),
                  .async_in(async_ext_QE_A),
                  .sync_out(ext_QE_A)
                  );
						
synchronizer sync_QE_B(
                  .clk(clk),
                  .reset(reset),
                  .async_in(async_ext_QE_B),
                  .sync_out(ext_QE_B)
                  );
						
synchronizer sync_QE_I(
                  .clk(clk),
                  .reset(reset),
                  .async_in(async_ext_QE_I),
                  .sync_out(ext_QE_I)
                  );

/////////////////////////////////////////////////
//
// decode quadrature signals

quadrature_enc QE(
		.clk(clk), 
		.reset(reset), 
		.quadA_in(QE_A), 
		.quadB_in(QE_B), 
		.quadI_in(QE_I),
		.count_pulse(pulse),
		.direction(direction), 
		.index(index)
		);
		
/////////////////////////////////////////////////
//
// encoder pulse counter (360 counts per revolution)
//
// Notes :
//   1. If motor has stopped during a quad_A pulses then it could be 
//    infinitely long.
//    Therefore clamp the velocity value to a very low speed. Example below
//    is a speed of 1mm/sec for a 70mm diameter wheel with 10MHz clock.
//    If motor has stopped outwith a Quad_A pulse then the velocity will read
//    as zero.
//    uP software can detect each of these cases.
//   2. The diameter of the wheel could be a settable constant.
//

logic clear_all, increment_speed_counter, load_speed_buffer, clear_speed_counter;
logic  max_count;

QE_speed_measure_FSM  QE_speed_measure_FSM_sys( 
               .clk(clk), 
					.reset(reset), 
               .QE_A_sig(QE_A), 
					.max_count(max_count),
               .clear_all(clear_all), 
					.increment_speed_counter(increment_speed_counter), 
					.load_speed_buffer(load_speed_buffer), 
					.clear_speed_counter(clear_speed_counter)
               );
					
always_ff @(posedge clk or negedge reset)
begin
   if (!reset) begin
      speed 			<= 0;
		QE_speed_buffer	<= 0;
   end  else begin
		if (increment_speed_counter == 1'b1) begin
			speed <= speed + 1;
		end else begin
			if (load_speed_buffer == 1'b1) begin
				QE_speed_buffer <= speed;
			end else begin
				if (clear_speed_counter == 1'b1) begin
					speed <= 0;
				end else begin
					if (clear_all == 1'b1) begin
						speed					<= 0;
						QE_speed_buffer	<= 0;
					end
				end
			end
		end
	end
end

assign max_count = (speed > `MAX_SPEED_COUNT) ? 1'b1 : 1'b0;
	
always_ff @(posedge pulse or negedge reset)
begin
   if (!reset) begin
      count <= 0;
   end  else begin
      if (direction)
         count<=count + 1; 
      else
         count<=count - 1;
   end
end

//
// Count index pulses (1 per revolution)
//

always_ff @(posedge index or negedge reset)   
begin   
   if (!reset) begin
      turns <= 0;
   end else begin
      if(direction)
         turns<=turns + 1; 
      else
         turns<=turns - 1;
   end
end

endmodule
