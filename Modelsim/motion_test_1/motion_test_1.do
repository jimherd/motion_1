#
# motion_test_1 : system test 1
#
set RUN_TIME  25000ns

# options : PWM_TEST_0, PWM_TEST_1, QE_TEST_0

set     TEST     QE_TEST_0

project open C:/jth/HW_new_robot/Quartus_projects/motion_1/Modelsim/motion_test_1
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
#
add wave -divider "internal 32-bit bus"
add wave -label BUS_handshake_1 -position end  sim:/motion_test_1_tb/uut/intf/handshake_1
add wave -label BUS_handshake_2 -position end  sim:/motion_test_1_tb/uut/intf/handshake_2
add wave -label RW -position end  sim:/motion_test_1_tb/uut/intf/RW
add wave -label reg_addr -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/bus/reg_address
add wave -label BUS_data_out -radix hexadecimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/bus/data_out
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
		add wave -label PWM0_subsystem_enable -position end  {sim:/motion_test_1_tb/uut/pwm_ch0/subsystem_enable}
		add wave -label BUS_state -position end  {sim:/motion_test_1_tb/uut/pwm_ch0/bus_FSM_sys/state}
		add wave -label read_word_from_BUS -position end  {sim:/motion_test_1_tb/uut/pwm_ch0/bus_FSM_sys/read_word_from_BUS}
		add wave -label write_word_to_BUS -position end  {sim:/motion_test_1_tb/uut/pwm_ch0/bus_FSM_sys/write_data_word_to_BUS}
		add wave -label T_ON_reg_CH0 -radix hexadecimal -position end  {sim:/motion_test_1_tb/uut/pwm_ch0/T_on}
		add wave -label {PWM_ch[0]} -position end  {sim:/motion_test_1_tb/uut/pwm_ch0/pwm}
	}
	QE_TEST_0 {
		add wave -divider "QE subsystem"
		add wave -label QE0_subsystem_enable -position end  sim:/motion_test_1_tb/uut/QE_ch0/subsystem_enable
		add wave -label speed_measure_state -position end  sim:/motion_test_1_tb/uut/QE_ch0/QE_speed_measure_FSM_sys/state
		add wave -label QE_sim_state -position end  sim:/motion_test_1_tb/uut/QE_ch0/QE_generator_FSM_sys/state
		add wave -label QE_sim_phase_cnt -position end  -radix decimal sim:/motion_test_1_tb/uut/QE_ch0/QE_sim_phase_counter
		add wave -label QE_dec_phase_time  -radix decimal -position end  sim:/motion_test_1_tb/uut/QE_ch0/QE_sim_phase_time
		add wave -label QE_dec_phase_timer -position end  sim:/motion_test_1_tb/uut/QE_ch0/decrement_phase_timer
		add wave -label QE_sim_phase_timer -position end  -radix decimal sim:/motion_test_1_tb/uut/QE_ch0/QE_sim_phase_timer
		add wave -label QE_sim_pulse_cnt -position end  -radix decimal sim:/motion_test_1_tb/uut/QE_ch0/QE_sim_pulse_counter
		add wave -label speed -position end  -radix decimal sim:/motion_test_1_tb/uut/QE_ch0/QE_speed
		add wave -label QE_speed_measure -position end  -radix decimal sim:/motion_test_1_tb/uut/QE_ch0/QE_speed_buffer
		add wave -label QE_pulse_count -position end  -radix decimal sim:/motion_test_1_tb/uut/QE_ch0/QE_count_buffer
		add wave -label QE_rev_count -position end  -radix decimal sim:/motion_test_1_tb/uut/QE_ch0/QE_turns_buffer
		add wave -label QE_A -position end  -radix decimal sim:/motion_test_1_tb/uut/QE_ch0/QE_A
		add wave -label QE_B -position end  sim:/motion_test_1_tb/uut/QE_ch0/QE_B
		add wave -label QE_I -position end  sim:/motion_test_1_tb/uut/QE_ch0/QE_I
	}
}
#
# run simulation
#
run $RUN_TIME
wave zoom full


