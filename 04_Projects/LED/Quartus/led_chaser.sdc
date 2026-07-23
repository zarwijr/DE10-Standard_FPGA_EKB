# Khai báo clock 50MHz cho cổng CLOCK_50 (T = 20.000 ns)
create_clock -name clk_50m -period 20.000 [get_ports CLOCK_50]

# Tự động tính toán độ không đảm bảo của clock (Clock Uncertainty)
derive_clock_uncertainty

# Khai báo False Path cho nút bấm reset và các đầu ra LED
set_false_path -from [get_ports {KEY0_rst_n}]
set_false_path -to [get_ports {LEDR[*]}]