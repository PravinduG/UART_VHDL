set_property PACKAGE_PIN W5 [get_ports CLK]
set_property PACKAGE_PIN U18 [get_ports RESET]
set_property PACKAGE_PIN A18 [get_ports TX]
set_property PACKAGE_PIN B18 [get_ports RX]

set_property IOSTANDARD LVCMOS33 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports RESET]
set_property IOSTANDARD LVCMOS33 [get_ports TX]
set_property IOSTANDARD LVCMOS33 [get_ports RX]

set_output_delay -clock [get_clocks CLK] -min -add_delay 0.000 [get_ports {TX}]
set_input_delay -clock [get_clocks CLK] -min -add_delay 0.000 [get_ports {RX}]

set_output_delay -clock [get_clocks CLK] -max -add_delay 0.000 [get_ports {TX}]
set_input_delay -clock [get_clocks CLK] -max -add_delay 0.000 [get_ports {RX}]