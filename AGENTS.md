# Repository Guidelines

## Project Structure & Module Organization
- `src/` contains SystemVerilog RTL (e.g., `cnn.sv`, `maxpool.sv`, `inference.sv`) and `src/dump/` waveform dump wrappers (`dump_<module>.sv`).
- `test/` contains Cocotb testbenches (`test_<module>.py`) and test-side helper assets.
- `tools/` includes Python utilities for generating memory/init artifacts (`gen_fc_mem.py`, `gen_initial_block.py`).
- `model/` and `data/` store quantized weights and dataset inputs.
- Generated outputs belong in `waveforms/`, `sim_build/`, and `logs/`; treat these as build artifacts.

## Build, Test, and Development Commands
- `python3 -m venv venv && source venv/bin/activate` sets up a local Python environment.
- `pip install --upgrade pip cocotb` installs simulation test dependencies.
- `make test_cnn` runs RTL + Cocotb for the CNN module and writes `waveforms/cnn.vcd`.
- `make test_maxpool`, `make test_division`, `make test_inference` run other module-level regressions.
- `make lint` runs `verible-verilog-lint` on `src/*.sv` (if Verible is installed).
- `make clean` removes `sim_build/`, generated VCDs, and transient test outputs.

## Coding Style & Naming Conventions
- Use lowercase snake_case for filenames and module-aligned test names: `src/<module>.sv`, `test/test_<module>.py`.
- Keep RTL style consistent with existing code: explicit `logic` types, `always_ff`/`always_comb`, and reset-safe initialization.
- Use 4-space indentation in Python; keep Cocotb tests readable and deterministic when possible.
- When adding a new RTL source file, update `SOURCES` in `Makefile` so it is compiled in regressions.

## Testing Guidelines
- Primary framework is Cocotb with Icarus Verilog (`iverilog` + `vvp`).
- Add or update `test/test_<module>.py` when changing module behavior.
- Ensure `results.xml` has no failures and relevant waveform output is generated for debug.
- Prefer focused module tests before running larger integration flows.

## Commit & Pull Request Guidelines
- Keep commits small and single-purpose; use short, imperative messages (history trend: concise lowercase summaries).
- Recommended format: `<area>: <action>` (example: `inference: fix Q16 accumulation overflow`).
- PRs should include: change summary, impacted modules/files, test commands run, and key outputs (logs or waveform screenshots when useful).
- Link related issues/tasks and call out any known limitations or follow-up work.

## Configuration & Artifact Hygiene
- Do not commit generated simulation artifacts (`waveforms/*.vcd`, `sim_build/`, `results.xml`, temp logs).
- Avoid hardcoded absolute paths; use repository-relative paths in scripts and tests.
