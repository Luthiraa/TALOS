import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.binary import BinaryValue
import numpy as np
import random

async def wait_for_division(dut):
    """Wait for division to complete and return results"""
    while not dut.valid.value:
        await RisingEdge(dut.clk)
    
    quotient = int(dut.quotient.value)
    remainder = int(dut.remainder.value)
    return quotient, remainder

@cocotb.test()
async def test_division_basic(dut):
    """Basic division test with simple cases"""
    
    print("="*60)
    print("DIVISION TEST - BASIC OPERATIONS")
    print("="*60)
    
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    
    # Reset
    print("Resetting DUT...")
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.dividend.value = 0
    dut.divisor.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Test cases: (dividend, divisor, expected_quotient, expected_remainder)
    test_cases = [
        (100, 10, 10, 0),
        (123, 7, 17, 4),
        (1000, 33, 30, 10),
        (255, 16, 15, 15),
        (42, 42, 1, 0),
        (15, 20, 0, 15),  # dividend < divisor
        (1, 1, 1, 0),
        (0, 5, 0, 0),     # dividend = 0
    ]
    
    for i, (dividend, divisor, exp_quotient, exp_remainder) in enumerate(test_cases):
        print(f"\nTest Case {i+1}: {dividend} ÷ {divisor}")
        print(f"Expected: Q={exp_quotient}, R={exp_remainder}")
        
        # Set inputs
        dut.dividend.value = dividend
        dut.divisor.value = divisor
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        
        # Wait for completion
        quotient, remainder = await wait_for_division(dut)
        
        print(f"Got:      Q={quotient}, R={remainder}")
        
        # Check results
        assert quotient == exp_quotient, f"Quotient mismatch: got {quotient}, expected {exp_quotient}"
        assert remainder == exp_remainder, f"Remainder mismatch: got {remainder}, expected {exp_remainder}"
        
        print("✓ PASS")
        
        # Wait a bit before next test
        await RisingEdge(dut.clk)
    
    print("\n" + "="*60)
    print("ALL BASIC DIVISION TESTS PASSED!")
    print("="*60)

@cocotb.test()
async def test_division_by_zero(dut):
    """Test division by zero detection"""
    
    print("="*60)
    print("DIVISION TEST - DIVISION BY ZERO")
    print("="*60)
    
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    
    # Reset
    print("Resetting DUT...")
    dut.rst_n.value = 0
    dut.start.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Test division by zero
    print("Testing division by zero: 100 ÷ 0")
    dut.dividend.value = 100
    dut.divisor.value = 0
    dut.start.value = 1
    await RisingEdge(dut.clk)
    
    # Check that divide_by_zero flag is asserted
    assert dut.divide_by_zero.value == 1, "divide_by_zero should be asserted"
    print("✓ divide_by_zero flag correctly asserted")
    
    dut.start.value = 0
    await RisingEdge(dut.clk)
    
    # Check that flag is deasserted when start is low
    assert dut.divide_by_zero.value == 0, "divide_by_zero should be deasserted when start is low"
    print("✓ divide_by_zero flag correctly deasserted")
    
    print("\nDIVISION BY ZERO TEST PASSED!")

@cocotb.test()
async def test_division_random(dut):
    """Random division test cases for robustness"""
    
    print("="*60)
    print("DIVISION TEST - RANDOM CASES")
    print("="*60)
    
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    
    # Reset
    print("Resetting DUT...")
    dut.rst_n.value = 0
    dut.start.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Generate random test cases
    num_tests = 20
    max_value = 1000
    
    for i in range(num_tests):
        dividend = random.randint(0, max_value)
        divisor = random.randint(1, max_value)  # Avoid division by zero
        
        exp_quotient = dividend // divisor
        exp_remainder = dividend % divisor
        
        print(f"\nRandom Test {i+1}: {dividend} ÷ {divisor}")
        
        # Set inputs
        dut.dividend.value = dividend
        dut.divisor.value = divisor
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        
        # Wait for completion
        quotient, remainder = await wait_for_division(dut)
        
        # Verify
        assert quotient == exp_quotient, f"Quotient mismatch: got {quotient}, expected {exp_quotient}"
        assert remainder == exp_remainder, f"Remainder mismatch: got {remainder}, expected {exp_remainder}"
        
        if i % 5 == 4:  # Print progress every 5 tests
            print(f"✓ Tests 1-{i+1} passed")
    
    print(f"\n✓ ALL {num_tests} RANDOM TESTS PASSED!")

@cocotb.test()
async def test_division_timing(dut):
    """Test division timing and ready/valid handshaking"""
    
    print("="*60)
    print("DIVISION TEST - TIMING AND HANDSHAKING")
    print("="*60)
    
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    
    # Reset
    dut.rst_n.value = 0
    dut.start.value = 0
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    assert dut.ready.value == 1, "Module should be ready initially"
    print("Module ready at startup")
    
    print("Starting division: 1000 ÷ 7")
    dut.dividend.value = 1000
    dut.divisor.value = 7
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0
    
    await RisingEdge(dut.clk)
    cycle_count = 1
    while not dut.valid.value:
        assert dut.ready.value == 0, f"Ready should be low during operation (cycle {cycle_count})"
        await RisingEdge(dut.clk)
        cycle_count += 1
    
    print(f"✓ Division completed in {cycle_count} cycles")
    print(f"✓ Result: Q={int(dut.quotient.value)}, R={int(dut.remainder.value)}")
    
    # Check that ready goes high after completion
    await RisingEdge(dut.clk)
    assert dut.ready.value == 1, "Module should be ready after completion"
    print("✓ Module ready after completion")
    
    print("\nTIMING TEST PASSED!")