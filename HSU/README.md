# A_inv Module

## Overview
The `A_inv` module is a hardware implementation for Galois Field (GF) operations using the primitive polynomial $x^6 + x + 1$. It performs dual-purpose calculations in a single cycle:
* **Square Mode:** 4-parallel squaring operations on 6-bit GF(2^6) elements
* **Inverse Mode:** 2×2 matrix-vector multiplication for $A^{-1}$ computation for $S_4$ (j=2) and $S_6$ (j=3) configurations

## I/O Port Specifications

| Port Name | Direction | Width | Description |
|:---|:---:|:---:|:---|
| `i_clk` | Input | 1 | Clock signal. |
| `i_rst_n` | Input | 1 | Asynchronous Reset (Active-Low). |
| `i_mode` | Input | 1 | **Mode Select:** `0` = Square; `1` = A Inverse (Matrix Multiply). |
| `i_4or6` | Input | 1 | **Config Select (Inverse Mode only):** `0` = $S_4$ (j=2); `1` = $S_6$ (j=3). |
| `i_gf_mul0_in1` | Input | 6 | Data input for GF Multiplier 0. |
| `i_gf_mul1_in1` | Input | 6 | Data input for GF Multiplier 1. |
| `i_gf_mul2_in1` | Input | 6 | Data input for GF Multiplier 2. |
| `i_gf_mul3_in1` | Input | 6 | Data input for GF Multiplier 3. |
| `i_undecoded_idx_1` | Input | 2 | **Primary index** for matrix coefficient selection (Inverse Mode only). |
| `i_undecoded_idx_2` | Input | 2 | **Secondary index** for matrix coefficient selection (Inverse Mode only). |
| `o_HS_1` | Output | 6 | **Output 1 (Registered).** Square result or matrix row 1 result. |
| `o_HS_2` | Output | 6 | **Output 2 (Registered).** Square result or matrix row 2 result. |
| `o_HS_3` | Output | 6 | **Output 3 (Registered).** Square result only; 0 in Inverse Mode. |
| `o_HS_4` | Output | 6 | **Output 4 (Registered).** Square result only; 0 in Inverse Mode. |

---

## Design Constraints & Timing

### 1. Registering Policy
* **Inputs:** All input signals are **NOT registered**. They feed directly into the internal combinational logic. Ensure inputs are stable relative to the clock edge.
* **Outputs:** All output signals (`o_HS_1`, `o_HS_2`, `o_HS_3`, `o_HS_4`) are **registered**. The result of the combinational logic is sampled on the rising edge of `i_clk`, resulting in a **1-cycle latency**.
  - **Timing:** Input signals set on `negedge` → combinational computation → `posedge` samples results into registers → `next posedge` reads registered outputs

### 2. Index Constraint (Inverse Mode Only)
> [!IMPORTANT]
> For correct functionality in **Inverse Mode** (`i_mode = 1`), the following condition must be met:
> 
> **`i_undecoded_idx_1 < i_undecoded_idx_2`**
>
> The internal decoder only supports cases where the first index is strictly less than the second (e.g., {0,1}, {0,2}, {0,3}, {1,2}, {1,3}, {2,3}). Valid indices range from 0 to 3.

---

## Functional Modes

### Mode 0: Square Mode (`i_mode = 0`)
The module performs 4-parallel squaring operations in GF(2^6).
* `o_HS_1` ← `i_gf_mul0_in1`² (mod p(x))
* `o_HS_2` ← `i_gf_mul1_in1`² (mod p(x))
* `o_HS_3` ← `i_gf_mul2_in1`² (mod p(x))
* `o_HS_4` ← `i_gf_mul3_in1`² (mod p(x))

**Configuration:** `i_4or6` is ignored in this mode.

### Mode 1: Inverse Mode (`i_mode = 1`)

#### Mathematical Background

For two failed subcodewords (b=2), the A Inverse Matrix computation solves:
$$\begin{bmatrix}
S_{2j}^{(l_1)} \\
S_{2j}^{(l_2)}
\end{bmatrix}
=
\begin{bmatrix}
1 & 1 \\
\alpha^{(2j+1)l_1} & \alpha^{(2j+1)l_2}
\end{bmatrix}^{-1}
\begin{bmatrix}
\tilde{S}_{2j}^{(0)} \\
\tilde{S}_{2j}^{(1)}
\end{bmatrix}$$

In GF(2) arithmetic (where addition = XOR), the matrix inverse simplifies to:
$$\mathbf{A}^{-1} = \frac{1}{\alpha^{(2j+1)l_1} + \alpha^{(2j+1)l_2}}
\begin{bmatrix}
\alpha^{(2j+1)l_2} & 1 \\
\alpha^{(2j+1)l_1} & 1
\end{bmatrix}$$

where:
* The exponent term is **(2j+1)** with j depending on the configuration
* For **S_4:** j = 2 → exponent = **5** → $\alpha^{5l_1}, \alpha^{5l_2}$
* For **S_6:** j = 3 → exponent = **7** → $\alpha^{7l_1}, \alpha^{7l_2}$
* $\alpha$ is the root of the primitive polynomial $p(x) = x^6 + x + 1$

#### Hardware Operation

The module performs the matrix-vector multiplication:
$$\begin{bmatrix} o_{HS1} \\ o_{HS2} \end{bmatrix} = \begin{bmatrix} a_{11} & a_{12} \\ a_{21} & a_{22} \end{bmatrix} \begin{bmatrix} i\_gf\_mul0\_in1 \\ i\_gf\_mul1\_in1 \end{bmatrix}$$

where the matrix coefficients are selected based on `i_4or6` and `{i_undecoded_idx_1, i_undecoded_idx_2}`:

$$o_{HS1} = (a_{11} \times i\_gf\_mul0\_in1) \oplus (a_{12} \times i\_gf\_mul1\_in1)$$
$$o_{HS2} = (a_{21} \times i\_gf\_mul2\_in1) \oplus (a_{22} \times i\_gf\_mul3\_in1)$$
$$o_{HS3}, o_{HS4} = 0$$

#### Matrix Coefficients (Detailed Breakdown)

##### S_4 Matrices (i_4or6 = 0, j = 2, Exponent = 5)

| Index (l₁, l₂) | a₁₁ | a₁₂ | a₂₁ | a₂₂ |
|:---:|:---:|:---:|:---:|:---:|
| (0, 1) | `000011` | `000010` | `000010` | `000010` |
| (0, 2) | `000101` | `000100` | `000100` | `000100` |
| (0, 3) | `101110` | `101111` | `101111` | `101111` |
| (1, 2) | `000011` | `111101` | `000010` | `111101` |
| (1, 3) | `000101` | `111001` | `000100` | `111001` |
| (2, 3) | `000011` | `010111` | `000010` | `010111` |

**Polynomial Basis (GF(2^6) elements):**

* **(0, 1):** $\begin{bmatrix} \alpha+1 & \alpha \\ \alpha & \alpha \end{bmatrix}$ 
  - Denominator: $\alpha^5 + 1 = \alpha + 1$

* **(0, 2):** $\begin{bmatrix} \alpha^2+1 & \alpha^2 \\ \alpha^2 & \alpha^2 \end{bmatrix}$
  - Denominator: $\alpha^{10} + \alpha^5 = \alpha^2 + 1$ (using $\alpha^6 = \alpha + 1$)

* **(0, 3):** $\begin{bmatrix} \alpha^5+\alpha^3+\alpha^2+\alpha & \alpha^5+\alpha^3+\alpha^2+\alpha+1 \\ \alpha^5+\alpha^3+\alpha^2+\alpha+1 & \alpha^5+\alpha^3+\alpha^2+\alpha+1 \end{bmatrix}$
  - Denominator: $\alpha^{15} + \alpha^5 = \alpha^5 + \alpha^3 + \alpha^2 + \alpha$

* **(1, 2):** $\begin{bmatrix} \alpha+1 & \alpha^5+\alpha^4+\alpha^3+\alpha^2+1 \\ \alpha & \alpha^5+\alpha^4+\alpha^3+\alpha^2+1 \end{bmatrix}$
  - Denominator: $\alpha^5 + \alpha^{10} = \alpha + 1$

* **(1, 3):** $\begin{bmatrix} \alpha^2+1 & \alpha^5+\alpha^4+\alpha^3+1 \\ \alpha^2 & \alpha^5+\alpha^4+\alpha^3+1 \end{bmatrix}$
  - Denominator: $\alpha^5 + \alpha^{15} = \alpha^2 + 1$

* **(2, 3):** $\begin{bmatrix} \alpha+1 & \alpha^4+\alpha^2+\alpha+1 \\ \alpha & \alpha^4+\alpha^2+\alpha+1 \end{bmatrix}$
  - Denominator: $\alpha^{10} + \alpha^{15} = \alpha + 1$

---

##### S_6 Matrices (i_4or6 = 1, j = 3, Exponent = 7)

| Index (l₁, l₂) | a₁₁ | a₁₂ | a₂₁ | a₂₂ |
|:---:|:---:|:---:|:---:|:---:|
| (0, 1) | `101101` | `101100` | `101100` | `101100` |
| (0, 2) | `100010` | `100011` | `100011` | `100011` |
| (0, 3) | `111010` | `111011` | `111011` | `111011` |
| (1, 2) | `101101` | `110011` | `101100` | `110011` |
| (1, 3) | `100010` | `010000` | `100011` | `010000` |
| (2, 3) | `101101` | `101001` | `101100` | `101001` |

**Polynomial Basis (GF(2^6) elements):**

* **(0, 1):** $\begin{bmatrix} \alpha^5+\alpha^3+\alpha^2+1 & \alpha^5+\alpha^3+\alpha^2 \\ \alpha^5+\alpha^3+\alpha^2 & \alpha^5+\alpha^3+\alpha^2 \end{bmatrix}$
  - Denominator: $\alpha^7 + 1 = \alpha^5 + \alpha^3 + \alpha^2 + 1$ (using $\alpha^6 = \alpha + 1$)

* **(0, 2):** $\begin{bmatrix} \alpha^5+\alpha & \alpha^5+\alpha+1 \\ \alpha^5+\alpha+1 & \alpha^5+\alpha+1 \end{bmatrix}$
  - Denominator: $\alpha^{14} + \alpha^7 = \alpha^5 + \alpha$ (using field reduction)

* **(0, 3):** $\begin{bmatrix} \alpha^5+\alpha^4+\alpha^3+\alpha & \alpha^5+\alpha^4+\alpha^3+\alpha+1 \\ \alpha^5+\alpha^4+\alpha^3+\alpha+1 & \alpha^5+\alpha^4+\alpha^3+\alpha+1 \end{bmatrix}$
  - Denominator: $\alpha^{21} + \alpha^7 = \alpha^5 + \alpha^4 + \alpha^3 + \alpha$

* **(1, 2):** $\begin{bmatrix} \alpha^5+\alpha^3+\alpha^2+1 & \alpha^5+\alpha^4+\alpha+1 \\ \alpha^5+\alpha^3+\alpha^2 & \alpha^5+\alpha^4+\alpha+1 \end{bmatrix}$
  - Denominator: $\alpha^7 + \alpha^{14} = \alpha^5 + \alpha^3 + \alpha^2 + 1$

* **(1, 3):** $\begin{bmatrix} \alpha^5+\alpha & \alpha^4 \\ \alpha^5+\alpha+1 & \alpha^4 \end{bmatrix}$
  - Denominator: $\alpha^7 + \alpha^{21} = \alpha^5 + \alpha$

* **(2, 3):** $\begin{bmatrix} \alpha^5+\alpha^3+\alpha^2+1 & \alpha^5+\alpha^3+1 \\ \alpha^5+\alpha^3+\alpha^2 & \alpha^5+\alpha^3+1 \end{bmatrix}$
  - Denominator: $\alpha^{14} + \alpha^{21} = \alpha^5 + \alpha^3 + \alpha^2 + 1$

---

**Note on Index Ordering:** All matrix coefficients assume $l_1 < l_2$. If your system has $l_1 > l_2$, simply swap the computed results $S^{(l_1)}$ and $S^{(l_2)}$.

---

## GF(2^6) Field Parameters

| Parameter | Value |
|:---|:---|
| **Primitive Polynomial** | $p(x) = x^6 + x + 1$ |
| **Field Size** | $2^6 = 64$ elements |
| **Operation (Addition)** | XOR (⊕) |
| **Operation (Multiplication)** | Polynomial multiplication modulo $p(x)$ |

**Note:** All coefficients in the matrix tables above are expressed as 6-bit binary numbers using the representation $[b_5 b_4 b_3 b_2 b_1 b_0]$ where $b_i$ is the coefficient of $\alpha^i$.