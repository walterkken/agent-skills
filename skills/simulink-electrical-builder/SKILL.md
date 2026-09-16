---
name: simulink-electrical-builder
description: "Design and assemble electrical-engineering Simulink/Simscape models from MATLAB examples and reusable modules. Use when the user wants to build, modify, reconstruct, or modularize a Simulink electrical simulation, especially microgrids, wind/PV/storage, converters, machines, transformers, faults, grid-forming/grid-following controls, and power-system studies. First confirm the study purpose and top-level architecture; then select compatible example-derived modules, generate MATLAB build scripts, validate release/toolbox/backend compatibility, and produce a reproducible .slx model locally. Also responds to Simulink 电气搭建、Simulink 仿真搭建、Electrical Builder and Simulink EE Builder."
---

# Simulink Electrical Builder

Build electrical-engineering Simulink models as reproducible model-construction projects, not as opaque one-off `.slx` files.

## Non-negotiable workflow

### 1. Confirm purpose and architecture before building

Before choosing blocks, present a compact proposed architecture and ask the user to confirm only the items that materially change the model:

- **Study purpose**: steady state, RMS/electromechanical transient, EMT, converter control, protection, HIL/real-time, parameter sweep, fault ride-through, stability assessment, etc.
- **Topology**: source(s) → converter/machine → transformer/line/bus → load/grid/storage, including buses and connection points.
- **Plant/control scope**: which components need switching-level detail, averaged models, phasor/RMS abstraction, or control-only models.
- **MATLAB release and products**: especially Simulink, Simscape, Simscape Electrical, Stateflow, Simulink Control Design, and legacy Specialized Power Systems availability.
- **Inputs/disturbances**: faults, load steps, wind/irradiance profiles, voltage/frequency steps, breaker events, current limits, islanding, etc.
- **Required outputs**: voltages, currents, P/Q, frequency, rotor speed/angle, DC-link voltage, SOC, controller states, stability indicators, logging format.

Do not begin detailed wiring while the intended system boundary is still ambiguous. If the user already supplied these facts, summarize the architecture and proceed without re-asking them.

### 2. Detect the modeling backend before module selection

Run `matlab/simee_detect_environment.m` or otherwise determine the MATLAB release and installed products.

Use one primary physical-network backend per connected electrical network:

- `simscape-electrical-native`: preferred for new projects and mandatory for R2026a+ because Specialized Power Systems was removed.
- `specialized-power-systems`: legacy path for older installed releases and existing SPS projects when the required blocks/examples are available.
- `simulink-control-only`: for controllers, estimators, supervisory logic, signal processing, and test harnesses that interface to a plant through Simulink signals.

Never directly mix Simscape conserving ports with SPS electrical ports. Mixed projects may contain both technologies only as separated model regions connected through explicit signal-level or controlled-source interfaces whose physical meaning is documented.

### 3. Select examples as evidence-backed module sources

Read `catalog/examples.json` and `catalog/compatibility.md`. Prefer MathWorks examples or installed MathWorks libraries because their parameterization, solver assumptions, and required products are documented.

For each requested subsystem, record:

- module role and fidelity;
- source example/library and official URL;
- backend (`simscape-electrical-native`, `specialized-power-systems`, or `simulink-control-only`);
- minimum/maximum release when known;
- required products;
- electrical base values and units;
- solver/sample-time assumptions;
- ports and signal semantics;
- known incompatibilities.

Do not copy proprietary MathWorks example binaries into this repository. Extract/copy blocks only from the user's locally installed MATLAB examples or libraries when generating the user's local project.

### 4. Compose by modules, not by scattered blocks

Prefer top-level subsystems/model references with stable interfaces:

- `GRID` / source
- `NETWORK` / transformer / line / bus
- `GEN_*` / synchronous machine / DFIG / PV / wind
- `CONV_*` / GFM / GFL / rectifier / inverter
- `BESS`
- `LOAD_*`
- `FAULTS_BREAKERS`
- `MEASUREMENT`
- `CONTROL_*`
- `SUPERVISORY`
- `LOGGING_METRICS`

A module should expose a small number of meaningful interfaces rather than many internal signals. Preserve the internal structure of trusted example subsystems until there is a reason to refactor them.

### 5. Run compatibility checks before wiring

Reject or explicitly adapt a combination when any of these disagree:

- physical-network backend;
- nominal frequency;
- phase representation and connection convention;
- SI vs per-unit parameterization and base values;
- voltage level and transformer ratio;
- continuous/discrete solver assumptions;
- control sample times and PWM frequency;
- averaged vs switching semiconductor fidelity;
- phasor/RMS vs EMT domain;
- machine mechanical interface assumptions;
- required product/release availability.

For discrete control sample times, require exact equality or an intentional integer-rate relationship unless a rate transition is added. For switching converters, ensure the global/local solver and step size are appropriate for switching frequency and the study goal.

### 6. Build reproducibly

Use `matlab/simee_build.m` with a generated blueprint JSON when possible. The blueprint is the source of truth for model name, modules, parameters, connections, solver configuration, and provenance.

Programmatic construction should use documented Simulink APIs such as `new_system`, `load_system`, `add_block`, `set_param`, `add_line`, and `save_system`. Save generated artifacts in a user project folder, not in this Skill directory.

When a requested module comes from an installed example, copy the smallest coherent subsystem that preserves its control/plant assumptions. Avoid copying the entire example unless the user explicitly wants a derivative of that example.

### 7. Validate before declaring success

At minimum:

1. update/compile the model;
2. report unresolved library links or missing products;
3. inspect algebraic-loop/solver errors;
4. run a short nominal simulation;
5. verify the requested signals exist and have physically plausible dimensions/units;
6. run the user's key disturbance;
7. compare at least one expected invariant or benchmark (power balance, rated operating point, steady-state frequency/voltage, known example trace, etc.);
8. save the `.slx`, blueprint, build script, run script, and a short `MODEL_REPORT.md`.

Do not claim the model is validated if MATLAB execution was unavailable. In that case, deliver the generated source files and clearly mark validation as pending on the user's MATLAB installation.

## Decision policy for fidelity

Choose the lowest fidelity that can answer the engineering question:

- energy management / hours-minutes → system-level or averaged models;
- electromechanical dynamics / frequency support → machine + averaged converter/control;
- converter control / fault ride-through / current limiting → averaged EMT or switching model depending the claim;
- semiconductor switching / harmonics / protection timing → switching-level EMT;
- HIL / real-time → fixed-step-compatible blocks and explicit execution-rate budget.

Do not increase fidelity merely because a detailed example exists.

## Expected deliverables for a build request

Return or create:

- confirmed architecture diagram in text;
- selected module table with source/provenance;
- compatibility decisions and any adapters;
- blueprint JSON;
- MATLAB build script and run/validation script;
- generated `.slx` when MATLAB execution is available;
- `MODEL_REPORT.md` containing release, products, solver, module sources, key parameters, validation status, and known limitations.

## Repository files

- `catalog/examples.json` — curated official example/module source registry.
- `catalog/compatibility.md` — compatibility rules and release migration notes.
- `matlab/simee_detect_environment.m` — inspect release/products/SPS availability.
- `matlab/simee_build.m` — generic JSON-driven Simulink builder.
- `matlab/simee_validate_blueprint.m` — static compatibility validation.

## Safety against plausible-looking but broken models

Never invent a MathWorks library path, block parameter name, example identifier, or product dependency. Verify it from the local MATLAB installation or official documentation before relying on it. If the exact source path differs by release, resolve it locally and record the resolved path in the generated model report.
