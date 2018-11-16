//
// motion_channel_sv : 
//
// Implement a single encoder channel
//
`include  "global_constants.sv"
`include  "interfaces.sv"


module motion_channel #(QE_UNIT = 0) ( 
												input  logic clk, reset,
												IO_bus  bus,
												input  logic quad_A, quad_B, quad_I
												);

//
// subsystem registers accessible to external system
//   
logic [31:0]  QE_count_buffer;
logic [31:0]  QE_turns_buffer;
logic [31:0]  QE_velocity_buffer;
logic [31:0]  QE_config;
//
logic data_avail, read_word_from_BUS, write_data_word_to_BUS, write_status_word_to_BUS;
logic subsystem_enable;

//
// storage
//   
logic [31:0]  turns;
int unsigned count, velocity;
logic direction, pulse, index;

//
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
quadrature_enc QE(
		.clk(clk), 
		.reset(reset), 
		.quadA_in(quad_A), 
		.quadB_in(quad_B), 
		.quadI_in(quad_I),
		.count_pulse(pulse),
		.direction(direction), 
		.index(index)
		);

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
// Measure velocity
//
always_ff @(posedge clk or negedge reset)
begin
   if (!reset) begin
      velocity <= 0;
   end else begin
      if(velocity < 23387412)
         velocity <= velocity + 1; 
      else
         velocity <= velocity - 1;
   end
end

//
// save current copy of velocity.
// Be aware of the difference clock/anticlockwise movement
//
always_ff @(posedge quad_B)   
begin   
   if (quad_A == 1'b1)
      QE_velocity_buffer   <= velocity;
      velocity   				<= 0;
end

always_ff @(negedge quad_B)   
begin   
   if (quad_A == 1'b0)
      QE_velocity_buffer   <= velocity;
      velocity   				<= 0;
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
