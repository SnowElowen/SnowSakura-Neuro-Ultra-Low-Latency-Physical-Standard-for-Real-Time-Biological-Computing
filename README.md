# SnowSakura-Neuro: Physical Layer Implementation Specs for 15EG High-Density BCI

**Target: 36ns Zero-Jitter Total Latency (18ns PMA + 18ns Neural Parsing & Trigger)**  
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

---
*(Detailed XDC constraints and manual routing TCL scripts are kept in internal physical model iterations.)*
