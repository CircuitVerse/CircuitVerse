/**
 * FSM Editor - Main controller for FSM diagram editing
 * Integrates with CircuitVerse simulator
 * @category FSM Editor
 */

/* eslint-disable import/no-cycle */
import FSMModel from './fsmModel';
import StateRenderer from './stateRenderer';
import TransitionRenderer from './transitionRenderer';

class FSMEditor {
  /**
   * Initialize FSM Editor
   * @param {string} canvasId - ID of canvas element
   * @param {string} fsmType - FSM type ('moore' or 'mealy')
   */
  constructor(canvasId, fsmType = 'mealy') {
    // Canvas setup
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) {
      throw new Error(`Canvas element with id "${canvasId}" not found`);
    }

    this.ctx = this.canvas.getContext('2d');
    this.canvas.width = this.canvas.offsetWidth;
    this.canvas.height = this.canvas.offsetHeight;

    // Initialize FSM Model
    this.model = new FSMModel(fsmType);

    // Renderer caches
    this.stateRenderers = new Map();     // Map<stateId, StateRenderer>
    this.transitionRenderers = [];       // Array of TransitionRenderer

    // Interaction state
    this.mode = 'select';                // 'select', 'add', 'connect'
    this.selectedStateId = null;
    this.selectedTransitionId = null;
    this.draggingStateId = null;
    this.connectFromStateId = null;
    this.hoveredStateId = null;
    this.mouseX = 0;
    this.mouseY = 0;

    // Setup event listeners
    this.setupEventListeners();

    // Render loop
    this.render();
  }

  /**
   * Setup mouse and keyboard event listeners
   * @protected
   */
  setupEventListeners() {
    // Mouse events
    this.canvas.addEventListener('mousedown', e => this.handleCanvasClick(e));
    this.canvas.addEventListener('mousemove', e => this.handleCanvasMove(e));
    this.canvas.addEventListener('mouseup', e => this.handleCanvasMouseUp(e));
    this.canvas.addEventListener('dblclick', e => this.handleDoubleClick(e));
    this.canvas.addEventListener('contextmenu', e => this.handleContextMenu(e));

    // Listen to model changes
    this.model.on((event) => {
      this.updateRenderers();
      this.render();
    });
  }

  /**
   * Update renderer caches based on model
   * @protected
   */
  updateRenderers() {
    // Update state renderers
    for (const [stateId, stateData] of this.model.states) {
      if (!this.stateRenderers.has(stateId)) {
        this.stateRenderers.set(stateId, new StateRenderer(stateData));
      }
    }

    // Remove deleted states
    for (const stateId of this.stateRenderers.keys()) {
      if (!this.model.states.has(stateId)) {
        this.stateRenderers.delete(stateId);
      }
    }

    // Update transition renderers
    this.transitionRenderers = this.model.transitions.map(transition => {
      const fromState = this.model.getState(transition.fromStateId);
      const toState = this.model.getState(transition.toStateId);
      return new TransitionRenderer(transition, fromState, toState, 30);
    });
  }

  /**
   * Handle canvas click
   * @protected
   */
  handleCanvasClick(e) {
    const rect = this.canvas.getBoundingClientRect();
    this.mouseX = e.clientX - rect.left;
    this.mouseY = e.clientY - rect.top;

    if (this.mode === 'add') {
      this.handleAddMode();
    } else if (this.mode === 'connect') {
      this.handleConnectMode();
    } else {
      this.handleSelectMode();
    }

    this.render();
  }

  /**
   * Handle canvas mouse move
   * @protected
   */
  handleCanvasMove(e) {
    const rect = this.canvas.getBoundingClientRect();
    this.mouseX = e.clientX - rect.left;
    this.mouseY = e.clientY - rect.top;

    // Update hovering state
    this.hoveredStateId = null;
    for (const [stateId, renderer] of this.stateRenderers) {
      if (renderer.contains(this.mouseX, this.mouseY)) {
        this.hoveredStateId = stateId;
        break;
      }
    }

    // Handle dragging
    if (this.draggingStateId !== null) {
      const state = this.model.getState(this.draggingStateId);
      if (state) {
        state.x = this.mouseX;
        state.y = this.mouseY;
        this.updateRenderers();
      }
    }

    this.render();
  }

  /**
   * Handle mouse up
   * @protected
   */
  handleCanvasMouseUp(e) {
    this.draggingStateId = null;
  }

  /**
   * Handle select mode
   * @protected
   */
  handleSelectMode() {
    // Deselect previous
    this.deselectAll();

    // Check if clicking state
    for (const [stateId, renderer] of this.stateRenderers) {
      if (renderer.contains(this.mouseX, this.mouseY)) {
        this.selectState(stateId);
        this.draggingStateId = stateId; // Start dragging
        return;
      }
    }

    // Check if clicking transition
    for (const renderer of this.transitionRenderers) {
      if (renderer.contains(this.mouseX, this.mouseY)) {
        this.selectTransition(renderer.transitionData.id);
        return;
      }
    }
  }

  /**
   * Handle add mode (create new states)
   * @protected
   */
  handleAddMode() {
    // Don't create overlapping states
    for (const [, renderer] of this.stateRenderers) {
      if (renderer.contains(this.mouseX, this.mouseY)) {
        return;
      }
    }

    // Create new state
    const label = `State${this.model.nextStateId}`;
    this.model.createState(this.mouseX, this.mouseY, label);
  }

  /**
   * Handle connect mode (create transitions)
   * @protected
   */
  handleConnectMode() {
    // Check if clicking a state
    for (const [stateId, renderer] of this.stateRenderers) {
      if (renderer.contains(this.mouseX, this.mouseY)) {
        if (this.connectFromStateId === null) {
          // Start connection
          this.connectFromStateId = stateId;
          const state = this.model.getState(stateId);
          if (state) state.isSelected = true;
        } else if (this.connectFromStateId !== stateId) {
          // Complete connection
          this.createTransitionWithDialog(this.connectFromStateId, stateId);
          this.connectFromStateId = null;
        }
        return;
      }
    }

    // Clear selection if clicking empty space
    if (this.connectFromStateId !== null) {
      const state = this.model.getState(this.connectFromStateId);
      if (state) state.isSelected = false;
      this.connectFromStateId = null;
    }
  }

  /**
   * Handle double click (edit labels)
   * @protected
   */
  handleDoubleClick(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    // Check state
    for (const [stateId, renderer] of this.stateRenderers) {
      if (renderer.contains(x, y)) {
        const state = this.model.getState(stateId);
        if (state) {
          const newLabel = prompt('Enter state label:', state.label);
          if (newLabel !== null && newLabel.trim() !== '') {
            state.label = newLabel.trim();
            this.render();
          }
        }
        return;
      }
    }
  }

  /**
   * Handle right click context menu
   * @protected
   */
  handleContextMenu(e) {
    e.preventDefault();

    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    // Check state
    for (const [stateId, renderer] of this.stateRenderers) {
      if (renderer.contains(x, y)) {
        if (confirm('Delete this state?')) {
          this.model.deleteState(stateId);
        }
        return;
      }
    }

    // Check transition
    for (const renderer of this.transitionRenderers) {
      if (renderer.contains(x, y)) {
        if (confirm('Delete this transition?')) {
          this.model.deleteTransition(renderer.transitionData.id);
        }
        return;
      }
    }
  }

  /**
   * Select a state
   */
  selectState(stateId) {
    this.deselectAll();
    const state = this.model.getState(stateId);
    if (state) {
      state.isSelected = true;
      this.selectedStateId = stateId;
    }
  }

  /**
   * Select a transition
   */
  selectTransition(transitionId) {
    this.deselectAll();
    const transition = this.model.transitions.find(t => t.id === transitionId);
    if (transition) {
      transition.isSelected = true;
      this.selectedTransitionId = transitionId;
    }
  }

  /**
   * Deselect all elements
   */
  deselectAll() {
    for (const [, state] of this.model.states) {
      state.isSelected = false;
    }
    this.model.transitions.forEach(t => {
      t.isSelected = false;
    });
    this.selectedStateId = null;
    this.selectedTransitionId = null;
  }

  /**
   * Create transition with user input dialog
   */
  createTransitionWithDialog(fromStateId, toStateId) {
    const input = prompt('Enter transition input label:');
    if (input === null) return; // Cancelled

    let output = null;
    if (this.model.type === 'mealy') {
      output = prompt('Enter transition output label:') || '';
    }

    if (input.trim() !== '' || output !== null) {
      this.model.createTransition(fromStateId, toStateId, input || '', output);
    }
  }

  /**
   * Set editor mode
   * @param {string} mode - 'select', 'add', or 'connect'
   */
  setMode(mode) {
    if (['select', 'add', 'connect'].includes(mode)) {
      this.mode = mode;
      this.connectFromStateId = null;

      // Clear selection on mode change
      if (mode === 'add') {
        this.deselectAll();
      }
    }
  }

  /**
   * Render the FSM to canvas
   */
  render() {
    const width = this.canvas.width;
    const height = this.canvas.height;

    // Clear canvas
    this.ctx.fillStyle = '#FAFAFA';
    this.ctx.fillRect(0, 0, width, height);

    // Draw grid
    this.drawGrid();

    // Draw all transitions first (so they appear behind states)
    for (const renderer of this.transitionRenderers) {
      renderer.draw(this.ctx, this.model.type);
    }

    // Draw all states
    for (const [, renderer] of this.stateRenderers) {
      renderer.draw(this.ctx, this.model.type);
    }

    // Draw connection preview during connect mode
    if (this.mode === 'connect' && this.connectFromStateId !== null) {
      const fromRenderer = this.stateRenderers.get(this.connectFromStateId);
      if (fromRenderer) {
        this.ctx.strokeStyle = '#4CAF50';
        this.ctx.lineWidth = 2;
        this.ctx.setLineDash([5, 5]);
        this.ctx.beginPath();
        this.ctx.moveTo(fromRenderer.stateData.x, fromRenderer.stateData.y);
        this.ctx.lineTo(this.mouseX, this.mouseY);
        this.ctx.stroke();
        this.ctx.setLineDash([]);
      }
    }

    // Draw mode indicator
    this.drawModeIndicator();
  }

  /**
   * Draw grid background
   * @protected
   */
  drawGrid() {
    const gridSize = 20;
    this.ctx.strokeStyle = '#EEEEEE';
    this.ctx.lineWidth = 0.5;

    for (let x = 0; x < this.canvas.width; x += gridSize) {
      this.ctx.beginPath();
      this.ctx.moveTo(x, 0);
      this.ctx.lineTo(x, this.canvas.height);
      this.ctx.stroke();
    }

    for (let y = 0; y < this.canvas.height; y += gridSize) {
      this.ctx.beginPath();
      this.ctx.moveTo(0, y);
      this.ctx.lineTo(this.canvas.width, y);
      this.ctx.stroke();
    }
  }

  /**
   * Draw mode indicator
   * @protected
   */
  drawModeIndicator() {
    const modeText = `Mode: ${this.mode.toUpperCase()}`;
    this.ctx.fillStyle = '#333333';
    this.ctx.font = '12px Arial';
    this.ctx.textAlign = 'left';
    this.ctx.fillText(modeText, 10, 20);
  }

  /**
   * Delete selected element
   */
  deleteSelected() {
    if (this.selectedStateId !== null) {
      this.model.deleteState(this.selectedStateId);
      this.selectedStateId = null;
    } else if (this.selectedTransitionId !== null) {
      this.model.deleteTransition(this.selectedTransitionId);
      this.selectedTransitionId = null;
    }
  }

  /**
   * Export FSM to JSON
   */
  export() {
    return this.model.export();
  }

  /**
   * Import FSM from JSON
   */
  import(data) {
    this.model.import(data);
    this.updateRenderers();
    this.render();
  }

  /**
   * Download FSM as JSON file
   */
  downloadJSON() {
    const data = JSON.stringify(this.export(), null, 2);
    const blob = new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'fsm.json';
    a.click();
    URL.revokeObjectURL(url);
  }

  /**
   * Load FSM from JSON file
   */
  loadFromJSON(file) {
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = JSON.parse(e.target.result);
        this.import(data);
      } catch (error) {
        console.error('Error loading FSM:', error);
        alert('Error loading FSM file');
      }
    };
    reader.readAsText(file);
  }

  /**
   * Get FSM statistics
   */
  getStats() {
    return {
      stateCount: this.model.states.size,
      transitionCount: this.model.transitions.length,
      type: this.model.type,
    };
  }

  /**
   * Clear the FSM
   */
  clear() {
    if (confirm('Clear all states and transitions?')) {
      this.model.clear();
      this.deselectAll();
      this.connectFromStateId = null;
      this.render();
    }
  }
}

export default FSMEditor;
