# Pipelined AHB-to-APB Bridge

A pipelined AHB–APB bridge designed in Verilog HDL, built as part of the Maven Silicons SoC design program. The bridge lets a high-speed AHB master talk to low-speed APB peripherals, converting AHB pipelined transactions into APB Setup/Enable transfers.

## Architecture

The design has three main blocks:

- **AHB Master (verification BFM)** — generates configurable single and burst read/write transactions (SINGLE, INCR4/8/16, WRAP4/8/16).
- **AHB Slave Interface** (`ahb_slave.v`) — validates AHB transfers, decodes addresses, and pipelines address/data/control signals (`Haddr1/2`, `Hwdata1/2`, `Hwritereg/2`) for the APB side. Also drives read data back to the AHB master.
- **APB Controller** (`apb_pro.v`) — an 8-state FSM (`IDLE`, `WWAIT`, `READ`, `WRITE`, `WRITEP`, `RENABLE`, `WENABLE`, `WENABLEP`) that converts valid AHB transactions into APB Setup and Enable phases, and generates `HREADYOUT` to synchronize completion back to the AHB side.

A top-level wrapper (`top_bridge.v`) instantiates and connects the AHB Slave Interface and APB Controller, routing pipeline signals between them and read data (`Prdata_bridge`) back through the read path.

```
AHB Master → AHB Slave Interface → APB Controller → APB Peripheral
                    ↑                                      │
                    └──────────── Prdata_bridge ────────────┘
```

## Features

- Fully pipelined AHB-side address/data/control capture
- FSM-based APB controller handling both read and write transactions
- Support for single transfers and INCR/WRAP burst transfers (4/8/16 beats)
- Address decoding and peripheral select generation
- Read data returned to the AHB master via `Hrdata`

## Verification

A custom AHB Master BFM drives the DUT with configurable transactions:

- `ahb_burst_and_single_write()` — single and burst writes across all supported burst types
- `ahb_burst_and_single_read()` — single and burst reads, with data captured into an internal buffer for checking

Test cases covered:

| Test Case | Description |
|---|---|
| Single Write | Word write transaction |
| Single Read | Word read transaction |
| INCR4 Write | Incrementing burst write |
| INCR4 Read | Incrementing burst read |
| WRAP4 Write | Wrapping burst write |
| WRAP4 Read | Wrapping burst read |

All test cases were verified against expected AHB/APB protocol timing via waveform analysis.

## Synthesis

RTL was synthesized in Xilinx Vivado:

- Module hierarchy preserved after synthesis
- Internal communication between AHB Slave Interface and APB Controller maintained
- Netlist generated successfully for implementation

## Repository Structure

```
├── ahb_master.v      # AHB Master BFM (verification)
├── AHB_slave.v        # AHB Slave Interface
├── apb_pro.v          # APB Controller (FSM)
├── top_bridge.v        # Top-level wrapper
├── tb_bridge.v         # Testbench
└── docs/                # Waveforms, block diagrams, synthesis report
```

## Key Learnings

- Handling latch inference and combinational passthrough requirements for `Hrdata`
- Pipeline alignment across burst writes to keep AHB and APB timing synchronized
- FSM design for protocol bridging between two different bus timing domains

## Acknowledgment

Built as part of the **Maven Silicons** SoC design program.
