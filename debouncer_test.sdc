#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

# PLL
derive_pll_clocks -create_base_clocks

# compute the jitter behavior of the PLLs
derive_clock_uncertainty

# Definition of additional Base clocks
create_clock -name MAX10_CLK1_50 -period "50 MHz" [get_ports MAX10_CLK1_50]

# identify asynchronous inputs/outputs in design
set_false_path -from KEY[*]
set_false_path -to LED[*] 