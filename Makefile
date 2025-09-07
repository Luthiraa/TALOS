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
src/maxpool.sv \
src/division.sv \
src/simple_divide.sv \
src/flatten.sv \
src/neuron.sv \
src/inference.sv


# Test targets
test_counter: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s counter -s dump -g2012 $(SOURCES) src/dump/dump_counter.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_counter $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv counter.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/counter.vcd &

test_cnn: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s cnn -s dump -g2012 $(SOURCES) src/dump/dump_cnn.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_cnn $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv cnn.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/cnn.vcd &

test_maxpool: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s maxpool -s dump -g2012 $(SOURCES) src/dump/dump_maxpool.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_maxpool $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv maxpool.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/maxpool.vcd &

test_division: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s division -s dump -g2012 $(SOURCES) src/dump/dump_division.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_division $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv division.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/division.vcd &

test_simple_divide: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s simple_divide -s dump -g2012 $(SOURCES) src/dump/dump_simple_divide.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_simple_divide $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv simple_divide.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/simple_divide.vcd &

test_flatten: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s flatten -s dump -g2012 $(SOURCES) src/dump/dump_flatten.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_flatten $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv flatten.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/flatten.vcd &

test_neuron: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s neuron -s dump -g2012 $(SOURCES) src/dump/dump_neuron.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_neuron $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv neuron.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/neuron.vcd &

test_inference: $(SIM_BUILD_DIR)
	$(IVERILOG) -o $(SIM_VVP) -s inference -s dump -g2012 $(SOURCES) src/dump/dump_inference.sv
	PYTHONOPTIMIZE=$(NOASSERT) MODULE=test_inference $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $(SIM_VVP)
	! grep failure results.xml
	mv inference.vcd waveforms/ 2>/dev/null || true
	@echo "Opening GTKWave..."
	gtkwave waveforms/inference.vcd &

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