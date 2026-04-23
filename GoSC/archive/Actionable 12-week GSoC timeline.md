### Community Bonding (Weeks 1-2): Environment Setup & Architecture

The goal here is to establish your workflow, finalize the technical blueprint, and get comfortable with the existing codebase (particularly how CircuitVerse handles combinational analysis and canvas rendering).

**Week 1: Setup & Codebase Deep-Dive**

- **Concrete Deliverables:** Local environment set up (Backend/Frontend). A merged PR for a "good first issue" (if not already done) to test the CI/CD pipeline. A documented map of the current `Combinational Analysis` codebase, as you will likely reuse its Quine-McCluskey minimization logic.
    
- **Potential Blockers:** Docker container issues or environment variable misconfigurations.
    
- **Mentor Check-in Point:** "Are my local environment and testing suites perfectly mirroring the production setup? What specific files govern the current combinational circuit generation?"
    

**Week 2: Plan Refinement & UI/UX Wireframing**

- **Concrete Deliverables:** A finalized architectural design document. Figma wireframes (or similar) for the FSM input UI (e.g., will users input state transition tables, or draw a state diagram?).
    
- **Potential Blockers:** Scope creep. Deciding between a graphical state diagram editor (hard) vs. a tabular state transition input (more manageable for a first iteration).
    
- **Mentor Check-in Point:** "Let's review the UI/UX wireframes. Should we restrict the MVP to tabular inputs and standard flip-flops (D or JK) to ensure we hit the mid-term goals?"
    

---

### Coding Phase 1 (Weeks 3-6): Core Synthesis Engine

This phase focuses strictly on the "brain" of the synthesizer: turning data into logic equations.

**Week 3: Data Structures & Input Parsing**

- **Concrete Deliverables:** Creation of the internal data models (classes/structs) to represent States, Transitions, Inputs, and Outputs. A robust parser that converts the UI input (JSON/Form data) into this internal FSM model.
    
- **Potential Blockers:** Handling invalid user inputs (e.g., unreachable states, conflicting transitions) without crashing the application.
    
- **Mentor Check-in Point:** "How should the parser handle and display validation errors back to the user?"
    

**Week 4: State Assignment & Encoding**

- **Concrete Deliverables:** Implementation of state encoding algorithms. The engine should automatically assign binary values to states (e.g., State A = 00, State B = 01). Bonus: Add an option for One-Hot encoding.
    
- **Potential Blockers:** Ensuring the logic cleanly scales when the user inputs an odd number of states (requiring optimization of unused state combinations/don't cares).
    
- **Mentor Check-in Point:** "Review my encoding logic—are there any edge cases with 'don't care' conditions that I'm overlooking?"
    

**Week 5: Boolean Logic Generation**

- **Concrete Deliverables:** Integration of the encoded FSM with a logic minimizer (like Quine-McCluskey). Generation of the minimized sum-of-products (SOP) boolean equations for the next-state logic and output logic.
    
- **Potential Blockers:** Performance bottlenecks. Minimization algorithms can freeze the browser if the FSM has too many variables.
    
- **Mentor Check-in Point:** "Should we hard-cap the number of FSM states/inputs to prevent browser memory crashes during minimization?"
    

**Week 6: Circuit Mapping Engine**

- **Concrete Deliverables:** The translator that takes the minimized boolean equations and maps them to CircuitVerse canvas elements (AND, OR, NOT gates, and Flip-Flops).
    
- **Potential Blockers:** Algorithmic layout. Generating the components is easy; placing them on the canvas so they don't look like a tangled mess of wires is incredibly difficult.
    
- **Mentor Check-in Point:** "What are the existing best practices in the codebase for auto-routing wires and spacing generated gates?"
    

---

### Mid-term Evaluation (Week 7)

- **Concrete Deliverable:** A working, testable MVP of the FSM Synthesizer. A user should be able to input a basic 3-state Moore machine via a rudimentary interface, and the engine should generate a functionally correct (even if visually messy) circuit on the canvas.
    
- **Potential Blockers:** Tying the independent engine modules together might reveal data-type mismatches.
    
- **Mentor Check-in Point:** "Does the MVP meet the organization's mid-term expectations? What is the immediate priority for Phase 2?"
    

---

### Coding Phase 2 (Weeks 8-11): UI Integration & Advanced Features

With the engine working, the focus shifts to user experience, edge cases, and robustness.

**Week 8: Frontend UI Implementation**

- **Concrete Deliverables:** Building the actual FSM input modal using Vue.js (or the current frontend stack). Ensuring it is responsive, accessible, and matches the CircuitVerse design system.
    
- **Potential Blockers:** Synchronizing the Vue component state with the legacy canvas state.
    
- **Mentor Check-in Point:** "Are there any specific component libraries or CSS guidelines I must strictly adhere to for this modal?"
    

**Week 9: Connecting UI to Engine & Auto-Layout Refinement**

- **Concrete Deliverables:** Wiring the frontend form to the backend/JS engine. Improving the spatial layout algorithm from Week 6 so the generated circuit is neat, modular, and easy to read.
    
- **Potential Blockers:** The auto-routing logic for wires might loop or overlap confusingly.
    
- **Mentor Check-in Point:** "Let's review the visual output of the synthesized circuits. Are there adjustments needed for the bounding boxes of the components?"
    

**Week 10: Advanced Features (Mealy/Moore & Custom Flip-Flops)**

- **Concrete Deliverables:** Expanding the engine to explicitly support both Mealy (outputs depend on inputs + state) and Moore (outputs depend only on state) architectures. Adding user selection for D-type vs. JK-type flip-flops.
    
- **Potential Blockers:** Mealy and Moore machines require different timing and wiring logic; keeping the codebase DRY (Don't Repeat Yourself) while separating these paradigms.
    
- **Mentor Check-in Point:** "Are my architectural distinctions between the Mealy and Moore generation logic clean and maintainable?"
    

**Week 11: Comprehensive Testing & Debugging**

- **Concrete Deliverables:** High test coverage. Unit tests for the parsing, encoding, and minimization logic (using Jest/Vitest). Integration tests ensuring the UI triggers the correct canvas rendering.
    
- **Potential Blockers:** Writing reliable tests for canvas elements and graphical wire routing can be notoriously flaky.
    
- **Mentor Check-in Point:** "What is the minimum acceptable test coverage percentage for this new module before final submission?"
    

---

### Final Week (Week 12): Documentation & Code Cleanup

- **Concrete Deliverables:** Complete developer documentation for the FSM module. A user-facing tutorial or interactive guide on how to use the FSM Synthesizer. Final code formatting, linting, and squash-merging of commits.
    
- **Potential Blockers:** Underestimating the time it takes to write high-quality, clear documentation.
    
- **Mentor Check-in Point:** "Can we do a final review of the PR and documentation to ensure everything is ready for the GSoC final submission?"