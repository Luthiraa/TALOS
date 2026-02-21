# testbench.tcl
# Top-level simulation script for top_inference_de1 in ModelSim/Questa.
# This script:
#   1) Compiles Quartus simulation libraries (if needed)
#   2) Compiles the project RTL/IP
#   3) Simulates top_inference_de1
#   4) Drives CLOCK_50 and SW[9:0]
#   5) Captures useful waveforms and prints key internal status

transcript on
# Keep session open on errors so the failing command is visible.
onerror {resume}

puts "=== testbench.tcl: starting ==="

# -----------------------------------------------------------------------------
# Resolve paths
# -----------------------------------------------------------------------------
set SCRIPT_DIR [file normalize [pwd]]
set PROJ_DIR   $SCRIPT_DIR

# Allow override from environment if needed
if {[info exists ::env(QUARTUS_ROOTDIR)]} {
    set QUARTUS_DIR [file normalize $::env(QUARTUS_ROOTDIR)]
} else {
    # Default for Intel FPGA Lite 18.1 on Windows
    set QUARTUS_DIR "C:/intelFPGA_lite/18.1/quartus"
}

set SIMLIB_DIR [file join $QUARTUS_DIR "eda" "sim_lib"]

puts "Project dir : $PROJ_DIR"
puts "Quartus dir : $QUARTUS_DIR"
puts "Sim lib dir : $SIMLIB_DIR"

proc require_file {p} {
    if {![file exists $p]} {
        puts "ERROR: required file not found: $p"
        quit -code 2
    }
}

require_file [file join $SIMLIB_DIR "altera_primitives.v"]
require_file [file join $SIMLIB_DIR "220model.v"]
require_file [file join $SIMLIB_DIR "sgate.v"]
require_file [file join $SIMLIB_DIR "altera_mf.v"]
require_file [file join $SIMLIB_DIR "altera_lnsim.sv"]
require_file [file join $SIMLIB_DIR "mentor" "cyclonev_atoms_ncrypt.v"]
require_file [file join $SIMLIB_DIR "mentor" "cyclonev_hmi_atoms_ncrypt.v"]
require_file [file join $SIMLIB_DIR "cyclonev_atoms.v"]
require_file [file join $SIMLIB_DIR "mentor" "cyclonev_hssi_atoms_ncrypt.v"]
require_file [file join $SIMLIB_DIR "cyclonev_hssi_atoms.v"]
require_file [file join $SIMLIB_DIR "mentor" "cyclonev_pcie_hip_atoms_ncrypt.v"]
require_file [file join $SIMLIB_DIR "cyclonev_pcie_hip_atoms.v"]

# -----------------------------------------------------------------------------
# Clean local compile libs for a deterministic run
# -----------------------------------------------------------------------------
if {[file exists [file join $PROJ_DIR "libraries"]]} {
    file delete -force [file join $PROJ_DIR "libraries"]
}

vlib [file join $PROJ_DIR "libraries"]
vlib [file join $PROJ_DIR "libraries" "work"]
vmap work [file join $PROJ_DIR "libraries" "work"]

foreach lib {
    altera_ver lpm_ver sgate_ver altera_mf_ver altera_lnsim_ver
    cyclonev_ver cyclonev_hssi_ver cyclonev_pcie_hip_ver
} {
    vlib [file join $PROJ_DIR "libraries" $lib]
    vmap $lib [file join $PROJ_DIR "libraries" $lib]
}

# -----------------------------------------------------------------------------
# Compile device libraries required by Intel IP (ROM + PLL)
# -----------------------------------------------------------------------------
puts "=== Compiling Quartus simulation libraries ==="
vlog [file join $SIMLIB_DIR "altera_primitives.v"]                       -work altera_ver
vlog [file join $SIMLIB_DIR "220model.v"]                                -work lpm_ver
vlog [file join $SIMLIB_DIR "sgate.v"]                                   -work sgate_ver
vlog [file join $SIMLIB_DIR "altera_mf.v"]                               -work altera_mf_ver
vlog -sv [file join $SIMLIB_DIR "altera_lnsim.sv"]                       -work altera_lnsim_ver
vlog [file join $SIMLIB_DIR "mentor" "cyclonev_atoms_ncrypt.v"]          -work cyclonev_ver
vlog [file join $SIMLIB_DIR "mentor" "cyclonev_hmi_atoms_ncrypt.v"]      -work cyclonev_ver
vlog [file join $SIMLIB_DIR "cyclonev_atoms.v"]                          -work cyclonev_ver
vlog [file join $SIMLIB_DIR "mentor" "cyclonev_hssi_atoms_ncrypt.v"]     -work cyclonev_hssi_ver
vlog [file join $SIMLIB_DIR "cyclonev_hssi_atoms.v"]                     -work cyclonev_hssi_ver
vlog [file join $SIMLIB_DIR "mentor" "cyclonev_pcie_hip_atoms_ncrypt.v"] -work cyclonev_pcie_hip_ver
vlog [file join $SIMLIB_DIR "cyclonev_pcie_hip_atoms.v"]                 -work cyclonev_pcie_hip_ver

# -----------------------------------------------------------------------------
# Compile design RTL/IP
# -----------------------------------------------------------------------------
puts "=== Compiling design files ==="
vlog -sv [file join $PROJ_DIR "fixedpoint.sv"]
vlog -sv [file join $PROJ_DIR "cnn.sv"]
vlog -sv [file join $PROJ_DIR "fc_w_rom.v"]
vlog -sv [file join $PROJ_DIR "maxpool.sv"]
vlog -sv [file join $PROJ_DIR "inference.sv"]
vlog      [file join $PROJ_DIR "pll_10" "pll_10_0002.v"]
vlog      [file join $PROJ_DIR "pll_10.v"]
vlog -sv [file join $PROJ_DIR "top_inference_de1.sv"]

# -----------------------------------------------------------------------------
# Elaborate
# -----------------------------------------------------------------------------
puts "=== Elaborating top_inference_de1 ==="
vsim -voptargs=+acc \
    -L work \
    -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver \
    -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver \
    top_inference_de1

# -----------------------------------------------------------------------------
# Wave setup: top control + inference/cnn/maxpool internals
# -----------------------------------------------------------------------------
puts "=== Adding key debug waveforms ==="
add wave -group TOP     sim:/top_inference_de1/CLOCK_50
add wave -group TOP     sim:/top_inference_de1/SW
add wave -group TOP     sim:/top_inference_de1/pll_locked
add wave -group TOP     sim:/top_inference_de1/rst_sync_ff
add wave -group TOP     sim:/top_inference_de1/en_sync_ff
add wave -group TOP     sim:/top_inference_de1/start_pulse
add wave -group TOP     sim:/top_inference_de1/cst
add wave -group TOP     sim:/top_inference_de1/dut_rst_n
add wave -group TOP     sim:/top_inference_de1/dut_enable
add wave -group TOP     sim:/top_inference_de1/display_en
add wave -group TOP     sim:/top_inference_de1/complete
add wave -group TOP     sim:/top_inference_de1/o0
add wave -group TOP     sim:/top_inference_de1/y
add wave -group TOP     sim:/top_inference_de1/o0_latched

add wave -group INFER   sim:/top_inference_de1/dut/st
add wave -group INFER   sim:/top_inference_de1/dut/ker_sel
add wave -group INFER   sim:/top_inference_de1/dut/cnn_en_r
add wave -group INFER   sim:/top_inference_de1/dut/mp_en_r
add wave -group INFER   sim:/top_inference_de1/dut/clear_accum_r
add wave -group INFER   sim:/top_inference_de1/dut/complete_r

add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/complete_r
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/convolutions
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/filter_oper
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/hor_align
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/vert_align
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/kernel_hor
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/kernel_vert
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/conv_acc
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/tap_wgt
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/tap_pix
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/prod_q16
add wave -group CNN     sim:/top_inference_de1/dut/cnn_ins/overflow_mul

add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/st
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/convolutions
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/filter_oper
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/running_max
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/w_addr_reg
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/w_q_rom
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/a_q
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/prod64
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/neuron0
add wave -group MAXPOOL sim:/top_inference_de1/dut/ma_ins/complete

# Add every accessible signal recursively (full dump view).
# This can be large, but it guarantees no internal signal is omitted.
puts "=== Adding full hierarchical waveform dump ==="
add wave -group ALL_SIGNALS -r sim:/top_inference_de1/*

# -----------------------------------------------------------------------------
# Stimulus (no separate tb module; force top-level board pins)
# SW[1] is reset_n source (active-low raw), SW[0] is enable/start source.
# -----------------------------------------------------------------------------
puts "=== Applying stimulus ==="
force -freeze sim:/top_inference_de1/CLOCK_50 0 0ns, 1 10ns -repeat 20ns

# Hold reset asserted initially: SW1=0, SW0=0
force sim:/top_inference_de1/SW 10'b0000000000
run 2 us

# Release reset, still disabled
force sim:/top_inference_de1/SW 10'b0000000010
run 10 us

# Start pulse via SW0 rising edge
force sim:/top_inference_de1/SW 10'b0000000011

# Run long enough to execute all 4 passes + complete
run 20 ms

# -----------------------------------------------------------------------------
# Report key status in transcript
# -----------------------------------------------------------------------------
puts "=== Final status snapshot ==="
puts "time                 = [now]"
puts "top.cst              = [examine sim:/top_inference_de1/cst]"
puts "top.complete         = [examine sim:/top_inference_de1/complete]"
puts "top.o0               = [examine sim:/top_inference_de1/o0]"
puts "top.y                = [examine sim:/top_inference_de1/y]"
puts "dut.st               = [examine sim:/top_inference_de1/dut/st]"
puts "dut.ker_sel          = [examine sim:/top_inference_de1/dut/ker_sel]"
puts "cnn.complete_r       = [examine sim:/top_inference_de1/dut/cnn_ins/complete_r]"
puts "cnn.convolutions     = [examine sim:/top_inference_de1/dut/cnn_ins/convolutions]"
puts "maxpool.complete     = [examine sim:/top_inference_de1/dut/ma_ins/complete]"
puts "maxpool.convolutions = [examine sim:/top_inference_de1/dut/ma_ins/convolutions]"
puts "maxpool.neuron0      = [examine sim:/top_inference_de1/dut/ma_ins/neuron0]"
puts "maxpool.w_addr_reg   = [examine sim:/top_inference_de1/dut/ma_ins/w_addr_reg]"
puts "maxpool.w_q_rom      = [examine sim:/top_inference_de1/dut/ma_ins/w_q_rom]"

puts "=== testbench.tcl: done (interactive session left open) ==="

# Keep GUI open for manual inspection.
# Uncomment next line for batch mode:
# quit -code 0
