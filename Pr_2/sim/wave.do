onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /processor_tb/clk
add wave -noupdate /processor_tb/reset
add wave -noupdate -radix hexadecimal /processor_tb/iAddr
add wave -noupdate -radix hexadecimal /processor_tb/iDataIn
add wave -noupdate -radix unsigned -childformat {{/processor_tb/i_processor/reg_bank_pm/regs(0) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(1) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(2) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(3) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(4) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(5) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(6) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(7) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(8) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(9) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(10) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(11) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(12) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(13) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(14) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(15) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(16) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(17) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(18) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(19) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(20) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(21) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(22) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(23) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(24) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(25) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(26) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(27) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(28) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(29) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(30) -radix hexadecimal} {/processor_tb/i_processor/reg_bank_pm/regs(31) -radix hexadecimal}} -expand -subitemconfig {/processor_tb/i_processor/reg_bank_pm/regs(0) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(1) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(2) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(3) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(4) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(5) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(6) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(7) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(8) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(9) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(10) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(11) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(12) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(13) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(14) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(15) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(16) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(17) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(18) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(19) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(20) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(21) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(22) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(23) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(24) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(25) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(26) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(27) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(28) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(29) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(30) {-height 15 -radix hexadecimal} /processor_tb/i_processor/reg_bank_pm/regs(31) {-height 15 -radix hexadecimal}} /processor_tb/i_processor/reg_bank_pm/regs
add wave -noupdate -radix hexadecimal /processor_tb/i_processor/Result_MEM
add wave -noupdate -radix hexadecimal /processor_tb/i_processor/OpA_EX
add wave -noupdate -radix hexadecimal /processor_tb/i_processor/OpB_EX
add wave -noupdate -radix hexadecimal /processor_tb/i_processor/Result_EX
add wave -noupdate /processor_tb/i_processor/ALUControl_EX
add wave -noupdate /processor_tb/i_processor/ALUOp_EX
add wave -noupdate /processor_tb/i_processor/Funct_EX
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {169019 ps} 0}
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
WaveRestoreZoom {131404 ps} {186860 ps}
