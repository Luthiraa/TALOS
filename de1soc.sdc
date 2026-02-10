# DE1-SoC base clock
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

# Recommended defaults
derive_pll_clocks
derive_clock_uncertainty
