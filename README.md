# TALOS: Tensor Accelerated Logic for On-Chip Systems

A hardware CNN accelerator that performs MNIST digit classification, implemented in SystemVerilog and deployed on the DE1-SoC FPGA.

## Architecture

TALOS implements a minimal CNN pipeline in hardware:

1. **Convolution** — 4 filters × 3×3 kernels with Q16.16 fixed-point arithmetic
2. **Max Pooling** — 2×2 stride-2 downsampling
3. **Flatten** — Reshapes feature maps into a 1D vector
4. **Fully Connected** — 10-neuron output layer with ReLU activation

## Repository Structure

```
.
├── src/                        # RTL modules (simulation/cocotb)
│   ├── cnn.sv                  # Convolution engine
│   ├── maxpool.sv              # Max pooling
│   ├── flatten.sv              # Flatten layer
│   ├── neuron.sv               # FC neuron with MAC + activation
│   ├── relu.sv                 # ReLU activation
│   ├── division.sv             # Multi-cycle integer divider
│   ├── simple_divide.sv        # Single-cycle divider
│   ├── cnn_weights_int8.sv     # Quantized weight ROM
│   └── dump/                   # VCD dump modules
├── test/                       # Cocotb testbenches
│   ├── test_cnn.py
│   ├── test_maxpool.py
│   ├── test_flatten.py
│   ├── test_neuron.py
│   ├── test_division.py
│   ├── test_simple_divide.py
│   └── test_counter.py
├── on-chip/                    # DE1-SoC FPGA implementation (Quartus)
│   ├── cnn.sv                  # On-chip convolution (fixed-point multiply)
│   ├── inference.sv            # Full inference pipeline
│   ├── maxpool.sv              # On-chip max pooling
│   ├── fixedpoint.sv           # Q16.16 fixed-point library
│   ├── top_inference_de1.sv    # DE1-SoC top-level wrapper
│   ├── fc_w_rom*.v             # FC weight ROMs
│   ├── fc_w_neuron*.mif        # Weight memory init files
│   ├── output_files/           # Quartus compilation output
│   └── *.qsf / *.qpf          # Quartus project files
├── model/                      # Python model & weight quantization
├── Makefile                    # Build and test automation
└── README.md
```

## Setup

### Dependencies

```bash
# Ubuntu / WSL
sudo apt update
sudo apt install -y python3 python3-pip python3-venv iverilog gtkwave build-essential
```

### Install

```bash
git clone https://github.com/Luthiraa/TALOS.git
cd TALOS
python3 -m venv venv
source venv/bin/activate
pip install cocotb numpy
```

## Running Tests

```bash
source venv/bin/activate

make test_cnn
make test_maxpool
make test_flatten
make test_neuron
make test_division
make test_simple_divide
make test_counter
```

Waveforms are saved to `waveforms/` and auto-opened in GTKWave.

## FPGA Deployment

The `on-chip/` directory contains the full Quartus project targeting the DE1-SoC (Cyclone V). Open `on-chip/top_inference_de1.qpf` in Quartus Prime and compile. The design runs at 10 MHz via an on-chip PLL.

**Board I/O:**
- `SW[0]` — Enable inference
- `SW[1]` — Reset (active low)
- `LEDR` — Output neuron values
- `HEX0–HEX5` — Output display
