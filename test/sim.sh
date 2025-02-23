#Build
rm -f modsim.bin
rm -f tb.vcd

iverilog -g2012 -Wall -D EN_SIMULATION -o modsim.bin tb.v  ../src/nanospi_top.v

#Run sim
vvp modsim.bin

#Display results
#gtkwave nanospi_test.vcd --rcvar 'fontname_signals Monospace 12' --rcvar 'fontname_waves Monospace 12'

