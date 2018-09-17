//
// global_constants_sv : System GLOBAL constants
//
`ifndef   _global_constants_sv_
`define   _global_constants_sv_

	//
	// system channels
	//
	`define NOS_ENCODER_CHANNELS   4
	`define NOS_PWM_CHANNELS       2
	`define NOS_SERVO_CHANNELS     8

	//
	// Register map
	//
   `define GLOBAL_CONFIG   0
   
   `define PWM_BASE            1
   `define NOS_PWM_REGISTERS   4
   
   `define PWM_PERIOD      0
   `define PWM_ON_TIME     1
   `define PWM_CONFIG      2
   `define PWM_STATUS      3
   
   `define ENCODER_BASE    (4 * `NOS_PWM_CHANNELS)
   
   `define COUNT_BUFFER    (`ENCODER_BASE + (0 * `NOS_ENCODER_CHANNELS))	   
   `define TURN_BUFFER     (`ENCODER_BASE + (1 * `NOS_ENCODER_CHANNELS))
   `define VELOCITY_BUFFER (`ENCODER_BASE + (2 * `NOS_ENCODER_CHANNELS))
   `define ENCODER_CONFIG  (`ENCODER_BASE + (3 * `NOS_ENCODER_CHANNELS))
   `define ENCODER_STATUS  (`ENCODER_BASE + (4 * `NOS_ENCODER_CHANNELS))
   
   //
   // number of 32-bit values to be read from slave
   //
   `define NOS_READ_WORDS     2
   //
   // Number of bytes read from and written to uP
   //
   `define NOS_READ_BYTES     6
   `define NOS_WRITE_BYTES    (`NOS_READ_WORDS * 4)

   //
   // named bytes in byte packet from uP
   //
   `define CMD_REG         0
   `define REGISTER_NUMBER 1
   `define UP_STATUS_REG   4
   //
   `define RD_CMD  0
   `define WR_CMD  1

   
   //
   // bit definitions
   //
   `define BIT0  0
   `define BIT1  1
   `define BIT2  2
   `define BIT3  3
   `define BIT4  4
   `define BIT5  5
   `define BIT6  6
   `define BIT7  7
   
   `define RESET_CMD_DONE 8'hFF
  
   
   
`endif    // _global_constants_sv_

