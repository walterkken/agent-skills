# Simulink Electrical Builder — Compatibility Rules

This file is the compatibility gate used before composing example-derived electrical modules.

## 1. Release/backend rule

| MATLAB release | Preferred new-project backend | Legacy SPS status | Builder behavior |
| --- | --- | --- | --- |
| R2026a+ | Simscape Electrical native | Specialized Power Systems removed | Do not select SPS blocks. Migrate old SPS projects or rebuild with native Simscape Electrical components. |
| R2025b | Simscape Electrical native for new work | SPS may still exist; conversion assistant is available | Existing SPS projects may be maintained, but new modules should not increase SPS dependency without a reason. |
| R2024b–R2025a | Simscape Electrical native where practical | SPS may exist | Prefer native blocks for new reusable modules; legacy projects can stay SPS when migration cost is not justified. |
| R2021b–R2024a | Depends on installed project/examples | SPS commonly used in existing projects | Match the user's installed environment and existing model. Do not assume current documentation paths exist. |

Never infer availability from release alone. Detect installed products and attempt to resolve required libraries locally.

## 2. Physical-domain isolation

A connected electrical network must use one physical modeling technology.

Allowed:

- Simscape Electrical physical network + Simulink controller through sensors/converters/control inputs.
- SPS network + Simulink controller through SPS measurements/control signals.
- Separate SPS and Simscape test models in the same project.
- Explicit signal-level coupling between physically separated abstractions when the interface equations, units, and causality are documented.

Not allowed:

- directly wiring a Simscape conserving electrical port to an SPS electrical terminal;
- silently replacing a three-phase physical connection by three scalar Simulink signals;
- mixing phasor-domain and EMT-domain plant sections without a defined interface model.

## 3. Fidelity compatibility

Use a single declared study fidelity per phenomenon:

| Study goal | Typical plant choice | Converter choice | Time scale |
| --- | --- | --- | --- |
| Energy management | system-level / algebraic / averaged | averaged | seconds to hours |
| Frequency support / electromechanical transient | dynamic machines + network | averaged converter/control | milliseconds to tens of seconds |
| Converter control / current limiting / FRT | EMT-capable network | averaged or switching | microseconds to seconds |
| Harmonics / switching devices / detailed protection | EMT | switching devices | sub-microseconds to milliseconds depending on switching frequency |
| HIL / real time | fixed-step compatible simplification | fixed-step averaged or suitable switching model | target-rate dependent |

Do not insert a switching-level converter into an hours-long EMS model unless the user explicitly needs a multi-rate/co-simulation architecture.

## 4. Electrical bases and units

Before connecting two modules, compare and record:

- nominal line-line / line-neutral voltage convention;
- nominal frequency;
- rated apparent/active power;
- SI vs per-unit parameterization;
- per-unit base power and base voltage;
- transformer vector group and phase shift;
- grounding/neutral convention;
- positive-sequence only vs full three-phase representation.

If bases differ, convert parameters or insert the physically correct transformer/interface. Never treat per-unit values from different bases as directly compatible.

## 5. Solver compatibility

For Simscape networks, ensure each physical network has the required Solver Configuration and reference blocks. Use the Simscape local solver only when it supports the selected component set and study requirement.

For switching models, choose the step size with respect to switching frequency and the transient being measured. A model that runs with an excessively large step is not considered validated.

For mixed continuous/discrete control:

- declare each controller sample time;
- require equal rates or intentional integer multiples;
- add rate transitions when crossing asynchronous/disparate rates;
- keep PWM/carrier rate separate from outer control loops;
- document zero-order holds, delays, filters, and measurement sampling.

## 6. Control-frame compatibility

When combining converter or machine controls, verify:

- abc / alpha-beta / dq frame;
- Park-transform sign convention;
- angle reference and PLL/VSM angle source;
- power sign convention (generation positive or load positive);
- RMS/peak amplitude convention;
- radians vs degrees;
- electrical vs mechanical angular speed;
- frequency in Hz vs angular frequency in rad/s.

A dq controller copied from another example is not compatible merely because its input names match.

## 7. Module provenance

Every copied/adapted module should be traceable in `MODEL_REPORT.md` with:

- source example or library;
- official documentation URL;
- source MATLAB release;
- local source model/block path;
- modifications made;
- assumptions retained from the original example;
- validation performed after extraction.

## 8. Migration from Specialized Power Systems

For old SPS models:

1. inventory SPS blocks before changing the model;
2. preserve a baseline simulation and logged signals;
3. use the official conversion assistant where supported;
4. identify unsupported/partially supported blocks;
5. convert or replace modules in controlled groups;
6. rerun the same baseline scenario;
7. compare waveforms/steady-state values and document tolerances;
8. only then refactor the architecture.

Do not combine migration and controller redesign in one untraceable step.

## 9. Acceptance gate

A module combination is accepted only when all relevant entries below are either `PASS` or explicitly resolved by an adapter:

- backend
- release/product availability
- physical port type
- phase representation
- units/base values
- nominal frequency
- voltage/rating
- solver/fidelity
- sample time
- control frame/sign convention
- initialization/operating point
- required outputs/logging

If any item is unknown, mark it `UNKNOWN` and resolve it before claiming the integrated model is runnable.
