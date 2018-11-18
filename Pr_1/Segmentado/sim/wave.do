onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /processor_tb/i_processor/Clk
add wave -noupdate /processor_tb/i_processor/Reset
add wave -noupdate /processor_tb/clk
add wave -noupdate /processor_tb/reset
add wave -noupdate -radix decimal /processor_tb/iAddr
add wave -noupdate -radix binary /processor_tb/iDataIn
add wave -noupdate /processor_tb/dAddr
add wave -noupdate /processor_tb/dRdEn
add wave -noupdate /processor_tb/dWrEn
add wave -noupdate /processor_tb/dDataOut
add wave -noupdate /processor_tb/dDataIn
add wave -noupdate /processor_tb/endSimulation
add wave -noupdate /processor_tb/i_processor/A2_ID
add wave -noupdate /processor_tb/i_processor/Rd2_ID
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {390 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 279
configure wave -valuecolwidth 114
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {111 ns} {130 ns}
