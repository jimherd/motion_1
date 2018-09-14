#
# motion_test_1 : system test 1
#

#
project open C:/jth/HW_new_robot/Quartus_projects/motion_1/Modelsim/motion_test_1
#
# uses "-permissive" to downgrade some interface port errors
#
vsim -voptargs=\"+acc\" -permissive work.motion_system work.motion_test_1_tb
#
# setup waves to be viewed
#
add wave -label CLOCK -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/clk
add wave -label uP_start -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_start
add wave -label uP_handshake_1 -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_handshake_1
add wave -label uP_handshake_2 -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_handshake_2
add wave -label uP_data_out -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_data_out
add wave -label uP_state -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_interface_sys/state
add wave -label target_count -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/target_count
add wave -label count -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/counter
add wave -label counter_zero -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/counter_zero
#
# run simulation
#
run 2000ns
wave zoom full


