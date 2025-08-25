#================DO NOT MODIFY BELOW===================== 
# Compiler and simulator settings
IVERILOG = iverilog
VVP = vvp
COCOTB_PREFIX = $(shell cocotb-config --prefix)

COCOTB_LIBS = $(COCOTB_PREFIX)/cocotb/libs

SIM_BUILD_DIR = sim_build
SIM_VVP = $(SIM_BUILD_DIR)/sim.vvp

# Environment variables
export COCOTB_REDUCED_LOG_FMT=1
export LIBPYTHON_LOC=$(shell cocotb-config --libpython)
export PYTHONPATH := test:$(PYTHONPATH)

#=============== MODIFY BELOW ======================
# ********** IF YOU HAVE A NEW VERILOG FILE, ADD IT TO THE SOURCES VARIABLE
SOURCES = src/counter.sv \
src/cnn.sv \
src/maxpool.sv

# Test targets
test_counter: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s counter -s dump -g2012 $(SOURCES) src/dump_counter.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_counter $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv counter.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/counter.vcd &

test_cnn: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s cnn -s dump -g2012 $(SOURCES) src/dump_cnn.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_cnn $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv cnn.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/cnn.vcd &

test_maxpool: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s maxpool -s dump -g2012 $(SOURCES) src/dump_maxpool.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_maxpool $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv maxpool.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/maxpool.vcd &

# ============ DO NOT MODIFY BELOW THIS LINE ==============

# Create simulation build directory and waveforms directory
$(SIM_BUILD_DIR):
	mkdir -p $(SIM_BUILD_DIR)
	mkdir -p waveforms

# Waveform viewing (standalone)
show_counter: 
	@if [ -f waveforms/counter.vcd ]; then \
		gtkwave waveforms/counter.vcd & \
	else \
		echo "No VCD file found. Run 'make test_counter' first."; \
	fi

# Linting
lint:
	verible-verilog-lint src/*sv --rules_config verible.rules 2>/dev/null || echo "Verible not available"

# Cleanup
clean:
	rm -rf waveforms/*.vcd $(SIM_BUILD_DIR) test/__pycache__ results.xml

.PHONY: clean test_counter show_counter lint