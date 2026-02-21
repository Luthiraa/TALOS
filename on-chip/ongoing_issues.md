# TALOS — Ongoing Issues for MNIST Inference on DE1-SoC

> **Last updated:** 2026-02-10  
> **Sources:** Independent RTL audit (Antigravity) + GPT 5.3 transcript analysis  
> **Target:** DE1-SoC (Cyclone V 5CSEMA5F31C6)

---

## DE1-SoC Memory Resources (Reference)

The Cyclone V 5CSEMA5F31C6 on the DE1-SoC provides:

| Resource | Total Available | Notes |
|----------|----------------|-------|
| **M10K blocks** | 397 blocks × 10,240 bits = ~4.065 Mbit | Primary on-chip BRAM; each block is 10 Kbit |
| **MLAB (Adaptive LUT RAM)** | Distributed across ALMs | Small, fast; 640 bits each, used for small FIFOs/LUTs |
| **ALMs (Adaptive Logic Modules)** | 32,070 | Each contains LUTs + flip-flops |
| **DSP blocks (18×18 multipliers)** | 87 | Used for fixed-point multiplies |
| **Registers** | ~128,000+ | Flip-flops available for pipeline registers / state |

The current design's memory footprint (from the successful Jan 27 build) uses approximately:
- **~28% interconnect routing** (no routing pressure)
- **M10K BRAM** for `fc_w_rom` (1 block at 1024×32 = 32 Kbit)
- **Register-based arrays** for `img[784]`, `kernels[36]`, `cnn_out[676]`, `convimg[676]`, `outmax[676]` — consuming **massive register counts**

---

## Table of Contents

1. [SHOW-STOPPERS — Design Never Completes or Produces Wrong Results](#1-show-stoppers)
2. [FUNCTIONAL BUGS — Wrong Inference Results](#2-functional-bugs)
3. [MEMORY & RESOURCE ISSUES — DE1-SoC Specific](#3-memory--resource-issues)
4. [SYNTHESIS / FITTER / CONSTRAINTS ISSUES](#4-synthesis--fitter--constraints-issues)
5. [CODE QUALITY / MAINTAINABILITY](#5-code-quality--maintainability)

---

## 1. SHOW-STOPPERS

These bugs prevent the design from completing inference or cause fundamentally incorrect output. **Nothing downstream can work until these are fixed.**

---

### 1.1 `cnn.sv:113` — Wrong vertical scan bound causes out-of-range computation

**File:** [cnn.sv:113](file:///Users/luthiraa/Documents/TALOS/cnn.sv#L113)  
**Severity:** 🔴 Critical — causes garbage convolution outputs  
**Source:** Both audits independently identified this

**The Bug:**

```systemverilog
// LINE 113 (CURRENT — WRONG):
else if (vert_align < IMG_WIDTH) begin
    vert_align <= vert_align + 1;
    hor_align <= 0;
end
```

The CNN module walks the image in 2D using `hor_align` (horizontal) and `vert_align` (vertical) counters. When `hor_align` reaches the right edge (`IMG_WIDTH - KERNEL_SIZE + 1 = 26` for a 28-wide image), it should wrap to the next row by incrementing `vert_align` and resetting `hor_align` to 0. The bound check on `vert_align` should be `IMG_HEIGHT - KERNEL_SIZE + 1` (= 26 for 28-high image), but it uses `IMG_WIDTH` (= 28).

**What actually happens:**

For the current 28×28 MNIST image, `IMG_WIDTH = IMG_HEIGHT = 28`, so the bound `vert_align < 28` is evaluated instead of `vert_align < 26`. This means:

1. Rows 26 and 27 are computed even though valid output rows are only 0–25 (OUT_H = 26).
2. At row 26, the kernel window extends to row 28 (indices 26, 27, 28) — but `img[28 * 28 + col]` is past the declared array `img[783:0]`. For synthesis this reads from undefined space; for simulation it reads from another signal's memory.
3. The convolutions counter increments to `OUT_E + 2*26 = 676 + 52 = 728` before `vert_align` reaches 28 and stops advancing.
4. Since the completion check is `convolutions < OUT_E` (676), and convolutions already passed 676 at row 25, `complete_r` fires on schedule — but the `x[]` output array has been corrupted by the extra out-of-bound writes from rows 26-27, which write into `x[vert_align*OUT_W + hor_align]` where `vert_align = 26, 27` → indices 676–727, **overflowing** the `x[675:0]` array.

**Memory impact on DE1-SoC:**

The `x[]` array is `logic signed [31:0] x[675:0]` — implemented as **21,632 flip-flops** (676 × 32 bits). When `vert_align` exceeds 25, the write `x[vert_align*OUT_W + hor_align]` computes indices 676–727. In Quartus synthesis, these out-of-range writes are either:
- **Silently ignored** (if the synthesizer can prove the index exceeds the array), OR
- **Wrapped** (if the address width is wider than needed), causing writes to indices `676 mod 676 = 0, 1, 2...` — **corrupting the first 52 outputs**.

In either case, the register count is not affected (still 21,632 FFs for `x[]`), but **the correct output data in `x[0]` through `x[51]` may be overwritten** with garbage values from the invalid kernel window.

**The fix:**

```diff
- else if (vert_align < IMG_WIDTH) begin
+ else if (vert_align < IMG_HEIGHT - KERNEL_SIZE + 1) begin
```

Or equivalently: `vert_align < OUT_H`.

---

### 1.2 `maxpool.sv:779,800,840` — `running_max` initialized to 0 instead of most-negative value

**File:** [maxpool.sv:779](file:///Users/luthiraa/Documents/TALOS/maxpool.sv#L779), [maxpool.sv:800](file:///Users/luthiraa/Documents/TALOS/maxpool.sv#L800), [maxpool.sv:840](file:///Users/luthiraa/Documents/TALOS/maxpool.sv#L840)  
**Severity:** 🔴 Critical — silently produces incorrect maxpool results for any tile with all-negative values  
**Source:** Both audits identified this; comments in the code say "YOU WANT THIS LIKE THAT" — indicating a deliberate (but wrong) choice

**The Bug:**

```systemverilog
// CURRENT (WRONG) — three locations:
running_max <= 32'sd0;     // Line 779 (reset)
running_max <= 32'sd0;     // Line 800 (!enable)
running_max <= 32'sd0;     // Line 840 (after ST_ACCUM)
```

The maxpool algorithm finds the **maximum** value in each 2×2 tile. `running_max` is the accumulator that tracks the largest value seen so far within the current tile. It must be initialized to the **smallest possible signed 32-bit value** (`32'sh8000_0000` = -2,147,483,648) before scanning each tile, so that the first tap always replaces it.

By initializing to 0, **any tile where all four values are negative will output 0** instead of the true maximum (the least-negative value). This is extremely common in MNIST inference because the input image is normalized to a range centered near `-0.4242` (Q16.16: `0xffff9367` = -27,801), and many tiles in the convolution output are entirely negative.

**What actually happens:**

Consider a 2×2 maxpool tile with convolution outputs: `[-10648, -10648, -10648, -10648]` (common in the border regions of the MNIST convolution). The maxpool should output `-10648` as the maximum. Instead:

- Cycle 0: `running_max = 0`, `tap = -10648` → `(-10648 > 0)` is FALSE → `running_max` stays 0
- Cycle 1: `running_max = 0`, `tap = -10648` → still FALSE → stays 0
- Cycle 2–3: Same.
- Result: tile outputs `0` instead of `-10648`.

This systematically corrupts **every maxpool tile in the border/background regions** of the image, which for a 28×28 MNIST digit is the majority of the 13×13 = 169 tiles per channel.

**Memory impact on DE1-SoC:**

`running_max` is a single 32-bit register (32 flip-flops). The fix does not change register count at all — it only changes the reset value loaded into those 32 FFs. No BRAM or additional logic is consumed.

However, the **downstream effect** is massive: the corrupted maxpool values feed into the FC layer MAC accumulation (`neuron0 <= neuron0 + prod64`), which is a 64-bit accumulator (64 FFs). Every corrupted tile contributes a wrong product, and since accumulation is irreversible, **the entire FC output is garbage**.

**The fix:**

```diff
- running_max <= 32'sd0;
+ running_max <= 32'sh8000_0000;  // most-negative signed 32-bit value
```

Apply at all three locations (lines 779, 800, 840).

The old commented-out code versions at lines 119, 139, 370, 390 correctly used `32'sh8000_0000`, but when the module was rewritten, this was changed to `0`. The code comments "YOU WANT THIS LIKE THAT" suggest this was an intentional change that is **incorrect**.

---

### 1.3 `maxpool.sv:785` — `convimg` reset loop only clears first `OUT_ELEMS` of `OUT_ELEMS*4` entries

**File:** [maxpool.sv:721](file:///Users/luthiraa/Documents/TALOS/maxpool.sv#L721) (declaration), [maxpool.sv:785](file:///Users/luthiraa/Documents/TALOS/maxpool.sv#L785) (reset loop)  
**Severity:** 🔴 Critical — leaves 3/4 of the convimg array uninitialized  
**Source:** Both audits identified this

**The Bug:**

```systemverilog
// LINE 721 — declaration:
output logic signed [31:0] convimg[OUT_ELEMS*4-1:0],
// OUT_ELEMS = 13*13 = 169, so array is 676 entries (indices 0–675)

// LINE 785 — reset:
for (int i = 0; i < OUT_ELEMS; i++) convimg[i] <= 32'sd0;
// Only clears indices 0–168, leaving indices 169–675 UNINITIALIZED
```

The `convimg` output array is sized to hold all 4 kernel passes' maxpool results: `OUT_ELEMS * 4 = 169 * 4 = 676` entries. But the reset loop iterates only `OUT_ELEMS = 169` times, leaving the upper 507 entries at their power-on undefined state.

**What actually happens at runtime:**

The maxpool module writes to `convimg[pass_sel * TOTAL_CONV + convolutions]` at line 831. For pass 0, it writes indices 0–168. For pass 1, indices 169–337. For pass 2, indices 338–506. For pass 3, indices 507–675. So during normal operation, all 676 entries are eventually written.

**But during reset** (either at power-on or when `!enable`), only entries 0–168 are cleared. If the FSM is interrupted mid-computation (e.g., user resets via SW[1] during pass 2), entries 169–337 from pass 1 contain stale data, entries 338–506 are partially written, and 507–675 are garbage from the previous run. When inference restarts, the stale `convimg` values are readable from the `outmax` signal in `inference.sv`, producing misleading HEX display output.

**Memory impact on DE1-SoC:**

`convimg[675:0]` with 32-bit entries = **21,632 flip-flops**. This is an enormous register array. On reset, 507 × 32 = 16,224 of those flip-flops have undefined initial values. In FPGA (Cyclone V), registers power up to 0 by default, so on the **very first** power-on this isn't catastrophic. But after any software-controlled reset mid-run (which the inference FSM does between passes — see `!enable` at maxpool.sv:787–804), the upper entries retain their old values.

The full `convimg` array costs:
- **21,632 DFFs** ≈ 10,816 ALMs (each ALM has 2 registers)
- This is **~33.7% of the device's 32,070 ALMs** just for this one array
- Combined with `x[675:0]` in cnn.sv (another 21,632 FFs), `img[783:0]` (25,088 FFs), `kernels[35:0]` (1,152 FFs), and `outmax[675:0]` (21,632 FFs) — you're using approximately **91,136 FFs** (≈ 45,568 ALMs) for register arrays alone, which is **~142% of the device's ALM count**.

> [!CAUTION]
> This math shows the design is near or over the ALM limit with all arrays in registers. Quartus may fit this by utilizing MLAB (Adaptive LUT RAM) or the fitter's ability to pack registers tightly, but this is a **massive resource pressure point**. Any small increase in array sizes will cause fitting failure.

**The fix:**

```diff
- for (int i = 0; i < OUT_ELEMS; i++) convimg[i] <= 32'sd0;
+ for (int i = 0; i < OUT_ELEMS * 4; i++) convimg[i] <= 32'sd0;
```

And the same loop should be added in the `!enable` reset branch (lines 787–804), which currently doesn't clear `convimg` at all.

---

### 1.4 Simulation never completes — stale test harness

**File:** [test_output.log](file:///Users/luthiraa/Documents/TALOS/test_output.log)  
**Severity:** 🔴 Critical — no working simulation possible  
**Source:** Antigravity audit

**The Bug:**

The test_output.log at line 1 shows the iverilog command was:
```
iverilog ... src/counter.sv src/cnn.sv src/maxpool.sv ... src/inference.sv ...
```

All source files have `src/` prefix — but the current codebase has all `.sv` files in the project root (no `src/` directory exists). This means:

1. The test log is **stale** — it was generated against a previous version of the code from when files lived in `src/`.
2. The current files may have different bugs or fixes than what the test ran against.
3. The simulation ran for **2,312,391 ns** (over **2.3 million cycles** at 1ns clock) without `complete` ever going high, then timed out.
4. The test references modules like `neuron.sv` and `counter.sv` that no longer exist in the project.

**Impact:** You have **no valid simulation** of the current code. Any debugging conclusions from the test log may not apply to the current RTL.

The reason the simulation stalled is likely the combination of bugs #1.1 (wrong vertical bound causing extended computation) and #1.2 (running_max=0 causing incorrect results that may interact with the FSM control flow). Additionally, the `fc_w_rom` Altera IP (`altsyncram`) has no simulation model in Icarus Verilog — `w_q_rom` resolves to `x` (undefined), making `neuron0` accumulate `x` values.

---

## 2. FUNCTIONAL BUGS

These produce wrong inference results but don't prevent the design from completing.

---

### 2.1 `neuron0` is 64-bit but `o0` is 32-bit — silent truncation loses upper bits

**File:** [inference.sv:977](file:///Users/luthiraa/Documents/TALOS/inference.sv#L977) (declaration), [inference.sv:1161](file:///Users/luthiraa/Documents/TALOS/inference.sv#L1161) (assignment)  
**Severity:** 🟡 High — result may be completely wrong due to bit truncation  
**Source:** Both audits identified this

**The Bug:**

```systemverilog
// Line 977:
logic signed [63:0] neuron0;       // 64-bit accumulator

// Line 889:
output wire signed [31:0] o0,      // 32-bit output port

// Line 1161:
assign o0 = neuron0;               // implicit truncation: takes bits [31:0] only
```

The FC layer MAC accumulates 676 products (one per maxpool output across 4 channels). Each product is `(w64 * a64) >>> 16` where both operands are Q16.16 (32-bit). The raw product is 64-bit, right-shifted by 16 = 48 bits significant. Summing 676 such products can easily exceed 32-bit range.

**Numerical analysis:**

- Max single product magnitude: `(2^15 - 1) × (2^15 - 1) / 2^16 ≈ 2^14 ≈ 16,384` (in Q16.16 integer representation)
- Summing 676 such products: worst case `676 × 16,384 ≈ 11,075,584` — this fits in 24 bits, so 32-bit truncation *might* be safe for typical MNIST values.
- But the accumulator is 64-bit for a reason — to avoid overflow during accumulation. The final value should be **explicitly saturated or range-checked** before truncation.

**Memory impact on DE1-SoC:**

The 64-bit `neuron0` register consumes **64 flip-flops** (trivial). The `o0` wire is 32-bit. The truncation itself doesn't waste resources — but if you need the full 64-bit value at the output (e.g., for multi-neuron argmax comparison), you'd need to widen all downstream paths by 32 bits each, adding ~32 FFs per output register.

**The fix (minimum):**

```systemverilog
// Saturating cast from 64-bit to 32-bit Q16.16:
assign o0 = (neuron0 > 64'sh000000007FFFFFFF) ? 32'sh7FFFFFFF :
            (neuron0 < -64'sh0000000080000000) ? 32'sh80000000 :
            neuron0[31:0];
```

---

### 2.2 FC ROM only loads `fc_w_neuron7.mif` — only 1 of 10 output neurons implemented

**File:** [fc_w_rom.v:86](file:///Users/luthiraa/Documents/TALOS/fc_w_rom.v#L86)  
**Severity:** 🟡 High — design can only compute class 7, not all 10 MNIST digits  
**Source:** Both audits identified this

**The Bug:**

```verilog
// fc_w_rom.v line 86:
altsyncram_component.init_file = "fc_w_neuron7.mif",
```

There are 10 MIF files in the project (`fc_w_neuron0.mif` through `fc_w_neuron9.mif`), one per output class. MNIST classification requires computing all 10 outputs and selecting the maximum (argmax) as the predicted digit. The current ROM is hardcoded to load only neuron 7's weights.

The `maxpool.sv` module instantiates exactly one `fc_w_rom`:

```systemverilog
// maxpool.sv line 753:
fc_w_rom u_fc_w_rom (
    .address(w_addr_reg),
    .clock(clk),
    .q(w_q_rom)
);
```

And `inference.sv` instantiates exactly one `maxpool`:

```systemverilog
// inference.sv line 985:
maxpool ... ma_ins ( ... );
```

So the entire design computes exactly **one** FC output (neuron 7). There is no argmax logic, and no way to compare across classes.

**Memory impact on DE1-SoC:**

Current: 1 ROM × 1024 words × 32 bits = **32,768 bits = 4 M10K blocks** (each M10K is 10,240 bits; 1024×32 requires ⌈32,768/10,240⌉ = 4 blocks).

For full 10-class inference, you'd need either:
- **10 parallel ROMs**: 10 × 4 = **40 M10K blocks** (out of 397 available = 10.1%). Feasible but significant.
- **1 shared ROM, time-multiplexed 10×**: Requires 10 × 676 = 6,760 words at 32 bits. Would need `⌈6,760 × 32 / 10,240⌉ = 22 M10K blocks` with a wider address (13 bits). This is more memory-efficient if you pipeline the neuron accumulations sequentially.
- **Dual-port ROM**: If you use dual-port M10K, you can halve the pass count but double the port usage per block.

Current MIF file sizes for reference:
- `fc_w_neuron0.mif` through `fc_w_neuron6.mif`, `fc_w_neuron8.mif`, `fc_w_neuron9.mif`: ~10,781 bytes each
- `fc_w_neuron7.mif`: ~16,374 bytes (larger — may contain more entries or padding)

---

### 2.3 `outmax` array hardcoded to `[675:0]` instead of parameterized

**File:** [inference.sv:978](file:///Users/luthiraa/Documents/TALOS/inference.sv#L978)  
**Severity:** 🟡 Medium — works by coincidence for current params, breaks if anything changes  
**Source:** Both audits identified this

**The Bug:**

```systemverilog
// Line 978:
logic signed [31:0] outmax [675:0];              // HARDCODED
// Should be:
logic signed [31:0] outmax [NO_KERNELS*MAXPOOL_SIZE*MAXPOOL_SIZE-1:0]; // PARAMETERIZED
// For current params: 4 * 13 * 13 - 1 = 675 ✓
```

If `NO_KERNELS`, `IMG_HEIGHT`, `IMG_WIDTH`, `KERNEL_SIZE`, or `MAXPOOL_KERNEL` change, this array will be the wrong size. A larger value causes wasted registers; a smaller value causes out-of-bounds writes from maxpool, which silently corrupt adjacent registers in Quartus synthesis.

**Memory impact on DE1-SoC:**

`outmax[675:0]` at 32 bits = **21,632 flip-flops**. This is identical to `convimg` in maxpool and contributes to the ~91K FF register pressure described in issue #1.3. If the array is accidentally undersized, writes beyond the bound corrupt state in unpredictable ways — there is **no FPGA equivalent of a segfault**.

---

### 2.4 HEX debug display can only show 8 of 676 maxpool outputs

**File:** [inference.sv:1187](file:///Users/luthiraa/Documents/TALOS/inference.sv#L1187)  
**Severity:** 🟡 Low (debug only) — limits on-board observability  
**Source:** Both audits identified this

**The Bug:**

```systemverilog
// Line 1186-1187:
wire [31:0] k;
assign k = outmax[SW[4:2]];   // SW[4:2] is 3 bits → indices 0–7 only
```

There are 676 maxpool outputs but you can only display the first 8 on the HEX displays. Even using all 10 switches (`SW[9:0]`) would only give 10 bits = 1024 indices, which is enough — but the current 3-bit slice is far too narrow.

**Memory impact on DE1-SoC:** None — `SW[4:2]` is a 3-bit wire, and the mux from `outmax` synthesizes to ~32 LUTs (one 8:1 mux per bit of `k`). Widening to `SW[9:0]` would increase the mux to 1024:1 (about 10 LUT levels), costing ~320 additional LUTs.

---

### 2.5 HEX/SW/display logic embedded inside `inference` module instead of top-level

**File:** [inference.sv:891-898](file:///Users/luthiraa/Documents/TALOS/inference.sv#L891-L898), [inference.sv:1164-1195](file:///Users/luthiraa/Documents/TALOS/inference.sv#L1164-L1195)  
**Severity:** 🟡 Medium — architectural violation making the module non-reusable  
**Source:** GPT 5.3 transcript identified this

**The Bug:**

The `inference` module's port list includes board-specific signals:

```systemverilog
output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
input  logic        display_en,
input  logic [9:0]  SW
```

And the module body contains the `hex7()` function, the `outmax[SW[4:2]]` mux, and the HEX driver assignments. This means:
- The inference module cannot be instantiated twice (e.g., for batch processing) without HEX port conflicts
- The module cannot be used in a simulation testbench without stubbing these ports
- The `SW` input adds 10 pins to the module interface that have nothing to do with inference

The HEX display logic, the `hex7()` function, and the SW mux should all be in `top_inference_de1.sv`, reading from `outmax` via a separate output port.

**Memory impact on DE1-SoC:** The `hex7` function synthesizes to ~7 LUTs per HEX segment × 6 displays = ~42 LUTs. These LUTs are allocated inside the `inference` entity, making the fitter's placement job harder (it must route HEX output pins from deep inside the logic hierarchy instead of from the top-level).

---

### 2.6 `cnn.sv:93-95` — Debug output `y` only captured at convolution 1

**File:** [cnn.sv:93-95](file:///Users/luthiraa/Documents/TALOS/cnn.sv#L93-L95)  
**Severity:** 🟡 Low — wastes a 32-bit output port  
**Source:** Antigravity audit

```systemverilog
if (convolutions == 1) begin
    y <= conv_acc;
end
```

The `y` output captures the accumulator value only when the second convolution completes. This is a debug artifact. The port is declared (`output logic signed [31:0] y`) but not connected in the inference instantiation (line 951: `// .y(y)` is commented out). Quartus will synthesize the register and then optimize it away since it's unconnected — but it clutters the module interface.

---

### 2.7 `cnn.sv` — `.y()` port commented out in inference instantiation

**File:** [inference.sv:951](file:///Users/luthiraa/Documents/TALOS/inference.sv#L951)  
**Severity:** 🟡 Low — unconnected output port warning  
**Source:** Antigravity audit

```systemverilog
cnn ... cnn_ins (
    ...
    .complete(cnn_complete),
//  .y(y)                      // <-- commented out
);
```

The `cnn` module's `y` output is left unconnected. Quartus generates a warning: `"Output pins are stuck at VCC or GND"` or `"Port y is not connected"`. This is noise in the report that can mask real issues.

---

## 3. MEMORY & RESOURCE ISSUES

These issues specifically relate to how memory is used (or wasted) on the DE1-SoC's Cyclone V FPGA.

---

### 3.1 All major data arrays are in registers, not BRAM — catastrophic register pressure

**Severity:** 🔴 Critical for scalability  
**Source:** Both audits identified this

**Current register array inventory:**

| Array | Location | Size | Flip-Flops | Could use BRAM? |
|-------|----------|------|------------|-----------------|
| `img[783:0]` | top_inference_de1.sv | 784 × 32 | **25,088** | ✅ Yes (M10K) |
| `kernels[35:0]` | top_inference_de1.sv | 36 × 32 | **1,152** | ❌ Too small |
| `cnn_out[675:0]` (= `x[]`) | cnn.sv | 676 × 32 | **21,632** | ⚠️ Possible but needs 2-port |
| `convimg[675:0]` | maxpool.sv | 676 × 32 | **21,632** | ⚠️ Possible |
| `outmax[675:0]` | inference.sv | 676 × 32 | **21,632** | ⚠️ Possible |
| **TOTAL** | | | **91,136 FFs** | |

The Cyclone V 5CSEMA5F31C6 has **128,300 registers** (flip-flops) across 32,070 ALMs. The arrays alone consume **71%** of all available registers, leaving only 37,164 FFs for the FSMs, counters, synchronizers, PLL, and everything else.

> [!WARNING]
> If any array grows (e.g., larger image, more kernels, deeper FC layer), the design will **immediately fail to fit**. The current build reportedly succeeded, but it's operating at the edge of the device's capacity.

**How BRAM could help:**

| Array | BRAM implementation | M10K blocks needed | Savings in FFs |
|-------|--------------------|--------------------|----------------|
| `img[783:0]` | Single-port ROM (read-only after init) | ⌈784×32/10240⌉ = **3 blocks** | **25,088 FFs saved** |
| `cnn_out[675:0]` | Simple dual-port (CNN writes, maxpool reads) | ⌈676×32/10240⌉ = **3 blocks** | **21,632 FFs saved** |
| `convimg[675:0]` | Simple dual-port (maxpool writes, inference reads) | **3 blocks** | **21,632 FFs saved** |
| `outmax[675:0]` | Could be eliminated (same data as convimg) | **0** | **21,632 FFs saved** |
| **TOTAL** | | **9 M10K blocks** (of 397 available = 2.3%) | **89,984 FFs saved** |

This would reduce register usage from 91,136 to ~1,152 FFs for data arrays — a **98.7% reduction**, freeing the device for a full 10-neuron implementation.

**Why it isn't done now:** Unpacked arrays in SystemVerilog (`logic [31:0] arr[N-1:0]`) are NOT automatically inferred as BRAM by Quartus. You must explicitly:
1. Use `(* ramstyle = "M10K" *)` attributes, OR
2. Code the access pattern as single-clock synchronous read + write (Quartus inference rules require registered outputs), OR
3. Use Altera `altsyncram` IP (as done for `fc_w_rom`)

The current code uses combinational reads (`always_comb tap = img[...]`), which **prevents BRAM inference** because M10K requires synchronous (registered) reads. Converting to BRAM would require adding one cycle of read latency to the pipeline.

---

### 3.2 `fc_w_rom` has 1024 words but only 676 are used — wastes M10K capacity

**File:** [fc_w_rom.v:90](file:///Users/luthiraa/Documents/TALOS/fc_w_rom.v#L90)  
**Severity:** 🟠 Medium — wastes 35% of the ROM  
**Source:** Both audits identified this

```verilog
altsyncram_component.numwords_a = 1024,   // 1024 words allocated
altsyncram_component.widthad_a = 10,      // 10-bit address
```

The actual number of weights used per neuron is `TOTAL_CONV * 4 = 169 * 4 = 676`. The ROM is 52% over-provisioned.

**Memory impact:**
- 1024 × 32 bits = 32,768 bits = **4 M10K blocks** (10,240 bits each, but blocks are allocated in whole units)
- Actual need: 676 × 32 = 21,632 bits = **3 M10K blocks**
- **Waste: 1 M10K block** (10,240 bits)
- Address could be narrowed to 10 bits → 9 bits (`$clog2(676)` = 10, actually 10 is still needed), so no address savings here

For 10-neuron expansion (issue #2.2), correct sizing becomes important: 10 × 676 × 32 = 216,320 bits = **22 M10K blocks** vs. 10 × 1024 × 32 = 327,680 bits = **32 M10K blocks**. That's 10 wasted blocks.

---

### 3.3 `img[]` and `kernels[]` are compile-time constants — consume both ROM bits AND register space

**File:** [top_inference_de1.sv:67-891](file:///Users/luthiraa/Documents/TALOS/top_inference_de1.sv#L67-L891)  
**Severity:** 🟠 Medium — the 784 image values are embedded as constant LUT logic  
**Source:** Both audits identified this

The `initial` block assigns 784 image values and 36 kernel values as compile-time constants. Quartus may:

1. **Implement as registers with init values**: 25,088 FFs initialized via configuration bitstream
2. **Optimize to constant wires**: If Quartus detects the arrays are never written after init, it may replace each element with its constant value, which becomes **LUT-based constant generation** (no FFs, but significant LUT usage for non-trivial constants)
3. **Infer ROM**: Unlikely because the access pattern is via unpacked array indexing, not synchronous read

In the best case (option 2), the 784 constants still consume approximately 784 × 32 × (average LUT utilization per constant bit) ≈ **6,000–12,000 LUTs**.

If this design is meant to classify different images, the image must be loadable at runtime (via HPS, JTAG, or external memory), not hardcoded.

---

### 3.4 `cnn.sv` uses combinational multiply — no DSP block inference

**File:** [cnn.sv:46-56](file:///Users/luthiraa/Documents/TALOS/cnn.sv#L46-L56)  
**Severity:** 🟠 Medium — may use LUTs instead of dedicated DSP hardware  
**Source:** Antigravity audit

```systemverilog
fxp_mul #(
    .WIIA(16), .WIFA(16),
    .WIIB(16), .WIFB(16),
    .WOI (16), .WOF (16),
    .ROUND(1)
) u_mul (
    .ina(tap_wgt),
    .inb(tap_pix),
    .out(prod_q16),
    .overflow(overflow_mul)
);
```

The `fxp_mul` module in `fixedpoint.sv` implements multiplication using `*` operator on `wire` types (combinational). This prevents Quartus from inferring DSP blocks because DSP block inference typically requires:
- **Registered inputs and/or outputs** (pipeline FFs around the multiply)
- The `(* multstyle = "dsp" *)` attribute (which is commented out at line 45: `// (* multstyle = "dsp" *)`)

If the multiply synthesizes to LUTs instead of DSP blocks, it consumes approximately **256 ALMs** for a 32×32 multiply (vs. 2 DSP blocks which are free dedicated silicon).

The DE1-SoC has **87 DSP blocks**, and this design needs only 2 multipliers (one in CNN, one in maxpool MAC). There is no reason to use LUTs for multiplication.

**The fix:** Uncomment the DSP attribute and add pipeline registers around the multiply, or use the `fxp_mul_pipe` variant from `fixedpoint.sv`.

---

### 3.5 Maxpool MAC uses blocking assignment for 64-bit multiply — synthesis risk

**File:** [maxpool.sv:835-838](file:///Users/luthiraa/Documents/TALOS/maxpool.sv#L835-L838)  
**Severity:** 🟠 Medium — potential simulation/synthesis mismatch  
**Source:** GPT 5.3 transcript identified this

```systemverilog
// Inside always_ff:
w64    = $signed(w_q_rom);      // blocking assignment
a64    = $signed(a_q);          // blocking assignment
prod64 = (w64 * a64) >>> 16;    // blocking assignment
neuron0 <= neuron0 + prod64;    // non-blocking assignment
```

Using **blocking assignments** (`=`) inside an `always_ff` block is a simulation/synthesis coding style violation. In simulation, blocking assignments execute sequentially within the block, so this works correctly. But some synthesis tools may interpret blocking and non-blocking differently, potentially causing `w64`, `a64`, and `prod64` to be optimized into combinational logic that doesn't match the simulation behavior.

The 64-bit multiply `(w64 * a64)` is a 64×64→64 operation (though only 32 bits of each operand are meaningful). If synthesized as LUTs, this requires approximately **1,024 ALMs**. If either `w64` or `a64` were declared as `logic` (registered), the synthesizer could use DSP blocks.

---

## 4. SYNTHESIS / FITTER / CONSTRAINTS ISSUES

---

### 4.1 QSF assigns pins for ~200 unused peripherals — massive fitter warning noise

**File:** [top_inference_de1.qsf:51-308](file:///Users/luthiraa/Documents/TALOS/top_inference_de1.qsf#L51-L308)  
**Severity:** 🟠 Medium — clutters reports, causes "invalid Fitter assignment" warnings  
**Source:** Both audits identified this

The QSF contains `set_location_assignment` entries for **every pin on the DE1-SoC board**:
- ADC (4 pins)
- Audio (6 pins)
- DRAM (40 pins)
- GPIO_0 (36 pins)
- GPIO_1 (36 pins)
- VGA (27 pins)
- USB (12 pins)
- PS2 (4 pins)
- IRDA (2 pins)
- TD (10 pins)
- FAN_CTRL, FPGA_I2C, etc.

None of these are used by the design. The fitter processes each assignment, finds no matching port in the netlist, and generates a warning. This produces **hundreds of "ignored" assignment warnings** that bury real issues.

**The fix:** Remove all `set_location_assignment` lines for ports not in the top-level module interface. Keep only:
- `CLOCK_50` (1 pin)
- `SW[9:0]` (10 pins)
- `KEY[3:0]` (4 pins)
- `LEDR[9:0]` (10 pins)
- `HEX0[6:0]` through `HEX5[6:0]` (42 pins)

Total: 67 pins instead of ~260.

---

### 4.2 I/O pin assignments marked "incomplete" for active pins

**Severity:** 🟠 Medium — may cause I/O standard mismatches on FPGA  
**Source:** GPT 5.3 transcript, from fit.rpt

The Quartus fitter report flags that active I/O pins (HEX, SW, LEDR, KEY) have **incomplete assignments** — specifically, I/O standard, current strength, and slew rate are not explicitly set. Quartus defaults to `2.5V` for Cyclone V, which happens to match the DE1-SoC's I/O banks, but relying on defaults is fragile.

**The fix:** Add I/O standard assignments:
```tcl
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[*]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[*]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[*]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX*
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
```

---

### 4.3 Auto Fit compilation mode — reduced fitter effort

**Severity:** 🔵 Low — not a bug, but non-optimal  
**Source:** GPT 5.3 transcript, from fit.rpt

The Quartus project uses **Auto Fit** fitter mode, which reduces placement and routing effort once timing is met. For a design with 28% routing utilization and a 10 MHz clock (with ~31 MHz Fmax), this is fine — there's massive timing margin. But if you increase the clock or add more logic, switching to **Standard Fit** would give better results.

---

### 4.4 SDC only constrains CLOCK_50 — PLL output clock not explicitly constrained

**File:** [de1soc.sdc](file:///Users/luthiraa/Documents/TALOS/de1soc.sdc)  
**Severity:** 🔵 Low — `derive_pll_clocks` auto-handles this  
**Source:** GPT 5.3 transcript

```tcl
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
derive_pll_clocks
derive_clock_uncertainty
```

The `derive_pll_clocks` command should automatically create the 10 MHz clock constraint for the PLL output. This is correct for Quartus. However, if the PLL configuration changes (e.g., output frequency), the derived constraint updates automatically, which could silently pass timing for an unintended frequency.

---

## 5. CODE QUALITY / MAINTAINABILITY

---

### 5.1 `inference.sv` — 870 lines of dead commented-out code (73% of file)

**File:** [inference.sv:1-869](file:///Users/luthiraa/Documents/TALOS/inference.sv#L1-L869)  
**Severity:** 🔵 Medium — makes the file nearly impossible to navigate  
**Source:** Both audits identified this

The file contains **three** complete previous versions of the module, all commented out with `//`. Lines 1–137, 139–300, and 302–838 are dead code. Only lines 870–1197 (328 lines) are active. This is the result of iterative development where old versions were preserved as comments instead of using version control.

---

### 5.2 `maxpool.sv` — 701 lines of dead commented-out code (81% of file)

**File:** [maxpool.sv:1-701](file:///Users/luthiraa/Documents/TALOS/maxpool.sv#L1-L701)  
**Severity:** 🔵 Medium — same issue as above  
**Source:** Both audits identified this

Three complete previous versions of `maxpool`, all commented out. Active code is lines 702–863 (162 lines).

---

### 5.3 No `neuron.sv` module exists — FC layer is hardcoded inside maxpool

**Severity:** 🔵 Medium — poor separation of concerns  
**Source:** Both audits identified this

The old commented-out code in `inference.sv` shows 10 explicit `neuron` module instantiations (lines 549–677) with proper weights, biases, and activation functions. This module was removed, and its MAC logic was **folded into `maxpool.sv`** (the `neuron0` accumulator, ROM, and `ST_ACCUM` state). This means:

- Maxpool is no longer a pure maxpool — it's a fused maxpool+FC module
- Adding more neurons requires duplicating the entire maxpool module or adding more accumulators + ROMs inside it
- The module cannot be reused in other contexts (e.g., a different CNN architecture)

---

### 5.4 `fixedpoint.sv` uses Verilog-2001 style in SystemVerilog project

**Severity:** 🔵 Low — tool warnings about mixed styles  
**Source:** Antigravity audit

The fixed-point library uses `reg`, `wire`, `always @(*)`, `always @(posedge clk or negedge rstn)` — all Verilog-2001 constructs. While Quartus handles mixed SV/Verilog seamlessly, linting tools and some simulators may produce warnings about mixing paradigms.

---

### 5.5 `ker_sel` initialized in declaration (non-portable)

**File:** [inference.sv:908](file:///Users/luthiraa/Documents/TALOS/inference.sv#L908)  
**Severity:** 🔵 Low — FPGA-only construct  

```systemverilog
logic [1:0] ker_sel = 0;    // declaration-time init
```

This is correctly reset in the FSM (line 1002: `ker_sel <= 2'd0`), so the init is redundant. On Cyclone V FPGAs, declaration-time initialization sets the configuration bitstream default — it works. But for ASICs or formal verification, this construct may not be supported.

---

## Summary — Fix Priority Matrix

| # | Issue | Severity | Impact on DE1-SoC Memory | Effort | Blocks Other Fixes? |
|---|-------|----------|--------------------------|--------|---------------------|
| 1.1 | `vert_align < IMG_WIDTH` | 🔴 Show-stopper | Out-of-bound `x[]` writes corrupt FFs | 1 line | Yes — corrupts CNN out |
| 1.2 | `running_max = 0` | 🔴 Show-stopper | No mem impact; corrupts all maxpool tiles | 3 lines | Yes — corrupts FC input |
| 1.3 | `convimg` reset range | 🔴 Show-stopper | 16,224 FFs left uninitialized on reset | 1 line | Partial — affects restart |
| 1.4 | Stale test harness | 🔴 Show-stopper | N/A | Rebuild test | Yes — no validation |
| 2.1 | 64→32 truncation | 🟡 Functional | 0 extra FFs; needs saturation logic | 5 lines | No |
| 2.2 | Only neuron7 ROM | 🟡 Functional | Need 9 more ROMs (36 M10K blocks) | 2–4 hrs | No |
| 2.3 | Hardcoded outmax size | 🟡 Functional | 0 extra FFs | 1 line | No |
| 2.4 | HEX shows 8/676 | 🟡 Debug | ~288 LUTs for wider mux | 1 line | No |
| 2.5 | HEX in inference | 🟡 Arch | ~42 LUTs misplaced | 30 min | No |
| 3.1 | All arrays in FFs | 🔴 Scalability | **~91K FFs → 9 M10K blocks** if fixed | 4+ hrs | Blocks 10-neuron expansion |
| 3.2 | ROM over-provisioned | 🟠 Waste | 1 extra M10K block | 10 min | No |
| 3.3 | Hardcoded image | 🟠 Usability | ~12K LUTs for constants | 1 hr | No |
| 3.4 | No DSP inference | 🟠 Waste | ~256 ALMs wasted per multiply | 20 min | No |
| 4.1 | QSF unused pins | 🟠 Noise | 0 | 15 min | No |
