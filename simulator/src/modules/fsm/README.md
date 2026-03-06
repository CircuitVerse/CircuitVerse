# FSM (Finite State Machine) Editor Module

Adds a Finite State Machine diagram editor to the CircuitVerse simulator.

## Files

- **fsmModel.js** - Core data model for FSM (states, transitions, validation)
- **stateRenderer.js** - Canvas renderer for FSM states (circles with labels)
- **transitionRenderer.js** - Canvas renderer for FSM transitions (arrows and arcs)
- **fsmEditor.js** - Main Editor controller (canvas interaction, modes, event handling)
- **index.js** - Module exports

## Integration Points

The FSM editor is integrated into CircuitVerse as follows:

1. **UI Button**: Added to Tools menu in `app/views/simulator/edit.html.erb`
   - Button ID: `openFSMEditor`
   - Handler: `logixFunction.openFSMEditor()` in `simulator/src/data.js`
   - Tool: `fsmTool` object in `simulator/src/fsmTool.js`

2. **Styling**: `app/assets/stylesheets/fsm-editor.css`
   - Canvas and toolbar styling
   - Responsive design for mobile support

3. **Modes**: FSM editor runs in separate canvas overlay
   - Does not interfere with circuit editing
   - Click to toggle on/off
   - Automatic resize handling

## Architecture

```
fsmTool.js (Entry point)
    ↓
FSMEditor (Main Controller)
    ├── FSMModel (Data Layer)
    │   ├── States (Map)
    │   └── Transitions (Array)
    │
    ├── StateRenderer (View Layer)
    │   └── Canvas drawing
    │
    └── TransitionRenderer (View Layer)
        └── Canvas drawing
```

## Features

- ✅ Create and position states
- ✅ Create transitions between states
- ✅ Moore and Mealy machine support
- ✅ Edit labels (double-click states)
- ✅ Delete elements (right-click or Delete key)
- ✅ Drag to move states
- ✅ Import/Export JSON
- ✅ Mode switching (select, add, connect)

## Usage

```javascript
// Opens the FSM editor
logixFunction.openFSMEditor();

// Or directly
import fsmTool from './fsmTool';
fsmTool.open();
```

## Key Methods

### FSMEditor
- `setMode(mode)` - Set editor mode: 'select', 'add', 'connect'
- `deleteSelected()` - Delete selected element
- `export()` - Get FSM data as JSON
- `import(data)` - Load FSM from JSON
- `render()` - Redraw canvas

### FSMModel
- `createState(x, y, label, output)` - Add state
- `createTransition(fromId, toId, input, output)` - Add transition
- `deleteState(stateId)` - Remove state
- `deleteTransition(transitionId)` - Remove transition
- `export()` - Get FSM as JSON
- `import(data)` - Load FSM from JSON

## Data Format (JSON)

```json
{
  "type": "mealy",
  "states": [
    {
      "id": 1,
      "x": 100,
      "y": 100,
      "label": "State1",
      "output": null,
      "isSelected": false
    }
  ],
  "transitions": [
    {
      "id": 1,
      "fromStateId": 1,
      "toStateId": 2,
      "input": "0",
      "output": "X",
      "isSelected": false
    }
  ]
}
```

## No Breaking Changes

- ✅ Uses isolated canvas
- ✅ No modifications to existing modules
- ✅ No new global variables
- ✅ No new dependencies
- ✅ Respects CircuitVerse architecture

## Development Notes

1. **Mode Isolation**: FSM runs independently with its own mode system
2. **Event Driven**: Model emits events on changes, renderers update automatically
3. **Canvas**: Uses standard HTML5 Canvas 2D context
4. **ES6**: Uses modern JavaScript (class-based, arrow functions, destructuring)

## Testing

See tests in the complete integration guide for:
- Unit tests for FSMModel
- Integration tests for FSMEditor
- Manual testing procedures

## Future Enhancements

- State properties (entry/exit actions)
- Multiple FSM diagrams per circuit
- Generate circuit from FSM
- Animation support
- Undo/Redo for FSM edits
- FSM validation rules
