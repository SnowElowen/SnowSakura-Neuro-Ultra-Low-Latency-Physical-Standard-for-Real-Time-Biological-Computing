# SnowSakura-Neuro: Ultra-Low Latency Physical Standard for Real-Time Biological Computing
This is SnowSakura-Neuro (SnowSakura 2)
## Introduction

I have always believed that the pursuit of ultimate hardware performance should not be confined solely to the world of financial competition. I am driven by a desire to contribute my capabilities to the advancement of Biological Computing and Neuroengineering. As such, this repository is dedicated to the biology domain, centered around my specialized Testbench (TB) ecosystem.

Unlike my highly-specialized HKEX HFT physical layer implementations, which are built for absolute isolation and speed, SnowSakura-Neuro is designed for a broader impact. I will periodically upload and maintain public-facing Verilog implementations for standard biological communication protocols—specifically versions featuring integrated Buffers to ensure community-wide usability.

To those following my HKEX HFT work: rest assured that I will maintain a rigorous Balance between these two domains.

A Note on Proprietary Logic:
Please understand that my personal Raw Mode configurations, XDC Constraints, and TCL Manual Routing scripts will remain private. These files contain highly specialized methodologies derived from my HFT research and represent core technical assets. However, I am committed to applying my expertise in Low-Latency architecture to provide the biological community with high-quality, distributable hardware logic that can truly push the boundaries of what is possible in science.


**Target: 36ns Zero-Jitter Total Latency (18ns PMA + 18ns Neural Parsing & Trigger) And 6466B OR 8B10B(BUFFER OR BYPASS)**  
**Deterministic for Multi-Channel Neural Spike Sorting & Closed-Loop Stimulation**

---

## Physical Layer Design Philosophy

*   **Determinism over Abstraction**: In the realm of 36ns latency, standard biological signal processing stacks (Python/C++ algorithms) are nothing but propagation noise.
*   **Hardware Sovereignty**: We bypass OS kernels, traditional DSPs, and standard IP blocks. Neural raw data streams are mapped directly to the **GTH Transceiver** (Raw Mode, buffer bypassed) and dedicated **LUT** resources via manual **Routing** and **TCL** scripts.
*   **Timing is Law**: Every clock cycle at **322.56 MHz** counts. The architecture strictly enforces a **6-FF Pipeline**: 3-cycle RX synchronization, 1-cycle spike classification, 1-cycle dual-path stimulation arbitration, and 1-cycle TX. More than two levels of **Combinational Logic** on the critical path is strictly prohibited.

---

## Implementation Constraints (ZU15EG Physical Layer)

*   **Clock Domain**: Strictly operating at 322.56 MHz for wire-speed parsing.
*   **Buffer Bypass**: GTH receiver must use raw mode with the elastic buffer bypassed for manual alignment to eliminate non-deterministic latency.
*   **Manual Synchronization**: A Triple-FF synchronization chain must be manually implemented in RTL for the asynchronous clock domain; Vivado default automatic constraints are forbidden.
*   **Logic Depth**: Maximum of two levels of combinational logic between any two registers on the GTH RX Data Path.

## Chapter 1: The Zero-Jitter Neural Processing Benchmark

This testbench, `tb_snowsakura_neuro_top.v`, establishes a high-performance physical layer baseline for deterministic biological signal processing on the **Zynq UltraScale+ ZU15EG** platform.

### Simulation Environment & Physical Parameters
*   **Clock Domain**: Operates at a precise **322.56 MHz** frequency (**3.1ns** period), simulating the recovered clock environment of a high-speed GTH transceiver.
*   **Data Path Simulation**: Models a **Raw Mode** data path that bypasses the internal elastic buffer. This is critical for eliminating non-deterministic latency (jitter) inherent in standard IP-based buffering.
*   **Target Latency**: Benchmarks a total path latency of **36ns**. This is partitioned into an **18ns PMA** hardware delay and an **18ns (6-cycle) logical budget**.

### Functional Mechanics
*   **Synthetic Spike Injection**: At wire-speed, the TB injects a specific 64-bit signature (`64'hA5A5_DEAD_BEEF_0001`) to simulate a high-density neural spike burst.
*   **Pipeline Verification**: It validates a **6-FF Pipeline** architecture. The implementation includes **3-cycle RX synchronization**, **1-cycle spike classification**, **1-cycle dual-path arbitration**, and **1-cycle TX**.
*   **Strict Timing Assertion**: The simulation employs a hard-coded logic check to ensure the output stimulus occurs within exactly 6 clock cycles of the input spike.
    > `if ((cycle_count - spike_injected_cycle) > 6)`
*   **Failure Protocol**: If the logic execution exceeds the 18ns budget, the TB triggers a `FATAL TIMING VIOLATION`. This indicates the presence of jitter or logic-path congestion that would compromise a real-time neural feedback loop.

### Objective
The TB is designed to prove that neural signal interfacing can achieve the same level of physical-layer determinism required by **HFT** (High-Frequency Trading) architectures, ensuring that closed-loop stimulation remains phase-coherent with biological intent.

---
*(Detailed XDC constraints and manual routing TCL scripts are kept in internal physical model iterations.)*
