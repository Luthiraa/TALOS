import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def counter_basic_test(dut):
    """Test counter basic functionality"""
    
    clock = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(clock.start())
    
    dut.rst_n.value = 0
    dut.enable.value = 0
    

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    

    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    await Timer(100, units="ps")
    

    assert int(dut.count.value) == 0, f"Counter not reset properly: {dut.count.value}"
    

    dut.enable.value = 1
    

    for i in range(10):
        await RisingEdge(dut.clk)
        await Timer(100, units="ps")
        expected = (i + 1) % 256
        actual = int(dut.count.value)
        assert actual == expected, f"Count mismatch at step {i+1}: expected {expected}, got {actual}"
    

    dut.enable.value = 0
    await Timer(100, units="ps")
    current_count = int(dut.count.value)
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(100, units="ps")
    

    final_count = int(dut.count.value)
    assert final_count == current_count, f"Counter didn't stop when disabled: was {current_count}, now {final_count}"

@cocotb.test()
async def counter_overflow_test(dut):
    """Test counter overflow"""
    
    clock = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(clock.start())
    

    dut.rst_n.value = 0
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    

    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    

    for i in range(254):
        await RisingEdge(dut.clk)
    
    await Timer(100, units="ps")
    assert int(dut.count.value) == 255, f"Counter should be at 255, got {dut.count.value}"
    

    await RisingEdge(dut.clk)
    await Timer(100, units="ps")
    

    assert int(dut.count.value) == 0, f"Overflow not handled correctly: expected 0, got {dut.count.value}"