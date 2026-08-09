if {[file exists work]} {
	vdel -lib work -all
}

vlib work

# bien dich 

vlog ../RTL/*.v

vlog *.v

# khoi chay mo phong

vsim -voptargs="+acc" work.tb_vga_timing

# them song va chay

add wave -r /*

run -all