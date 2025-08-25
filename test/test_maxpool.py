import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.binary import BinaryValue
import numpy as np

@cocotb.test()
async def test_maxpool(dut):
    """Test max pooling operation"""
    
    # Parameters
    IMG_HEIGHT = 4
    IMG_WIDTH = 4
    KERNEL_SIZE = 2  # For 2x2 max pooling
    
    print("="*60)
    print("MAX POOLING TEST STARTING")
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
    
    # Create test image
    img_2d = np.array([
        [1,  2,  6,  1],
        [0,  4,  8,  9],
        [5,  3, 11, 12],
        [9, 10,  1, 13],
    ], dtype=np.uint8)
    
    print("INPUT IMAGE:")
    print(img_2d)
    
    # Convert to format expected by DUT (array of individual pixels)
    img_flat = img_2d.flatten()
    print(f"Flattened image: {img_flat}")
    
    # Set input values - assign each pixel individually
    for i in range(len(img_flat)):
        dut.img[i].value = int(img_flat[i])
    
    print("\nStarting max pooling...")
    # Enable operation
    dut.enable.value = 1
    
    # Wait for completion
    await wait_for_completion(dut, timeout_cycles=100)
    
    print("Max pooling completed!")
    
    # Read results
    out_height = IMG_HEIGHT // KERNEL_SIZE
    out_width = IMG_WIDTH // KERNEL_SIZE
    total_outputs = out_height * out_width
    
    print(f"\nOutput dimensions: {out_height}x{out_width}")
    
    # Extract output values
    output_values = []
    for i in range(total_outputs):
        val = dut.convimg[i].value
        output_values.append(int(val))
        print(f"pooled_img[{i}] = {val}")
    
    # Reshape to 2D for easier viewing
    output_2d = np.array(output_values).reshape(out_height, out_width)
    print(f"\nOutput 2D array:")
    print(output_2d)
    
    # Verify against expected results
    expected = numpy_maxpool(img_2d, KERNEL_SIZE)
    print(f"\nExpected result:")
    print(expected)
    
    # Compare results
    if np.array_equal(output_2d, expected):
        print("✓ Test PASSED - Output matches expected result!")
    else:
        print("✗ Test FAILED - Output does not match expected result!")
        print("Differences:")
        diff = output_2d - expected
        print(diff)
    
    print("="*60)

def numpy_maxpool(img, kernel_size):
    """Reference max pooling implementation using numpy"""
    img_h, img_w = img.shape
    out_h = img_h // kernel_size
    out_w = img_w // kernel_size
    
    output = np.zeros((out_h, out_w), dtype=np.uint8)
    
    for i in range(out_h):
        for j in range(out_w):
            # Extract the region
            region = img[i*kernel_size:(i+1)*kernel_size, 
                        j*kernel_size:(j+1)*kernel_size]
            # Find maximum in the region
            output[i, j] = np.max(region)
    
    return output

async def wait_for_completion(dut, timeout_cycles=1000):
    """Wait for the operation to complete"""
    cycle_count = 0
    while cycle_count < timeout_cycles:
        await RisingEdge(dut.clk)
        if dut.complete.value == 1:
            print(f"Operation completed in {cycle_count} cycles")
            return
        cycle_count += 1
        
        # Print progress every 10 cycles for debugging
        if cycle_count % 10 == 0:
            print(f"Cycle {cycle_count}: complete = {dut.complete.value}")
    
    raise TimeoutError(f"Operation did not complete within {timeout_cycles} cycles")

def print_step_by_step_maxpool(img_2d, kernel_size):
    """Print detailed step-by-step max pooling for manual verification"""
    img_h, img_w = img_2d.shape
    out_h = img_h // kernel_size
    out_w = img_w // kernel_size
    
    print("\nSTEP-BY-STEP MAX POOLING:")
    print("-" * 40)
    
    for i in range(out_h):
        for j in range(out_w):
            print(f"\nOutput position [{i}][{j}]:")
            region = img_2d[i*kernel_size:(i+1)*kernel_size, 
                           j*kernel_size:(j+1)*kernel_size]
            print(f"  Region:")
            print(f"  {region}")
            max_val = np.max(region)
            print(f"  Maximum = {max_val}")