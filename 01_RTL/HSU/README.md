# A_inv Module

## Overview
The `A_inv` module is a hardware implementation for Galois Field (GF) operations. It performs dual-purpose calculations: 6-bit parallel squaring or weighted-sum inverse operations ($A^{-1}$) for $S_4$ and $S_6$ configurations.

## I/O Port Specifications

| Port Name | Direction | Width | Description |
|:---|:---:|:---:|:---|
| `i_clk` | Input | 1 | Clock signal. |
| `i_rst_n` | Input | 1 | Asynchronous Reset (Active-Low). |
| `i_mode` | Input | 1 | **Mode Select:** `0` = Square; `1` = A Inverse. |
| `i_4or6` | Input | 1 | **Config Select:** `0` = $S_4$; `1` = $S_6$. |
| `i_0or1` | Input | 1 | **Interleave Select:** `0` = $b_1$ (1st); `1` = $b_2$ (2nd). |
| `i_gf_mul0_in1` | Input | 6 | Data input for GF Multiplier 0. |
| `i_gf_mul1_in1` | Input | 6 | Data input for GF Multiplier 1. |
| `i_undecoded_idx_1` | Input | 2 | Primary coefficient selection index. |
| `i_undecoded_idx_2` | Input | 2 | Secondary coefficient selection index. |
| `o_HS_1` | Output | 6 | **Primary Output (Registered).** |
| `o_HS_2` | Output | 6 | **Secondary Output (Registered).** |

---

## Design Constraints & Timing

### 1. Registering Policy
* **Inputs:** All input signals are **NOT registered**. They feed directly into the internal combinational logic. Ensure inputs are stable relative to the clock edge.
* **Outputs:** All output signals (`o_HS_1`, `o_HS_2`) are **registered**. The result of the combinational logic is sampled on the rising edge of `i_clk`, resulting in a **1-cycle latency**.

### 2. Index Constraint
> [!IMPORTANT]
> For correct functionality in **Inverse Mode** (`i_mode = 1`), the following condition must be met:
> **`i_undecoded_idx_1 < i_undecoded_idx_2`**
>
> The internal decoder only supports cases where the first index is strictly less than the second (e.g., {0,1}, {0,2}, {0,3}, {1,2}, {1,3}, {2,3}).

---

## Functional Modes

### Square Mode (`i_mode = 0`)
The module acts as two independent squarers.
* `o_HS_1` = `i_gf_mul0_in1`²
* `o_HS_2` = `i_gf_mul1_in1`²

### Inverse Mode (`i_mode = 1`)
The module performs a weighted XOR of the two multipliers based on the selected configuration and indices.
* `o_HS_1` = (`i_gf_mul0_in1` × `coeff_0`) ⊕ (`i_gf_mul1_in1` × `coeff_1`)
* `o_HS_2` = `0` (Unused)