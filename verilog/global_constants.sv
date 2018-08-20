//
// global_constants_sv : System GLOBAL constants
//
`ifndef   _global_constants_sv_
`define   _global_constants_sv_

	//
	// NOS_CLOCKS : Number of ring counter clocks
	//
	`define NOS_CLOCKS 5
	
	//
	// system channels
	//
	`define NOS_ENCODER_CHANNELS   4
	`define NOS_PWM_CHANNELS       4
	`define NOS_SERVO_CHANNELS     8

	//
	// Register map
	//
   `define PWM_BASE        0
   
   `define PWM_PERIOD      `PWM_BASE + (0 * `NOS_PWM_CHANNELS)
   `define PWM_ON_TIME     `PWM_BASE + (1 * `NOS_PWM_CHANNELS)
   `define PWM_CONFIG      `PWM_BASE + (2 * `NOS_PWM_CHANNELS)
   `define PWM_STATUS      `PWM_BASE + (3 * `NOS_PWM_CHANNELS)
   
   `define ENCODER_BASE    (4 * `NOS_PWM_CHANNELS)
   
   `define COUNT_BUFFER    `ENCODER_BASE + (0 * `NOS_ENCODER_CHANNELS)	   
   `define TURN_BUFFER     `ENCODER_BASE + (1 * `NOS_ENCODER_CHANNELS)	
   `define VELOCITY_BUFFER `ENCODER_BASE + (2 * `NOS_ENCODER_CHANNELS)	
   `define ENCODER_CONFIG  `ENCODER_BASE + (3 * `NOS_ENCODER_CHANNELS)	
   `define ENCODER_STATUS  `ENCODER_BASE + (4 * `NOS_ENCODER_CHANNELS)	
   
   //
   // Number of bytes read from and written to uP
   //
   `define NOS_READ_BYTES     6
   `define NOS_WRITE_BYTES    5
   
   
`endif    // _global_constants_sv_

