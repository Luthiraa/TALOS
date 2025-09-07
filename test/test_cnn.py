# Import important libraries
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.binary import BinaryValue
import numpy as np
import random

# Simple convolution testbench
@cocotb.test()
async def test_convolution_simple(dut):
    """Simple convolution test - just run and observe"""
    
    # Parameters (chose a small image for easy debugging)
    IMG_HEIGHT = 28 
    IMG_WIDTH = 28
    KERNEL_SIZE = 3
    
    print("="*60)
    print("CONVOLUTION TEST STARTING")
    print("="*60)
    
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    
    # Reset
    print("Resetting DUT...")
    dut.rst_n.value = 0
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Create simple test image
    img_2d = np.random.randint(0, 256, size=(IMG_HEIGHT, IMG_WIDTH), dtype=np.int32)
    
    # Create simple test kernel
    kernel_2d = np.array([
        [3, 0, 6],
        [0, 2, 0],
        [1, 0, 5]
    ], dtype=np.int32)  # Changed to int32 to match your Verilog
    
    print("INPUT IMAGE:")
    print(img_2d)
    print("\nKERNEL:")
    print(kernel_2d)
    
    # Calculate expected output for comparison
    expected = numpy_convolution(img_2d, kernel_2d)
    print("\nEXPECTED OUTPUT:")
    print(expected)
    print(f"Expected output shape: {expected.shape}")
    
    # Convert to flattened format for DUT - flatten row by row
    img_flat = img_2d.flatten()  # This gives [1,1,0,1,0,1,1,0,0,1,0,1,1,0,1,1]
    kernel_flat = kernel_2d.flatten()  # This gives [3,0,6,0,2,0,1,0,5]
    
    print(f"\nFlattened image: {img_flat}")
    print(f"Flattened kernel: {kernel_flat}")
    
    # Apply inputs - assign each element individually
    for i in range(IMG_HEIGHT * IMG_WIDTH):
        dut.img[i].value = int(img_flat[i])
    
    for i in range(KERNEL_SIZE * KERNEL_SIZE):
        dut.kernel[i].value = int(kernel_flat[i])
    
    print("\nStarting convolution...")
    # Enable convolution
    dut.enable.value = 1
    
    # Wait for completion
    await wait_for_completion(dut, timeout_cycles=100000)
    
    print("Convolution completed!")
    
    # Read and display the output
    print("\nACTUAL OUTPUT:")
    output_size = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1)
    actual_output = []
    for i in range(output_size):
        val = dut.convimg[i].value
        actual_output.append(val)
        print(f"convimg[{i}] = {val}")
    

def numpy_convolution(img, kernel):
    """Reference convolution implementation using numpy"""
    img_h, img_w = img.shape
    ker_h, ker_w = kernel.shape
    
    out_h = img_h - ker_h + 1
    out_w = img_w - ker_w + 1
    
    output = np.zeros((out_h, out_w), dtype=np.int32)
    
    for i in range(out_h):
        for j in range(out_w):
            conv_sum = 0
            for ki in range(ker_h):
                for kj in range(ker_w):
                    conv_sum += int(img[i + ki, j + kj]) * int(kernel[ki, kj])
            output[i, j] = conv_sum
    
    return output

async def wait_for_completion(dut, timeout_cycles=10000):
    """Wait for the convolution to complete"""
    cycle_count = 0
    while cycle_count < timeout_cycles:
        await RisingEdge(dut.clk)
        if dut.complete.value == 1:
            print(f"Convolution completed in {cycle_count} cycles")
            return
        cycle_count += 1
    
    raise TimeoutError(f"Convolution did not complete within {timeout_cycles} cycles")