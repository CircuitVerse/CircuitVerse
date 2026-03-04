### 🌳 Skill Tree Breakdown

To build the FSM Synthesizer frontend, you need to progress through these nodes:

1. **Prerequisites:** HTML/CSS structure, Modern JavaScript (ES6+), Array methods (`map`, `filter`, `reduce`), and Arrow Functions.
    
2. **Vue.js Core:** Reactivity (`ref`, `reactive`), the Composition API, and Template Syntax.
    
3. **Component Architecture:** Props (passing data down), Emits (sending events up), and Lifecycle Hooks (what happens when a component loads/unloads).
    
4. **Project-Specific Skills:** Form Input Bindings (for the FSM state tables) and basic HTML5 `<canvas>` manipulation (to understand how CircuitVerse renders elements).
    

---

### 🗺️ Week-by-Week Roadmap & Exercises

**Week 1: Modern JavaScript Essentials**

- **Focus:** Brushing up on the JS features Vue relies on heavily.
    
- **Exercise:** Write a simple JS script that takes an array of FSM state objects (e.g., `{ state: 'A', next: 'B' }`) and uses `.filter()` and `.map()` to return only specific transitions.
    

**Week 2: Vue 3 Basics & Reactivity**

- **Focus:** Setting up a Vite + Vue project and understanding how Vue updates the screen automatically when data changes.
    
- **Exercise:** Build a simple "Counter" app, but modify it into a "State Toggler" (clicking a button cycles text from State A -> State B -> State C).
    

**Week 3: Component Communication**

- **Focus:** Breaking an app into pieces. Understanding `defineProps` and `defineEmits`.
    
- **Exercise:** Create a parent component holding a list of logical gates, and a child component that displays a single gate. Pass the gate's name to the child via props, and emit an event when the user clicks the child component.
    

**Week 4: Forms & User Input (`v-model`)**

- **Focus:** Capturing user data smoothly. This is critical for the UI where users will type in their FSM truth tables.
    
- **Exercise:** Build a dynamic form where a user can add or remove rows for "Current State", "Input", and "Next State".
    

**Week 5: The HTML5 Canvas**

- **Focus:** CircuitVerse uses Canvas heavily for drawing wires and gates.
    
- **Exercise:** Use standard JS within a Vue component's `onMounted` lifecycle hook to draw a simple rectangle (representing a logic gate) and a line (representing a wire) on a `<canvas>` element.
    

**Weeks 6-8: The Mini-Project Implementation**

- **Focus:** Tying it all together by building the Capstone Mini-Project (details below).
    

---

### 📚 Curated Resources (Project-Based & Hands-On)

- **Documentation:** [The Official Vue.js 3 Guide](https://vuejs.org/guide/introduction.html). Read specifically through the "Composition API" toggles. It is widely considered one of the best-written documentation sites in the industry.
    
- **Interactive Tutorial:** [Vuejs.org Tutorial](https://vuejs.org/tutorial/). A built-in, browser-based coding environment that walks you through core concepts step-by-step.
    
- **Video Course:** "Vue 3 Crash Course" by Traversy Media or "Vue.js 3 Tutorial" by Net Ninja on YouTube. Both are excellent for visual, hands-on learners who want to build alongside the instructor.
    
- **Canvas API:** [MDN Canvas API Tutorial](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial).
    

---

### 🛠️ Capstone Mini-Project: "The Mini FSM Visualizer"

To prove you are ready for the CircuitVerse codebase, you will build a standalone Vue application that mimics a tiny slice of your GSoC goal.

**The Requirements:**

1. **The Input UI:** Create a Vue form where a user can define up to 3 states. They input the _Current State_, _Input (0 or 1)_, and _Next State_.
    
2. **The State Manager:** Use Vue's reactivity to store this table data dynamically.
    
3. **The Canvas Renderer:** Create a separate Vue component containing a `<canvas>`. When the user submits the form, draw basic circles for the states and lines connecting them based on the user's input.
    
4. **The Interactivity:** Add a button that "steps" through the machine, highlighting the current active state circle in a different color.
    

This project forces you to handle reactive state, pass data between components, and interact with the canvas—the exact trifecta needed for the CircuitVerse FSM Synthesizer.