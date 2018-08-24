//
// motion_channel_sv : 
//
// Implement a single encoder channel
//
`include  "global_constants.sv"


module motion_channel #(MOTION_UNIT = 0) ( 
                                          input  logic clk, reset,
                                          IO_bus.slave  bus,
                                          input  logic quad_A, quad_B, quad_I
                                          );


//
// storage
//	
logic [31:0]  count_buffer, turns, turns_buffer, velocity_buffer;
int unsigned count[0:3], velocity[`NOS_ENCODER_CHANNELS];
logic direction, pulse, index;

//
// requied subunits
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
//	1. If motor has stopped during a quad_A pulses then it could be 
//    infinitely long.
//    Therefore clamp the velocity value to a very low speed. Example below
//    is a speed of 1mm/sec for a 70mm diameter wheel with 10MHz clock.
//    If motor has stopped outwith a Quad_A pulse then the velocity will read
//    as zero.
//    uP software can detect each of these cases.
//	2. The diameter of the wheel could be a settable constant.
//
always_ff @(posedge pulse or negedge reset)
begin
	if (!reset) begin
		count[MOTION_UNIT] <= 0;
	end  else begin
		if (direction)
			count[MOTION_UNIT]<=count[MOTION_UNIT] + 1; 
		else
			count[MOTION_UNIT]<=count[MOTION_UNIT] - 1;
	end
end

//
// Measure velocity
//
always_ff @(posedge clk or negedge reset)
begin
	if (!reset) begin
		velocity[MOTION_UNIT] <= 0;
	end else begin
		if(velocity[MOTION_UNIT] < 23387412)
			velocity[MOTION_UNIT] <= velocity[MOTION_UNIT] + 1; 
		else
			velocity[MOTION_UNIT] <= velocity[MOTION_UNIT] - 1;
	end
end

//
// save current copy of velocity.
// Be aware of the difference clock/anticlockwise movement
//
always_ff @(posedge quad_B)	
begin	
	if (quad_A == 1'b1)
		velocity_buffer 		<= velocity[MOTION_UNIT];
		velocity[MOTION_UNIT]   <= 0;
end

always_ff @(negedge quad_B)	
begin	
	if (quad_A == 1'b0)
		velocity_buffer 		<= velocity[MOTION_UNIT];
		velocity[MOTION_UNIT]   <= 0;
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
