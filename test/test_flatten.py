import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import numpy as np

@cocotb.test()
async def test_flatten(dut):
    """Test flatten operation"""

    HEIGHT = 3
    WIDTH = 3
    MAPS = 2

    print("=" * 60)
    print("FLATTEN TEST STARTING")
    print("=" * 60)

    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())

    dut.rst_n.value = 0
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    img_filters = np.array([
        [[1,  2,  6],
         [0,  4,  8],
         [5,  3, 11]],
        [[1,  2,  6],
         [0,  4,  8],
         [5,  3, 11]]
    ], dtype=np.uint8)

    for i in range(len(img_filters)):
        img_flat = img_filters[i].flatten()
        for j in range(len(img_flat)):
            dut.cnnmaps[i * 9 + j].value = int(img_flat[j])

    dut.enable.value = 1

    await wait_for_completion(dut, timeout_cycles=100)

    print("Flatten completed!")
    print("=" * 60)


async def wait_for_completion(dut, timeout_cycles=1000):
    """Wait for the operation to complete"""
    cycle_count = 0
    while cycle_count < timeout_cycles:
        await RisingEdge(dut.clk)
        if dut.done.value == 1:
            print(f"Completed in {cycle_count} cycles")
            return
        cycle_count += 1

        if cycle_count % 10 == 0:
            print(f"Cycle {cycle_count}: done = {dut.done.value}")

    raise TimeoutError(f"Did not complete within {timeout_cycles} cycles")