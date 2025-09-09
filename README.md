# TALOS: Tensor Accelerated Logic for On-Chip Systems

### System Dependencies

```bash
# Ubuntu (WSL)
sudo apt update
sudo apt install -y python3 python3-pip python3-venv
sudo apt install -y iverilog gtkwave
sudo apt install -y build-essential
```

## Setup

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd <project-directory>
```

### 2. Create Python Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Python Dependencies
```bash
pip install --upgrade pip
pip install cocotb
```

### 4. Verify Installation
```bash
# Check Icarus Verilog
iverilog -V

# Check GTKWave
gtkwave --version
```

## Project Structure

```
.
├── src/
│   ├── counter.sv          # Simple Counter
│   └── dump_counter.sv     # VCD dump module
├── test/
│   └── test_counter.py     # Cocotb testbench for simple counter
├── waveforms/              # Generated waveform files
├── Makefile               # Build and test automation
├── .gitignore
└── README.md
```

## Usage

### Run Tests
```bash
# Activate virtual environment (if not already active)
source venv/bin/activate

# Run basic counter test
make test_counter

```

### View Waveforms
```bash
# Waveforms automatically open after tests, or manually:
make show_counter

# Or directly with GTKWave:
gtkwave waveforms/counter.vcd &
```
