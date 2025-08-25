import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
import random

async def setup_dut(dut):
    """Setup DUT with clock and reset"""
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")  # 10ns period = 100MHz
    cocotb.start_soon(clock.start())
    
    # Initialize inputs
    dut.rst_n.value = 0
    dut.enable.value = 0
    dut.dividend.value = 0
    dut.divisor.value = 0
    
    # Reset pulse
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

@cocotb.test()
async def simple_divide_basic_test(dut):
    """Test basic division functionality"""
    await setup_dut(dut)
    
    # Test Case 1: Simple division
    dut.dividend.value = 20
    dut.divisor.value = 4
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 5, f"20/4 quotient: expected 5, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 0, f"20/4 remainder: expected 0, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"20/4 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"
    
    # Test Case 2: Division with remainder
    dut.dividend.value = 21
    dut.divisor.value = 4
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 5, f"21/4 quotient: expected 5, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 1, f"21/4 remainder: expected 1, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"21/4 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"

@cocotb.test()
async def simple_divide_by_zero_test(dut):
    """Test divide by zero handling"""
    await setup_dut(dut)
    
    dut.dividend.value = 100
    dut.divisor.value = 0
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 0, f"100/0 quotient: expected 0, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 0, f"100/0 remainder: expected 0, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 1, f"100/0 divide_by_zero: expected 1, got {dut.divide_by_zero.value}"

@cocotb.test()
async def simple_divide_edge_cases_test(dut):
    """Test edge cases"""
    await setup_dut(dut)
    
    # Test Case 1: Division resulting in 0
    dut.dividend.value = 3
    dut.divisor.value = 5
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 0, f"3/5 quotient: expected 0, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 3, f"3/5 remainder: expected 3, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"3/5 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"
    
    # Test Case 2: Zero divided by something
    dut.dividend.value = 0
    dut.divisor.value = 5
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 0, f"0/5 quotient: expected 0, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 0, f"0/5 remainder: expected 0, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"0/5 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"
    
    # Test Case 3: Division by 1
    dut.dividend.value = 42
    dut.divisor.value = 1
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 42, f"42/1 quotient: expected 42, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 0, f"42/1 remainder: expected 0, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"42/1 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"
    
    # Test Case 4: Self division
    dut.dividend.value = 25
    dut.divisor.value = 25
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 1, f"25/25 quotient: expected 1, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 0, f"25/25 remainder: expected 0, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"25/25 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"

@cocotb.test()
async def simple_divide_large_numbers_test(dut):
    """Test with large numbers"""
    await setup_dut(dut)
    
    # Test Case 1: Max 32-bit divided by 2
    dut.dividend.value = 0xFFFFFFFF
    dut.divisor.value = 2
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    expected_quotient = 0x7FFFFFFF
    expected_remainder = 1
    
    assert int(dut.quotient.value) == expected_quotient, f"MAX/2 quotient: expected {expected_quotient}, got {dut.quotient.value}"
    assert int(dut.remainder.value) == expected_remainder, f"MAX/2 remainder: expected {expected_remainder}, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"MAX/2 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"
    
    # Test Case 2: Max divided by itself
    dut.dividend.value = 0xFFFFFFFF
    dut.divisor.value = 0xFFFFFFFF
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 1, f"MAX/MAX quotient: expected 1, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 0, f"MAX/MAX remainder: expected 0, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"MAX/MAX divide_by_zero: expected 0, got {dut.divide_by_zero.value}"

@cocotb.test()
async def simple_divide_power_of_two_test(dut):
    """Test power of 2 divisions"""
    await setup_dut(dut)
    
    # Test Case 1: 64/8
    dut.dividend.value = 64
    dut.divisor.value = 8
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 8, f"64/8 quotient: expected 8, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 0, f"64/8 remainder: expected 0, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"64/8 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"
    
    # Test Case 2: 1024/16
    dut.dividend.value = 1024
    dut.divisor.value = 16
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    
    assert int(dut.quotient.value) == 64, f"1024/16 quotient: expected 64, got {dut.quotient.value}"
    assert int(dut.remainder.value) == 0, f"1024/16 remainder: expected 0, got {dut.remainder.value}"
    assert int(dut.divide_by_zero.value) == 0, f"1024/16 divide_by_zero: expected 0, got {dut.divide_by_zero.value}"

@cocotb.test()
async def simple_divide_random_test(dut):
    """Test with random values"""
    await setup_dut(dut)
    
    # Set seed for reproducible tests
    random.seed(42)
    
    for i in range(20):
        # Generate random dividend and non-zero divisor
        dividend = random.randint(1, 0xFFFF)  # Keep numbers reasonable for faster simulation
        divisor = random.randint(1, 0xFFFF)
        
        # Calculate expected values using Python
        expected_quotient = dividend // divisor
        expected_remainder = dividend % divisor
        
        # Apply to DUT
        dut.dividend.value = dividend
        dut.divisor.value = divisor
        dut.enable.value = 1
        await RisingEdge(dut.clk)
        dut.enable.value = 0
        await RisingEdge(dut.clk)
        
        # Check results
        actual_quotient = int(dut.quotient.value)
        actual_remainder = int(dut.remainder.value)
        actual_div_by_zero = int(dut.divide_by_zero.value)
        
        assert actual_quotient == expected_quotient, f"Random test {i}: {dividend}/{divisor} quotient: expected {expected_quotient}, got {actual_quotient}"
        assert actual_remainder == expected_remainder, f"Random test {i}: {dividend}/{divisor} remainder: expected {expected_remainder}, got {actual_remainder}"
        assert actual_div_by_zero == 0, f"Random test {i}: {dividend}/{divisor} divide_by_zero: expected 0, got {actual_div_by_zero}"