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
├── src/                        
│   ├── cnn.sv                  
│   ├── maxpool.sv              
│   ├── flatten.sv              
│   ├── neuron.sv               
│   ├── relu.sv                 
│   ├── division.sv             
│   ├── simple_divide.sv        
│   ├── cnn_weights_int8.sv     
│   └── dump/                   
├── test/
├── cocotb/                       
│   ├── test_cnn.py
│   ├── test_maxpool.py
│   ├── test_flatten.py
│   ├── test_neuron.py
│   ├── test_division.py
│   ├── test_simple_divide.py
│   └── test_counter.py
├── tcl/
│   ├── testbench.tcl.     # testbench for model-sim
├── on-chip/                     
│   ├── cnn.sv                  
│   ├── inference.sv            
│   ├── maxpool.sv              
│   ├── fixedpoint.sv           
│   ├── top_inference_de1.sv    
│   ├── fc_w_rom*.v             
│   ├── fc_w_neuron*.mif        
│   ├── output_files/           
│   └── *.qsf / *.qpf          
├── model/                      
├── Makefile                    
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
