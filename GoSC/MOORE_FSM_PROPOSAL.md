# GSoC 2026 Proposal: Moore Machine FSM Visualizer for CircuitVerse

## My Background & Motivation
I'm passionate about making circuit logic easier to understand. Right now, students manually convert FSM diagrams to circuits—adding states, transitions, drawing logic gates. It's tedious and error-prone.

I want to build a tool that lets students **visualize and simulate Moore machines** interactively in CircuitVerse, then export them as working circuits.

## The Problem
- FSM diagrams are abstract; students don't see how they map to actual circuits
- Manual conversion is error-prone (missed transitions, wrong logic)
- CircuitVerse has great circuit tools but no FSM integration
- Reference tools like https://madebyevan.com/fsm/ show *what's possible*, but don't export to CircuitVerse

## My Solution: 3-Month Plan

### Phase 1 (Weeks 1-4): Moore Machine Basics
**Goal:** Users can define Moore machines and see state diagrams, then simulate them

- **Week 1-2: Visual FSM Editor**
  - Interactive state diagram editor (inspired by Evan's tool)
  - Add/delete/connect states
  - Define inputs and outputs
  - Real-time validation of transitions
  - **Deliverable:** Users can draw a Moore machine, see visualization

- **Week 3: Input/Output Handling**
  - Map inputs to transitions
  - Map states to outputs
  - Simulation engine for testing
  - **Deliverable:** Users can simulate their Moore machine step-by-step

- **Week 4: Export and Testing**
  - Export FSM definition (JSON format)
  - Test suite covering edge cases
  - Documentation for users
  - **Deliverable:** 10+ working FSM examples, documented

### Phase 2 (Weeks 5-8): Circuit Generation
**Goal:** Automatically generate working CircuitVerse circuits from Moore machines

- **Week 5-6: State Encoding**
  - Binary encoding for states
  - Truth table generation for flip-flops
  - Logic equation generation
  - **Deliverable:** State encoding + equations for example FSMs

- **Week 7: Circuit Synthesis**
  - Generate CircuitVerse components (flip-flops, logic gates)
  - Build circuit from equations
  - **Deliverable:** Simple Moore machines → working CircuitVerse circuits

- **Week 8: Testing & Validation**
  - Verify generated circuits match FSM behavior
  - Test coverage for synthesis engine
  - **Deliverable:** 5+ test cases, all passing

### Phase 3 (Weeks 9-12): Polish & Documentation
**Goal:** Production-ready tool with clear user docs and contributor guide

- **Week 9-10: UI Integration**
  - Integrate Moore FSM editor into CircuitVerse UI
  - Clear workflow: define → validate → synthesize → simulate
  - Error messages and user feedback
  - **Deliverable:** Working UI integration, live in CircuitVerse

- **Week 11: Documentation**
  - User guide with examples
  - Contributor guide for extending to Mealy machines
  - Technical architecture documentation
  - **Deliverable:** 3 documentation files, review-ready

- **Week 12: Final Review & Cleanup**
  - Address feedback from mentor and reviewers
  - Performance optimization if needed
  - Final testing before submission
  - **Deliverable:** Production-ready, all tests green

## Why Moore Machines First?
- Simpler than Mealy (outputs depend on state only, not inputs)
- Good learning progression: perfect first step
- Establishes foundation for future Mealy support
- Reference tool (Evan's) is Moore-focused

## Success Criteria
1. ✅ Users can create Moore FSMs in CircuitVerse UI
2. ✅ FSMs simulate correctly (step through, check outputs)
3. ✅ Generated circuits work in CircuitVerse simulator
4. ✅ 15+ test cases, all passing
5. ✅ Clear documentation for users + contributors

## Why I'm Qualified
- Strong experience with digital logic (FSMs, truth tables, flip-flop logic)
- Familiar with CircuitVerse codebase (recent contribution history)
- Good at breaking complex problems into manageable parts
- Committed to writing clean, documented code

## Future Work (After GSoC)
- Extend to Mealy machines (similar approach, outputs depend on state + input)
- Add graphical FSM minimization tools
- Optimize circuit generation for complex machines
- Community-contributed FSM library
