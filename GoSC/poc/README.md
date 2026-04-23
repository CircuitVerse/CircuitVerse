# FSM Synthesizer POC (Project 3)

This POC demonstrates the minimum technical pipeline for CircuitVerse Project 3:

1. Parse and validate FSM definitions.
2. Encode states (binary encoding).
3. Derive next-state and output logic expressions (canonical SOP form).
4. Emit a generated logic-block representation suitable for later mapping to CircuitVerse components.

## Files
- `fsm_poc.js`: core POC implementation
- `examples/moore_3state.json`: Moore FSM sample
- `examples/mealy_4state.json`: Mealy FSM sample
- `poc_check.js`: lightweight runner + assertions

## Run
```bash
node GoSC/poc/poc_check.js
```

## Output
The runner prints:
- state encodings
- next-state equations
- output equations
- generated logic block summary

## Notes
- Equations are generated in canonical SOP style for clarity.
- Boolean minimization and advanced layout are intentionally excluded from this MVP POC.
- D flip-flop model is assumed for next-state logic (`D_i = Q_i'`).
