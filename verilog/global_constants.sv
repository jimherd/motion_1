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
// There are NO code or variable definitions in this file

`ifndef   _global_constants_sv_
`define   _global_constants_sv_

//
// System versions

`define	MAJOR_VERSION       0
`define	MINOR_VERSION       1

//
// System compilation directives
// =============================
//
// Uncomment if you want to create PWM subsystems by a "generate" construct.

`define USE_PWM_GENERATE

//
// Uncomment if you want to create QE subsystems by a "generate" construct.

`define USE_QE_GENERATE

 //
 // Uncomment if you want to return a 32-bit status word for each command
 // transaction

 //`define INCLUDE_32_BIT_STATUS_RETURN
 
//
// uncomment to skip disabling of PWM channel when pulse width is changed.
// Testing required as may cause race condition

`define  ENABLE_PWM_DISABLE_WHEN_WIDTH_CHANGED

//
// System constants
// ================
//

///////////////////////////////////////////////////
//
// number of subsystems 


    `define NOS_PWM_CHANNELS            2
    `define NOS_QE_CHANNELS             2
    `define NOS_RC_SERVO_CHANNELS       8
    
///////////////////////////////////////////////////
//
// Registers in each unit type

    `define NOS_SYS_INFO_REGISTERS      1
    `define NOS_PWM_REGISTERS           4
    `define NOS_QE_REGISTERS            7
    `define NOS_RC_REGISTERS            (3 + `NOS_RC_SERVO_CHANNELS)


///////////////////////////////////////////////////
//
// Register address map
    
    `define REGISTER_BASE               0
    `define PWM_BASE                   `REGISTER_BASE + `NOS_SYS_INFO_REGISTERS
    `define QE_BASE                     ((`NOS_PWM_REGISTERS * `NOS_PWM_CHANNELS) + `PWM_BASE)
    `define RC_BASE                     ((`NOS_QE_REGISTERS * `NOS_QE_CHANNELS) + `QE_BASE)
    `define RC_ON_TIME_BASE             (`RC_BASE + 3)
    
    `define NXT_BASE                    ((3 + `NOS_RC_SERVO_CHANNELS) + `RC_BASE)
    
    `define FIRST_ILLEGAL_REGISTER      `NXT_BASE
    `define LAST_REGISTER               8'hFF

///////////////////////////////////////////////////
//
// System information subsystem

    `define SYS_INFO_0        `REGISTER_BASE   // Read-only register
    
    `define SYS_INFO_0_DATA   (( `MAJOR_VERSION         <<  0) + \
                                (`MINOR_VERSION         <<  4) + \
                                (`NOS_PWM_CHANNELS      <<  8) + \
                                (`NOS_QE_CHANNELS       << 12) + \
                                (`NOS_RC_SERVO_CHANNELS << 16))
    
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
    
    `define T_ON_MINIMUM         3  // smallest pwm ON pulse (60nS)

///////////////////////////////////////////////////
//
// Quadrature encoder subsystem

    `define QE_COUNT_BUFFER         0   
    `define QE_TURN_BUFFER          1
    `define QE_SPEED_BUFFER         2
    `define QE_SIM_PHASE_TIME       3
    `define QE_COUNTS_PER_REV       4
    `define QE_CONFIG               5
    `define QE_STATUS               6

//
// used in testbench files

   `define QE_0     (`QE_BASE + (0 * `NOS_QE_REGISTERS))      
   `define QE_1     (`QE_BASE + (1 * `NOS_QE_REGISTERS))
   `define QE_2     (`QE_BASE + (2 * `NOS_QE_REGISTERS))
   `define QE_3     (`QE_BASE + (3 * `NOS_QE_REGISTERS))

///////////////////////////////////////////////////
//
// RC Servo subsystem

    `define RC_SERVO_PERIOD         0   
    `define RC_SERVO_CONFIG         1
    `define RC_SERVO_STATUS         2
    `define RC_SERVO_ON_TIME        3

    //
    // definition of configuration register bits
    
    `define RC_SERVO_CHANNEL_0_ENABLE     0     // 1 bit 
    `define RC_SERVO_CHANNEL_1_ENABLE     1     // 1 bit 
    // repeated for set of channels
    //
    
    `define RC_SERVO_GLOBAL_ENABLE       31     // 1 bit 
    
//
// used in testbench files

    `define RC_0    (`RC_BASE)      

///////////////////////////////////////////////////
//
// Interface constants

    //
    // number of 32-bit values to be read from slave
    
    `ifdef INCLUDE_32_BIT_STATUS_RETURN
        `define NOS_READ_WORDS_FROM_SLAVE     2
    `else
        `define NOS_READ_WORDS_FROM_SLAVE     1
    `endif
    
    `define NOS_READ_BYTES_FROM_SLAVE     (4 * `NOS_READ_WORDS_FROM_SLAVE)
    //
    // Number of bytes read from and written to uP

    `define NOS_READ_BYTES_FROM_UP     6
    `define NOS_WRITE_BYTES_TO_UP    (`NOS_READ_WORDS_FROM_SLAVE * 4)
    //
    // named bytes in byte packet from uP

    `define CMD_REG         0
    `define REGISTER_NUMBER 1
    `define UP_STATUS_REG   0
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

    
    enum bit {MODE_IN1A_IN2B=1'b0, MODE_PWM_DIR=1'b1} H_bridge_interface_types;


    enum bit [1:0] {MOTOR_COAST=2'b00, MOTOR_FORWARD=2'b01, MOTOR_BACKWARD=2'b10, MOTOR_BRAKE=2'b11} motor_commands;	
    enum bit       {PWM_BRAKE_DWELL=1'b0, PWM_COAST_DWELL=1'b1} PWM_dwell_modes;
    enum bit       {BACKWARD=1'b0, FORWARD=1'b1} motor_directions;
    
//
// bit definitions/positions for 32-bit PWM/H-bridge configuaration register

    `define  PWM_ENABLE               0      // 1 bit
    //
    `define  H_BRIDGE_INT_ENABLE     16      // 1 bit
    `define  H_BRIDGE_EXT_ENABLE     17      // 1 bit
    `define  H_BRIDGE_MODE           18      // 2 bits
    `define  H_BRIDGE_COMMAND        20      // 3 bits
    `define  H_BRIDGE_SWAP           24      // 1 bit
    `define  H_BRIDGE_DWELL_MODE     25      // 1 bit
    `define  H_BRIDGE_INVERT_PINS    26      // 2 bits

//
// bit definitions/positions for 32-bit Quadrature encoder configuaration register

    `define  QE_ENABLE                   0   // 1-bit

    `define  QE_SOURCE                   1   // 1 bit : external or internal signals
    `define  QE_SIM_ENABLE               2   // 1 bit : enable quadrature encoder simulator
    `define  QE_SIM_DIRECTION            3   // 1 bit : flip simulated A/B signals
    `define  QE_FLIP_AB                  4   // 1 bit : flip AB signals to quadrature decoder
    
    `define  QE_SPEED_MEASURE_ENABLE    16   // 1 bit : 
    `define  QE_SPEED_FILTER_ENABLE     17   // 1 bit : enables binary averaging filter
    `define  QE_FILTER_SIZE             20   // 3 bits : sample size == value to the power 2.
    
    enum bit {QE_EXTERNAL, QE_INTERNAL} QE_encoder_source;
    enum bit {QE_CW, QE_CCW} rotational_direction;
    enum bit {NO, YES} condition;
    
    `define MAX_SPEED_COUNT 200000000
    
    enum bit {FALSE, TRUE} bool_states;
    
//
// other constants

    `define TIMEOUT_COUNT   10000
    

`endif    // _global_constants_sv_

