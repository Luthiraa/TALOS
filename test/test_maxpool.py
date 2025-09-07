import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.binary import BinaryValue
import numpy as np

@cocotb.test()
async def test_maxpool(dut):
    """Test max pooling operation"""
    
    # Parameters
    IMG_HEIGHT = 26
    IMG_WIDTH = 26
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
        [2872, 3418, 3008, 3026, 2260, 2141, 2789, 2176, 2687, 2516, 2898, 1826, 3302, 2284, 2631, 1883, 1882, 2261, 1439, 2257, 2604, 1513, 2692, 2209, 2655, 2263],
        [2188, 2938, 3474, 2225, 2477, 1768, 2517, 2514, 2413, 2461, 3054, 2217, 3547, 3087, 3764, 3059, 2482, 3726, 2642, 3032, 2669, 1255, 2183, 1862, 1970, 2185],
        [2145, 1811, 2495, 2059, 2762, 2065, 1807, 2288, 1806, 2002, 2116, 2121, 3244, 3019, 2876, 3180, 1849, 3133, 1912, 1930, 2369, 1680, 2288, 1433, 1921, 2892],
        [2575, 2584, 2173, 2067, 2630, 1948, 2467, 2336, 2241, 2191, 2723, 2699, 3248, 3001, 2214, 2122, 1597, 2432, 2348, 1800, 2284, 1799, 2880, 3066, 3080, 3228],
        [2306, 2946, 2239, 1885, 2208,  932, 1835, 1793, 2010, 2200, 1830, 2173, 2748, 2377, 1850, 1642, 1535, 2273, 1955, 1838, 2963, 2666, 2714, 3453, 2928, 3139],
        [3089, 3271, 3319, 2718, 3055, 1298, 2327, 2171, 1867, 2499, 1922, 2021, 2650, 2535, 2336, 1785, 1286, 2728, 2779, 2926, 3066, 3769, 3065, 4135, 3476, 3534],
        [2742, 2654, 3065, 2815, 3086, 2392, 2178, 3132, 2148, 3462, 2550, 2895, 2129, 2238, 1639, 2092, 1663, 2914, 2924, 3437, 2695, 3761, 2833, 3645, 3130, 3371],
        [2646, 2452, 3111, 2281, 2804, 2756, 2374, 3288, 2847, 3586, 2876, 3678, 2654, 3610, 2449, 2439, 1910, 2939, 2999, 3270, 2708, 3868, 3732, 3209, 4326, 3362],
        [2100, 2224, 3501, 2693, 3656, 2904, 3148, 3328, 3093, 3325, 2754, 2919, 1995, 2422, 2349, 2655, 2182, 2358, 2415, 2964, 2120, 2805, 3059, 2435, 3156, 2965],
        [2803, 2447, 3417, 3021, 3376, 2022, 2113, 2366, 2533, 3532, 2261, 2593, 2467, 3044, 3616, 3750, 3809, 4052, 2852, 3683, 2424, 2505, 2387, 3154, 2898, 2537],
        [3167, 2990, 3899, 3237, 3269, 2138, 2994, 2543, 3500, 3889, 2841, 2271, 1879, 1960, 2872, 2938, 2923, 3600, 2337, 3292, 2013, 2726, 1978, 3361, 3254, 3173],
        [3525, 2478, 3689, 2087, 2827, 1681, 3086, 3072, 4055, 4200, 3454, 2857, 2395, 1810, 2991, 3394, 3925, 4108, 3268, 2213, 1338, 1782, 2432, 2613, 3510, 2182],
        [3547, 3017, 3485, 2593, 3263, 2736, 3849, 2990, 4163, 3842, 3649, 2950, 2441, 1841, 2225, 2653, 3182, 2808, 3367, 2412, 2132, 1671, 2830, 1490, 3025, 2461],
        [2794, 2917, 2275, 2199, 2921, 3026, 3143, 2580, 3487, 3071, 4640, 3906, 3231, 2544, 2638, 2678, 2781, 2299, 2874, 2568, 2457, 1678, 3006, 1669, 2400, 2116],
        [2267, 2986, 2056, 1824, 2994, 3607, 3656, 3263, 3367, 2744, 3522, 3459, 3279, 2630, 2731, 2626, 2430, 2600, 2036, 2430, 3094, 2683, 3471, 2496, 3115, 2384],
        [2869, 1989, 2247, 2291, 3149, 3519, 3337, 3141, 2665, 2813, 3174, 2788, 3168, 2723, 3048, 2510, 2591, 2967, 2311, 2422, 2068, 2468, 2404, 2731, 2413, 1885],
        [3125, 2061, 2550, 2811, 2542, 2993, 3684, 3072, 3153, 2702, 2519, 2038, 3472, 2971, 3152, 3033, 3712, 2988, 2607, 2837, 2414, 2888, 3236, 2789, 3445, 2830],
        [2701, 1475, 2405, 3035, 2745, 2279, 2515, 2263, 1935, 2656, 2552, 2505, 2594, 2322, 2304, 2171, 2581, 2000, 1893, 2504, 2004, 2439, 3245, 2180, 2739, 2271],
        [2430, 1490, 2336, 2271, 2910, 2498, 2105, 2408, 1782, 3258, 2847, 3156, 2400, 2340, 2122, 3038, 2509, 1997, 1607, 1362, 1739, 2315, 3040, 2784, 3765, 3142],
        [2887, 1276, 3227, 2875, 3694, 3475, 3170, 2093, 1792, 2665, 2610, 2488, 1498, 2097, 1000, 2497, 1222, 1714, 1956, 2414, 2187, 3076, 2755, 3244, 3834, 3464],
        [2765, 1877, 2738, 2795, 3630, 3437, 2826, 2012, 1887, 2471, 2169, 3388, 1709, 2765, 1729, 3040, 2339, 2274, 2054, 1725, 2164, 2457, 3805, 3884, 4513, 3475],
        [1830, 1726, 2320, 2356, 3004, 3382, 2340, 2270, 1597, 2448, 1850, 3409, 2686, 2591, 2374, 2038, 2300, 2444, 2820, 3029, 3075, 2802, 3080, 3175, 3945, 3119],
        [2728, 2657, 3178, 2705, 2715, 2562, 1879, 1934, 1439, 2171, 2918, 3401, 3703, 2501, 3139, 2365, 2343, 2914, 2631, 3181, 3322, 4098, 3567, 3686, 3630, 3087],
        [2787, 3106, 3137, 2464, 2091, 1855, 2652, 2094, 2726, 1412, 3172, 2993, 3230, 2389, 2656, 2681, 2219, 3123, 2233, 3937, 3164, 4358, 3033, 3552, 3736, 3352],
        [2922, 4155, 2981, 3383, 2610, 2300, 2991, 1918, 3668, 1885, 3531, 3129, 3034, 2722, 2436, 2327, 2364, 2900, 2614, 3065, 3450, 3631, 3832, 2563, 3808, 2065],
        [1956, 3070, 2532, 2521, 2549, 2846, 3397, 2234, 3027, 1332, 2903, 2541, 3535, 3226, 3163, 2478, 1816, 1805, 3171, 2647, 4064, 2874, 4037, 2279, 3330, 1873]
    ], dtype=np.int32)
    
    print("INPUT IMAGE:")
    print(img_2d)
    
    # Convert to format expected by DUT (array of individual pixels)
    img_flat = img_2d.flatten()
    print(f"Flattened image: {img_flat[:10]}")
    
    # Set input values - assign each pixel individually
    for i in range(len(img_flat)):
        dut.img[i].value = int(img_flat[i])
    
    print("\nStarting max pooling...")
    # Enable operation
    dut.enable.value = 1
    
    # Wait for completion
    await wait_for_completion(dut)
    
    print("Max pooling completed!")
    
    # Read results
    out_height = IMG_HEIGHT // KERNEL_SIZE
    out_width = IMG_WIDTH // KERNEL_SIZE
    total_outputs = out_height * out_width
    
    print(f"\nOutput dimensions: {out_height}x{out_width}")

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

async def wait_for_completion(dut, timeout_cycles=200000000):
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