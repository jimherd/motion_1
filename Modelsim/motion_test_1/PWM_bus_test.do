vsim -voptargs=\"+acc\" work.motion_system work.motion_test_1_tb
# vsim -voptargs=""+acc"" work.motion_system work.motion_test_1_tb 
# Start time: 21:19:31 on Sep 13,2018
# Loading sv_std.std
# Loading work.types
# Loading work.motion_system_sv_unit
# Loading work.motion_system
# Loading work.IO_bus
# Loading work.uP_interface_sv_unit
# Loading work.uP_interface
# Loading work.uP_interface_FSM
# Loading work.pwm_channel
# Loading work.bus_FSM
# Loading work.pwm_FSM
# Loading work.motion_test_1_tb_sv_unit
# Loading work.motion_test_1_tb
# ** Warning: (vsim-3839) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37): Variable '/motion_system/intf/handshake1_2', driven via a port connection, is multiply driven. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1/bus_FSM_sys File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/bus_FSM.sv
# ** Warning: (vsim-3015) C:/jth/HW_new_robot/Quartus_projects/motion_1/test_bench/motion_test_1_tb.sv(20): [PCDPC] - Port size (8) does not match connection size (1) for port 'uP_data_out'. The port definition is at: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/motion_system.sv(24).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/motion_system.sv
# ** Warning: (vsim-3839) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37): Variable '/motion_test_1_tb/uut/intf/handshake1_2', driven via a port connection, is multiply driven. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut/pwm_ch1/bus_FSM_sys File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/bus_FSM.sv
# ** Error (suppressible): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Error (suppressible): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(130): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Error (suppressible): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(129): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Error (suppressible): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(128): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Error (suppressible): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(127): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# Error loading design
verror 7033
# 
# vsim-vlog Message # 7033:
# In SystemVerilog, a variable assigned inside an always_comb,
# always_latch, or always_ff may not be assigned by any other process.
# 
# This message will be downgraded to a warning with the -permissive argument
# This error message can be suppressed or downgraded to a note or warning
vsim -voptargs=\"+acc\" -permissive work.motion_system work.motion_test_1_tb
# vsim -voptargs=""+acc"" -permissive work.motion_system work.motion_test_1_tb 
# Start time: 23:55:56 on Sep 13,2018
# Loading sv_std.std
# Loading work.types
# Loading work.motion_system_sv_unit
# Loading work.motion_system
# Loading work.IO_bus
# Loading work.uP_interface_sv_unit
# Loading work.uP_interface
# Loading work.uP_interface_FSM
# Loading work.pwm_channel
# Loading work.bus_FSM
# Loading work.pwm_FSM
# Loading work.motion_test_1_tb_sv_unit
# Loading work.motion_test_1_tb
# ** Warning: (vsim-3839) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37): Variable '/motion_system/intf/handshake1_2', driven via a port connection, is multiply driven. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1/bus_FSM_sys File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/bus_FSM.sv
# ** Warning: (vsim-3015) C:/jth/HW_new_robot/Quartus_projects/motion_1/test_bench/motion_test_1_tb.sv(20): [PCDPC] - Port size (8) does not match connection size (1) for port 'uP_data_out'. The port definition is at: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/motion_system.sv(24).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/motion_system.sv
# ** Warning: (vsim-3839) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37): Variable '/motion_test_1_tb/uut/intf/handshake1_2', driven via a port connection, is multiply driven. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut/pwm_ch1/bus_FSM_sys File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/bus_FSM.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(130): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(129): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(128): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(127): Variable '/motion_system/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131): Variable '/motion_test_1_tb/uut/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(130): Variable '/motion_test_1_tb/uut/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(129): Variable '/motion_test_1_tb/uut/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(128): Variable '/motion_test_1_tb/uut/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# ** Warning (downgraded): (vsim-7033) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(127): Variable '/motion_test_1_tb/uut/intf/data_in' driven in a combinational block, may not be driven by any other process. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(131).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut/pwm_ch1 File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
add wave -position insertpoint  \
sim:/motion_test_1_tb/uut/uP_interface_sys/uP_interface_sys/clk
add wave -position end  sim:/motion_test_1_tb/uut/uP_interface_sys/uP_interface_sys/clk
run -all
quit -sim
pwd
# C:/jth/HW_new_robot/Quartus_projects/motion_1/Modelsim/motion_test_1
vsim -gui work.bus_FSM work.motion_system work.motion_system_sv_unit work.motion_test_1_tb work.motion_test_1_tb_sv_unit work.pwm_channel work.pwm_FSM work.types work.uP_interface work.uP_interface_FSM work.uP_interface_sv_unit
# vsim -gui work.bus_FSM work.motion_system work.motion_system_sv_unit work.motion_test_1_tb work.motion_test_1_tb_sv_unit work.pwm_channel work.pwm_FSM work.types work.uP_interface work.uP_interface_FSM work.uP_interface_sv_unit 
# Start time: 00:03:02 on Sep 14,2018
# Loading sv_std.std
# Loading work.bus_FSM
# Loading work.types
# Loading work.motion_system_sv_unit
# Loading work.motion_system
# Loading work.IO_bus
# Loading work.uP_interface_sv_unit
# Loading work.uP_interface
# Loading work.uP_interface_FSM
# Loading work.pwm_channel
# Loading work.pwm_FSM
# Loading work.motion_test_1_tb_sv_unit
# Loading work.motion_test_1_tb
# ** Warning: (vsim-3839) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37): Variable '/motion_system/intf/handshake1_2', driven via a port connection, is multiply driven. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37).
#    Time: 0 ps  Iteration: 0  Instance: /motion_system/pwm_ch1/bus_FSM_sys File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/bus_FSM.sv
# ** Warning: (vsim-3015) C:/jth/HW_new_robot/Quartus_projects/motion_1/test_bench/motion_test_1_tb.sv(20): [PCDPC] - Port size (8) does not match connection size (1) for port 'uP_data_out'. The port definition is at: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/motion_system.sv(24).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/motion_system.sv
# ** Warning: (vsim-3839) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37): Variable '/motion_test_1_tb/uut/intf/handshake1_2', driven via a port connection, is multiply driven. See C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(37).
#    Time: 0 ps  Iteration: 0  Instance: /motion_test_1_tb/uut/pwm_ch1/bus_FSM_sys File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/bus_FSM.sv
# ** Fatal: (vsim-3695) C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv(11): The interface port 'bus' must be passed an actual interface.
#    Time: 0 ps  Iteration: 0  Instance: /pwm_channel File: C:/jth/HW_new_robot/Quartus_projects/motion_1/verilog/pwm_channel.sv
# FATAL ERROR while loading design
# Error loading design

pwd
# C:/jth/HW_new_robot/Quartus_projects/motion_1/Modelsim/motion_test_1
vsim -do motion_test_1.do
# No design specified
