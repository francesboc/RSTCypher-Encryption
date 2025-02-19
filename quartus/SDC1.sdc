create_clock -name clk -period 10 [get_ports clk]
set_false_path -from [get_ports rst_n] -to [get_clocks clk]
set_input_delay -min 1 -clock [get_clocks clk] [get_ports {rst_n ptxt_valid key[*][*] ptxt_char[*]}]
set_input_delay -max 2 -clock [get_clocks clk] [get_ports {rst_n ptxt_valid key[*][*] ptxt_char[*]}]
set_output_delay -min 1 -clock [get_clocks clk] [get_ports {ctxt_str[*] ctxt_ready err_invalid_ptxt_char err_invalid_key key_not_installed}]
set_output_delay -max 2 -clock [get_clocks clk] [get_ports {ctxt_str[*] ctxt_ready err_invalid_ptxt_char err_invalid_key key_not_installed}]