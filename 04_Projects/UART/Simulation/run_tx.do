if {[file exists work]} {
	vdel -lib work -all
}

vlib work

# bien dich ma nguyen RTL va Testbench
vlog ../RTL/uart_tx.v

vlog tb_uart_tx.v

# khoi chay mo phong

vsim -voptargs="+acc" work.tb_uart_tx

# them song va chay

add wave -r /*
run -all


