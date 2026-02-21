import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import numpy as np

@cocotb.test()
async def test_neuron(dut):
    """Test neuron MAC + activation"""

    PREV_NEURONS = 10

    print("=" * 60)
    print("NEURON TEST STARTING")
    print("=" * 60)

    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())

    dut.rst_n.value = 0
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    prevlayer = np.array([6, 7, 8, 3, 4, -11, -12, 6, 7, 9], dtype=np.int32)
    weights = np.array([1, 1, 1, 0, 1, 1, 0, 0, 0, 1], dtype=np.int32)
    bias = 2

    for i in range(len(prevlayer)):
        dut.inputlayer[i].value = int(prevlayer[i])
        dut.weights[i].value = int(weights[i])

    dut.bias.value = bias
    dut.activation = 1

    dut.enable.value = 1

    await wait_for_completion(dut, timeout_cycles=100)

    print("Neuron computation completed!")
    print("=" * 60)


async def wait_for_completion(dut, timeout_cycles=1000):
    """Wait for the operation to complete"""
    cycle_count = 0
    while cycle_count < timeout_cycles:
        await RisingEdge(dut.clk)
        if dut.complete.value == 1:
            print(f"Completed in {cycle_count} cycles")
            return
        cycle_count += 1

        if cycle_count % 10 == 0:
            print(f"Cycle {cycle_count}: complete = {dut.complete.value}")

    raise TimeoutError(f"Did not complete within {timeout_cycles} cycles")