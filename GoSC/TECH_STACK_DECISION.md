# Tech Stack Decision: Moore FSM Visualizer

## Current CircuitVerse Tech Stack
- **Backend:** Ruby on Rails
- **Frontend:** Vue.js (Composition API)
- **Editor/Simulator:** Canvas-based custom implementation
- **Build:** Vite (modern, fast)

## Design Tool Comparison

### Option A: Canvas-Based (Like Evan's FSM Tool)
**Pros:**
- Full control over rendering (smooth, responsive)
- Small library size (Evan's: pure JavaScript)
- Matches CircuitVerse's existing simulator approach
- Fast, no dependencies

**Cons:**
- More complex to implement drag/drop, zoom, pan
- Text rendering trickier
- Accessibility challenges

**Estimate:** 2-3 weeks to MVP

---

### Option B: Vue.js + SVG Components
**Pros:**
- Reuses CircuitVerse's existing Vue infrastructure
- Easier to integrate with rest of UI
- Better accessibility (SVG is semantic HTML)
- Easier drag-drop with Vue directives
- Easier to test (component-based)

**Cons:**
- Slightly heavier (but negligible)
- Need to learn SVG manipulation in Vue

**Estimate:** 2-3 weeks to MVP

---

### Option C: Library-Based (e.g., Mermaid, GoJS, yEd)
**Pros:**
- Battle-tested, feature-rich
- Less code to maintain

**Cons:**
- Overkill for simple Moore machines
- Limited customization for CircuitVerse export
- Licensing/dependency concerns
- Doesn't match CircuitVerse styling

**Estimate:** Higher maintenance cost long-term

---

## Recommendation: **Option B (Vue.js + SVG)**

**Reasoning:**
1. **Consistency:** Matches CircuitVerse's existing architecture
2. **Integration:** Easy to hook into Rails backend
3. **Maintainability:** Future contributors understand Vue
4. **Speed:** Not slower than Evan's tool for educational use
5. **Extensibility:** Easy to add Mealy support later

## Architecture Plan

```
frontend/
├── components/
│   ├── FsmEditor.vue          # Main editor component
│   ├── StateNode.vue          # Draggable state bubble
│   ├── Transition.vue         # Arrow between states
│   ├── EditorCanvas.vue       # SVG container
│   └── StatePropertiesPanel.vue # Edit state inputs/outputs
├── services/
│   ├── fsmService.ts          # FSM data model
│   ├── svgRenderService.ts    # SVG drawing logic
│   └── simulationService.ts   # Step-by-step simulator
└── styles/
    └── fsm-editor.scss

backend/
├── app/
│   ├── controllers/
│   │   └── fsm_editor_controller.rb
│   ├── models/
│   │   ├── fsm.rb
│   │   ├── state.rb
│   │   └── transition.rb
│   └── services/
│       ├── fsm_validator.rb
│       ├── state_encoder.rb
│       ├── circuit_generator.rb
│       └── circuit_synthesizer.rb
└── spec/
    ├── models/
    └── services/
```

## Implementation Priority

**Week 1-2:** SVG Editor Core
- State creation/deletion
- Transition drawing
- Basic SVG rendering

**Week 3:** Interaction + Simulation
- Drag-and-drop
- Input/output assignment
- Step-through simulator

**Week 4:** Export & Polish
- JSON export
- SVG/PNG export
- Validation messages

**Week 5-6:** Circuit Generation
- State encoding service
- Logic equation generator
- Circuit mapper

**Week 7-8:** Synthesis & Integration
- CircuitVerse circuit generator
- Export to simulator
- Testing

**Week 9-12:** Polish, doc, testing

## Key Libraries

```json
{
  "dependencies": {
    "vue": "^3.x",
    "vuex": "^4.x",
    "axios": "^1.x"
  },
  "devDependencies": {
    "vitest": "^1.x",
    "@testing-library/vue": "^8.x"
  }
}
```

## Success Metrics
- ✅ Editor loads in <500ms
- ✅ Drag/drop smooth at 60fps
- ✅ Export circuit in <1 second
- ✅ Works on Chrome, Firefox, Safari
- ✅ Mobile-responsive (tablet-friendly)

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| SVG performance with many states (50+) | Use virtualization if needed; optimize rendering |
| Canvas rendering complexity | Start simple (rectangles + lines), add features incrementally |
| Browser compatibility | Test in all major browsers weekly |

## Future Expansion

Once Moore works well:
- Mealy machine variant (outputs on transitions)
- FSM minimization tool
- State machine library/templates
- Simulation playback (animate transitions)
