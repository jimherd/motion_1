#
# motion_test_1 : system test 1
#
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
add wave -label uP_start -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_start
add wave -label uP_RW -position end  sim:/motion_test_1_tb/async_RW
add wave -label uP_handshake_1 -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_handshake_1
add wave -label uP_handshake_2 -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_handshake_2
add wave -label write_byte_to_uP -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/write_uP_byte
add wave -label uP_data -radix hexadecimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_data
add wave -label uP_state -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_interface_sys/state
add wave -label target_count -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/target_count
add wave -label count -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/counter
add wave -label counter_zero -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/counter_zero
add wave -label reg_addr -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/bus/reg_address
add wave -label subsystem_enable -position end  sim:/motion_test_1_tb/uut/pwm_ch0/subsystem_enable
add wave -label RW -position end  sim:/motion_test_1_tb/uut/intf/RW
add wave -label BUS_data_out -radix hexadecimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/bus/data_out
add wave -label BUS_data_in -radix decimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/bus/data_in
add wave -label BUS_state -position end  sim:/motion_test_1_tb/uut/pwm_ch0/bus_FSM_sys/state
add wave -label BUS_handshake_1 -position end  sim:/motion_test_1_tb/uut/intf/handshake_1
add wave -label BUS_handshake_2 -position end  sim:/motion_test_1_tb/uut/intf/handshake_2
add wave -label read_word_from_BUS -position end  sim:/motion_test_1_tb/uut/pwm_ch0/bus_FSM_sys/read_word_from_BUS
add wave -label write_word_to_BUS -position end  sim:/motion_test_1_tb/uut/pwm_ch0/bus_FSM_sys/write_data_word_to_BUS
add wave -label T_ON_reg_CH0 -radix hexadecimal -position end  sim:/motion_test_1_tb/uut/pwm_ch0/T_on
add wave -label output_packet -radix hexadecimal -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/output_packet
add wave -label read_bus_word -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/read_bus_word
add wave -label PWM_ch0 -position end  sim:/motion_test_1_tb/uut/pwm_ch0/pwm
#
# run simulation
#
run 15000ns
wave zoom full


