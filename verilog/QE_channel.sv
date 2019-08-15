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
// QE_channel_sv : Implement a single quadrature encoder channel
// =============
// 

`include  "global_constants.sv"
`include  "interfaces.sv"

import types::*;

module QE_channel #(QE_UNIT = 0) ( 
									input  logic clk, reset,
									IO_bus  bus,						// internal 32-bit bus
									input  logic async_ext_QE_A, 	// external encoder A input
									input  logic async_ext_QE_B, 	// external encoder B input
									input  logic async_ext_QE_I	// external encoder I input
									);

// 
// definition of first and last registers for this unit

`define	FIRST_QE_REGISTER		(`QE_COUNT_BUFFER + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))
`define	LAST_QE_REGISTER		((`QE_STATUS +       (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS))) - 1)							
									//
// subsystem registers accessible to external system
   
uint32_t  QE_count_buffer;
uint32_t  QE_turns_buffer;
uint32_t  QE_speed_buffer;
uint32_t  QE_sim_phase_time;
uint32_t  QE_counts_per_rev;
uint32_t  QE_config;
uint32_t  QE_status;

//
// internal registers
   
uint32_t  QE_temp_speed_counter;

//
// local signals

logic QE_direction, QE_pulse, index;
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
// Decode register address to check if this subsystem is addressed

always_comb begin
	if ((bus.reg_address >= `FIRST_QE_REGISTER) && (bus.reg_address <= `LAST_QE_REGISTER)) begin
		subsystem_enable = 1;
	end else begin
		subsystem_enable = 0;
	end
end

////always_comb begin
////      subsystem_enable = 1;
//      case (bus.reg_address)  
//         (`QE_COUNT_BUFFER  	+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: subsystem_enable = 1;   // 1
//         (`QE_TURN_BUFFER 		+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS))) 	: subsystem_enable = 1;
//         (`QE_SPEED_BUFFER    + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: subsystem_enable = 1;
//         (`QE_SIM_PHASE_TIME  + (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS))) 	: subsystem_enable = 1;
//         (`QE_COUNTS_PER_REV 	+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))	: subsystem_enable = 1;
//         (`QE_CONFIG  			+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: subsystem_enable = 1;
//         (`QE_STATUS  			+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)))  	: subsystem_enable = 1;			
//         default                                                         		: subsystem_enable = 0;  // 0
//      endcase
//end

//
// get register data from internal 32-bit bus

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

//
// Extract data from configuration register

logic  QE_source, QE_sim_enable, QE_sim_direction, QE_flip_AB;

assign QE_source        = QE_config[`QE_SOURCE];
assign QE_sim_enable    = QE_config[`QE_SIM_ENABLE];
assign QE_sim_direction = QE_config[`QE_SIM_DIRECTION];
assign QE_flip_AB       = QE_config[`QE_FLIP_AB];

//
// put register data onto internal 32-bit bus

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
// define 32-bit value to be written to bus

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

//
// collect status data into status register

assign QE_status = {QE_I, QE_B, QE_A ,ext_QE_I, ext_QE_B, ext_QE_A};


always_ff @(posedge clk or negedge reset)
begin
   if (!reset) begin
      QE_sim_phase_counter <= 0;
		QE_sim_pulse_counter <= 0;
		QE_sim_phase_timer   <= (`QE_COUNT_BUFFER  	+ (`QE_BASE + (QE_UNIT * `NOS_QE_REGISTERS)));
   end  else begin
		if (inc_counters == 1'b1) begin
			QE_sim_phase_counter <= QE_sim_phase_counter + 1'b1;
			QE_sim_pulse_counter <= QE_sim_pulse_counter + 1;
			int_QE_I <= 0;
		end else begin
			if (clear_phase_counter == 1'b1) begin
				QE_sim_phase_counter <= 0;
				int_QE_I <= 0;
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
	if (QE_sim_direction == QE_CW) begin
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

logic  QE_A_tmp, QE_B_tmp, QE_I_tmp;

always_comb
begin
	QE_A_tmp = 1'b0;
	QE_B_tmp = 1'b0;
	QE_I     = 1'b0;
	if (QE_source == QE_INTERNAL) begin
		QE_A_tmp = int_QE_A;
		QE_B_tmp = int_QE_B;
		QE_I     = int_QE_I;
	end else begin
		QE_A_tmp = ext_QE_A;
		QE_B_tmp = ext_QE_B;
		QE_I     = ext_QE_I;	
	end
end

assign QE_A = (QE_flip_AB == NO) ? QE_A_tmp : QE_B_tmp;
assign QE_B = (QE_flip_AB == NO) ? QE_B_tmp : QE_A_tmp;


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

quadrature_decoder QE(
		.clk(clk), 
		.reset(reset), 
		.quadA_in(QE_A), 
		.quadB_in(QE_B), 
		.quadI_in(QE_I),
		.count_pulse(QE_pulse),
		.direction(QE_direction), 
		.index(index)
		);
		
/////////////////////////////////////////////////
//
// encoder pulse counter 
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

logic clear_all, inc_temp_speed_counter, dec_sample_count, load_speed_buffer, do_average;
logic speed_measure_enable, count_overflow, speed_filter_enable, samples_complete;

byte_t sample_counter;
					
QE_speed_measure_FSM  QE_speed_measure_FSM_sys( 
               .clk(clk), 
					.reset(reset), 
					.speed_measure_enable(speed_measure_enable),
               .QE_A(QE_A),
					.count_overflow(count_overflow),
					.speed_filter_enable(speed_filter_enable),
					.samples_complete(samples_complete),
					
               .clear_all(clear_all),
					.inc_temp_speed_counter(inc_temp_speed_counter),
					.dec_sample_count(dec_sample_count),
					.do_average(do_average),
					.load_speed_buffer(load_speed_buffer)
					);

assign speed_measure_enable = QE_config[`QE_SPEED_MEASURE_ENABLE];					
assign count_overflow       = (QE_speed_buffer > `MAX_SPEED_COUNT) ? 1'b1 : 1'b0;
assign speed_filter_enable  = QE_config[`QE_SPEED_FILTER_ENABLE];
assign samples_complete     = (sample_counter == 0) ? 1'b1 : 1'b0;

					
always_ff @(posedge clk or negedge reset)
begin
   if (!reset) begin
      QE_speed_buffer 	<= 0;
		QE_speed_buffer	<= 0;
		sample_counter    <= 0;
   end  else begin
		if (speed_measure_enable == 1'b1) begin
			if (inc_temp_speed_counter == 1'b1) begin
				QE_temp_speed_counter <= QE_temp_speed_counter + 1;
			end else begin
				if (dec_sample_count == 1'b1) begin
					sample_counter = sample_counter - 1'b1;
				end else begin
					if (load_speed_buffer == 1'b1) begin
						QE_speed_buffer <= QE_temp_speed_counter;
					end else begin
						if (clear_all == 1'b1) begin
							QE_speed_buffer	<= 0;
							if (speed_filter_enable == 1'b1) begin	   
								case (QE_config[(`QE_FILTER_SIZE + 2):`QE_FILTER_SIZE])
									0       : sample_counter <=  1;
									1       : sample_counter <=  2;
									2       : sample_counter <=  4;
									3       : sample_counter <=  8;
									4       : sample_counter <= 16;
									default : sample_counter <=  1;
								endcase;
							end
						end else begin
							if (do_average == 1'b1) begin
								case (QE_config[(`QE_FILTER_SIZE + 2):`QE_FILTER_SIZE])
									0       : QE_temp_speed_counter <= QE_temp_speed_counter;
									1       : QE_temp_speed_counter <= QE_temp_speed_counter << 1;
									2       : QE_temp_speed_counter <= QE_temp_speed_counter << 2;
									3       : QE_temp_speed_counter <= QE_temp_speed_counter << 3;
									4       : QE_temp_speed_counter <= QE_temp_speed_counter << 4;
									default : QE_temp_speed_counter <= QE_temp_speed_counter;
								endcase;
							end
						end
					end
				end
			end
		end
	end
end

//
// Now count quadrature pulses
//
// Uses state machine to sync count to clock

logic inc_QE_count_buffer, dec_QE_count_buffer;
		
count_FSM QE_pulse_count_FSM_sys(
		.clk(clk),
		.reset(reset),
	// inputs
      .count_sig(QE_pulse),
		.direction(QE_direction),
	// outputs
      .inc_counter(inc_QE_count_buffer),
		.dec_counter(dec_QE_count_buffer)
);	

	
always_ff @(posedge clk or negedge reset)
begin
   if (!reset) begin
      QE_count_buffer <= 0;
   end  else begin
      if (inc_QE_count_buffer) begin
         QE_count_buffer<=QE_count_buffer + 1; 
      end else begin
			if (dec_QE_count_buffer) begin
				QE_count_buffer<=QE_count_buffer - 1;
			end
		end
   end
end

//
// Now count index quadrature pulses (1 per revolution)
//
// Uses state machine to sync count to clock

logic inc_QE_turns_buffer, dec_QE_turns_buffer;
		
count_FSM QE_index_count_FSM_sys(
		.clk(clk),
		.reset(reset),
	// inputs
      .count_sig(index),
		.direction(QE_direction),
	// outputs
      .inc_counter(inc_QE_turns_buffer),
		.dec_counter(dec_QE_turns_buffer)
);	

always_ff @(posedge clk or negedge reset)   
begin   
   if (!reset) begin
      QE_turns_buffer <= 0;
   end else begin
      if(inc_QE_turns_buffer) begin
         QE_turns_buffer <= QE_turns_buffer + 1; 
      end else begin
			if(dec_QE_turns_buffer) begin
				QE_turns_buffer <= QE_turns_buffer - 1;
			end
		end
   end
end

endmodule
