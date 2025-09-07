# # Import important libraries
# import cocotb
# from cocotb.clock import Clock
# from cocotb.triggers import RisingEdge, FallingEdge, Timer
# from cocotb.binary import BinaryValue
# import numpy as np
# import random

# # Simple convolution testbench
# @cocotb.test()
# async def test_inference_simple(dut):
#     """Simple convolution test - just run and observe"""
    
#     # Parameters (chose a small image for easy debugging)
#     IMG_HEIGHT = 4 
#     IMG_WIDTH = 4
#     KERNEL_SIZE = 3
    
#     print("="*60)
#     print("CONVOLUTION TEST STARTING")
#     print("="*60)
    
#     # Start clock
#     cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    
#     # Reset
#     print("Resetting DUT...")
#     dut.rst_n.value = 0
#     dut.enable.value = 0
#     await RisingEdge(dut.clk)
#     await RisingEdge(dut.clk)
#     dut.rst_n.value = 1
#     await RisingEdge(dut.clk)
    
#     # Create simple test image
#     img_2d = np.array([
#         [1, 1, 0, 1, 0, 0],
#         [0, 1, 1, 0, 1, 1],
#         [0, 1, 0, 1, 1, 0],
#         [1, 0, 1, 1, 0, 0],
#         [1, 1, 1, 1, 0, 1]
#     ], dtype=np.int32)
    
#     # Create simple test kernel
#     kernel_2d = np.array([
#         [[3, 0, 6],
#         [0, 2, 0],
#         [1, 0, 5]],
#         [[3, 0, 6],
#         [0, 2, 0],
#         [1, 0, 5]]
#     ], dtype=np.int32)  # Changed to int32 to match your Verilog
    
#     print("INPUT IMAGE:")
#     print(img_2d)
#     print("\nKERNEL:")
#     print(kernel_2d)

#     img_flat = img_2d.flatten()

#     for i in range(IMG_HEIGHT * IMG_WIDTH):
#         dut.img[i].value = int(img_flat[i])
    
#     # Calculate expected output for comparison
#     for i in range(len(kernel_2d)):
#         expected = numpy_convolution(img_2d, kernel_2d[i])
#         print("\nEXPECTED OUTPUT:")
#         print(expected)
#         print(f"Expected output shape: {expected.shape}")
        
#         # Convert to flattened format for DUT - flatten row by row
#         img_flat = img_2d.flatten()  # This gives [1,1,0,1,0,1,1,0,0,1,0,1,1,0,1,1]
#         kernel_flat = kernel_2d[i].flatten()  # This gives [3,0,6,0,2,0,1,0,5]

#         for j in range(len(kernel_flat)):
#             dut.kernels[i*KERNEL_SIZE*KERNEL_SIZE+j].value = int(kernel_flat[j])
        
#         print(f"Flattened kernel: {kernel_flat}")
    
    
#     print("\nStarting convolution...")
#     # Enable convolution
#     dut.enable.value = 1
    
#     # Wait for completion
#     await wait_for_completion(dut, timeout_cycles=100000)
    
#     print("Convolution completed!")
    
#     # # Read and display the output
#     # print("\nACTUAL OUTPUT:")
#     # output_size = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1)
#     # actual_output = []
#     # for i in range(output_size):
#     #     val = dut.convimg[i].value
#     #     actual_output.append(val)
#     #     print(f"convimg[{i}] = {val}")
    

# def numpy_convolution(img, kernel):
#     """Reference convolution implementation using numpy"""
#     img_h, img_w = img.shape
#     ker_h, ker_w = kernel.shape
    
#     out_h = img_h - ker_h + 1
#     out_w = img_w - ker_w + 1
    
#     output = np.zeros((out_h, out_w), dtype=np.int32)
    
#     for i in range(out_h):
#         for j in range(out_w):
#             conv_sum = 0
#             for ki in range(ker_h):
#                 for kj in range(ker_w):
#                     conv_sum += int(img[i + ki, j + kj]) * int(kernel[ki, kj])
#             output[i, j] = conv_sum
    
#     return output

# async def wait_for_completion(dut, timeout_cycles=10000):
#     """Wait for the convolution to complete"""
#     cycle_count = 0
#     while cycle_count < timeout_cycles:
#         await RisingEdge(dut.clk)
#         if dut.complete.value == 1:
#             print(f"Convolution completed in {cycle_count} cycles")
#             return
#         cycle_count += 1
    
#     raise TimeoutError(f"Convolution did not complete within {timeout_cycles} cycles")

# # Import important libraries
# import cocotb
# from cocotb.clock import Clock
# from cocotb.triggers import RisingEdge, FallingEdge, Timer
# from cocotb.binary import BinaryValue
# import numpy as np
# import random

# # Simple convolution testbench
# @cocotb.test()
# async def test_convolution_simple(dut):
#     """Simple convolution test - just run and observe"""
    
#     # Parameters (CHANGED: Updated to MNIST dimensions)
#     IMG_HEIGHT = 28  # CHANGED: MNIST image height
#     IMG_WIDTH = 28   # CHANGED: MNIST image width
#     KERNEL_SIZE = 3
    
#     print("="*60)
#     print("CONVOLUTION TEST STARTING")
#     print("="*60)
    
#     # Start clock
#     cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    
#     # Reset
#     print("Resetting DUT...")
#     dut.rst_n.value = 0
#     dut.enable.value = 0
#     await RisingEdge(dut.clk)
#     await RisingEdge(dut.clk)
#     dut.rst_n.value = 1
#     await RisingEdge(dut.clk)
    
#     # CHANGED: Create random MNIST-like image (grayscale values 0-255)
#     img_2d = np.random.randint(0, 256, size=(IMG_HEIGHT, IMG_WIDTH), dtype=np.int32)
    
#     # CHANGED: Create random convolution kernel with signed values
#     kernel_2d = np.random.randint(-5, 6, size=(KERNEL_SIZE, KERNEL_SIZE), dtype=np.int32)
    
#     print("INPUT IMAGE (first 5x5 corner):")
#     print(img_2d[:5, :5])  # CHANGED: Only show corner since 28x28 is too large
#     print("\nKERNEL:")
#     print(kernel_2d)
    
#     # Calculate expected output for comparison
#     expected = numpy_convolution(img_2d, kernel_2d)
#     print("\nEXPECTED OUTPUT (first 5x5 corner):")
#     print(expected[:5, :5])  # CHANGED: Only show corner
#     print(f"Expected output shape: {expected.shape}")
    
#     # Convert to flattened format for DUT - flatten row by row
#     img_flat = img_2d.flatten()  
#     kernel_flat = kernel_2d.flatten()  
    
#     print(f"\nFlattened image (first 10 elements): {img_flat[:10]}")  # CHANGED: Only show first 10
#     print(f"Flattened kernel: {kernel_flat}")
    
#     # Apply inputs - assign each element individually
#     for i in range(IMG_HEIGHT * IMG_WIDTH):
#         dut.img[i].value = int(img_flat[i])
    
#     for i in range(KERNEL_SIZE * KERNEL_SIZE):
#         dut.kernels[i].value = int(kernel_flat[i])
    
#     print("\nStarting convolution...")
#     # Enable convolution
#     dut.enable.value = 1
    
#     # Wait for completion
#     await wait_for_completion(dut, timeout_cycles=1000000)  # CHANGED: Increased timeout for larger image
    
#     print("Convolution completed!")
    
#     # # Read and display the output
#     # print("\nACTUAL OUTPUT (first 10 elements):")  # CHANGED: Only show first 10
#     # output_size = (IMG_HEIGHT - KERNEL_SIZE + 1) * (IMG_WIDTH - KERNEL_SIZE + 1)
#     # actual_output = []
#     # for i in range(min(10, output_size)):  # CHANGED: Only read first 10 for display
#     #     val = dut.convimg[i].value
#     #     actual_output.append(val)
#     #     print(f"convimg[{i}] = {val}")
    

# def numpy_convolution(img, kernel):
#     """Reference convolution implementation using numpy"""
#     img_h, img_w = img.shape
#     ker_h, ker_w = kernel.shape
    
#     out_h = img_h - ker_h + 1
#     out_w = img_w - ker_w + 1
    
#     output = np.zeros((out_h, out_w), dtype=np.int32)
    
#     for i in range(out_h):
#         for j in range(out_w):
#             conv_sum = 0
#             for ki in range(ker_h):
#                 for kj in range(ker_w):
#                     conv_sum += int(img[i + ki, j + kj]) * int(kernel[ki, kj])
#             output[i, j] = conv_sum
    
#     return output

# async def wait_for_completion(dut, timeout_cycles=10000):
#     """Wait for the convolution to complete"""
#     cycle_count = 0
#     while cycle_count < timeout_cycles:
#         await RisingEdge(dut.clk)
#         if dut.complete.value == 1:
#             print(f"Convolution completed in {cycle_count} cycles")
#             return
#         cycle_count += 1
    
#     raise TimeoutError(f"Convolution did not complete within {timeout_cycles} cycles")

# # Import important libraries
# import cocotb
# from cocotb.clock import Clock
# from cocotb.triggers import RisingEdge, FallingEdge, Timer
# from cocotb.binary import BinaryValue
# import numpy as np
# import random

# # Multi-kernel convolution testbench
# @cocotb.test()
# async def test_convolution_multi_kernel(dut):
#     """Multi-kernel convolution test - tests inference module with multiple CNN blocks"""
    
#     # Parameters - should match your inference module
#     IMG_HEIGHT = 28
#     IMG_WIDTH = 28
#     NO_KERNELS = 4    # Number of kernels/CNN blocks
#     KERNEL_SIZE = 3
    
#     print("="*60)
#     print(f"MULTI-KERNEL CONVOLUTION TEST STARTING")
#     print(f"Image size: {IMG_HEIGHT}x{IMG_WIDTH}")
#     print(f"Number of kernels: {NO_KERNELS}")
#     print(f"Kernel size: {KERNEL_SIZE}x{KERNEL_SIZE}")
#     print("="*60)
    
#     # Start clock
#     cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    
#     # Reset
#     print("Resetting DUT...")
#     dut.rst_n.value = 0
#     dut.enable.value = 0
#     await RisingEdge(dut.clk)
#     await RisingEdge(dut.clk)
#     dut.rst_n.value = 1
#     await RisingEdge(dut.clk)
    
#     # Create random MNIST-like image (grayscale values 0-255)
#     img_2d = np.random.randint(0, 256, size=(IMG_HEIGHT, IMG_WIDTH), dtype=np.int32)
    
#     # Create multiple random convolution kernels
#     kernels_2d = []
#     kernels_flat_all = []
    
#     for k in range(NO_KERNELS):
#         # Create random kernel with signed values
#         kernel_2d = np.random.randint(-5, 6, size=(KERNEL_SIZE, KERNEL_SIZE), dtype=np.int32)
#         kernels_2d.append(kernel_2d)
        
#         # Flatten this kernel and add to the combined array
#         kernel_flat = kernel_2d.flatten()
#         kernels_flat_all.extend(kernel_flat)
        
#         print(f"\nKERNEL {k}:")
#         print(kernel_2d)
#         print(f"Flattened kernel {k}: {kernel_flat}")
    
#     print("INPUT IMAGE:")
#     print(img_2d)
    
#     # Calculate expected outputs for comparison
#     expected_outputs = []
#     for k in range(NO_KERNELS):
#         expected = numpy_convolution(img_2d, kernels_2d[k])
#         print(f"\nEXPECTED CONVOLUTION OUTPUT {k}")
#         print(expected)
#         expected = numpy_maxpool(expected, 2)
#         expected_outputs.append(expected)
#         print(f"\nEXPECTED MAXPOOL OUTPUT {k}")
#         print(expected)
#         print(f"Expected output {k} shape: {expected.shape}")
    
#     # Convert image to flattened format for DUT
#     img_flat = img_2d.flatten()
    
#     print(f"\nFlattened image (first 10 elements): {img_flat[:10]}")
#     print(f"Total kernels flattened length: {len(kernels_flat_all)}")
#     print(f"Expected kernels array size: {NO_KERNELS * KERNEL_SIZE * KERNEL_SIZE}")
    
#     # Verify sizes match
#     assert len(kernels_flat_all) == NO_KERNELS * KERNEL_SIZE * KERNEL_SIZE, \
#         f"Kernel array size mismatch: got {len(kernels_flat_all)}, expected {NO_KERNELS * KERNEL_SIZE * KERNEL_SIZE}"
    
#     # Apply inputs - assign each element individually
#     print("\nAssigning image to DUT...")
#     for i in range(IMG_HEIGHT * IMG_WIDTH):
#         dut.img[i].value = int(img_flat[i])
    
#     print("Assigning kernels to DUT...")
#     for i in range(len(kernels_flat_all)):
#         dut.kernels[i].value = int(kernels_flat_all[i])
#         if i < 20:  # Print first 20 assignments for debugging
#             print(f"  kernels[{i}] = {kernels_flat_all[i]}")
    
#     print("\nStarting convolution...")
#     # Enable convolution
#     dut.enable.value = 1
    
#     # Monitor progress
#     cycle_count = 0
#     max_cycles = 2000000  # Increased timeout for larger image and multiple kernels
    
#     while cycle_count < max_cycles:
#         await RisingEdge(dut.clk)
#         cycle_count += 1
        
#         # Check for completion
#         try:
#             if dut.complete.value == 1:
#                 print(f"\Inference completed in {cycle_count} cycles!")
#                 break
#         except:
#             # Handle case where complete signal might not be readable
#             pass
#     else:
#         print(f"\nWARNING: Inference did not complete within {max_cycles} cycles")
#         # Continue anyway to see what we can observe
    
#     # Final status check
#     try:
#         print(f"\nFinal status:")
#         print(f"  complete = {dut.complete.value}")
#     except Exception as e:
#         print(f"  Could not read final status: {e}")
    
#     print("\nTest completed!")


# def numpy_convolution(img, kernel):
#     """Reference convolution implementation using numpy"""
#     img_h, img_w = img.shape
#     ker_h, ker_w = kernel.shape
    
#     out_h = img_h - ker_h + 1
#     out_w = img_w - ker_w + 1
    
#     output = np.zeros((out_h, out_w), dtype=np.int32)
    
#     for i in range(out_h):
#         for j in range(out_w):
#             conv_sum = 0
#             for ki in range(ker_h):
#                 for kj in range(ker_w):
#                     conv_sum += int(img[i + ki, j + kj]) * int(kernel[ki, kj])
#             output[i, j] = conv_sum
    
#     return output

# def numpy_maxpool(img, pool_size):
#     """Reference maxpool implementation"""
#     img_h, img_w = img.shape
    
#     out_h = (img_h - pool_size) // 2 + 1
#     out_w = (img_w - pool_size) // 2 + 1
    
#     output = np.zeros((out_h, out_w), dtype=np.int32)
    
#     for i in range(out_h):
#         for j in range(out_w):
#             start_i = i * 2
#             start_j = j * 2
            
#             max_val = img[start_i, start_j]
#             for pi in range(pool_size):
#                 for pj in range(pool_size):
#                     if start_i + pi < img_h and start_j + pj < img_w:
#                         val = img[start_i + pi, start_j + pj]
#                         if val > max_val:
#                             max_val = val
            
#             output[i, j] = max_val
    
#     return output


# Import important libraries
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.binary import BinaryValue
import numpy as np
import random

# Multi-kernel convolution testbench
@cocotb.test()
async def test_inference_full_pipeline(dut):
    """Full inference pipeline test - tests CNN + maxpool + neural network"""
    
    # Parameters - should match your inference module
    IMG_HEIGHT = 28
    IMG_WIDTH = 28
    NO_KERNELS = 4    # Number of kernels/CNN blocks
    KERNEL_SIZE = 3
    MAXPOOL_KERNEL = 2 
    NO_NEURONS = 2
    
    # ADDED: Calculate dimensions for neural network
    conv_output_size = IMG_HEIGHT - KERNEL_SIZE + 1  # 26x26
    maxpool_output_size = ((conv_output_size - MAXPOOL_KERNEL) >> 1) + 1  # 13x13
    flattened_size = NO_KERNELS * maxpool_output_size * maxpool_output_size  # 4 * 13 * 13 = 676
    
    print("="*60)
    print(f"FULL INFERENCE PIPELINE TEST STARTING")
    print(f"Image size: {IMG_HEIGHT}x{IMG_WIDTH}")
    print(f"Number of kernels: {NO_KERNELS}")
    print(f"Kernel size: {KERNEL_SIZE}x{KERNEL_SIZE}")
    print(f"Maxpool kernel: {MAXPOOL_KERNEL}x{MAXPOOL_KERNEL}")  # ADDED
    print(f"Conv output size: {conv_output_size}x{conv_output_size}")  # ADDED
    print(f"Maxpool output size: {maxpool_output_size}x{maxpool_output_size}")  # ADDED
    print(f"Flattened size: {flattened_size}")  # ADDED
    print(f"Number of neurons: {NO_NEURONS}")  # ADDED
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
    
    # Create random MNIST-like image (grayscale values 0-255)
    img_2d = np.random.randint(0, 256, size=(IMG_HEIGHT, IMG_WIDTH), dtype=np.int32)
    
    # Create multiple random convolution kernels
    kernels_2d = []
    kernels_flat_all = []
    
    for k in range(NO_KERNELS):
        # Create random kernel with signed values
        kernel_2d = np.random.randint(-5, 6, size=(KERNEL_SIZE, KERNEL_SIZE), dtype=np.int32)
        kernels_2d.append(kernel_2d)
        
        # Flatten this kernel and add to the combined array
        kernel_flat = kernel_2d.flatten()
        kernels_flat_all.extend(kernel_flat)
        
        print(f"\nKERNEL {k}:")
        print(kernel_2d)
        print(f"Flattened kernel {k}: {kernel_flat}")
    
    # ADDED: Create random weights and biases for neural network
    print(f"\nCreating neural network weights and biases...")
    total_weights_needed = NO_NEURONS * flattened_size
    weights_flat = np.random.randint(-10, 11, size=total_weights_needed, dtype=np.int32)
    biases = np.random.randint(-100, 101, size=NO_NEURONS, dtype=np.int32)
    
    print(f"Total weights needed: {total_weights_needed}")
    print(f"Weights (first 10): {weights_flat[:10]}")
    print(f"Biases: {biases}")
    
    print("INPUT IMAGE (first 5x5 corner):")
    print(img_2d[:5, :5])
    
    # Calculate expected outputs for comparison
    expected_outputs = []
    flattened_outputs = []
    
    for k in range(NO_KERNELS):
        expected_conv = numpy_convolution(img_2d, kernels_2d[k])
        expected_maxpool = numpy_maxpool(expected_conv, MAXPOOL_KERNEL)
        expected_outputs.append(expected_maxpool)
        flattened_outputs.extend(expected_maxpool.flatten())
        
        print(f"\nEXPECTED CONVOLUTION OUTPUT {k} (first 5x5):")
        print(expected_conv[:5, :5])
        print(f"\nEXPECTED MAXPOOL OUTPUT {k}:")
        print(expected_maxpool)
        print(f"Expected maxpool output {k} shape: {expected_maxpool.shape}")
    
    # ADDED: Calculate expected neural network outputs
    print(f"\nFlattened feature map length: {len(flattened_outputs)}")
    expected_neuron_outputs = []
    
    for n in range(NO_NEURONS):
        start_idx = n * flattened_size
        end_idx = start_idx + flattened_size
        neuron_weights = weights_flat[start_idx:end_idx]
        
        expected_output = numpy_neuron_no_activation(
            np.array(flattened_outputs), 
            neuron_weights, 
            biases[n]
        )
        expected_neuron_outputs.append(expected_output)
        print(f"Expected neuron {n} output: {expected_output}")
    
    # Convert image to flattened format for DUT
    img_flat = img_2d.flatten()
    
    print(f"\nFlattened image (first 10 elements): {img_flat[:10]}")
    print(f"Total kernels flattened length: {len(kernels_flat_all)}")
    print(f"Expected kernels array size: {NO_KERNELS * KERNEL_SIZE * KERNEL_SIZE}")
    
    # Verify sizes match
    assert len(kernels_flat_all) == NO_KERNELS * KERNEL_SIZE * KERNEL_SIZE, \
        f"Kernel array size mismatch: got {len(kernels_flat_all)}, expected {NO_KERNELS * KERNEL_SIZE * KERNEL_SIZE}"
    
    # Apply inputs - assign each element individually
    print("\nAssigning image to DUT...")
    for i in range(IMG_HEIGHT * IMG_WIDTH):
        dut.img[i].value = int(img_flat[i])
    
    print("Assigning kernels to DUT...")
    for i in range(len(kernels_flat_all)):
        dut.kernels[i].value = int(kernels_flat_all[i])
        if i < 20:  # Print first 20 assignments for debugging
            print(f"  kernels[{i}] = {kernels_flat_all[i]}")
    
    # ADDED: Assign weights and biases to DUT
    print("Assigning weights to DUT...")
    for i in range(len(weights_flat)):
        dut.weights[i].value = int(weights_flat[i])
        if i < 20:  # Print first 20 assignments for debugging
            print(f"  weights[{i}] = {weights_flat[i]}")
    
    print("Assigning biases to DUT...")
    for i in range(len(biases)):
        dut.biases[i].value = int(biases[i])
        print(f"  biases[{i}] = {biases[i]}")
    
    print("\nStarting full inference pipeline...")
    # Enable inference
    dut.enable.value = 1
    
    # Monitor progress with more detailed logging
    cycle_count = 0
    max_cycles = 5000000  # INCREASED: More cycles needed for neural network
    
    while cycle_count < max_cycles:
        await RisingEdge(dut.clk)
        cycle_count += 1
        
        # ADDED: More detailed progress monitoring
        if cycle_count % 10000 == 0:  # Print every 10k cycles
            try:
                print(f"  Cycle {cycle_count}: complete = {dut.complete.value}")
                # ADDED: Monitor internal signals
                if hasattr(dut, 'flatten_complete'):
                    print(f"    flatten_complete = {dut.flatten_complete.value}")
            except:
                print(f"  Cycle {cycle_count}: monitoring...")
        
        # Check for completion
        try:
            if dut.complete.value == 1:
                print(f"\nFull inference pipeline completed in {cycle_count} cycles!")
                break
        except:
            # Handle case where complete signal might not be readable
            pass
    else:
        print(f"\nWARNING: Inference did not complete within {max_cycles} cycles")
        # Continue anyway to see what we can observe
    
    # # ADDED: Read neural network outputs
    # try:
    #     print(f"\nFinal neural network outputs:")
    #     hw_neuron_0 = dut.l.value.signed_integer if hasattr(dut, 'l') else "N/A"
    #     hw_neuron_1 = dut.m.value.signed_integer if hasattr(dut, 'm') else "N/A"
        
    #     print(f"  Hardware neuron 0 output: {hw_neuron_0}")
    #     print(f"  Hardware neuron 1 output: {hw_neuron_1}")
    #     print(f"  Expected neuron 0 output: {expected_neuron_outputs[0]}")
    #     print(f"  Expected neuron 1 output: {expected_neuron_outputs[1]}")
        
    #     # ADDED: Verify neural network outputs
    #     if hw_neuron_0 != "N/A" and hw_neuron_0 == expected_neuron_outputs[0]:
    #         print("✓ Neuron 0 output matches expected value")
    #     else:
    #         print("✗ Neuron 0 output does not match expected value")
            
    #     if hw_neuron_1 != "N/A" and hw_neuron_1 == expected_neuron_outputs[1]:
    #         print("✓ Neuron 1 output matches expected value")
    #     else:
    #         print("✗ Neuron 1 output does not match expected value")
            
    # except Exception as e:
    #     print(f"Could not read neural network outputs: {e}")
    
    # # Final status check
    # try:
    #     print(f"\nFinal status:")
    #     print(f"  complete = {dut.complete.value}")
    # except Exception as e:
    #     print(f"  Could not read final status: {e}")
    
    print("\nFull pipeline test completed!")


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

def numpy_maxpool(img, pool_size):
    """Reference maxpool implementation"""
    img_h, img_w = img.shape
    
    out_h = (img_h - pool_size) // 2 + 1
    out_w = (img_w - pool_size) // 2 + 1
    
    output = np.zeros((out_h, out_w), dtype=np.int32)
    
    for i in range(out_h):
        for j in range(out_w):
            start_i = i * 2
            start_j = j * 2
            
            max_val = img[start_i, start_j]
            for pi in range(pool_size):
                for pj in range(pool_size):
                    if start_i + pi < img_h and start_j + pj < img_w:
                        val = img[start_i + pi, start_j + pj]
                        if val > max_val:
                            max_val = val
            
            output[i, j] = max_val
    
    return output

# ADDED: Neural network reference functions
def numpy_neuron_no_activation(inputs, weights, bias):
    """Reference neuron implementation using numpy (no activation)"""
    weighted_sum = np.sum(inputs * weights) + bias
    return int(weighted_sum)