# Xóa thư viện cũ nếu có
if {[file exists work]} {
    vdel -lib work -all
}

# Tạo thư viện mới
vlib work

# Biên dịch toàn bộ RTL và Testbench (Đường dẫn tương đối)
vlog ../RTL/spi_master.v
vlog ../RTL/spi_slave.v
vlog ../RTL/spi_bist.v
vlog ../RTL/spi.v
vlog tb_spi_loopback.v

# Load mô phỏng
vsim -voptargs="+acc" work.tb_spi_loopback

# Tắt warning tràn số linh tinh (nếu có)
set NumericStdNoWarnings 1

# ----------------------------------------------
# Thêm tín hiệu vào Waveform
# ----------------------------------------------

add wave -divider "System & Controls"
add wave -color "Yellow"  /tb_spi_loopback/clk
add wave -color "Yellow"  /tb_spi_loopback/KEY
add wave -color "Orange"  /tb_spi_loopback/SW

add wave -divider "BIST Status (LEDs)"
add wave -color "Green" -label "PASS_FLAG"  {/tb_spi_loopback/LEDR[9]}
add wave -color "Red"   -label "ERROR_FLAG" {/tb_spi_loopback/LEDR[8]}
add wave -color "Cyan"  -label "BUSY"       {/tb_spi_loopback/LEDR[7]}

add wave -divider "BIST Controller Data"
add wave -radix hex       /tb_spi_loopback/dut/bist_inst/current_pattern
add wave -radix hex       /tb_spi_loopback/dut/bist_inst/captured_master_rx
add wave -radix hex       /tb_spi_loopback/dut/bist_inst/captured_slave_rx

add wave -divider "SPI PHYSICAL BUS (MODE 3)"
add wave -color "Magenta" /tb_spi_loopback/dut/spi_cs_n_wire
add wave -color "Magenta" /tb_spi_loopback/dut/spi_sclk_wire
add wave -color "Magenta" /tb_spi_loopback/dut/spi_mosi_wire
add wave -color "White"   -label "MISO_FROM_SLAVE"           /tb_spi_loopback/dut/spi_miso_slave_out
add wave -color "Red"     -label "MISO_TO_MASTER (Injected)" /tb_spi_loopback/dut/spi_miso_master_in

# Chạy mô phỏng
run -all

# Zoom waveform vừa màn hình
wave zoom full