#
# MIT License
#
# Copyright (c) 2018 James Herd
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#
# motion_test_1 : system test 1
#
set RUN_TIME  25000ns

# options : PWM_TEST_0, PWM_TEST_1, QE_INT_TEST_0, RC_SERVO_TEST_0

set     TEST     PWM_TEST_1

project open C:/jth/HW_new_robot/Quartus_projects/motion_1/Modelsim/motion_test_1
#
# compile
#
vlog -work work -sv -stats=none C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/types.sv
#
# uses "-permissive" to downgrade some interface port errors
#
quit -sim
vsim -voptargs=\"+acc\" -permissive work.motion_system work.motion_test_1_tb
#
# setup waves to be viewed
#
add wave -label CLOCK -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/clk
add wave -label RESET -position end  sim:/motion_test_1_tb/uut/reset
#
add wave -divider "uP/FPGA 8-bit bus"
add wave -label uP_start -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_start
add wave -label uP_RW -position end  sim:/motion_test_1_tb/async_uP_RW
add wave -label uP_handshake_1 -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_handshake_1
add wave -label uP_handshake_2 -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_handshake_2
add wave -label write_byte_to_uP -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/write_uP_byte
add wave -label uP_data -radix hexadecimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_data
add wave -label uP_state -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_interface_sys/state
add wave -label uP_nFault -position end sim:/motion_test_1_tb/uut/uP_interface_sys/uP_nFault
#
add wave -divider "internal 32-bit bus"
add wave -label BUS_handshake_1 -position end  sim:/motion_test_1_tb/uut/intf/handshake_1
add wave -label BUS_handshake_2 -position end  sim:/motion_test_1_tb/uut/intf/handshake_2
add wave -label RW -position end  sim:/motion_test_1_tb/uut/intf/RW
add wave -label reg_addr -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/bus/reg_address
add wave -label reg_add_valid -position end sim:/motion_test_1_tb/uut/intf/register_address_valid
add wave -label BUS_data_out -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/bus/data_out
add wave -label BUS_data_in -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/bus/data_in
add wave -label output_packet -radix hexadecimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/output_packet
add wave -label read_bus_word -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/read_bus_word
add wave -label target_count -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/target_count
add wave -label count -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/counter
add wave -label counter_zero -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/counter_zero
#
switch $TEST {
	PWM_TEST_1 {
		add wave -divider "PWM subsystem"
		add wave -label PWM0_subsystem_enable -position end  {sim:/motion_test_1_tb/uut/PWM_H_bridge[0]/pwm_ch/subsystem_enable}
		add wave -label BUS_state -position end  {sim:/motion_test_1_tb/uut/PWM_H_bridge[0]/pwm_ch/bus_FSM_sys/state}
		add wave -label read_word_from_BUS -position end  {sim:/motion_test_1_tb/uut/PWM_H_bridge[0]/pwm_ch/bus_FSM_sys/read_word_from_BUS}
		add wave -label write_word_to_BUS -position end  {sim:/motion_test_1_tb/uut/PWM_H_bridge[0]/pwm_ch/bus_FSM_sys/write_data_word_to_BUS}
		add wave -label T_ON_reg_CH0 -radix hexadecimal -position end  {sim:/motion_test_1_tb/uut/PWM_H_bridge[0]/pwm_ch/T_on}
		add wave -label {PWM_ch[0]} -position end  {sim:/motion_test_1_tb/uut/PWM_H_bridge[0]/pwm_ch/pwm}
        add wave -label data_in_reg -position end {sim:/motion_test_1_tb/uut/PWM_H_bridge[0]/pwm_ch/data_in_reg}
	}
	QE_INT_TEST_0 {
		add wave -divider "QE subsystem"
		add wave -label QE_reg_address -position end -radix decimal  {sim:/motion_test_1_tb/uut/intf/reg_address}
		add wave -label QE0_subsystem_enable -position end  {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch/subsystem_enable}
		add wave -label speed_measure_state -position end  {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_speed_measure_FSM_sys/state}
		add wave -label QE_sim_state -position end  {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_generator_FSM_sys/state}
		add wave -label QE_sim_phase_cnt -position end  -radix decimal {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_sim_phase_counter}
		add wave -label QE_dec_phase_time  -radix decimal -position end  {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_sim_phase_time}
		add wave -label QE_dec_phase_timer -position end  {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//decrement_phase_timer}
		add wave -label QE_sim_phase_timer -position end  -radix decimal {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_sim_phase_timer}
		add wave -label QE_sim_pulse_cnt -position end  -radix decimal {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_sim_pulse_counter}
#		add wave -label speed -position end  -radix decimal {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_speed}
		add wave -label QE_speed_measure -position end  -radix decimal {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_speed_buffer}
		add wave -label QE_pulse_count -position end  -radix decimal {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_count_buffer}
		add wave -label QE_rev_count -position end  -radix decimal {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_turns_buffer}
		add wave -label QE_A -position end  -radix decimal {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_A}
		add wave -label QE_B -position end  {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_B}
		add wave -label QE_I -position end  {sim:/motion_test_1_tb/uut/QE_encoder[0]/QE_ch//QE_I}
	}
	RC_SERVO_TEST_0 {
		add wave -divider "RC Servo subsystem"
		add wave -label Servo_0 -position end {sim:/motion_test_1_tb/uut/RC_servo_sys/RC_servo[0]}
		add wave -label RC_FSM_state -position end  {sim:/motion_test_1_tb/uut/RC_servo_sys/Servos[0]/RC_servo_channel_FSM_sys/state}
		add wave -label ON_time -radix decimal -position end  {sim:/motion_test_1_tb/uut/RC_servo_sys/RC_on_times[0]}
		add wave -label ON_count -position end -radix decimal  {sim:/motion_test_1_tb/uut/RC_servo_sys/tmp_RC_on_time_counter[0]}
		add wave -label period_count -radix decimal -position end  sim:/motion_test_1_tb/uut/RC_servo_sys/tmp_period_counter
	}
}
#
# run simulation
#
#switch $TEST {
#	RC_SERVO_TEST_0 {
#		run 1ms
#	}
#	default {
#		run $RUN_TIME
#	}
#}
wave zoom full


