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

   `define PWM_0        (`PWM_BASE + (0 * `NOS_PWM_REGISTERS))
   `define PWM_1        (`PWM_BASE + (1 * `NOS_PWM_REGISTERS))
   `define PWM_2        (`PWM_BASE + (2 * `NOS_PWM_REGISTERS))
   `define PWM_3        (`PWM_BASE + (3 * `NOS_PWM_REGISTERS))
   
   // register indexes
   `define PWM_PERIOD      0
   `define PWM_ON_TIME     1
   `define PWM_CONFIG      2
   `define PWM_STATUS      3
//
// adjustments to PWM timing values to give exact timing
//
   `define T_PERIOD_ADJUSTMENT  3
   `define T_ON_ADJUSTMENT      1
   
   `define ENCODER_BASE    (4 * `NOS_PWM_CHANNELS)
   
   `define COUNT_BUFFER    (`ENCODER_BASE + (0 * `NOS_ENCODER_CHANNELS))      
   `define TURN_BUFFER     (`ENCODER_BASE + (1 * `NOS_ENCODER_CHANNELS))
   `define VELOCITY_BUFFER (`ENCODER_BASE + (2 * `NOS_ENCODER_CHANNELS))
   `define ENCODER_CONFIG  (`ENCODER_BASE + (3 * `NOS_ENCODER_CHANNELS))
   `define ENCODER_STATUS  (`ENCODER_BASE + (4 * `NOS_ENCODER_CHANNELS))
   
   //
   // number of 32-bit values to be read from slave
   //
   `define NOS_READ_WORDS_FROM_SLAVE     2
   `define NOS_READ_BYTES_FROM_SLAVE     (4 * `NOS_READ_WORDS_FROM_SLAVE)
   //
   // Number of bytes read from and written to uP
   //
   `define NOS_READ_BYTES     6
   `define NOS_WRITE_BYTES    (`NOS_READ_WORDS_FROM_SLAVE * 4)
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
	
//	`define  MODE_PWM_DIR_CONTROL   1
//	`define  MODE_PWM_CONTROL       0
	
	enum bit {MODE_PWM_CONTROL=1'b0, MODE_PWM_DIR_CONTROL=1'b1} H_bridge_interface_types;

//   `define  MOTOR_OFF			0

	enum bit [1:0] {MOTOR_COAST=2'b00, MOTOR_FORWARD=2'b01, MOTOR_BACKWARD=2'b10, MOTOR_BRAKE=2'b11} motor_commands;	
	enum bit       {PWM_BRAKE_DWELL=1'b0, PWM_COAST_DWELL=1'b1} PWM_dwell_modes;
	enum bit       {BACKWARD=1'b0, FORWARD=1'b1} motor_directions;

`endif    // _global_constants_sv_

