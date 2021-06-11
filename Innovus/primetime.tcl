#Preparations:A new file with 1)Your testbench 2)CHIP.v(from apr) 3)CHIP.vdc 4)CHIP.spef 5)six .db files as shown below.
#Note for how to get CHIP.vdc:
    #Do post-sim, note that your top module for testing should be "CHIP", which is the top module in CHIP.v
    #Use $dumpfile("CHIP.vdc"); $dumpvars();

#Command1:source /usr/cad/synopsys/CIC/primetime.cshrc
#Command2:pt_shell -f primetime.tcl


#No need to modify below
set_host_options -max_cores 8
set power_enable_analysis true
set power_analysis_mode time_based
set power_report_leakage_breakdowns true
set power_clock_network_include_register_clock_pin_power true
set search_path "./"
set target_library "fsa0m_a_generic_core_ff1p98vm40c.db fsa0m_a_generic_core_ss1p62v125c.db fsa0m_a_generic_core_tt1p8v25c.db fsa0m_a_t33_generic_io_ff1p98vm40c.db fsa0m_a_t33_generic_io_ss1p62v125c.db fsa0m_a_t33_generic_io_tt1p8v25c.db"
set link_library "* fsa0m_a_generic_core_ff1p98vm40c.db * fsa0m_a_generic_core_ss1p62v125c.db * fsa0m_a_generic_core_tt1p8v25c.db * fsa0m_a_t33_generic_io_ff1p98vm40c.db * fsa0m_a_t33_generic_io_ss1p62v125c.db * fsa0m_a_t33_generic_io_tt1p8v25c.db"
set sythetic_library "dw_foundation.sldb"

read_file -format verilog [list SMVM_apr.v]
current_design [get_designs CHIP]
link_design CHIP
#Note:CHIP.v is your design and CHIP is your top module in CHIP.v

read_parasitics -format SPEF -verbose ./CHIP.spef
#No need to modify above


read_vcd ./top.vcd -strip_path SMVM_tb/Top 
report_switching_activity -list_not_annotated
#50 1400 is your starting and ending time of simulation, our design start at 100 and ends at 1370, so you can modify for your own.
#CHIP_tb/chip0 is decided from your testbench. CHIP_tb is the module name of yur tb, while chip0 is your module name of your testing top module.
#For example, in our testbench, we write 
#module CHIP_tb;
#    integer i, j, f, err;
#    reg clk, rst_n, valid, stop;
#    reg [10:0] before_ff [0:31];
#    reg [16:0] after_ff [0:63];
#    reg [10:0] data_in_r;
#    wire [16:0] data_out;
#    wire finish;
#    CHIP chip0(
#        .clk(clk),
#        .rst_n(rst_n),
#        .valid_i(valid),
#        .x_r(data_in_r),    
#        .finish(finish),
#        .answer(data_out)
#    );


#No need to modify below
check_power
set_power_analysis_options -waveform_interval 1
update_power
set_power_analysis_options -waveform_interval 1 -waveform_format out -waveform_output vcd
report_power -verbose -hierarchy > CHIP.power
