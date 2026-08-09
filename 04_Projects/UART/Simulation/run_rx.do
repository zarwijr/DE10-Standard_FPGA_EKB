if {[file exists work]} {
	vdel -lib work -all
}

vlib work

#bien dich

vlog ../RTL/uart_rx.v

vlog tb_uart_rx.v

# khoi chay mo phong

vsim -voptargs="+acc" work.tb_uart_rx

# them song va chay

add wave -r /*
run -all