# One-Page Design: FSM to Circuit Synthesizer (Project 3)

## 1) Problem and Target User Flow
CircuitVerse users can build circuits manually, but there is no guided path for converting Finite State Machines into sequential logic circuits. This feature adds a practical learning bridge:

1. User defines FSM (states, symbols, transitions, outputs).
2. System validates and normalizes the FSM.
3. System encodes states and derives next-state/output logic.
4. System generates a CircuitVerse-compatible sequential circuit.
5. User opens, simulates, and edits the generated circuit.

## 2) FSM Data Model (MVP)
A normalized machine model should include:

- `machineType`: `moore` or `mealy`
- `inputs`: list of input symbols (MVP assumes binary input support first)
- `outputs`: output symbol set
- `states`:
  - `id` (unique state name)
  - `isInitial` (boolean)
- `transitions`:
  - `fromState`
  - `input`
  - `toState`
  - `output` (required for Mealy transitions; optional/ignored for Moore transitions)
- `stateOutputs` (Moore only): mapping from state -> output value

Validation constraints:
- Exactly one initial state.
- Deterministic transitions: for each `(state, input)`, only one transition.
- Transition completeness for declared symbols.
- No references to undefined states/symbols.

## 3) Moore/Mealy Conversion Strategy
### Shared pipeline
- Parse and validate FSM model.
- Assign deterministic state encodings.
- Build next-state truth tables.
- Minimize/derive Boolean expressions.
- Map expressions to gates and sequential elements.

### Moore handling
- Outputs depend only on current state bits.
- Output equations derived from encoded state mapping.

### Mealy handling
- Outputs depend on current state bits and current input bits.
- Output equations derived from transition-level output labels.

Implementation note:
- Keep one common synthesis core with machine-type specific output derivation adapters to avoid duplicated logic.

## 4) State Encoding and Equation Derivation (MVP)
- Default encoding: binary encoding of states.
- Let number of states be `N`; number of state bits is `k = ceil(log2(N))`.
- For each next-state bit `Q_i'`, derive equation from transition table.
- For each output bit `Z_j`, derive equation based on Moore/Mealy mode.

MVP simplification:
- Start with deterministic binary-input FSMs.
- Add one-hot encoding as stretch feature.

## 5) Output Circuit Representation
The synthesis output should produce a CircuitVerse-compatible structure containing:

- Sequential elements:
  - `k` flip-flops (D flip-flops for MVP)
- Combinational network:
  - gates implementing each `Q_i'` equation
  - gates implementing each output equation `Z_j`
- Net connectivity:
  - wiring between current-state bits, input pins, combinational gates, and flip-flop inputs
- Metadata:
  - component IDs
  - positional placeholders for baseline readable layout
  - labels for state bits and outputs

Generated circuit requirements:
- Opens in simulator without manual patching.
- Produces behavior equivalent to source FSM for benchmark test vectors.
- Remains editable by user after generation.

## 6) MVP Boundaries and Non-Goals
MVP includes:
- Structured/tabular FSM input (not advanced graph editor).
- Moore + Mealy synthesis for small-to-medium FSM sizes.
- Functional correctness over aggressive optimization.

MVP excludes:
- Advanced auto-layout/wire routing quality guarantees.
- Very large FSM optimization and formal performance guarantees.
- Non-FSM automata models.

## 7) Testing and Verification Plan
- Unit tests:
  - parser/validator
  - state encoding
  - next-state and output equation generation
- Integration tests:
  - end-to-end FSM input to runnable synthesized circuit
- Benchmark fixtures:
  - at least one Moore and one Mealy canonical machine

Acceptance definition:
- Synthesized circuit outputs match expected transition/output behavior for benchmark input sequences.

## 8) Risks and Early Mitigation
- Scope creep risk: keep MVP input tabular and defer advanced editor.
- Integration risk: reuse existing simulator serialization conventions early.
- Complexity risk: set practical state/input limits and warn users when exceeded.

## 9) Immediate Next Steps (This Week)
1. Finalize schema contract and validator rules.
2. Build 3-5 state POC with one Moore and one Mealy example.
3. Share this design with mentors and confirm MVP boundaries.
4. Start 1-2 supporting PRs (tests/bugfix/docs) for proposal credibility.
