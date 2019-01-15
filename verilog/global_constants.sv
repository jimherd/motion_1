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
// global_constants.sv : System GLOBAL constants
// ===================
//

`ifndef   _global_constants_sv_
`define   _global_constants_sv_

//
// System compilation directives
// =============================
//
// Uncomment if you want to create PWM subsystems by a "generate" construct.
// (As of Nov 2018 this feature does not work)
//
// `define USE_PWM_GENERATE

//
// System constants
// ================
//

///////////////////////////////////////////////////
//
// number of subsystems 

	`define NOS_PWM_CHANNELS      	2
	`define NOS_QE_CHANNELS  			2
   `define NOS_RC_SERVO_CHANNELS    8

///////////////////////////////////////////////////
//
// Register address map
	
	`define BASE_REGISTER_ADDRESS   	1
	`define PWM_BASE            	   `BASE_REGISTER_ADDRESS
	`define NOS_PWM_REGISTERS   	   (`PWM_STATUS + 1)
	`define QE_BASE            		((`NOS_PWM_REGISTERS * `NOS_PWM_CHANNELS) + `PWM_BASE)
   `define NOS_QE_REGISTERS   		(`QE_STATUS + 1)
	`define RC_BASE                  ((`NOS_QE_REGISTERS * `NOS_QE_CHANNELS) + `QE_BASE)
	`define NOS_RC_REGISTERS         (3 + `NOS_RC_SERVO_CHANNELS)
	`define RC_ON_TIME_BASE          (`RC_BASE + 3)
	`define NXT_BASE                 (3 + `NOS_RC_SERVO_CHANNELS) + RC_BASE)

///////////////////////////////////////////////////
//
// PWM subsystem
//	
// used in testbench files

   `define PWM_0        (`PWM_BASE + (0 * `NOS_PWM_REGISTERS))
   `define PWM_1        (`PWM_BASE + (1 * `NOS_PWM_REGISTERS))
   `define PWM_2        (`PWM_BASE + (2 * `NOS_PWM_REGISTERS))
   `define PWM_3        (`PWM_BASE + (3 * `NOS_PWM_REGISTERS))
//   
// register indexes - status should always be last

   `define PWM_PERIOD      0
   `define PWM_ON_TIME     1
   `define PWM_CONFIG      2
   `define PWM_STATUS      3
//
// adjustments to PWM timing values to give exact timing

   `define T_PERIOD_ADJUSTMENT  3
   `define T_ON_ADJUSTMENT      1

///////////////////////////////////////////////////
//
// Quadrature encoder subsystem

   `define QE_COUNT_BUFFER    	0   
   `define QE_TURN_BUFFER     	1
   `define QE_SPEED_BUFFER 	   2
	`define QE_SIM_PHASE_TIME		3
	`define QE_COUNTS_PER_REV		4
	`define QE_CONFIG  				5
   `define QE_STATUS  				6

//
// used in testbench files

   `define QE_0	(`QE_BASE + (0 * `NOS_QE_CHANNELS))      
   `define QE_1	(`QE_BASE + (1 * `NOS_QE_CHANNELS))
   `define QE_2 	(`QE_BASE + (2 * `NOS_QE_CHANNELS))
   `define QE_3 	(`QE_BASE + (3 * `NOS_QE_CHANNELS))

///////////////////////////////////////////////////
//
// RC Servo subsystem

   `define RC_SERVO_PERIOD    	0   
   `define RC_SERVO_CONFIG     	1
	`define RC_SERVO_STATUS     	2
	`define RC_SERVO_ON_TIME      3

	//
	// definition of configuration register bits
	
	`define RC_SERVO_CHANNEL_0_ENABLE     0		// 1 bit 
	`define RC_SERVO_CHANNEL_1_ENABLE     1		// 1 bit 
	// repeated for set of channels
	//
	
	`define RC_SERVO_GLOBAL_ENABLE       31		// 1 bit 
	
//
// used in testbench files

   `define RC_0	(`RC_BASE)      

///////////////////////////////////////////////////
//
// Interface constants

   //
   // number of 32-bit values to be read from slave
  
   `define NOS_READ_WORDS_FROM_SLAVE     2
   `define NOS_READ_BYTES_FROM_SLAVE     (4 * `NOS_READ_WORDS_FROM_SLAVE)
   //
   // Number of bytes read from and written to uP
  
   `define NOS_READ_BYTES     6
   `define NOS_WRITE_BYTES    (`NOS_READ_WORDS_FROM_SLAVE * 4)
   //
   // named bytes in byte packet from uP
   
   `define CMD_REG         0
   `define REGISTER_NUMBER 1
   `define UP_STATUS_REG   4
   //
   `define RD_CMD  0
   `define WR_CMD  1

   //
   // bit definitions
   
   `define BIT0  0
   `define BIT1  1
   `define BIT2  2
   `define BIT3  3
   `define BIT4  4
   `define BIT5  5
   `define BIT6  6
   `define BIT7  7
   
   `define RESET_CMD_DONE 8'hFF

	
	enum bit {MODE_PWM_CONTROL=1'b0, MODE_PWM_DIR_CONTROL=1'b1} H_bridge_interface_types;


	enum bit [1:0] {MOTOR_COAST=2'b00, MOTOR_FORWARD=2'b01, MOTOR_BACKWARD=2'b10, MOTOR_BRAKE=2'b11} motor_commands;	
	enum bit       {PWM_BRAKE_DWELL=1'b0, PWM_COAST_DWELL=1'b1} PWM_dwell_modes;
	enum bit       {BACKWARD=1'b0, FORWARD=1'b1} motor_directions;
	
//
// bit definitions for PWM/H-bridge configuaration register

	`define	PWM_ENABLE			 	 0
	//
	`define	H_BRIDGE_INT_ENABLE	16		// 1 bit
	`define	H_BRIDGE_EXT_ENABLE	17		// 1 bit
	`define	H_BRIDGE_COMMAND		18		// 3 bits
	`define	H_BRIDGE_MODE  		21		// 2 bits
	`define	H_BRIDGE_SWAP			22		// 1 bit
	`define	H_BRIDGE_DWELL_MODE	23		// 1 bit
	`define	H_BRIDGE_INVERT_PINS	24		// 2 bits

//
// bit definitions for Quadrature encoder configuaration register

	`define  QE_SOURCE		       1		// 1 bit : external or internal signals
	`define  QE_SIM_ENABLE         2    // 1 bit : enable quadrature encoder simulator
	`define  QE_SIM_DIRECTION      3    // 1 bit : flip simulated A/B signals
	`define  QE_FLIP_AB            4    // 1 bit : flip AB signals to quadrature decoder
	
	`define  QE_SPEED_MEASURE_ENABLE		16	// 1 bit : 
	`define  QE_SPEED_FILTER_ENABLE		17 // 1 bit : enables binary averaging filter
	`define  QE_FILTER_SIZE					18 // 3 bits : sample size == value to the power 2.
	
	enum bit {QE_INTERNAL, QE_EXTERNAL} QE_encoder_source;
	enum bit {QE_CW, QE_CCW} rotational_direction;
	enum bit {NO, YES} condition;
	
	`define MAX_SPEED_COUNT 2000000
	
	enum bit {FALSE, TRUE} bool_states;

`endif    // _global_constants_sv_

