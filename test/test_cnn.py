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
    IMG_HEIGHT = 4 
    IMG_WIDTH = 4
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
    img_2d = np.array([
        [1, 1, 0, 1],
        [0, 1, 1, 0],
        [0, 1, 0, 1],
        [1, 0, 1, 1],
    ], dtype=np.uint8)
    
    # Create simple test kernel
    kernel_2d = np.array([
        [3, 0, 6],
        [0, 2, 0],
        [1, 0, 5]
    ], dtype=np.uint8)
    
    print("INPUT IMAGE:")
    print(img_2d)
    print("\nKERNEL:")
    print(kernel_2d)
    
    # Calculate expected output for comparison
    expected = numpy_convolution(img_2d, kernel_2d)
    print("\nEXPECTED OUTPUT:")
    print(expected)
    print(f"Expected output shape: {expected.shape}")
    
    # Convert to flattened format for DUT
    img_flat = flatten_image(img_2d)
    kernel_2d = kernel_2d.flatten()
    
    print(f"\nFlattened image bits: {len(str(img_flat))}")
    
    # Apply inputs
    dut.img.value = img_flat
    
    for i in range(len(kernel_2d)):
        dut.kernel[i].value = int(kernel_2d[i])
    
    print("\nStarting convolution...")
    # Enable convolution
    dut.enable.value = 1
    
    # Wait for completion
    await wait_for_completion(dut, timeout_cycles=100000)
    
    print("Convolution completed!")
    print("Check GTKWave for signal analysis.")
    print("="*60)

def flatten_image(img_2d):
    img_height, img_width = img_2d.shape
    
    bit_string = ""
    # Process in normal order but APPEND
    for i in range(img_height):
        for j in range(img_width):
            pixel_bits = format(int(img_2d[i, j]), '01b')
            bit_string = pixel_bits + bit_string  # APPEND
    
    return BinaryValue(bit_string)

# def flatten_kernel(kernel_2d):
#     """Convert 2D kernel to flattened bit vector"""
#     kernel_size = kernel_2d.shape[0]
#     total_bits = kernel_size * kernel_size
    
#     bit_string = ""
#     # Pack row by row, MSB first for each element
#     for i in range(kernel_size):
#         for j in range(kernel_size):
#             # Handle signed values
#             val = int(kernel_2d[i, j])
#             if val < 0:
#                 val = val + 256  # Two's complement for 8-bit
#             kernel_bits = format(val, '08b')
#             bit_string = kernel_bits + bit_string  # Prepend for little-endian
    
#     return BinaryValue(bit_string)


def numpy_convolution(img, kernel):
    """Reference convolution implementation using numpy"""
    img_h, img_w = img.shape
    ker_h, ker_w = kernel.shape
    
    out_h = img_h - ker_h + 1
    out_w = img_w - ker_w + 1
    
    output = np.zeros((out_h, out_w), dtype=np.int16)
    
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